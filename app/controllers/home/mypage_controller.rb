class Home::MypageController < ApplicationController
  layout "portal", :except => [:gadget_hottopic,:gadget_bbs,:gadget_alert,:gadget_new_message,:gadget_notice,:gadget_blog_long,:gadget_kbn99,:gadget_cabinet_long,:gadget_schedule]

  @@limit_count = 10

  def index
    #パンくずリストに表示させる
    @pankuzu += "ホーム"

    @my_org = MUserBelong.get_main_org(current_m_user.user_cd)

  end

  def gadget_hottopic

    conditions_sql = ""
    conditions_param = {}
    order_sql = ""


    # お知らせ一覧の取得
    select_sql = " DISTINCT d_notice_bodies.* "
    conditions_sql = ""
    conditions_param = {}
    joins_sql = ""

    joins_sql = " INNER JOIN d_notice_heads ON d_notice_heads.id = d_notice_bodies.d_notice_head_id "
    joins_sql += " INNER JOIN d_notice_public_orgs ON d_notice_bodies.id = d_notice_public_orgs.d_notice_body_id "
#    joins_sql += " LEFT JOIN d_notice_files ON d_notice_bodies.id = d_notice_files.d_notice_body_id "

    conditions_sql = " hottopic_flg = :hottopic_flg"
    conditions_param[:hottopic_flg] = 0

    # 削除フラグを確認する。
    conditions_sql += " AND d_notice_bodies.delf = :delf "
    conditions_sql += " AND d_notice_public_orgs.delf = :delf "
    conditions_param[:delf] = '0'

    # ログインユーザの所属する組織の組織コードが公開対象組織になっているかを確認する。
    conditions_sql += " AND (d_notice_public_orgs.org_cd = '0' "
    user_org_list = MUserBelong.new.get_belong_org current_m_user.user_cd
    # 複数組織に所属するときは、そのすべてに対して閲覧が可能
    user_org_list.each do |user_org|
      conditions_sql += " OR d_notice_public_orgs.org_cd = SUBSTR(':public_org_cd', 0, LENGTH(d_notice_public_orgs.org_cd) + 1) "
      conditions_sql.gsub!(":public_org_cd", user_org.org_cd)
    end
    conditions_sql += "  OR d_notice_public_orgs.created_user_cd = :user_cd)"
    conditions_param[:user_cd] = current_m_user.user_cd
    # 公開前ではないかをチェック
    conditions_sql += " AND (d_notice_bodies.public_date_from <= cast(:public_date_from as date) OR d_notice_bodies.public_date_from ISNULL) "
    conditions_param[:public_date_from] = Time.now
    # 公開終了でないかをチェック(但し、投稿者については公開期間を考慮しない。)
    conditions_sql += " AND (d_notice_bodies.public_date_to >= cast(:public_date_to as date) OR d_notice_bodies.public_date_to ISNULL) "
    conditions_param[:public_date_to] = Time.now

    conditions_sql += " AND (d_notice_bodies.public_flg = 0 OR (d_notice_bodies.public_flg = 1 AND d_notice_bodies.post_user_cd = cast(:post_user_cd as char)))"
    conditions_param[:post_user_cd] = current_m_user.user_cd

    order_sql = " post_date DESC"

    m_notice_setting = MNoticeSetting.find(:all)
    @notices = DNoticeBody.paginate(:page => params[:page], :per_page => m_notice_setting[0]["page_max_count"], :select=>select_sql, :joins=>joins_sql, :conditions=>[conditions_sql, conditions_param], :order=>order_sql)
    @gadget_title = "お知らせ（お勧め情報）"
    @gadget_size = "long"
  end

  def gadget_bbs
    #主所属の組織コード(上部署を考慮した全ての関連組織コード)
    org_list = []
    org_list << MUserBelong.get_belong_org_list(current_m_user.user_cd)[0]
    org_colon = MOrg.edit_org_consider_lvl(org_list)

    #コメントがある場合:コメントの最新日付
    #コメントがない場合:トピックの最新日付を取得
    sql =  " SELECT t8.* "
    sql += " FROM   d_bbs_auths t1"
    sql += "      ,(SELECT t2.id"
    sql += "              ,t2.d_bbs_board_id"
    sql += "              ,t2.public_flg"
    sql += "              ,t2.title"
    sql += "              ,t2.post_date as t_post_date"
    sql += "              ,t7.post_date as c_post_date"
    sql += "              ,case "
    sql += "                when coalesce(t7.id, 0) = 0 then t2.post_date"  #トピック
    sql += "                when coalesce(t7.id, 0) != 0 then t7.post_date" #コメント
    sql += "              end as post_date"
    sql += "        FROM d_bbs_threads t2"
    #コメントがある場合は最新のコメントデータを取得
    sql += "             LEFT JOIN  (SELECT  MAX(coalesce(t6.id, 0)) as id"
    sql += "                                ,t6.d_bbs_thread_id"
    sql += "                                ,MAX(t6.post_date) as post_date"
    sql += "                         FROM    d_bbs_threads t5"
    sql += "                                 LEFT JOIN d_bbs_comments t6 ON t5.id = t6.d_bbs_thread_id"
    sql += "                         WHERE   t5.delf = 0"
    sql += "                         AND     coalesce(t6.delf, 0) = 0"
    sql += "                         GROUP BY t6.d_bbs_thread_id) t7"
    sql += "             ON t2.id = t7.d_bbs_thread_id) t8"
    sql += " WHERE t1.delf = 0 "
    sql += " AND   t1.d_bbs_board_id = t8.d_bbs_board_id "
    sql += " AND   t8.public_flg = 0 "
    sql += " AND   (t1.org_cd in (" + org_colon + ")"
    sql += "       OR t1.user_cd = '" + current_m_user.user_cd + "'"
    sql += "       OR t1.org_cd = '0')"
    sql += " AND   t8.post_date >= '" + (Date.today - 14).to_s + "'"
    sql += " ORDER BY t8.post_date desc"

    @bbs_threads = DBbsThread.paginate_by_sql(sql, :page => params[:page], :per_page => 5)
    @bbs_setting = MBbsSetting.new.get_bbs_settings
    @gadget_title = "掲示板の新着情報"
  end

  def gadget_alert
    #リマインダーデータ/スケジュールデータ
    sql = "SELECT a.*, "
    sql += " b.plan_date_from, "
    sql += " b.title as subject "
    sql += " FROM d_reminders a "
    sql += "    , d_schedules b"
    sql += " WHERE "
    sql += "      a.delf = '0'"
    sql += " AND  b.delf = '0'"
    sql += " AND  a.d_schedule_id = b.id"
    sql += " AND  a.reminder_kbn = 0"
    sql += " AND  a.user_cd = '" + current_m_user.user_cd + "'"
    sql += " AND  a.notice_date_from <= '" + Time.now.to_s + "'"
    sql += " AND  a.notice_date_to >= '" + Time.now.to_s + "'"
    sql += " ORDER BY a.notice_date_from desc, a.notice_date_to desc"
    @reminders = DReminder.paginate_by_sql(sql, :page => params[:page], :per_page => 5)
    @gadget_title = "アラーム情報"
  end

  def gadget_new_message
    @total_page_cnt = 0  #ページ総数
    @current_page = 0    #現在の表示ページ
    disp_cnt = 5.0       #1ページ当たりの表示データ数

    #データフラグ(1:Webメモリ, 2:本日のスケジュール, 3その他新着メッセージ)
    all_data = []     #全データの格納配列(配列[データフラグ, データ])
    @target_data = [] #表示データの格納配列(配列[データフラグ, データ])

    # Webメモリー
    webmemory_list = DCabinetBody.new.get_enable_alert_list current_m_user.user_cd
    #データ格納
    webmemory_list.each {|webmemory_data|
      all_data << [1, webmemory_data]
    }

    #スケジュールデータ
    reserve_list = DSchedule.find(:all, :conditions =>
      ["(plan_date_from = ? or (plan_date_from < ? and plan_date_to >= ?)) and user_cd = ? and delf = ?",
      Date.today, Date.today, Date.today, current_m_user.user_cd, 0],
      :order => "plan_date_from, plan_time_from, id")
    #データ格納
    reserve_list.each {|reserve_data|
      all_data << [2, reserve_data]
    }

    #メッセージデータ
    #削除するデータがある場合は削除後、データを表示する
    delete_id = params[:delete_id]
    if !delete_id.nil? && delete_id != ""
      DMessage.delete(delete_id)
    end
    message_list = DMessage.find(:all, :conditions => ["user_cd = ? and delf = ?", current_m_user.user_cd, 0], :order => "post_date")
    #データ格納
    message_list.each {|message_data|
      all_data << [3, message_data]
    }

    #ページ制御
    @current_page = 1 #現在の表示ページ
    if !params[:page].nil?
      @current_page = params[:page].to_i
    end
    start_cnt = (@current_page - 1) * disp_cnt  #表示データ開始位置
    end_cnt = start_cnt + (disp_cnt - 1)  #表示データ終了位置
    @target_data = all_data.slice(start_cnt..end_cnt) #表示データ
    @total_page_cnt = (all_data.size / disp_cnt).ceil #ページ総数

    @gadget_title = "あなたへの新着メッセージ"
  end

  def gadget_cabinet_long
    caller = "top"
    @cabinet_setting = MCabinetSetting.new.get_cabinet_settings
    @cabinet_list = DCabinetBody.get_cabinet_bodies params[:page], 5, 1, nil, current_m_user.user_cd, (Date.today - 14).strftime("%Y-%m-%d"), nil, nil, nil, nil, caller
    @gadget_title = "更新情報（共有キャビネット）"
  end

  def gadget_kbn99
    @notice_setting = MNoticeSetting.new.get_notice_settings
    @kbn99_list = DNoticeBody.get_gadget_kbn99 params[:page], 5, current_m_user.user_cd
    @gadget_title = "新着情報（お知らせ）"
  end

  def gadget_blog_long

    conditions_sql = ""
    conditions_param = {}
    order_sql = ""

    conditions_sql = " delf = :delf "
    conditions_param[:delf] = 0
    conditions_sql += " AND public_flg = :public_flg "
    conditions_param[:public_flg] = 0
#    conditions_sql += " AND top_disp_kbn = :top_disp_kbn "
#    conditions_param[:top_disp_kbn] = 0

    order_sql = " post_date DESC"

    @blogs = DBlogBody.paginate(:page => params[:page], :per_page => 5, :conditions => [conditions_sql, conditions_param], :order =>order_sql)
    @blog_setting = MBlogSetting.new.get_blog_settings
    @gadget_title = "新着ブログ"
  end

  def gadget_notice

    # お知らせ一覧の取得
    select_sql = " DISTINCT d_notice_bodies.* "
    conditions_sql = ""
    conditions_param = {}
    joins_sql = ""

    joins_sql = " INNER JOIN d_notice_heads ON d_notice_heads.id = d_notice_bodies.d_notice_head_id "
    joins_sql += " INNER JOIN d_notice_public_orgs ON d_notice_bodies.id = d_notice_public_orgs.d_notice_body_id "
    joins_sql += " LEFT JOIN d_notice_files ON d_notice_bodies.id = d_notice_files.d_notice_body_id "

    @top_disp_kbn = params[:top_disp_kbn]
    conditions_sql = " top_disp_kbn = :top_disp_kbn"
    conditions_param[:top_disp_kbn] = @top_disp_kbn

    # 削除フラグを確認する。
    conditions_sql += " AND d_notice_bodies.delf = :delf "
    conditions_sql += " AND d_notice_public_orgs.delf = :delf "
    conditions_param[:delf] = '0'

    # ログインユーザの所属する組織の組織コードが公開対象組織になっているかを確認する。
    conditions_sql += " AND (d_notice_public_orgs.org_cd = '0' "
    user_org_list = MUserBelong.new.get_belong_org current_m_user.user_cd
    # 複数組織に所属するときは、そのすべてに対して閲覧が可能
    user_org_list.each do |user_org|
      conditions_sql += " OR d_notice_public_orgs.org_cd = SUBSTR(':public_org_cd', 0, LENGTH(d_notice_public_orgs.org_cd) + 1) "
      conditions_sql.gsub!(":public_org_cd", user_org.org_cd)
    end
    conditions_sql += "  OR d_notice_public_orgs.created_user_cd = :user_cd)"
    conditions_param[:user_cd] = current_m_user.user_cd
    # 公開前ではないかをチェック
    conditions_sql += " AND (d_notice_bodies.public_date_from <= cast(:public_date_from as date)) "
    conditions_param[:public_date_from] = Time.now
    # 公開終了でないかをチェック
    conditions_sql += " AND (d_notice_bodies.public_date_to >= cast(:public_date_to as date) OR d_notice_bodies.public_date_to ISNULL ) "
    conditions_param[:public_date_to] = Time.now

    conditions_sql += " AND d_notice_bodies.public_flg = 0 "
    conditions_param[:post_user_cd] = current_m_user.user_cd

    conditions_sql += " AND d_notice_bodies.post_date >= :post_date"
    conditions_param[:post_date] = Date.today - 14

    order_sql = " d_notice_bodies.post_date DESC"

    @notices = DNoticeBody.paginate(:page => params[:page], :per_page => 5, :select=>select_sql, :joins=>joins_sql, :conditions=>[conditions_sql, conditions_param], :order=>order_sql)
    @notice_setting = MNoticeSetting.new.get_notice_settings
    @top_disp_kbn = params[:top_disp_kbn]

    @gadget_title = "重要なお知らせ"
    @gadget_size = "long"

    render :action => "gadget_notice_long"

  end

  #スケジュール(トップページ用)
  def gadget_schedule
    #**基準日の設定**
    if params[:week]
      @current_date = (params[:week].to_s[0,4] + "-" + params[:week].to_s[4,2] + "-" + params[:week].to_s[6,2]).to_date
    else
      @current_date = Date.today
    end

    #**対象日付リストを作成**
    @week_list = []
    current_week = @current_date.wday  #0:日曜..6:土曜
    #スケジュール設定テーブル
    setting_data = DScheduleSetting.find(:first, :conditions => ["user_cd = ? and delf = ?", current_m_user.user_cd, 0])
    if setting_data.nil?
      week_start_flg = 0
    else
      week_start_flg = setting_data.week_start_flg
    end
    #日曜開始の場合
    if week_start_flg == 1
      #今日が日曜日の場合
      if current_week == 0
        start_date = @current_date
      else
        start_date = @current_date - (current_week - 0)
      end
    #月曜開始の場合
    elsif week_start_flg == 2
      #今日が日曜日の場合
      if current_week == 1
        start_date = @current_date
      else
        start_date = @current_date - (current_week - 1)
      end
    #本日開始の場合
    else
      start_date = @current_date
    end
    end_date = start_date + 6
    for i in 0..6
      @week_list << [start_date + i]
    end
    session[:week_start_date] = start_date.strftime("%Y%m%d")

    #休日ハッシュを取得
    @holiday_hash = MCalendar.get_holiday_hash()
    #イベントハッシュを取得
    @event_hash = MCalendar.get_event_hash()

    #**スケジュールデータ(ログインユーザ)**
    @reserves = DSchedule.find(:all, :conditions =>
      ["(plan_date_from >= ? or (plan_date_from < ? and plan_date_to >= ?)) and plan_date_from <= ? and user_cd = ?",
      @current_date, @current_date, @current_date, end_date, current_m_user.user_cd],
      :order => "plan_date_from, plan_time_from, id")

    #配列[社員コード, 社員名, スケジュールリスト]を作成
    member_list_work = []
    member_list_work << [current_m_user.user_cd, current_m_user.name, @reserves]

    #**表示用にデータ加工**
    #配列[社員コード, 社員名, 日付に紐付くスケジュールリスト]を作成
    @member_list = DSchedule.create_disp_week_or_print_list(member_list_work)

    #**区分M(種別)より色を取得**
    @plan_color_list = MKbn.get_plan_color_list()
  end
end
