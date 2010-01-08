require "date"
class Schedule::ReserveController < ApplicationController
  layout "portal", :except => [:month, :week, :day, :list, :spare_time_other_member,
  :spare_time_facility, :other_member_list, :undecided_member, :facility_list, :secretary_print]

  SCHEDULE = "スケジュール"
  START_TIME = "07:00"
  END_TIME = "21:00"

  def index
    index_month
    render :action => "index_month"
  end

  #月単位
  def index_month
    #パンくずリストに表示させる
    @pankuzu += SCHEDULE
    month
  end

  #週単位
  def index_week
    #パンくずリストに表示させる
    @pankuzu += SCHEDULE
    week
  end

  #日単位
  def index_day
    #パンくずリストに表示させる
    @pankuzu += SCHEDULE
    day
  end

  #一覧
  def index_list
    #パンくずリストに表示させる
    @pankuzu += SCHEDULE
    list
  end

  #月単位
  def month
    #**基準日の設定**
    if params[:month]
      @current_date = (params[:month].to_s[0,4] + "-" + params[:month].to_s[4,2] + "-" + "01").to_date
    else
      @current_date = Date.today
    end
    @month = @current_date.strftime("%Y%m")

    #休日ハッシュを取得
    @holiday_hash_param = MCalendar.get_holiday_hash()
    @holiday_hash = MCalendar.get_holiday_hash()
    #イベントハッシュを取得
    @event_hash_param = MCalendar.get_event_hash()
    @event_hash = MCalendar.get_event_hash()

    #**ログインユーザが所属する部署情報取得**
    org_list = MUserBelong.get_belong_org_list(current_m_user.user_cd)
    #部署コードをカンマ区切りに編集
    org_colon_list = edit_org_colon(org_list)

    #**秘書マスタよりデータ取得**
    @secretaries_user_list = MSecretary.get_secretary_authorize_list(org_colon_list, current_m_user.user_cd, 0)
    if @secretaries_user_list.size > 0
      @secretaries_flg = 1
    else
      @secretaries_flg = 0
    end

    #**選択されたユーザを取得**
    if params[:secretaries_user_cd].nil? || params[:secretaries_user_cd]  == ""
      @select_secretaries_user_cd = current_m_user.user_cd
    else
      @select_secretaries_user_cd = params[:secretaries_user_cd]
    end

    #**選択されたユーザのスケジュール取得**
    @reserves = get_other_schedule_all_list_month(@select_secretaries_user_cd)

    #**表示用のデータ作成**
    #日付に紐付くスケジュールリスト作成
    @cell_reserves = []
    cell_reserves_work1 = []
    cell_reserves_work2 = []

    #配列[日跨りフラグ, 終日フラグ, 開始時間, 日付に紐付くスケジュールリスト](ソート用)を作成
    @reserves.each { |reserve|
      #開始日と終了日が異なる場合
      if reserve.plan_date_from.to_date < reserve.plan_date_to.to_date
        term = (reserve.plan_date_to.to_date - reserve.plan_date_from.to_date).to_i
        #途中の期間のデータも作成する
        for i in 0..term
          cell_reserves_work1 << [1, reserve.plan_allday_flg, reserve.plan_time_from.strftime("%H:%M"), reserve.plan_date_from.to_date + i, reserve]
        end
      else
        cell_reserves_work1 << [0, reserve.plan_allday_flg, reserve.plan_time_from.strftime("%H:%M"), reserve.plan_date_from.to_date, reserve]
      end
    }

    #ソート(日跨り>終日>開始時間)
    cell_reserves_work2 = cell_reserves_work1.sort{ |a,b|
      #優先度1:日跨り
      if a[0] == b[0]
        #優先度2:終日
        if a[1] == b[1]
          #優先度3:開始時間
          a[2] <=> b[2]
        else
          b[1] <=> a[1]
        end
      else
        b[0] <=> a[0]
      end
    }
    cell_reserves_work2.each { |reserve2|
      @cell_reserves << [reserve2[3], reserve2[4]]
    }

    #**区分M(種別)より色を取得**
    @plan_color_list = MKbn.get_plan_color_list()

    #遷移元情報を格納
    session[:from_mode] = '3'
  end

  #週単位
  def week
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

    #**ログインユーザが所属する部署/プロジェクト情報取得**
    org_list = MUserBelong.get_belong_org_list(current_m_user.user_cd)
    project_list = MProject.get_project_list(current_m_user.user_cd)
    #部署コードをカンマ区切りに編集
    org_colon_list = edit_org_colon(org_list)

    #**秘書マスタよりデータ取得**
    @secretaries_user_list = MSecretary.get_secretary_authorize_list(org_colon_list, current_m_user.user_cd, 0)
    if @secretaries_user_list.size > 0
      @secretaries_flg = 1
    else
      @secretaries_flg = 0
    end

    #秘書マスタよりハッシュ[ユーザコード, ユーザ名]作成(スケジュールリンク用)
    @secretaries_user_hash = getSecretaries_user_hash(org_colon_list, 0)

    #**スケジュールデータ(ログインユーザ)**
    @reserves = DSchedule.find(:all, :conditions =>
      ["(plan_date_from >= ? or (plan_date_from < ? and plan_date_to >= ?)) and plan_date_from <= ? and user_cd = ?",
      @current_date, @current_date, @current_date, end_date, current_m_user.user_cd],
      :order => "plan_date_from, plan_time_from, id")

    #参照できる所属リスト[所属フラグ(1:秘書機能, 2xy:部署, 3:プロジェクト), コード, 名称]の作成
    #x(表示階層)1:1階層下,2:2階層下,3:1階層上,4:課全体,5:部全体    y(選択組織)組織の階層
    index_secretary = 1
    index_org = 2
    index_project = 3
    @belong_list = DSchedule.get_visible_belong_list(org_list, project_list, 0, @proxy_user_cd, current_m_user.user_cd, @secretaries_flg)

    #**選択された所属を取得**
    if params[:other_checked_id].nil? || params[:other_checked_id] == ""
      #設定データが存在しない場合
      if setting_data.nil?
        if @secretaries_flg == 1
          @other_checked_id = 1 #1階層下の部署
        else
          @other_checked_id = 0 #1階層下の部署
        end
      else
        @other_checked_id = setting_data.other_member_init
        #設定マスタ作成時と現在の所属リスト数に差がある場合
        if @belong_list.size < @other_checked_id + 1
          @other_checked_id = 0
        end
      end
    else
      @other_checked_id = params[:other_checked_id].to_i
    end

    #**表示用のメンバーリスト作成**
    #選択された所属フラグを取得
    belong_flg = @belong_list[@other_checked_id][0]
    belong = @belong_list[@other_checked_id]
    #部署の場合
    if (belong_flg.to_s)[0..0].to_i == index_org
      org_cd = belong[1]
    #プロジェクトの場合
    elsif belong_flg == index_project
      project_id = belong[1].to_i
    end

    #配列[社員コード, 社員名, スケジュールリスト]を作成
    member_list_work = []
    #秘書機能が選択されている場合以外
    if belong_flg != index_secretary
      #本人を先頭に追加
      member_list_work << [current_m_user.user_cd, current_m_user.name, @reserves]
    end

    #秘書機能が選択されている場合
    if belong_flg == index_secretary
      #該当メンバーをリストに追加
      for data in @secretaries_user_list
        if data[0] != current_m_user.user_cd
          #各ユーザのスケジュールデータを取得
          reserves = get_other_schedule_all_list_week(end_date, data[0])
        end
        member_list_work << [data[0], data[1], reserves]
      end

    #組織が選択されている場合
    elsif belong_flg.to_s[0..0].to_i == index_org
      m_users_all = get_other_org_list(belong_flg, current_m_user.user_cd, org_cd)
      #該当メンバーをリストに追加
      for user in m_users_all
        if user.user_cd != current_m_user.user_cd
          #各ユーザのスケジュールデータを取得
          reserves = get_other_schedule_all_list_week(end_date, user.user_cd)
          member_list_work << [user.user_cd, user.name + "<br>" + user.org_name, reserves]
        end
      end

    #プロジェクトが選択されている場合
    else
      #ログインユーザと同じプロジェクトに属するユーザーを取得
      project_other = get_other_project_list(project_id)
      #該当メンバーをリストに追加
      for project in project_other
        if project.user_cd != current_m_user.user_cd
          #各ユーザのスケジュールデータを取得
          reserves = get_other_schedule_all_list_week(end_date, project.user_cd)
          member_list_work << [project.user_cd, project.name + "<br>" + project.org_name, reserves]
        end
      end
    end

    #参照可能な部署に所属するメンバーのハッシュ作成
    visible_member_hash = get_visible_member_hash(index_org)

    #公開/非公開の判断
    for member_data_work in member_list_work
      member_data = member_data_work[2]
      for data in member_data
        #本人または秘書機能データ以外の場合
        if @secretaries_user_hash[data.user_cd][0].nil?
          #該当データに対するスケジュール権限データを取得
          auth_list = get_other_schedule_list(end_date, data.user_cd, data.id)
          #公開データか判断
          public_flg = check_public(visible_member_hash, project_list, auth_list)
          if public_flg == 0
            #データを非公開にする
            data.public_kbn = 2
          end
        end
      end
    end

    #**表示用にデータ加工**
    #配列[社員コード, 社員名, 日付に紐付くスケジュールリスト]を作成
    @member_list = DSchedule.create_disp_week_or_print_list(member_list_work)

    #**区分M(種別)より色を取得**
    @plan_color_list = MKbn.get_plan_color_list()

    #遷移元情報を格納
    session[:from_mode] = '2'
  end

  #日単位
  def day
    #**基準日の設定**
    if params[:day]
      @current_date = (params[:day].to_s[0,4] + "-" + params[:day].to_s[4,2] + "-" + params[:day].to_s[6,2]).to_date
    else
      @current_date = Date.today
    end
    @day = @current_date.strftime("%Y%m%d")

    #表示時間の設定
    start_time_disp = Time.parse(@current_date.strftime("%Y-%m-%d") + " " + START_TIME)
    end_time_disp = Time.parse(@current_date.strftime("%Y-%m-%d") + " " + END_TIME)

    #休日ハッシュを取得
    @holiday_hash = MCalendar.get_holiday_hash()
    #イベントハッシュを取得
    @event_hash = MCalendar.get_event_hash()

    #**ログインユーザが所属する部署/プロジェクト情報取得**
    org_list = MUserBelong.get_belong_org_list(current_m_user.user_cd)
    project_list = MProject.get_project_list(current_m_user.user_cd)
    #部署コードをカンマ区切りに編集
    org_colon_list = edit_org_colon(org_list)

    #**秘書マスタよりデータ取得**
    @secretaries_user_list = MSecretary.get_secretary_authorize_list(org_colon_list, current_m_user.user_cd, 0)
    if @secretaries_user_list.size > 0
      @secretaries_flg = 1
    else
      @secretaries_flg = 0
    end

    #秘書マスタよりハッシュ[ユーザコード, ユーザ名]作成(スケジュールリンク用)
    @secretaries_user_hash = getSecretaries_user_hash(org_colon_list, 0)

    #**ログインユーザのスケジュールデータを取得**
    reserves_not_allday = get_login_schedule_all_list_day(current_m_user.user_cd, start_time_disp, end_time_disp, 0)  #終日以外
    reserves_allday = get_login_schedule_all_list_day(current_m_user.user_cd, start_time_disp, end_time_disp, 1)  #終日

    #参照できる所属リスト[所属フラグ(1:秘書機能, 2xy:部署, 3:プロジェクト), コード, 名称]の作成
    #x(表示階層)1:1階層下,2:2階層下,3:1階層上,4:課全体,5:部全体    y(選択組織)組織の階層
    index_secretary = 1
    index_org = 2
    index_project = 3
    @belong_list = DSchedule.get_visible_belong_list(org_list, project_list, 0, @proxy_user_cd, current_m_user.user_cd, @secretaries_flg)

    #スケジュール設定テーブル
    setting_data = DScheduleSetting.find(:first, :conditions => ["user_cd = ? and delf = ?", current_m_user.user_cd, 0])

    #選択された所属を取得
    if params[:other_checked_id].nil? || params[:other_checked_id] == ""
      #設定データが存在しない場合
      if setting_data.nil?
        if @secretaries_flg == 1
          @other_checked_id = 1 #1階層下の部署
        else
          @other_checked_id = 0 #1階層下の部署
        end
      else
        @other_checked_id = setting_data.other_member_init
        #設定マスタ作成時と現在の所属リスト数に差がある場合
        if @belong_list.size < @other_checked_id + 1
          @other_checked_id = 0
        end
      end
    else
      @other_checked_id = params[:other_checked_id].to_i
    end

    #**表示用のメンバーリスト作成**
    #選択された所属フラグを取得
    belong_flg = @belong_list[@other_checked_id][0]
    belong = @belong_list[@other_checked_id]
    #部署の場合
    if belong_flg.to_s[0..0].to_i == index_org
      org_cd = belong[1]
    #プロジェクトの場合
    elsif belong_flg == index_project
      project_id = belong[1].to_i
    end

    #配列[社員コード, 社員名, 終日リスト, スケジュールリスト(終日以外)]を作成
    member_list_work = []
    #秘書機能が選択されている場合以外
    if belong_flg != index_secretary
      #本人を先頭に追加
      member_list_work << [current_m_user.user_cd, current_m_user.name, reserves_allday, reserves_not_allday]
    end

    #秘書機能が選択されている場合
    if belong_flg == index_secretary
      #該当メンバーをリストに追加
      for data in @secretaries_user_list
        if data[0] != current_m_user.user_cd
          #各ユーザのスケジュールデータを取得(日単位)
          reserves_not_allday = get_other_schedule_all_list_day(data[0], start_time_disp, end_time_disp, 0)  #終日以外
          reserves_allday = get_other_schedule_all_list_day(data[0], start_time_disp, end_time_disp, 1)  #終日
        end

        member_list_work << [data[0], data[1], reserves_allday, reserves_not_allday]
      end

    #組織が選択されている場合
    elsif belong_flg.to_s[0..0].to_i == index_org
      m_users_all = get_other_org_list(belong_flg, current_m_user.user_cd, org_cd)
      #該当メンバーをリストに追加
      for user in m_users_all
        if user.user_cd != current_m_user.user_cd
          #各ユーザのスケジュールデータを取得(日単位)
          reserves_not_allday = get_other_schedule_all_list_day(user.user_cd, start_time_disp, end_time_disp, 0)  #終日以外
          reserves_allday = get_other_schedule_all_list_day(user.user_cd, start_time_disp, end_time_disp, 1)  #終日
          member_list_work << [user.user_cd, user.name + "<br>" + user.org_name, reserves_allday, reserves_not_allday]
        end
      end

    #プロジェクトが選択されている場合
    else
      #ログインユーザと同じプロジェクトに属するユーザーを取得
      @project_other = get_other_project_list(project_id)
      #該当メンバーをリストに追加
      for project in @project_other
        if project.user_cd != current_m_user.user_cd
          #各ユーザのスケジュールデータを取得(日単位)
          reserves_not_allday = get_other_schedule_all_list_day(project.user_cd, start_time_disp, end_time_disp, 0) #終日以外
          reserves_allday = get_other_schedule_all_list_day(project.user_cd, start_time_disp, end_time_disp, 1) #終日
          member_list_work << [project.user_cd, project.name + "<br>" + project.org_name, reserves_allday, reserves_not_allday]
        end
      end
    end

    #参照可能な部署に所属するメンバーのハッシュ作成
    visible_member_hash = get_visible_member_hash(index_org)

    #公開/非公開の判断
    for member_data_work in member_list_work
      for i in 2..3
        #1:終日, 2:終日以外
        member_data = member_data_work[i]
        for data in member_data
          #本人または秘書機能データ以外の場合
          if @secretaries_user_hash[data.user_cd][0].nil?
            #該当データに対するスケジュール権限データを取得
            auth_list = get_other_schedule_list(@current_date, data.user_cd, data.id)

            #公開データか判断
            public_flg = check_public(visible_member_hash, project_list, auth_list)
            if public_flg == 0
              #データを非公開にする
              data.public_kbn = 2
            end
          end
        end
      end
    end

    #**表示用にデータ加工**
    #配列[社員名, 行配列[行番号, スケジュール配列[時間, スケジュール, 表示日付]]]を作成
    @member_list = create_disp_day_list(member_list_work, start_time_disp, end_time_disp)

    #**区分M(種別)より色を取得**
    @plan_color_list = MKbn.get_plan_color_list()

    #遷移元情報を格納
    session[:from_mode] = '1'
  end

  #一覧
  def list
    #**基準日の設定**
    if params[:month]
      @current_date = (params[:month].to_s[0,4] + "-" + params[:month].to_s[4,2] + "-"  + params[:month].to_s[6,2]).to_date
    else
      @current_date = Date.today
    end
    session[:list_start_month] = @current_date.strftime("%Y%m%d")

    #休日ハッシュを取得
    @holiday_hash = MCalendar.get_holiday_hash()
    #イベントハッシュを取得
    @event_hash = MCalendar.get_event_hash()

    #**ログインユーザが所属する部署情報取得**
    org_list = MUserBelong.get_belong_org_list(current_m_user.user_cd)
    #部署コードをカンマ区切りに編集
    org_colon_list = edit_org_colon(org_list)

    #**秘書マスタよりデータ取得**
    @secretaries_user_list = MSecretary.get_secretary_authorize_list(org_colon_list, current_m_user.user_cd, 0)
    if @secretaries_user_list.size > 0
      @secretaries_flg = 1
    else
      @secretaries_flg = 0
    end

    #**選択されたユーザを取得**
    if params[:secretaries_user_cd].nil? || params[:secretaries_user_cd]  == ""
      @select_secretaries_user_cd = current_m_user.user_cd
    else
      @select_secretaries_user_cd = params[:secretaries_user_cd]
    end

    #**選択されたユーザのスケジュール取得**
    end_date = @current_date >> 2
    @reserves = DSchedule.find(:all, :conditions =>
      ["(plan_date_from >= ? or (plan_date_from < ? and plan_date_to >= ?)) and plan_date_from <= ? and user_cd = ?",
      @current_date, @current_date, @current_date, end_date, @select_secretaries_user_cd],
      :order => "plan_date_from, plan_time_from, id")

    #**表示用のデータ作成**
    #日付に紐付くスケジュールリスト作成
    cell_reserves = []
    @reserves.each { |reserve|
      #開始日と終了日が異なる場合
      if reserve.plan_date_from.to_date < reserve.plan_date_to.to_date
        term = (reserve.plan_date_to.to_date - reserve.plan_date_from.to_date).to_i
        #途中の期間のデータも作成する
        for i in 0..term
          #表示対象日のみ
          target_date = reserve.plan_date_from.to_date + i
          if (@current_date <= target_date) && (target_date <= end_date)
            cell_reserves << [target_date, reserve]
          end
        end
      else
        cell_reserves << [reserve.plan_date_from.to_date, reserve]
      end
    }

    #日付順にソートする
    @cell_reserves = cell_reserves.sort{ |a,b|
      a[0] <=> b[0]
    }

    #**区分M(種別)より名称を取得**
    @plan_name_list = MKbn.get_plan_name_list()

    #遷移元情報を格納
    session[:from_mode] = '4'
  end

  #空き状況確認(同時登録)
  def spare_time_other_member
    #**基準日の設定**
    if params[:day]
      @current_date = params[:day].to_date
    else
      @current_date = Date.today
    end

    #表示時間の設定
    start_time_disp = Time.parse(@current_date.strftime("%Y-%m-%d") + " " + START_TIME)
    end_time_disp = Time.parse(@current_date.strftime("%Y-%m-%d") + " " + END_TIME)

    #**メインユーザコードの取得(秘書機能用)**
    @select_proxy_user_cd = params[:select_proxy_user_cd]
    if @select_proxy_user_cd.nil? || @select_proxy_user_cd == ""
      @proxy_user_cd = current_m_user.user_cd
    else
      @proxy_user_cd = params[:select_proxy_user_cd]
    end

    #**メインユーザが所属する部署/プロジェクト情報取得**
    org_list = MUserBelong.get_belong_org_list(@proxy_user_cd)
    project_list = MProject.get_project_list(@proxy_user_cd)
    #部署コードをカンマ区切りに編集
    org_colon_list = edit_org_colon(org_list)

    #**秘書マスタよりデータ取得**
    @secretaries_user_list = MSecretary.get_secretary_authorize_list(org_colon_list, current_m_user.user_cd, 0)
    if @secretaries_user_list.size > 0
      @secretaries_flg = 1
    else
      @secretaries_flg = 0
    end

    #秘書マスタよりハッシュ[ユーザコード, ユーザ名]作成(スケジュールリンク用)
    @secretaries_user_hash = getSecretaries_user_hash(org_colon_list, 0)

    #**メインユーザのスケジュールデータを取得**
    reserves_not_allday = get_login_schedule_all_list_day(@proxy_user_cd, start_time_disp, end_time_disp, 0)  #終日以外
    reserves_allday = get_login_schedule_all_list_day(@proxy_user_cd, start_time_disp, end_time_disp, 1)  #終日

    #**表示データの準備**
    #**選択されたメンバーについて**
    member_list_work = []
    #本人を先頭に追加
    proxy_user_name = MUser.find(:first, :conditions => ["user_cd = ? and delf = ?", @proxy_user_cd, 0]).name
    member_list_work << [@proxy_user_cd, proxy_user_name, reserves_allday, reserves_not_allday]

    #他のメンバーをリストに追加
    @member = params[:member]
    if !(params[:member].nil? || params[:member] == "")
      selected_user_cd = params[:member].split(",")
      for user_cd in selected_user_cd
        if user_cd != @proxy_user_cd
          #各ユーザのスケジュールデータを取得(日単位)
          reserves_not_allday = get_other_schedule_all_list_day(user_cd, start_time_disp, end_time_disp, 0)  #終日以外
          reserves_allday = get_other_schedule_all_list_day(user_cd, start_time_disp, end_time_disp, 1)  #終日
          user_name = MUser.find(:first, :conditions => ["user_cd = ? and delf = ?", user_cd, 0]).name
          member_list_work << [user_cd, user_name, reserves_allday, reserves_not_allday]
        end
      end
    end

    #参照できる所属リスト[所属フラグ(0:空白, 1:秘書機能, 2xy:部署, 3:プロジェクト), コード, 名称]の作成
    #x(表示階層)1:1階層下,2:2階層下,3:1階層上,4:課全体,5:部全体    y(選択組織)組織の階層
    index_space = 0
    index_secretary = 1
    index_org = 2
    index_project = 3
    @belong_list = DSchedule.get_visible_belong_list(org_list, project_list, 1, @proxy_user_cd, current_m_user.user_cd, @secretaries_flg)

    #参照可能な部署に所属するメンバーのハッシュ作成
    visible_member_hash = get_visible_member_hash(index_org)

    #公開/非公開の判断
    for member_data_work in member_list_work
      for i in 2..3
        #1:終日, 2:終日以外
        member_data = member_data_work[i]
        for data in member_data
          #本人または秘書機能データ以外の場合
          if @secretaries_user_hash[data.user_cd][0].nil?
            #該当データに対するスケジュール権限データを取得
            auth_list = get_other_schedule_list(@current_date, data.user_cd, data.id)
            #公開データか判断
            public_flg = check_public(visible_member_hash, project_list, auth_list)
            if public_flg == 0
              #データを非公開にする
              data.public_kbn = 2
            end
          end
        end
      end
    end

    #**表示用にデータ加工**
    #配列[社員名, 行配列[行番号, スケジュール配列[時間, スケジュール, 表示日付]]]を作成
    @member_list = create_disp_day_list(member_list_work, start_time_disp, end_time_disp)

    #**区分M(種別)より色を取得**
    @plan_color_list = MKbn.get_plan_color_list()
  end

  #空き状況確認(施設)
  def spare_time_facility
    #**基準日の設定**
    if params[:day]
      @current_date = params[:day].to_date
    else
      @current_date = Date.today
    end

    #表示時間の設定
    start_time_disp = Time.parse(@current_date.strftime("%Y-%m-%d") + " " + START_TIME)
    end_time_disp = Time.parse(@current_date.strftime("%Y-%m-%d") + " " + END_TIME)

    #**メインユーザコードの取得(秘書機能用)**
    @select_proxy_user_cd = params[:select_proxy_user_cd]
    if @select_proxy_user_cd.nil? || @select_proxy_user_cd == ""
      @proxy_user_cd = current_m_user.user_cd
    else
      @proxy_user_cd = params[:select_proxy_user_cd]
    end

    #**メインユーザが所属する部署/プロジェクト情報取得**
    org_list = MUserBelong.get_belong_org_list(@proxy_user_cd)
    project_list = MProject.get_project_list(@proxy_user_cd)
    #部署コードをカンマ区切りに編集
    org_colon_list = edit_org_colon(org_list)

    #**メインユーザのスケジュールデータを取得**
    reserves_not_allday = get_login_schedule_all_list_day(@proxy_user_cd, start_time_disp, end_time_disp, 0)  #終日以外
    reserves_allday = get_login_schedule_all_list_day(@proxy_user_cd, start_time_disp, end_time_disp, 1)  #終日

    #**選択された施設について**
    @select_facility_list = params[:select_facility_list]
    #選択された施設をハッシュで取得
    @select_facility_hash = get_select_facility_hash(@select_facility_list)

    #施設グループコードを基にデータ取得
    facility_group_cd = params[:facility_group_cd]
    @facility_group_cd = facility_group_cd
    #施設Mより情報を取得
    org_edit_sql = MOrg.edit_org_consider_lvl(org_list)
    facility_list = getfacility_list(org_edit_sql, facility_group_cd, "")

    #配列[施設コード, 施設名, 終日リスト, 施設リスト(終日以外)]を作成
    facility_list_work = []
    count = 0
    @facility_all_list_colon = "" #表示する全ての施設
    for facility in facility_list
      #施設予約データより情報を取得(日単位)
      reserves_not_allday = get_other_facility_all_list_day(facility.facility_cd, start_time_disp, end_time_disp, 0) #終日以外
      reserves_allday = get_other_facility_all_list_day(facility.facility_cd, start_time_disp, end_time_disp, 1) #終日
      facility_list_work << [facility.facility_cd, facility.name + "<br>" + facility.case, reserves_allday, reserves_not_allday]
      if count == 0
        @facility_all_list_colon = facility.facility_cd
      else
        @facility_all_list_colon += "," + facility.facility_cd
      end
      count = count + 1
    end

    #配列[施設コード, 施設名, 終日リスト, 施設配列[時間, 施設(終日以外), 表示日付]]を作成
    element_list_work = []
    for element in facility_list_work
      #時間に紐付く施設リスト作成
      cell_reserves = []
      reserves = element[3]
      reserves.each { |reserve|
        cell_reserves << [reserve.plan_time_from, reserve, ""]
      }
      element_list_work << [element[0], element[1], element[2], cell_reserves]
    end

    #表示用に、配列[施設コード, 施設名, 行配列[行番号, 施設配列[時間, 施設, 表示日付]]]を作成
    #施設データの開始日時/終了日時は、表示用に上書きする場合あり
    @element_list = []

    #element:施設ごとの施設配列[時間, 施設リスト]
    for element in element_list_work
      #配列[行番号, 時間に紐付く施設リスト, 表示日付]のリスト
      day_row_list = []
      #メンバー各個人の施設リスト
      reserve_list = element[3]
      #reserve:格納する施設１件
      for reserve in reserve_list
        #ＤＢに登録されている日時
        start_date_old = reserve[1].plan_date_from
        end_date_old = reserve[1].plan_date_to
        start_time_old = Time.parse(start_date_old + " " + reserve[1].plan_time_from)
        end_time_old = Time.parse(end_date_old + " " + reserve[1].plan_time_to)

        disp_date = start_time_old.strftime("%H:%M") + "-" + end_time_old.strftime("%H:%M")

        #表示用に、開始日時/終了日時を上書きする
        reserve[1].plan_date_from = @current_date
        reserve[1].plan_date_to = @current_date
        if start_time_old < start_time_disp
          reserve[1].plan_time_from = Time.parse(@current_date.strftime("%Y-%m-%d") + " " + start_time_disp.strftime("%H:%M"))
        else
          reserve[1].plan_time_from = Time.parse(@current_date.strftime("%Y-%m-%d") + " " + reserve[1].plan_time_from)
        end
        if end_time_old < end_time_disp
          reserve[1].plan_time_to = Time.parse(@current_date.strftime("%Y-%m-%d") + " " + reserve[1].plan_time_to)
        else
          reserve[1].plan_time_to = Time.parse(@current_date.strftime("%Y-%m-%d") + " " + end_time_disp.strftime("%H:%M"))
        end

        #開始日(終了日は異なる)の場合
        if @current_date == start_date_old.to_date
          if @current_date != end_date_old.to_date
            #終了時間を上書き
            disp_date = start_time_old.strftime("%H:%M") + "-"
            reserve[1].plan_time_to = end_time_disp
          end

        #終了日(開始日は異なる)の場合
        elsif @current_date == end_date_old.to_date
          #開始時間を上書き
          disp_date = "-" + end_time_old.strftime("%H:%M")
          reserve[1].plan_time_from = start_time_disp

        #中間日の場合
        else
          #開始時間/終了時間を上書き
          disp_date = ""
          reserve[1].plan_time_from = start_time_disp
          reserve[1].plan_time_to = end_time_disp
        end

        #表示時間の格納
        reserve[2] = disp_date

        #該当施設をどの行配列に格納するか判断
        ins_flg = 0 #行配列への格納フラグ(0:格納不可, 1:格納可能)
        row_num = 0 #格納する配列の行番号
        #day_row:配列[行番号, 時間に紐付く施設リスト]]
        for day_row in day_row_list
          ins_flg = 1
          row_num = day_row[0]
          row_list = day_row[1] #格納されている施設リスト

          #row_data:格納されている施設１件
          for row_data in row_list
            if !(row_data[1].plan_time_from >= reserve[1].plan_time_to || row_data[1].plan_time_to <= reserve[1].plan_time_from)
              #該当行配列に格納できない
              ins_flg = 0
              break
            end
          end
        end

        #行配列リストの初期化
        if day_row_list.size == 0
          target_row_list = []
          target_row_list << reserve
          day_row_list << [0, target_row_list]
        else
          #既存行配列に格納する場合
          if ins_flg == 1
            target_day_row = day_row_list[row_num]
            target_row_list_work = target_day_row[1]
            target_row_list_work << reserve
            #開始時間でソート
            target_row_list = target_row_list_work.sort{ |a,b|
              a[0] <=> b[0]
            }
            day_row_list[row_num][1] = target_row_list
          else
            #新たな行配列を作成する
            target_row_list = []
            target_row_list << reserve
            day_row_list << [day_row_list.size, target_row_list]
          end
        end
      end

      @element_list << [element[0], element[1], element[2], day_row_list]
    end
  end

  def show

  end

  #登録用ダイアログ表示
  def new
    #パンくずリストに表示させる
    @pankuzu += SCHEDULE

    #**メインユーザコードの取得(秘書機能用)**
    @select_proxy_user_cd = params[:select_proxy_user_cd]
    if @select_proxy_user_cd.nil? || @select_proxy_user_cd == ""
      @proxy_user_cd = current_m_user.user_cd
    else
      @proxy_user_cd = params[:select_proxy_user_cd]
    end

    #**メインユーザが所属する部署/プロジェクト情報取得**
    org_list = MUserBelong.get_belong_org_list(@proxy_user_cd)
    project_list = MProject.get_project_list(@proxy_user_cd)
    #部署コードをカンマ区切りに編集
    org_colon_list = edit_org_colon(org_list)

    #**秘書マスタよりデータ取得**
    @secretaries_user_list = MSecretary.get_secretary_authorize_list(org_colon_list, current_m_user.user_cd, 0)
    if @secretaries_user_list.size > 0
      @secretaries_flg = 1
    else
      @secretaries_flg = 0
    end

    #参照できる所属リスト[所属フラグ(0:空白, 1:秘書機能, 2xy:部署, 3:プロジェクト), コード, 名称]の作成
    #x(表示階層)1:1階層下,2:2階層下,3:1階層上,4:課全体,5:部全体    y(選択組織)組織の階層
    @belong_list = DSchedule.get_visible_belong_list(org_list, project_list, 1, @proxy_user_cd, current_m_user.user_cd, @secretaries_flg)

    #所属の初期状態を設定(空白)
    @other_checked_id = 0

    #**表示するスケジュールデータの準備**
    #期末日を取得
    select_date = params[:date] #選択された日
    #会社M
    company_data = MCompany.find(:first, :conditions => ["delf = ?", 0])
    #期のリスト作成(0:1期末日, 1:2期末日..x:1期末日の1年後)
    term_list = []
    @term_colon = ""  #javaScriptでの入力チェック用
    term_list << get_term_date(select_date, company_data.term_end1, 0)
    @term_colon += company_data.term_end1
    if company_data.term_end2 != ""
      term_list << get_term_date(select_date, company_data.term_end2, 0)
      @term_colon += "," + company_data.term_end2
    end
    if company_data.term_end3 != ""
      term_list << get_term_date(select_date, company_data.term_end3, 0)
      @term_colon += "," + company_data.term_end3
    end
    if company_data.term_end4 != ""
      term_list << get_term_date(select_date, company_data.term_end4, 0)
      @term_colon += "," + company_data.term_end4
    end
    term_list << get_term_date(select_date, company_data.term_end1, 1)

    #直近の期末日を判定
    term_old = term_list[0]
    term_date = term_old
    for i in 1..(term_list.size - 1)
      term_new = term_list[i]
      if (term_old <= select_date.to_date) && (select_date.to_date < term_new)
        term_date = term_new
        break
      else
        term_old = term_new
      end
    end

    #時間の設定
    start_time = Time.now.strftime("%Y-%m-%d") + " 08:30"
    end_time = Time.now.strftime("%Y-%m-%d") + " 09:30"

    #**表示するスケジュールデータの作成**
    @reserve = DSchedule.new
    @reserve.plan_date_from = select_date
    @reserve.plan_date_to = select_date
    @reserve.plan_time_from = start_time.to_datetime
    @reserve.plan_time_to = end_time.to_datetime
    @reserve.repeat_date_to = term_date.strftime("%Y-%m-%d")

    #**区分M(種別)**
    @plan_list = MKbn.find(:all, :order=>:kbn_id, :conditions => ["kbn_cd = ? and delf = ?", "d_schedules_plan_kbn",0])

    #**区分M(種別)より終日フラグを取得**
    @plan_allday_list = MKbn.get_plan_allday_list()

    #**設定間隔を取得**
    @time_interval = get_time_interval()

    #**所属チェック配列(公開/非公開用)の作成**
    #メインユーザの所属リスト[所属フラグ(1:部署, 2:プロジェクト, 3:非公開), コード, 名称]の作成
    belong_user_list = DSchedule.get_belong_user_list(org_list, project_list)

    #公開/非公開配列(更新時とデータの持ち方を合わせる)の作成
    #配列[チェックフラグ, 所属一覧[所属フラグ(1:部署, 2:プロジェクト, 3:非公開), コード, 名称]]
    @belong_check_list = []
    for i in 0..(belong_user_list.size - 1)
      belong = belong_user_list[i]
      #部署の場合(デフォルト:チェックあり)
      if belong[0] == 1
        @belong_check_list << [1, belong]
      else
        @belong_check_list << [0, belong]
      end
    end

    #遷移元情報を格納
    session[:back_secretaries_user_cd] = params[:back_secretaries_user_cd]
    session[:back_belong_index] = params[:back_belong_index]
  end

  #更新用ダイアログ表示
  def edit
    #パンくずリストに表示させる
    @pankuzu += SCHEDULE

    #**表示するスケジュールデータの準備**
    #会社M
    company_data = MCompany.find(:first, :conditions => ["delf = ?", 0])
    #期のリスト作成(0:1期末日, 1:2期末日..x:1期末日の1年後)
    @term_colon = ""  #javaScriptでの入力チェック用
    @term_colon += company_data.term_end1
    if company_data.term_end2 != ""
      @term_colon += "," + company_data.term_end2
    end
    if company_data.term_end3 != ""
      @term_colon += "," + company_data.term_end3
    end
    if company_data.term_end4 != ""
      @term_colon += "," + company_data.term_end4
    end

    #**表示するスケジュールデータの作成**
    @reserve = DSchedule.find(params[:id])
    @reserve.plan_time_from = (@reserve.plan_date_from.strftime("%Y-%m-%d") + " " + @reserve.plan_time_from.strftime("%H:%M")).to_datetime
    @reserve.plan_time_to = (@reserve.plan_date_to.strftime("%Y-%m-%d") + " " + @reserve.plan_time_to.strftime("%H:%M")).to_datetime
    #招待社員CDが入っている場合
    if @reserve.invite_user_name != ""
      @create_user_name = @reserve.invite_user_name
    #ユーザCDと秘書CDが異なる場合
    elsif (@reserve.secretary_cd != "") && (@reserve.user_cd != @reserve.secretary_cd)
      @create_user_name = MUser.find(:first, :conditions => ["user_cd = ? and delf = ?", @reserve.secretary_cd, 0]).name
    end

    #**メインユーザコードの取得(秘書機能用)**
    #登録データが秘書機能で作成されている場合
    if @reserve.secretary_cd != ""
      @proxy_user_cd = @reserve.user_cd
      @select_proxy_user_cd = @reserve.user_cd
    else
      select_proxy_user_cd = params[:select_proxy_user_cd]
      if select_proxy_user_cd.nil? || select_proxy_user_cd == "" || select_proxy_user_cd == current_m_user.user_cd
        @proxy_user_cd = current_m_user.user_cd
        @select_proxy_user_cd = ""
      #秘書機能で参照したデータの場合
      else
        @proxy_user_cd = select_proxy_user_cd
        @select_proxy_user_cd = select_proxy_user_cd
      end
    end

    #**メインユーザが所属する部署/プロジェクト情報取得**
    org_list = MUserBelong.get_belong_org_list(@proxy_user_cd)
    project_list = MProject.get_project_list(@proxy_user_cd)
    #部署コードをカンマ区切りに編集
    org_colon_list = edit_org_colon(org_list)

    #秘書マスタよりデータ取得
    @secretaries_user_list = MSecretary.get_secretary_authorize_list(org_colon_list, current_m_user.user_cd, 0)
    if @secretaries_user_list.size > 0
      @secretaries_flg = 1
    else
      @secretaries_flg = 0
    end

    #参照できる所属リスト[所属フラグ(0:空白, 1:秘書機能, 2xy:部署, 3:プロジェクト), コード, 名称]の作成
    #x(表示階層)1:1階層下,2:2階層下,3:1階層上,4:課全体,5:部全体    y(選択組織)組織の階層
    index_space = 0
    index_secretary = 1
    index_org = 2
    index_project = 3
    @belong_list = DSchedule.get_visible_belong_list(org_list, project_list, 1, @proxy_user_cd, current_m_user.user_cd, @secretaries_flg)

    #**区分M(種別)**
    @plan_list = MKbn.find(:all, :order=>:kbn_id, :conditions => ["kbn_cd = ? and delf = ?", "d_schedules_plan_kbn", 0])

    #**区分M(種別)より終日フラグを取得**
    @plan_allday_list = MKbn.get_plan_allday_list()

    #**設定間隔を取得**
    @time_interval = get_time_interval()

    #**所属チェック配列(公開/非公開用)の作成**
    #メインユーザの所属リスト[所属フラグ(1:部署, 2:プロジェクト, 3:非公開), コード, 名称]の作成
    belong_user_list = DSchedule.get_belong_user_list(org_list, project_list)

    #公開/非公開配列の作成
    #配列[チェックフラグ(各所属のチェック有無), 所属一覧[所属フラグ(1:部署, 2:プロジェクト, 3:非公開), コード, 名称]]
    @belong_check_list = []
    unpublic_flg = 1  #非公開フラグ(0:公開, 1:完全に非公開)
    for belong in belong_user_list
      #部署
      if belong[0] == 1
        #スケジュール権限データ(組織用)
        @schedule_auth_org = DScheduleAuth.find(:all, :conditions => ["d_schedule_id = ? and org_cd = ? and delf = ?", params[:id], belong[1], 0])
        @pro_flg = 0  #プロジェクトチェックフラグ(0:チェック無/1:チェック有)
        if @schedule_auth_org.size > 0
          org_flg = 1
          unpublic_flg = 0
        else
          org_flg = 0
        end
        @belong_check_list << [org_flg, belong]

      #プロジェクト
      elsif belong[0] == 2
        #スケジュール権限データ(プロジェクト用)
        @schedule_auth_pro = DScheduleAuth.find(:all, :conditions => ["d_schedule_id = ? and project_id = ? and delf = ?", params[:id], belong[1].to_i, 0])
        @pro_flg = 0  #プロジェクトチェックフラグ(0:チェック無/1:チェック有)
        if @schedule_auth_pro.size > 0
          pro_flg = 1
          unpublic_flg = 0
        else
          pro_flg = 0
        end
        @belong_check_list << [pro_flg, belong]
      end
    end
    #非公開
    @belong_check_list << [unpublic_flg, belong]

    #**同時登録の初期値作成**
    belong_flg = @reserve.invite_checked_index
    belong_cd = @reserve.invite_checked_cd

    #空白または秘書機能が選択されていた場合
    if belong_flg == index_space || belong_flg == index_secretary
      @other_checked_id = belong_flg

    #部署が選択されていた場合
    elsif (belong_flg.to_s)[0..0].to_i == index_org
      #選択されていた部署CDを基に初期indexを設定
      for i in 0..(@belong_list.size - 1)
        belong_work = @belong_list[i]
        #部署CDの比較
        data_index = (belong_work[0].to_s)[0..0].to_i #インデックス(0:空白, 1:秘書機能, 2xy:部署, 3:プロジェクト)
        data_cd = belong_work[1] #組織コード
        data_cd_index = (belong_work[0].to_s)[1..1].to_i  #組織の中のインデックス(1:1階層下,2:2階層下,3:1階層上,4:課全体,5:部全体)
        if (data_index == index_org) && (data_cd == belong_cd) && (data_cd_index == (belong_flg.to_s)[1..1].to_i)
          @other_checked_id = i
          break
        end
      end

    #プロジェクトが選択されていた場合
    elsif belong_flg == index_project
      #選択されていたプロジェクトidを基に初期indexを設定
      for i in 0..(@belong_list.size - 1)
        belong_work = @belong_list[i]
        #プロジェクトidの比較
        if (belong_work[0] == index_project) && (belong_work[1] == belong_cd)
          @other_checked_id = i
          break
        end
      end
    end

    #遷移元情報を格納
    session[:back_secretaries_user_cd] = params[:back_secretaries_user_cd]
    session[:back_belong_index] = params[:back_belong_index]
  end

  #登録処理(POST)
  def create
    @msg = ""
    @duplicate_msg = ""
    from_mode = session[:from_mode]
    select_date = params[:select_date].to_date
    back_secretaries_user_cd = session[:back_secretaries_user_cd]
    back_belong_index = session[:back_belong_index]
    @select_button = params[:select_button].to_s
    @repeat_schedule_id = 0  #繰り返し予定基本id(スケジュール用,基準データidを保持)
    @repeat_facility_id = 0  #繰り返し予定基本id(施設用,基準データidを保持)

    #**遷移先を指定**
    if from_mode == "1"
      action = "index_day"
      day = select_date.strftime("%Y%m%d")
    elsif from_mode == "2"
      action = "index_week"
      start_date = session[:week_start_date].to_date
      week = start_date.strftime("%Y%m%d")
    elsif from_mode == "3"
      action = "index_month"
      month = select_date.strftime("%Y%m")
    else
      action = "index"
    end

    #**中止の場合は処理終了**
    if @select_button == "99"
      flash[:schedule_msg] = @msg
      flash[:duplicate_msg] = @duplicate_msg
      redirect_to :action => action, :month => month, :week => week, :day => day, :secretaries_user_cd => back_secretaries_user_cd, :other_checked_id => back_belong_index
      return
    end

    #**データ削除/登録の準備**
    #メインユーザコードの取得(秘書機能用)
    @select_proxy_user_cd = params[:select_proxy_user_cd]
    if @select_proxy_user_cd.nil? || @select_proxy_user_cd == ""
      @proxy_user_cd = current_m_user.user_cd
    else
      @proxy_user_cd = params[:select_proxy_user_cd]
    end

    #今回のメンバーリスト取得
    decided_member_new = params[:decided_member_new][0].split(",")
    decided_member_new.unshift(@proxy_user_cd)

    #招待フラグ(0:招待しない, 1:招待する)
    @invite_flg = 0
    if decided_member_new.size > 1
      @invite_flg = 1
    end

    #招待id(ログインユーザのスケジュールidとする)
    @invite_id = 0

    #**データ削除/登録を行う**
    for member in decided_member_new
      #**登録対象ユーザコード(招待用)**
      @user_cd = member

      #**招待情報の設定**
      #招待画面選択インデックス/招待画面選択CDの設定
      #ログインユーザの場合
      if @user_cd == @proxy_user_cd
        other_checked_id = params[:other_checked_id].to_i
        project_list = MProject.get_project_list(@proxy_user_cd)
        org_list = MUserBelong.get_belong_org_list(@proxy_user_cd)
        #部署コードをカンマ区切りに編集
        org_colon_list = edit_org_colon(org_list)
        #秘書マスタよりデータ取得
        @secretaries_user_list = MSecretary.get_secretary_authorize_list(org_colon_list, current_m_user.user_cd, 0)
        if @secretaries_user_list.size > 0
          @secretaries_flg = 1
        else
          @secretaries_flg = 0
        end
        #所属リストを基に選択された情報を取得
        belong_list = DSchedule.get_visible_belong_list(org_list, project_list, 1, @proxy_user_cd, current_m_user.user_cd, @secretaries_flg)
        @invite_checked_index = belong_list[other_checked_id][0]
        @invite_checked_cd = belong_list[other_checked_id][1]
      else
        #空白で登録
        @invite_checked_index = 0
        @invite_checked_cd = ""
      end

      #**基準データの作成**
      insert_table(0, "")

      #**繰り返しデータの作成**
      if @reserve.repeat_flg == 1
        #毎月がチェックがされた場合
        if @reserve.repeat_interval_flg == 1
          insert_repeat(1)
        #曜日指定がチェックがされた場合
        elsif @reserve.repeat_interval_flg == 2
          insert_repeat(2)
        end
      end
    end

    #遷移先の制御
    flash[:schedule_msg] = @msg
    flash[:duplicate_msg] = @duplicate_msg
    redirect_to :action => action, :month => month, :week => week, :day => day, :secretaries_user_cd => back_secretaries_user_cd, :other_checked_id => back_belong_index
    return
  end

  #更新処理(PUT /user/1)
  def update
    @msg = ""
    @duplicate_msg = ""
    from_mode = session[:from_mode]
    select_date = params[:select_date].to_date
    back_secretaries_user_cd = session[:back_secretaries_user_cd]
    back_belong_index = session[:back_belong_index]
    @select_button = params[:select_button].to_s

    #**遷移先を指定**
    if from_mode == "1"
      action = "index_day"
      day = select_date.strftime("%Y%m%d")
    elsif from_mode == "2"
      action = "index_week"
      start_date = session[:week_start_date].to_date
      week = start_date.strftime("%Y%m%d")
    elsif from_mode == "3"
      action = "index_month"
      month = select_date.strftime("%Y%m")
    elsif from_mode == "4"
      action = "index_list"
      start_date = session[:list_start_month].to_date
      month = start_date.strftime("%Y%m%d")
    else
      action = "index"
    end

    #**中止の場合は処理終了**
    if @select_button == "99"
      flash[:schedule_msg] = @msg
      flash[:duplicate_msg] = @duplicate_msg
      redirect_to :action => action, :month => month, :week => week, :day => day, :secretaries_user_cd => back_secretaries_user_cd, :other_checked_id => back_belong_index
      return
    end

    #**データ削除/登録の準備**
    #メインユーザコードの取得(秘書機能用)
    @select_proxy_user_cd = params[:select_proxy_user_cd]
    if @select_proxy_user_cd.nil? || @select_proxy_user_cd == ""
      @proxy_user_cd = current_m_user.user_cd
    else
      @proxy_user_cd = params[:select_proxy_user_cd]
    end

    #ログインユーザが参照しているデータ
    login_users_data = DSchedule.find(:first, :conditions => ["id = ? and user_cd = ?", params[:id], @proxy_user_cd])

    #今回のメンバーリスト取得(本人以外)
    decided_member_new = params[:decided_member_new][0].split(",")

    #今回の招待フラグ(0:招待しない, 1:招待する)
    @invite_flg = 0
    if decided_member_new.size > 0
      @invite_flg = 1
    end

    #既存のデータが招待していた場合
    decided_member_old = []
    decided_schedule_old = []
    @invite_old_flg = 0 #既存データの同時登録フラグ(0:同時登録でない, 1:同時登録である)
    @invite_schedule_old_colon = "" #既存データのスケジュールIDリスト
    if login_users_data.invite_id != 0
      #既存のメンバーリスト取得(本人以外)
      decided_member_old = DSchedule.find(:all, :select=>"DISTINCT(user_cd)",
        :conditions => ["invite_id = ? and user_cd not in (?)",
        login_users_data.invite_id, @proxy_user_cd])
      #既存のスケジュールID取得
      decided_schedule_old = DSchedule.find(:all, :select=>"id",
        :conditions => ["invite_id = ?", login_users_data.invite_id])
      @invite_schedule_old_colon = edit_schedule_id_colon(decided_schedule_old)
      @invite_old_flg = 1
    end

    #既存と今回を合わせたメンバーリストを作成する(配列[処理フラグ(1:削除のみ, 2:追加のみ, 3:削除と追加), ユーザコード])
    decided_member_work = []
    decided_member = []
    #今回のリストのデータを処理フラグ2と3に分ける
    for work_new in decided_member_new
      flg = 0
      for work_old in decided_member_old
        if work_new == work_old.user_cd
          decided_member_work << [3, work_new]
          flg = 1
        end
      end
      if flg == 0
        decided_member_work << [2, work_new]
      end
    end
    #既存のリストより処理フラグ1のデータを取得する
    for work_old in decided_member_old
      flg = 0
      for work_new in decided_member_new
        if work_old.user_cd == work_new
          flg = 1
        end
      end
      if flg == 0
        decided_member_work << [1, work_old.user_cd]
      end
    end

    #本人を先頭に追加する
    login_arr = [3, @proxy_user_cd]
    decided_member_work.unshift(login_arr)

    #削除ボタン押下の場合はフラグを更新
    if @select_button == '5' || @select_button == '6'
      for work in decided_member_work
        decided_member << [1, work[1]]
      end
    else
      decided_member = decided_member_work
    end

    #招待id(ログインユーザのスケジュールidとする)
    @invite_id = 0

    #**データ削除/登録を行う**
    #各メンバーごとにデータを作成する
    for member in decided_member
      @repeat_schedule_id = 0  #繰り返し予定基本id(スケジュール用,基準データidを保持)
      @repeat_facility_id = 0  #繰り返し予定基本id(施設用,基準データidを保持)
      @transact_mode = member[0]  #処理フラグ(1:削除のみ, 2:追加のみ, 3:削除と追加)
      @user_cd = member[1]  #登録対象ユーザコード(招待用)
      @invite_user_cd_old = ""  #招待社員CD
      @invite_user_name_old = ""  #招待社員名
      @secretary_cd_old = ""  #秘書CD

      #削除する場合
      if member[0] == 1 || member[0] == 3
        #スケジュールid取得
        #本人の場合
        if @user_cd == @proxy_user_cd
          schedule_id = params[:id]  #スケジュールid
          @invite_user_cd_old = login_users_data.invite_user_cd
          @invite_user_name_old = login_users_data.invite_user_name
          @secretary_cd_old = login_users_data.secretary_cd

        #本人以外の場合
        else
          schedule_id = ""
          #該当データ以降のデータを更新/削除の場合
          if @select_button == '4' || @select_button == '6'
            #指定日付に一番近いデータを取得
            data = DSchedule.find(:first, :conditions => [
              "user_cd = ? and invite_id = ? and plan_date_from >= ?", @user_cd, login_users_data.invite_id, login_users_data.plan_date_from],
              :order => "plan_date_from")
            if !data.nil?
              schedule_id = data.id
              @invite_user_cd_old = data.invite_user_cd
              @invite_user_name_old = data.invite_user_name
              @secretary_cd_old = data.secretary_cd
            end
          else
            data = DSchedule.find(:first, :conditions => [
              "user_cd = ? and invite_id = ? and plan_date_from = ?", @user_cd, login_users_data.invite_id, login_users_data.plan_date_from])
            if !data.nil?
              schedule_id = data.id
              @invite_user_cd_old = data.invite_user_cd
              @invite_user_name_old = data.invite_user_name
              @secretary_cd_old = data.secretary_cd
            end
          end
        end

        #削除データが存在する場合
        if schedule_id != ""
          #各テーブルからdelete
          #繰り返しデータがない場合
          if @select_button == '1'
            DSchedule.delete(schedule_id)
            DScheduleAuth.delete_all(["d_schedule_id = ?", schedule_id])
            DReminder.delete_all(["d_schedule_id = ?", schedule_id])
            DReserve.delete_all(["d_schedule_id = ?", schedule_id])
            DMessage.delete_all(["message_kbn = ? and etcint2 = ?", 1, schedule_id])

          #繰り返しデータがある場合
          #該当データのみ更新の場合
          elsif @select_button == '2'
            DSchedule.delete(schedule_id)
            DScheduleAuth.delete_all(["d_schedule_id = ?", schedule_id])
            DReminder.delete_all(["d_schedule_id = ?", schedule_id])
            DReserve.delete_all(["d_schedule_id = ?", schedule_id])
            DMessage.delete_all(["message_kbn = ? and etcint2 = ?", 1, schedule_id])

          #該当データ以降のデータを更新/削除の場合
          elsif @select_button == '4' || @select_button == '6'
            repeat_schedule_id = DSchedule.find(schedule_id).repeat_schedule_id #繰り返し予定基本id
            delete_list = DSchedule.find(:all, :conditions => ["repeat_schedule_id = ? and plan_date_from >= ?", repeat_schedule_id, params[:select_date]])

            for delete_data in delete_list
              DSchedule.delete_all(["id = ?", delete_data.id])
              DScheduleAuth.delete_all(["d_schedule_id = ?", delete_data.id])
              DReminder.delete_all(["d_schedule_id = ?", delete_data.id])
              DReserve.delete_all(["d_schedule_id = ?", delete_data.id])
              DMessage.delete_all(["message_kbn = ? and etcint2 = ?", 1, delete_data.id])
            end

          #データ削除の場合
          elsif @select_button == '5'
            DSchedule.delete(schedule_id)
            DScheduleAuth.delete_all(["d_schedule_id = ?", schedule_id])
            DReminder.delete_all(["d_schedule_id = ?", schedule_id])
            DReserve.delete_all(["d_schedule_id = ?", schedule_id])
            DMessage.delete_all(["message_kbn = ? and etcint2 = ?", 1, schedule_id])
          end
        end
      end

      #追加する場合
      if member[0] == 2 || member[0] == 3

        #**招待情報の設定**
        #招待画面選択インデックス/招待画面選択CDの設定
        #ログインユーザの場合
        if @user_cd == current_m_user.user_cd
          other_checked_id = params[:other_checked_id].to_i
          project_list = MProject.get_project_list(@proxy_user_cd)
          org_list = MUserBelong.get_belong_org_list(@proxy_user_cd)
          #部署コードをカンマ区切りに編集
          org_colon_list = edit_org_colon(org_list)
          #秘書マスタよりデータ取得
          @secretaries_user_list = MSecretary.get_secretary_authorize_list(org_colon_list, current_m_user.user_cd, 0)
          if @secretaries_user_list.size > 0
            @secretaries_flg = 1
          else
            @secretaries_flg = 0
          end
          #所属リストを基に選択された情報を取得
          belong_list = DSchedule.get_visible_belong_list(org_list, project_list, 1, @proxy_user_cd, current_m_user.user_cd, @secretaries_flg)
          @invite_checked_index = belong_list[other_checked_id][0]
          @invite_checked_cd = belong_list[other_checked_id][1]
        else
          #空白で登録
          @invite_checked_index = 0
          @invite_checked_cd = ""
        end

        #**基準データの作成**
        insert_table(0, "")

        #**繰り返しデータの作成(該当データのみ更新の場合を除く)**
        if params[:select_button].to_s != '2'
          if @reserve.repeat_flg == 1
            #毎月がチェックがされた場合
            if @reserve.repeat_interval_flg == 1
              insert_repeat(1)
            #曜日指定がチェックがされた場合
            elsif @reserve.repeat_interval_flg == 2
              insert_repeat(2)
            end
          end
        end
      end
    end

#    #**本人のデータを削除する**
#    if !params[:own_delete_flg].nil?
#      #繰り返しデータがない または 該当データのみ更新の場合
#      if @select_button == '1' || @select_button == '2'
#        DSchedule.delete(@invite_id)
#        DScheduleAuth.delete_all(["d_schedule_id = ?", @invite_id])
#        DReminder.delete_all(["d_schedule_id = ?", @invite_id])
#        DReserve.delete_all(["d_schedule_id = ?", @invite_id])
#      end
#    end

    #**遷移先の制御**
    flash[:schedule_msg] = @msg
    flash[:duplicate_msg] = @duplicate_msg
    redirect_to :action => action, :month => month, :week => week, :day => day, :secretaries_user_cd => back_secretaries_user_cd, :other_checked_id => back_belong_index

  end

  #同時登録エリア表示(決定)
  def other_member_list
    plan_date_from = params[:plan_date_from].to_date

    #**メインユーザコードの取得(秘書機能用)**
    @select_proxy_user_cd = params[:select_proxy_user_cd]
    if @select_proxy_user_cd.nil? || @select_proxy_user_cd == ""
      @proxy_user_cd = current_m_user.user_cd
    else
      @proxy_user_cd = params[:select_proxy_user_cd]
    end

    #**表示用のメンバーリスト作成**
    @other_member_decide = []    #選択決定エリア用のデータ
    @other_member_undecide = []  #選択候補エリア用のデータ

    #招待idで登録されているユーザーを取得(ログインユーザ以外)
    if params[:invite_id].to_s != '0'
      invite_member = DSchedule.find(:all, :select=>"DISTINCT(user_cd), id", :conditions =>
        ["(plan_date_from = ? or (plan_date_from < ? and plan_date_to >= ?))
        and invite_id = ? and user_cd not in (?)",
        plan_date_from, plan_date_from, plan_date_from, params[:invite_id], @proxy_user_cd],
        :order => "id")
      #該当メンバーをリストに追加
      for member in invite_member
        if member.user_cd != @proxy_user_cd
          #ユーザM
          m_users_other = MUser.find(:first, :conditions => ["user_cd = ? and delf = ?", member.user_cd, 0])
          #各ユーザの情報を取得
          @other_member_decide << [member.user_cd, m_users_other.name]
        end
      end
    end
  end

  #同時登録エリア表示(候補)
  def undecided_member
    #**メインユーザコードの取得(秘書機能用)**
    @select_proxy_user_cd = params[:select_proxy_user_cd]
    if @select_proxy_user_cd.nil? || @select_proxy_user_cd == ""
      @proxy_user_cd = current_m_user.user_cd
    else
      @proxy_user_cd = params[:select_proxy_user_cd]
    end

    #**ユーザが所属する部署/プロジェクト情報取得**
    org_list = MUserBelong.get_belong_org_list(@proxy_user_cd)
    project_list = MProject.get_project_list(@proxy_user_cd)
    #部署コードをカンマ区切りに編集
    org_colon_list = edit_org_colon(org_list)

    #**秘書マスタよりデータ取得**
    @secretaries_user_list = MSecretary.get_secretary_authorize_list(org_colon_list, current_m_user.user_cd, 0)
    if @secretaries_user_list.size > 0
      @secretaries_flg = 1
    else
      @secretaries_flg = 0
    end

    #秘書マスタよりハッシュ[ユーザコード, ユーザ名]作成(スケジュールリンク用)
    @secretaries_user_hash = getSecretaries_user_hash(org_colon_list, 0)

    #参照できる所属リスト[所属フラグ(0:空白, 1:秘書機能, 2xy:部署, 3:プロジェクト), コード, 名称]の作成
    #x(表示階層)1:1階層下,2:2階層下,3:1階層上,4:課全体,5:部全体    y(選択組織)組織の階層
    index_space = 0
    index_secretary = 1
    index_org = 2
    index_project = 3
    @belong_list = DSchedule.get_visible_belong_list(org_list, project_list, 1, @proxy_user_cd, current_m_user.user_cd, @secretaries_flg)

    #**選択された所属を取得**
    if params[:other_checked_id].nil? || params[:other_checked_id] == ""
      @other_checked_id = 0
    else
      @other_checked_id = params[:other_checked_id].to_i
    end

    #**表示用のメンバーリスト作成**
    @other_member_undecide = []
    #選択された所属フラグを取得
    belong_flg = @belong_list[@other_checked_id][0]
    belong = @belong_list[@other_checked_id]
    #部署の場合
    if (belong_flg.to_s)[0..0].to_i == index_org
      org_cd = belong[1]
    #プロジェクトの場合
    elsif belong_flg == index_project
      project_id = belong[1].to_i
    end

    #空白が選択されている場合
    if belong_flg == index_space
      #処理なし

    #秘書機能が選択されている場合
    elsif belong_flg == index_secretary
      #該当メンバーをリストに追加
      for data in @secretaries_user_list
        if data[0] != @proxy_user_cd
          @other_member_undecide << [data[0], data[1]]
        end
      end

    #組織が選択されている場合
    elsif belong_flg.to_s[0..0].to_i == index_org
      m_users_all = get_other_org_list(belong_flg, @proxy_user_cd, org_cd)
      #該当メンバーをリストに追加
      for user in m_users_all
        if user.user_cd != @proxy_user_cd
          @other_member_undecide << [user.user_cd, user.name]
        end
      end

    #プロジェクトが選択されている場合
    else
      #ログインユーザと同じプロジェクトに属するユーザーを取得
      project_other = get_other_project_list(project_id)
      #該当メンバーをリストに追加
      for project in project_other
        if project.user_cd != @proxy_user_cd
          @other_member_undecide << [project.user_cd, project.name]
        end
      end
    end
  end

  #施設エリア表示
  def facility_list
    @facility_decide = []    #選択決定エリア用のデータ
    @facility_undecide = []  #選択候補エリア用のデータ
    #**メインユーザコードの取得(秘書機能用)**
    @select_proxy_user_cd = params[:select_proxy_user_cd]
    if @select_proxy_user_cd.nil? || @select_proxy_user_cd == ""
      @proxy_user_cd = current_m_user.user_cd
    else
      @proxy_user_cd = params[:select_proxy_user_cd]
    end

    #**メインユーザが所属する部署情報取得**
    org_list = MUserBelong.get_belong_org_list(@proxy_user_cd)
    #部署コードをカンマ区切りに編集
    org_colon_list = edit_org_colon(org_list)

    #**施設候補リストの作成**
    #施設グループMよりデータ取得
    facility_group_list = MFacilityGroup.find(:all, :conditions => ["delf = ?", 0], :order => "sort_no")
    #全施設グループをリストに追加
    for facility_group in facility_group_list
      #施設の情報を取得
      @facility_undecide << [facility_group.facility_group_cd, facility_group.name]
    end

    #**施設決定リストの作成**
    #カレンダー画面から遷移した場合
    if params[:return_mode].nil?
      #**施設予約リストの作成**
      #施設予約データを取得(スケジュールで検索)
      facility_list = get_facility_reserve(0, params[:id], params[:plan_date_from], "")
      if facility_list.size > 0
        #予約施設をリストに追加
        for facility in facility_list
          #施設の情報を取得
          @facility_decide << [facility.facility_cd, facility.name + "<br>" + facility.case]
        end
      end

    #空き状況確認画面から遷移した場合
    else
      #既に選択されていた施設
      select_facility_list_old = params[:select_facility_list_old].split(",")
      #既に選択されていた施設(hash)
      select_facility_hash_old = get_select_facility_hash(params[:select_facility_list_old])
      #今回選択された施設
      select_facility_list_new = params[:facility_cd_colon].split(",")
      #今回表示された施設全て
      all_facility_list_new = params[:facility_all_list_colon].split(",")
      #今回選択されなかった施設を取得
      unselect_facility_list_new = ""
      count = 0
      for all_facility in all_facility_list_new
        select_flg = 0
        for select_facility in select_facility_list_new
          if select_facility == all_facility
            select_flg = 1
            break
          end
        end
        #選択された施設でない場合
        if select_flg == 0
          if count == 0
            unselect_facility_list_new = all_facility
          else
            unselect_facility_list_new += "," + all_facility
          end
          count = count + 1
        end
      end
      #今回選択されなかった施設(hash)
      unselect_facility_hash_new = get_select_facility_hash(unselect_facility_list_new)

      #既に選択されていた施設を取得
      if select_facility_list_old.size > 0
        #予約施設をリストに追加
        for facility_cd in select_facility_list_old
          #今回選択されなかった施設でない場合
          if unselect_facility_hash_new[facility_cd][0].nil?
            #施設予約データを取得(施設コードで検索)
            facility = get_facility_reserve(1, "", "", facility_cd)[0]
            if facility.nil?
              #施設Mより情報を取得
              facility = getfacility_list("", "", facility_cd)[0]
            end
            #施設の情報を取得
            @facility_decide << [facility.facility_cd, facility.name + "<br>" + facility.case]
          end
        end
      end

      #今回選択された施設を取得
      if select_facility_list_new.size > 0
        #予約施設をリストに追加
        for facility_cd in select_facility_list_new
          #既に選択された施設でない場合
          if select_facility_hash_old[facility_cd][0].nil?
            #施設Mより情報を取得
            facility = getfacility_list("", "", facility_cd)[0]
            #施設の情報を取得
            @facility_decide << [facility.facility_cd, facility.name + "<br>" + facility.case]
          end
        end
      end
    end
  end

  def secretary_print
    #**基準日の設定**
    @current_date = (params[:start_day][0,4] + "-" + params[:start_day][4,2] + "-" + "01").to_date

    #休日ハッシュを取得
    @holiday_hash = MCalendar.get_holiday_hash()
    #イベントハッシュを取得
    @event_hash = MCalendar.get_event_hash()

    #**月末日の取得**
    @last_manth_day = Date.new(@current_date.strftime("%Y").to_i, @current_date.strftime("%m").to_i, -1).strftime("%d").to_i

    #**ログインユーザが所属する部署/プロジェクト情報取得**
    org_list = MUserBelong.get_belong_org_list(current_m_user.user_cd)
    project_list = MProject.get_project_list(current_m_user.user_cd)
    #部署コードをカンマ区切りに編集
    org_colon_list = edit_org_colon(org_list)

    #**秘書マスタよりデータ取得**
    @secretaries_user_list = MSecretary.get_secretary_authorize_list(org_colon_list, current_m_user.user_cd, 0)

    #秘書マスタよりハッシュ[ユーザコード, ユーザ名]作成(スケジュールリンク用)
    @secretaries_user_hash = getSecretaries_user_hash(org_colon_list, 1)

    #**表示用のメンバーリスト作成**
    #配列[社員コード, 社員名, スケジュールリスト]を作成
    member_list_work = []

    #該当メンバーをリストに追加
    for data in @secretaries_user_list
      if data[0] != current_m_user.user_cd
        #各ユーザのスケジュールデータを取得
        reserves = get_other_schedule_all_list_print(data[0])
      end
      member_list_work << [data[0], data[1], reserves]
    end

    #**表示用にデータ加工**
    #配列[社員コード, 社員名, 日付に紐付くスケジュールリスト]を作成
    @member_list = DSchedule.create_disp_week_or_print_list(member_list_work)
  end

  def destroy
    @reserve = DSchedule.find(params[:id])
    @reserve.destroy

    redirect_to :action => "index"
  end

private
  #各テーブルへのinsert用メソッド
  #rep_flg：繰り返しデータフラグ(0：基準データ、1：繰り返しデータ)
  #start_date：スケジュール開始日(繰り返しデータの場合のみ使用)
  def insert_table(rep_flg, start_date)
    #**準備**
    proxy_user_name = MUser.find(:first, :conditions => ["user_cd = ? and delf = ?", @proxy_user_cd, 0]).name #メインユーザ名

    #**スケジュールデータ登録**
    @reserve = DSchedule.new(params[:reserve])
    @reserve.reminder_day_value = params[:reminder_day_value]
    @reserve.reminder_week_value = params[:reminder_week_value]
    @reserve.reminder_month_value = params[:reminder_month_value]
    @reserve.repeat_month_value = params[:repeat_month_value]
    @reserve.memo = params[:memo]
    #基準データ
    if rep_flg == 0
      @reserve.plan_date_from = params[:d_schedule]["plan_date_from"]
      @reserve.plan_date_to = params[:d_schedule]["plan_date_to"]
      @reserve.reminder_specify_date = params[:d_schedule]["reminder_specify_date"]
    #繰り返しデータ
    else
      @reserve.plan_date_from = start_date
      @reserve.plan_date_to = start_date + (params[:d_schedule]["plan_date_to"].to_date - params[:d_schedule]["plan_date_from"].to_date).to_i
      @reserve.reminder_specify_flg = 0
      @reserve.repeat_schedule_id = @repeat_schedule_id
    end
    #終日
    if @reserve.plan_allday_flg == 1
      @reserve.plan_time_from = (@reserve.plan_date_from.strftime("%Y-%m-%d") + " " + START_TIME).to_datetime
      @reserve.plan_time_to = (@reserve.plan_date_to.strftime("%Y-%m-%d") + " " + END_TIME).to_datetime
    else
      @reserve.plan_time_from = (@reserve.plan_date_from.strftime("%Y-%m-%d") + " " + @reserve.plan_time_from.strftime("%H:%M")).to_datetime
      @reserve.plan_time_to = (@reserve.plan_date_to.strftime("%Y-%m-%d") + " " + @reserve.plan_time_to.strftime("%H:%M")).to_datetime
    end
    #繰り返しがチェックされた場合
    if @reserve.repeat_flg == 1
      @reserve.repeat_date_to = params[:d_schedule]["repeat_date_to"]
    else
      @reserve.repeat_date_to = params[:repeat_date_to].to_date
    end
    @reserve.user_cd = @user_cd

    #**招待機能の関連項目**
    @reserve.invite_id = @invite_id
    @reserve.invite_checked_index = @invite_checked_index
    @reserve.invite_checked_cd = @invite_checked_cd
    if @invite_flg == 1 && (@user_cd == @proxy_user_cd)
      @reserve.invite_flg = 0
    else
      @reserve.invite_flg = @invite_flg
    end
    #処理フラグ(3:削除と追加)の場合
    if @transact_mode == 3
      #招待機能で登録する場合
      @reserve.invite_user_cd = @invite_user_cd_old
      @reserve.invite_user_name = @invite_user_name_old
    else
      #招待機能で登録する場合
      if @invite_flg == 1 && (@user_cd != @proxy_user_cd)
        @reserve.invite_user_cd = @proxy_user_cd
        @reserve.invite_user_name = proxy_user_name
      else
        @reserve.invite_user_cd = ""
        @reserve.invite_user_name = ""
      end
    end

    #**秘書機能の関連項目**
    if @transact_mode == 3
      @reserve.secretary_cd = @secretary_cd_old
    else
      #秘書機能で登録する場合
      if !(@select_proxy_user_cd.nil? || @select_proxy_user_cd == "")
        @reserve.secretary_cd = current_m_user.user_cd
      else
        @reserve.secretary_cd = ""
      end
    end
    @reserve.created_user_cd = current_m_user.user_cd
    @reserve.updated_user_cd = current_m_user.user_cd
    @reserve.save!

    #**繰り返しの基となる値の設定**
    #繰り返し予定基本idの設定
    #繰り返しデータありの場合
    if @reserve.repeat_flg == 1
      #基準データの場合
      if rep_flg == 0
        @repeat_schedule_id = @reserve.id  #繰り返し予定基本id
        @reserve.repeat_schedule_id = @repeat_schedule_id
        @reserve.save
      end
    end
    #招待idの設定
    #招待データあり かつメインユーザの基準データの場合
    if @invite_flg == 1 && @user_cd == @proxy_user_cd && rep_flg == 0
      @invite_id = @reserve.id
      @reserve.invite_id = @invite_id
      @reserve.save
    end

    #**スケジュール権限データ登録**
    check_id_list = params[:belong_check_list]
    if !(check_id_list.nil?)
      #ユーザが所属する部署/プロジェクト情報取得
      org_list = MUserBelong.get_belong_org_list(@proxy_user_cd)
      project_list = MProject.get_project_list(@proxy_user_cd)
      #ユーザの所属リスト[所属フラグ(1:部署, 2:プロジェクト, 3:非公開), コード, 名称]を作成
      belong_list = DSchedule.get_belong_user_list(org_list, project_list)

      #チェックされたデータを処理
      for i in 0..(check_id_list.size - 1)
        belong = belong_list[check_id_list[i].to_i]
        #部内が選択された場合
        if belong[0] == 1
          org_cd = belong[1]
          project_id = 0
        #プロジェクトが選択された場合
        elsif belong[0] == 2
          org_cd = ""
          project_id = belong[1].to_i
        #非公開が選択された場合
        else
          break
        end

        #スケジュール権限データ登録
        @auths = DScheduleAuth.new()
        @auths.d_schedule_id = @reserve.id
        @auths.org_cd = org_cd
        @auths.project_id = project_id
        @auths.user_cd = @user_cd
        @auths.created_user_cd = current_m_user.user_cd
        @auths.updated_user_cd = current_m_user.user_cd
        @auths.save
      end
    end

    #**リマインダーデータ登録**
    #マイページがチェックされた場合
    if @reserve.reminder_mypage_flg == 1
      insert_reminder(0, rep_flg, start_date)
    end
    #メールがチェックされた場合
    if @reserve.reminder_email_flg == 1
      insert_reminder(1, rep_flg, start_date)
    end
    #携帯メールがチェックされた場合
    if @reserve.reminder_mobile_mail_flg == 1
      insert_reminder(2, rep_flg, start_date)
    end

    #**メッセージデータ登録**
    #基準データかつ同時登録ユーザのみ
    if rep_flg == 0 && (@user_cd != @proxy_user_cd)
      #本文作成
      contents = ""
      contents += "タイトル  ：  " + @reserve.title + "<BR>"
      #終日以外
      if @reserve.plan_allday_flg == 0
        contents += "開始日時 ：  " + @reserve.plan_time_from.strftime("%Y年%m月%d日    %H時%M分") + "<BR>"
        contents += "終了日時  ：  " + @reserve.plan_time_to.strftime("%Y年%m月%d日    %H時%M分") + "<BR>"
      else
        contents += "開始日 ：  " + @reserve.plan_date_from.strftime("%Y年%m月%d日") + "<BR>"
        contents += "終了日 ：  " + @reserve.plan_date_to.strftime("%Y年%m月%d日") + "<BR>"
        contents += "終日" + "<BR>"
      end
      contents += "<BR>"
      #繰り返しあり
      if @reserve.repeat_flg == 1
        contents += "繰り返し登録  ：  あり<BR>"
        contents += "繰り返し条件<BR>"
        contents += "終了日  ：  " + @reserve.repeat_date_to.strftime("%Y年%m月%d日") + "<BR>"
        #月指定
        if @reserve.repeat_interval_flg == 1
          contents += "月指定  ：  毎月" + @reserve.repeat_month_value.to_s + "日<BR>"
        #曜日指定
        else
          contents += "曜日指定  ：  毎週"
          if @reserve.repeat_week_sun_flg == 1 #日曜
            contents += "日曜日    "
          end
          if @reserve.repeat_week_mon_flg == 1 #月曜
            contents += "月曜日    "
          end
          if @reserve.repeat_week_tue_flg == 1 #火曜
            contents += "火曜日    "
          end
          if @reserve.repeat_week_wed_flg == 1 #水曜
            contents += "水曜日    "
          end
          if @reserve.repeat_week_thu_flg == 1 #木曜
            contents += "木曜日    "
          end
          if @reserve.repeat_week_fri_flg == 1 #金曜
            contents += "金曜日    "
          end
          if @reserve.repeat_week_sat_flg == 1 #土曜
            contents += "土曜日    "
          end
        end
      end

      #**区分M(種別)**
      plan_name = MKbn.find(:first, :order=>:kbn_id, :conditions => ["kbn_cd = ? and kbn_id = ? and delf = ?", "d_schedules_plan_kbn", @reserve.plan_kbn, 0]).name

      @message = DMessage.new()
      @message.user_cd = @user_cd
      @message.message_kbn = 1
      @message.from_user_cd = @proxy_user_cd
      @message.from_user_name = proxy_user_name
      @message.title = "[" + plan_name + "]"  + @reserve.plan_date_from.strftime("%Y年%m月%d日") + "のスケジュールが" + proxy_user_name + "さんより登録されました"
      @message.post_date = Time.now
      @message.body = contents
      @message.etcint1 = 1  #マイページからの遷移先(スケジュール)
      @message.etcint2 = @reserve.id  #スケジュールID
      @message.etctxt1 = @reserve.plan_date_from.strftime("%Y%m%d")
      @message.created_user_cd = current_m_user.user_cd
      @message.updated_user_cd = current_m_user.user_cd
      @message.save
    end

    #**施設予約データ登録**
    #メインユーザの場合のみ
    if @user_cd == @proxy_user_cd
      decided_facility_new = params[:decided_facility_new][0].split(",")
      #施設が選択された場合
      if decided_facility_new.size > 0
        decided_facility_new.each do |facility_cd|
          #施設Mより情報を取得
          m_facility = MFacility.find(:first, :conditions => ["facility_cd = ? and enable_flg = ? and delf = ?", facility_cd, 0, 0])

          #重複データチェック
          #登録する情報を取得
          plan_allday_flg_new = @reserve.plan_allday_flg
          if plan_allday_flg_new == 1 #終日
            date_from_new = @reserve.plan_date_from.strftime("%Y%m%d") + "0000"
            date_to_new = (@reserve.plan_date_to + 1).strftime("%Y%m%d") + "0000"
          else
            date_from_new = @reserve.plan_time_from.strftime("%Y%m%d%H%M")
            date_to_new = @reserve.plan_time_to.strftime("%Y%m%d%H%M")
          end

          #テーブルの情報
          duplicate_flg = 0
          #既存のデータが同時登録だった場合
          if !(@invite_old_flg.nil? || @invite_old_flg == "") && @invite_old_flg == 1
            sql =  " SELECT * "
            sql += " FROM d_reserves"
            sql += " WHERE delf = '0'"
            sql += " AND facility_cd = '" + facility_cd + "'"
            sql += " AND (d_schedule_id not in (" + @invite_schedule_old_colon + ")"
            sql += "      OR (d_schedule_id is null))"
            d_reserve_list = DReserve.find_by_sql(sql)

          else
            d_reserve_list = DReserve.find(:all,
              :conditions => ["facility_cd = ? and delf = ?", facility_cd, 0])
          end
          #登録されている情報を取得
          for d_reserve in d_reserve_list
            plan_allday_flg_old = d_reserve.plan_allday_flg
            if plan_allday_flg_old == 1 #終日
              date_from_old = d_reserve.plan_date_from.strftime("%Y%m%d") + "0000"
              date_to_old = (d_reserve.plan_date_to + 1).strftime("%Y%m%d") + "0000"
            else
              date_from_old = d_reserve.plan_date_from.strftime("%Y%m%d") + d_reserve.plan_time_from.strftime("%H%M")
              date_to_old = d_reserve.plan_date_to.strftime("%Y%m%d") + d_reserve.plan_time_to.strftime("%H%M")
            end
            #日時の重複チェック
            if !(date_from_old >= date_to_new || date_to_old <= date_from_new)
              duplicate_flg = 1
              break
            end
          end

          #重複エラーの場合
          if duplicate_flg == 1
            #**メッセージデータ登録**
            #本文作成
            contents = ""
            contents += "タイトル  ：  " + @reserve.title + "<BR>"
            contents += "施設名  ：  " + m_facility.name + "<BR>"
            contents += "開始日 ：  " + @reserve.plan_date_from.strftime("%Y年%m月%d日") + "<BR>"
            contents += "終了日  ：  " + @reserve.plan_date_to.strftime("%Y年%m月%d日") + "<BR>"

            @duplicate_msg += "●施設名 ：  " + m_facility.name + "、"
            @duplicate_msg += "開始日 ：  " + @reserve.plan_date_from.strftime("%Y年%m月%d日") + "<br>"

            @message = DMessage.new()
            @message.user_cd = current_m_user.user_cd
            @message.message_kbn = 2
            @message.from_user_cd = @proxy_user_cd
            @message.from_user_name = proxy_user_name
            @message.title = @reserve.plan_date_from.strftime("%Y年%m月%d日") + "の予約(" + m_facility.name + ")が重複しました"
            @message.post_date = Time.now
            @message.body = contents
            @message.etcint1 = 1  #マイページからの遷移先(スケジュール)
            @message.etctxt1 = @reserve.plan_date_from.strftime("%Y%m%d")
            @message.created_user_cd = current_m_user.user_cd
            @message.updated_user_cd = current_m_user.user_cd
            @message.save

          else
            @facility = DReserve.new()
            @facility.facility_cd = facility_cd
            @facility.place_cd = m_facility.place_cd
            @facility.org_cd = m_facility.org_cd
            @facility.title = @reserve.title
            @facility.reserve_user_cd = @user_cd
            @facility.reserve_user_name = MUser.find(:first, :conditions => ["user_cd = ? and delf = ?", @user_cd, 0]).name
            @facility.memo = @reserve.memo
            #基準データ
            if rep_flg == 0
              @facility.plan_date_from = params[:d_schedule]["plan_date_from"]
              @facility.plan_date_to = params[:d_schedule]["plan_date_to"]
            #繰り返しデータ
            else
              @facility.plan_date_from = start_date
              @facility.plan_date_to = start_date + (params[:d_schedule]["plan_date_to"].to_date - params[:d_schedule]["plan_date_from"].to_date).to_i
              @facility.repeat_facility_id = @repeat_facility_id
            end
            @facility.plan_time_from = (@reserve.plan_date_from.strftime("%Y-%m-%d") + " " + @reserve.plan_time_from.strftime("%H:%M")).to_datetime
            @facility.plan_time_to = (@reserve.plan_date_to.strftime("%Y-%m-%d") + " " + @reserve.plan_time_to.strftime("%H:%M")).to_datetime
            @facility.plan_allday_flg = @reserve.plan_allday_flg
            @facility.repeat_flg = @reserve.repeat_flg
            #繰り返しがチェックされた場合
            if @facility.repeat_flg == 1
              @facility.repeat_date_to = params[:d_schedule]["repeat_date_to"]
            else
              @facility.repeat_date_to = params[:repeat_date_to].to_date
            end
            @facility.repeat_interval_flg = @reserve.repeat_interval_flg
            @facility.repeat_month_value = @reserve.repeat_month_value
            @facility.repeat_week_sun_flg = @reserve.repeat_week_sun_flg
            @facility.repeat_week_mon_flg = @reserve.repeat_week_mon_flg
            @facility.repeat_week_tue_flg = @reserve.repeat_week_tue_flg
            @facility.repeat_week_wed_flg = @reserve.repeat_week_wed_flg
            @facility.repeat_week_thu_flg = @reserve.repeat_week_thu_flg
            @facility.repeat_week_fri_flg = @reserve.repeat_week_fri_flg
            @facility.repeat_week_sat_flg = @reserve.repeat_week_sat_flg
            @facility.d_schedule_id = @reserve.id
            @facility.created_user_cd = current_m_user.user_cd
            @facility.updated_user_cd = current_m_user.user_cd
            @facility.save!
            #**繰り返しの基となる値の設定**
            #繰り返し予定基本idの設定
            #繰り返しデータありの場合
            if @reserve.repeat_flg == 1
              #繰り返し予定基本idが設定されていない場合(直前データまでが重複エラーの場合)
              if @repeat_facility_id == 0
                @repeat_facility_id = @facility.id  #繰り返し予定基本id
                @facility.repeat_facility_id = @repeat_facility_id
                @facility.save
              end
            end
          end
        end
      end
    end
  end

  #リマインダーデータへのinsert用メソッド
  #rem_kbn：通知区分(0：マイページ、1：メール、2：携帯メール)
  #rep_flg：繰り返しデータフラグ(0：基準データ、1：繰り返しデータ)
  #start_date：スケジュール開始日(繰り返しデータの場合のみ使用)
  def insert_reminder(rem_kbn, rep_flg, start_date)
    #基準データの場合
    if rep_flg == 0
      date_from = @reserve.plan_date_from
      date_to = @reserve.plan_date_to
    else
      date_from = start_date
      date_to = start_date + (@reserve.plan_date_to - @reserve.plan_date_from)
    end

    date_list = [] #追加する日付
    #数日前指定がチェックされた場合
    if @reserve.reminder_day_flg == 1
      date_list << (date_from - @reserve.reminder_day_value)
    end
    #数週間前指定がチェックされた場合
    if @reserve.reminder_week_flg == 1
      date_list << (date_from - @reserve.reminder_week_value * 7)
    end
    #数ヶ月前指定がチェックされた場合
    if @reserve.reminder_month_flg == 1
      date_list << (date_from << @reserve.reminder_month_value)
    end
    #指定日指定がチェックされた場合
    if @reserve.reminder_specify_flg == 1
      date_list << @reserve.reminder_specify_date
    end
    #リマインダーデータデータ登録
    for date in date_list
      #本文作成
      contents = ""
      contents += "以下のスケジュールのアラームメールです。\n確認をお願い致します。\n\n"
      contents += "---------------------------------------------------------------------" + "\n"
      contents += "タイトル  ：  " + @reserve.title + "\n"
      if @reserve.plan_allday_flg == 0  #終日以外
        contents += "開始日時 ：  " + date_from.strftime("%Y年%m月%d日") + " " + @reserve.plan_time_from.strftime("%H:%M")  + "\n"
        contents += "終了日時 ：  " + date_to.strftime("%Y年%m月%d日") + " " + @reserve.plan_time_to.strftime("%H:%M")  + "\n"
      else  #終日
        contents += "開始日時 ：  " + date_from.strftime("%Y年%m月%d日") + "  終日\n"
        contents += "終了日時 ：  " + date_to.strftime("%Y年%m月%d日") + "\n"
      end
      contents += "---------------------------------------------------------------------"

      @reminder = DReminder.new()
      @reminder.d_schedule_id = @reserve.id
      @reminder.reminder_kbn = rem_kbn
      @reminder.notice_date_from = date
      @reminder.notice_date_to = @reserve.plan_time_to
      @reminder.title = "【スケジュールアラーム通知】" + date_from.strftime("%Y年%m月%d日") + "の予定について"
      @reminder.body = contents
      @reminder.user_cd = @user_cd
      @reminder.created_user_cd = current_m_user.user_cd
      @reminder.updated_user_cd = current_m_user.user_cd
      @reminder.save
    end
  end

  #繰り返しデータ作成用メソッド
  #int_flg：繰り返し間隔フラグ(1:毎月、2:曜日指定)
  def insert_repeat(int_flg)
    plan_from = @reserve.plan_date_from
    plan_from_s = plan_from.strftime("%Y%m%d")
    plan_week = @reserve.plan_date_from.wday  #0:日曜..6:土曜

    #毎月がチェックがされた場合
    if int_flg == 1
      after_one_month = (plan_from >> 1).strftime("%Y%m%d")  #予定開始日の1ヶ月後
      begin
        next_date1 = (plan_from_s[0, 4] + plan_from_s[4, 2] + sprintf("%0#{2}d",@reserve.repeat_month_value)).to_date   #指定日(予定開始月が基準)
      rescue
        #該当月の月末日に置換する
        next_date1 = Date.new(plan_from_s[0, 4].to_i, plan_from_s[4, 2].to_i, -1)
      end
      begin
        next_date2 = (after_one_month[0, 4] + after_one_month[4, 2] + sprintf("%0#{2}d",@reserve.repeat_month_value)).to_date   #指定日(予定開始 + 1か月後の月が基準)
      rescue
        #該当月の月末日に置換する
        next_date1 = Date.new(after_one_month[0, 4].to_i, after_one_month[4, 2].to_i, -1)
      end

      #先頭日付(最初の繰り返し日)を設定
      date = next_date1
      #次の指定日 <= 予定開始日の場合
      if next_date1 <= plan_from
        date = next_date2
      end

      date_list = [] #追加する日付
      #先頭日付が、終了日より大きい場合
      if @reserve.repeat_date_to >= date
        #終了日まで処理を繰り返す
        while date <= @reserve.repeat_date_to
          date_list << date
          date = (date >> 1)
        end
      end

      #各テーブルへのinsert
      for date in date_list
        insert_table(1, date)
      end

    #曜日指定がチェックがされた場合
    elsif int_flg == 2
      week_list = []  #選択された曜日
      if @reserve.repeat_week_sun_flg == 1  #日曜
        week_list << 0
      end
      if @reserve.repeat_week_mon_flg == 1  #月曜
        week_list << 1
      end
      if @reserve.repeat_week_tue_flg == 1  #火曜
        week_list << 2
      end
      if @reserve.repeat_week_wed_flg == 1  #水曜
        week_list << 3
      end
      if @reserve.repeat_week_thu_flg == 1  #木曜
        week_list << 4
      end
      if @reserve.repeat_week_fri_flg == 1  #金曜
        week_list << 5
      end
      if @reserve.repeat_week_sat_flg == 1  #土曜
        week_list << 6
      end

      #選択された曜日の分、処理を繰り返す
      for next_week in week_list
        add_date = 0   #該当曜日までの日数

        #該当曜日を過ぎている場合
        if plan_week >= next_week
          add_date = 7 - (plan_week - next_week)
        else
          add_date = next_week - plan_week
        end

        #先頭日付(最初の繰り返し日)を設定
        date = plan_from + add_date

        date_list = [] #追加する日付
        #先頭日付が、終了日より大きい場合
        if @reserve.repeat_date_to >= date
          #終了日まで処理を繰り返す
          while date <= @reserve.repeat_date_to
            date_list << date
            date = (date + 7)
          end
        end

        #各テーブルへのinsert
        for date in date_list
          insert_table(1, date)
        end
      end
    end
  end

  #選択された階層に属するユーザーを取得
  #belong_flg:2xy(x(表示階層)1:1階層下,2:2階層下,3:1階層上,4:課全体,5:部全体    y:ユーザー所属組織の階層(1階層上の場合のみ使用))
  #user_cd:メインユーザコード
  #select_org_cd:組織コード(下階層表示:メインユーザの組織コード, 上階層表示:選択された組織コード)
  def get_other_org_list(belong_flg, user_cd, select_org_cd)
    #表示階層(1:1階層下,2:2階層下,3:1階層上,4:課全体,5:部全体)
    disp_num = belong_flg.to_s[1..1].to_i

    #選択された組織レベルを取得
    org_lvl = MOrg.find(:first, :conditions => ["org_cd = ? and delf = ?", select_org_cd, 0]).org_lvl

    #下の階層表示の場合
    if disp_num <= 2
      num_l = org_lvl            #検索組織レベル下限
      num_h = org_lvl + disp_num #検索組織レベル上限
    #1階層上を表示の場合
    elsif disp_num == 3
      num_l = org_lvl            #検索組織レベル下限
      num_h = org_lvl + 1        #検索組織レベル上限
    end

    #ユーザー属性M/所属M/組織M/職位M
    sql =  " SELECT a.* "
    sql +=  "   , e.case as org_name "
    sql += "    , e.org_cd "
    sql += "    , f.name "
    sql += " FROM m_user_attributes a "
    sql += "    , m_positions b "
    sql += "    , (SELECT g.user_cd"
    sql += "            , d.org_name4 as org_name4"
    sql += "            , d.org_name3 as org_name3"
    sql += "            , d.org_name2 as org_name2"
    sql += "            , d.org_name1 as org_name1"
    sql += "            , case "
    sql += "                when trim(org_name4) != '' then '(' || org_name4 || ')'"
    sql += "                when trim(org_name3) != '' then '(' || org_name3 || ')'"
    sql += "                when trim(org_name2) != '' then '(' || org_name2 || ')'"
    sql += "                when trim(org_name1) != '' then '(' || org_name1 || ')'"
    sql += "              end "
    sql += "            , g.org_cd"
    sql += "       FROM m_orgs d"
    sql += "          , (SELECT DISTINCT(f.user_cd) as user_cd "
    sql += "                  , MIN(f.org_cd) as org_cd "
    sql += "             FROM   m_user_belongs f"
    sql += "             WHERE  f.delf = 0"
    sql += "             AND    f.org_cd like ('" + select_org_cd + "%')"
    sql += "             GROUP BY f.user_cd) g"
    sql += "       WHERE d.delf = 0"
    if !num_l.nil?
      sql += "       AND d.org_lvl >= " + num_l.to_s
    end
    if !num_h.nil?
      sql += "       AND d.org_lvl <= " + num_h.to_s
    end
    sql += "         AND g.org_cd = d.org_cd"
    sql += "      ) e"
    sql += "    , m_users f "
    sql += " WHERE a.delf = '0'"
    sql += " AND b.delf = '0'"
    sql += " AND f.delf = '0'"
    sql += " AND a.position_cd = b.position_cd "
    sql += " AND a.user_cd = e.user_cd"
    sql += " AND a.user_cd = f.user_cd"
    sql += " ORDER BY a.sort_no, e.org_cd, b.sort_no, joined_date"

    org_list = MUserAttribute.find_by_sql(sql)
    return org_list
  end

  #ログインユーザと同じプロジェクトに属するユーザーを取得
  #project_where:プロジェクトidの条件句
  def get_other_project_list(project_id)
    #プロジェクトM/プロジェクトメンバーM/ユーザM/ユーザー所属M/組織M
    sql  = "SELECT g.*"
    sql += ", h.org_name4 as org_name4"
    sql += ", h.org_name3 as org_name3"
    sql += ", h.org_name2 as org_name2"
    sql += ", h.org_name1 as org_name1"
    sql += ", case "
    sql += "     when trim(org_name4) != '' then '(' || org_name4 || ')'"
    sql += "     when trim(org_name3) != '' then '(' || org_name3 || ')'"
    sql += "     when trim(org_name2) != '' then '(' || org_name2 || ')'"
    sql += "     when trim(org_name1) != '' then '(' || org_name1 || ')'"
    sql += "  end as org_name"
    sql += " FROM "
    sql += "      m_orgs h"
    sql += "    , m_user_belongs i"
    sql += "    , (SELECT a.* "
    sql += "            , b.user_cd "
    sql += "            , c.name "
    sql += "            , d.sort_no as u_sort_no "
    sql += "            , d.joined_date "
    sql += "            , e.sort_no as p_sort_no "
    sql += "        FROM  m_projects a "
    sql += "            , m_project_users b "
    sql += "            , m_users c "
    sql += "            , m_user_attributes d"
    sql += "            , m_positions e"
    sql += "       WHERE  a.delf = '0' "
    sql += "         AND  b.delf = '0' "
    sql += "         AND  c.delf = '0' "
    sql += "         AND  d.delf = '0' "
    sql += "         AND  e.delf = '0' "
    sql += "         AND  a.id = b.project_id"
    sql += "         AND  b.user_cd = c.user_cd"
    sql += "         AND  c.user_cd = d.user_cd"
    sql += "         AND  d.position_cd = e.position_cd"
    sql += "         AND  a.id = " + project_id.to_s + ") g"
    sql += " WHERE h.delf = '0'"
    sql += " AND  i.delf = '0'"
    sql += " AND  h.org_cd = i.org_cd"
    sql += " AND  i.user_cd = g.user_cd"
    sql += " AND  i.belong_kbn = 0"  #主所属
    #並び順
    sql += " ORDER BY g.u_sort_no, i.org_cd, g.p_sort_no, g.joined_date"

    project_other = MProject.find_by_sql(sql)
    return project_other
  end

  #各ユーザのスケジュールデータを取得(週単位：他の予定用)
  #date:条件句に使用する日付
  #user_cd:ユーザーコード
  def get_other_schedule_all_list_week(date, user_cd)
    reserves = DSchedule.find(:all, :conditions =>
      ["(plan_date_from >= ? or (plan_date_from < ? and plan_date_to >= ?)) and plan_date_from <= ? and user_cd = ?",
      @current_date, @current_date, @current_date, date, user_cd],
      :order => "plan_date_from, plan_time_from, id")
    return reserves
  end

  #各ユーザのスケジュールデータを取得(日単位：他の予定用)
  #user_cd:ユーザーコード
  #start_time_disp:表示開始時間
  #end_time_disp:表示終了時間
  #allday_flg:終日フラグ(0:終日以外, 1:終日)
  def get_other_schedule_all_list_day(user_cd, start_time_disp, end_time_disp, allday_flg)
    reserves = DSchedule.find(:all, :conditions =>
      ["(plan_date_from = ? or (plan_date_from < ? and plan_date_to >= ?))
      and (plan_time_from < ? and plan_time_to > ?)
      and user_cd = ? and plan_allday_flg = ?",
      @current_date, @current_date, @current_date, end_time_disp, start_time_disp, user_cd, allday_flg],
      :order => "plan_date_from, plan_time_from, id")
    return reserves
  end

  #各ユーザのスケジュールデータを取得(月単位：他の予定用)
  #user_cd:ユーザーコード
  def get_other_schedule_all_list_month(user_cd)
    month_before = (@current_date << 1) - 7 #(1か月+1週間)前
    month_after = (@current_date >> 1) + 7  #(1か月+1週間)後
    #基準となる月の前後１か月
    reserves = DSchedule.find(:all, :conditions =>
      ["((plan_date_from >= ? and plan_date_from <= ?) or (plan_date_from < ? and plan_date_to >= ?) or (plan_date_from < ? and plan_date_to >= ?))
      and user_cd = ?",
      month_before, month_after, month_before, month_before, month_after, month_after, user_cd],
      :order => "plan_date_from, plan_time_from, id")
    return reserves
  end

  #各ユーザのスケジュールデータを取得(秘書機能の印刷：他の予定用)
  #user_cd:ユーザーコード
  def get_other_schedule_all_list_print(user_cd)
    reserves = DSchedule.find(:all, :conditions =>
      ["(plan_date_from >= ? or (plan_date_from < ? and plan_date_to >= ?)) and user_cd = ?",
      @current_date, @current_date, @current_date, user_cd],
      :order => "plan_date_from, plan_time_from, id")
    return reserves
  end

  #メインユーザのスケジュールデータを取得(日単位)
  #user_cd:ユーザーコード
  #start_time_disp:表示開始時間
  #end_time_disp:表示終了時間
  #allday_flg:終日フラグ(0:終日以外, 1:終日)
  def get_login_schedule_all_list_day(user_cd, start_time_disp, end_time_disp, allday_flg)
    reserves = DSchedule.find(:all, :conditions =>
      ["(plan_date_from = ? or (plan_date_from < ? and plan_date_to >= ?))
      and (plan_time_from < ? and plan_time_to > ?)
      and user_cd = ? and plan_allday_flg = ?",
      @current_date, @current_date, @current_date, end_time_disp, start_time_disp, user_cd, allday_flg],
      :order => "plan_date_from, plan_time_from, id")
    return reserves
  end

  #スケジュール権限データに存在する情報を取得(他の予定用)
  #他の予定フラグ:(0:組織, 1:プロジェクト)
  #date:条件句に使用する日付
  #user_cd:ユーザーコード
  #org_cd:組織コード
  #project_id:プロジェクトid
  def get_other_schedule_list(date, user_cd, schedules_id)
    sql = "SELECT b.* "
    sql += " FROM d_schedules a "
    sql += "    , d_schedule_auths b"
    sql += " WHERE "
    sql += "      a.delf = '0'"
    sql += " AND  b.delf = '0'"
    sql += " AND  a.id = b.d_schedule_id"
    sql += " AND (a.plan_date_from >= CAST('" + @current_date.to_s + "' AS DATE)"
    sql += " OR  (a.plan_date_from < CAST('" + @current_date.to_s + "' AS DATE)"
    sql += "       AND a.plan_date_to >= CAST('" + @current_date.to_s + "' AS DATE)))"
    sql += " AND  a.plan_date_from <= CAST('" + date.to_s + "' AS DATE)"
    sql += " AND  a.user_cd = '" + user_cd + "'"
    sql += " AND  b.d_schedule_id = " + schedules_id.to_s

    #並び順
    sql += " ORDER BY a.plan_date_from, a.plan_time_from, a.id"

    reserves = DSchedule.find_by_sql(sql)
    return reserves
  end

  #公開データかチェック(公開/非公開の判断)
  #visible_member_hash:参照可能な部署に所属するメンバー
  #project_id:プロジェクトリスト
  #auth_list:スケジュール権限データ
  def check_public(visible_member_hash, project_list, auth_list)
    public_flg = 0
    for data in auth_list
      #組織に公開 かつ 参照可能な部署に所属するメンバーか
      if data.org_cd == "0" && !visible_member_hash[data.user_cd][0].nil?
        public_flg = 1
        break
      end
      if public_flg == 0
        #プロジェクトが存在するか
        for project in project_list
          if data.project_id == project.id.to_s
            public_flg = 1
            break
          end
        end
      end
      if public_flg == 1
        break
      end
    end
    return public_flg
  end

  #本人+秘書担当のハッシュを作成
  #pname_flg:名前に職位名を結合するか(0:結合しない, 1:結合する)
  def getSecretaries_user_hash(org_colon_list, pname_flg)
    #秘書担当を取得
    user_list = MSecretary.get_secretary_authorize_list(org_colon_list, current_m_user.user_cd, pname_flg)
    user_hash = Hash.new{|hash,key| hash[key]=[]}
    user_list.each { |user_work|
      user_hash[user_work[0]] << user_work[1]
    }
    #本人を追加
    user_hash[current_m_user.user_cd] << current_m_user.name

    return user_hash
  end

  #施設Mのデータを取得
  #org_edit_sql:メインユーザが所属する部署リスト
  #facility_group_cd:施設グループコード
  #facility_cd:施設コード
  def getfacility_list(org_edit_sql, facility_group_cd, facility_cd)
    #施設M/所属M/組織M
    #(1)組織コード='0' かつ拠点コード=ユーザの拠点コード
    sql =  " SELECT a.*"
    sql += "     , '' as org_name4"
    sql += "     , '' as org_name3"
    sql += "     , '' as org_name2"
    sql += "     , '' as org_name1"
    sql += "     , '(' || e.name || ')' as case"
    sql += " FROM m_facilities a "
    sql += "  ,(SELECT DISTINCT(c.place_cd) "
    sql += "    FROM m_user_belongs b "
    sql += "       , m_orgs c "
    sql += "    WHERE b.delf = '0'"
    sql += "    AND c.delf = '0'"
    sql += "    AND b.org_cd = c.org_cd"
    sql += "    AND b.user_cd = '" + @proxy_user_cd + "') d"
    sql += "  ,m_places e "
    sql += " WHERE "
    sql += "      a.delf = '0'"
    sql += " AND  a.org_cd = '0'"
    sql += " AND  a.place_cd = d.place_cd "
    sql += " AND  a.enable_flg = 0 "
    sql += " AND  e.delf = '0' "
    sql += " AND  d.place_cd = e.place_cd "
    if facility_group_cd != ""
      sql += " AND  a.facility_group_cd = '" + facility_group_cd + "'"
    end
    if facility_cd != ""
      sql += " AND  a.facility_cd = '" + facility_cd + "'"
    end

    #(2)組織コード=ユーザの組織コード かつ拠点コード=ユーザの拠点コード
    sql += " UNION "
    sql += " SELECT a.*"
    sql += "     , e.org_name4 as org_name4"
    sql += "     , e.org_name3 as org_name3"
    sql += "     , e.org_name2 as org_name2"
    sql += "     , e.org_name1 as org_name1"
    sql += "     , case "
    sql += "         when trim(org_name4) != '' then '(' || org_name4 || ')'"
    sql += "         when trim(org_name3) != '' then '(' || org_name3 || ')'"
    sql += "         when trim(org_name2) != '' then '(' || org_name2 || ')'"
    sql += "         when trim(org_name1) != '' then '(' || org_name1 || ')'"
    sql += "       end "
    sql += " FROM m_facilities a "
    sql += "  ,(SELECT DISTINCT(c.place_cd)"
    sql += "    FROM m_user_belongs b "
    sql += "       , m_orgs c "
    sql += "    WHERE b.delf = '0'"
    sql += "    AND c.delf = '0'"
    sql += "    AND b.org_cd = c.org_cd"
    sql += "    AND b.user_cd = '" + @proxy_user_cd + "') d"
    sql += "  , m_orgs e "
    sql += " WHERE "
    sql += "      a.delf = '0'"
    sql += " AND  e.delf = '0'"
    sql += " AND  a.org_cd = e.org_cd"
    if facility_group_cd != ""
      sql += " AND a.org_cd in (" + org_edit_sql + ")"
    end
    sql += " AND  a.place_cd = d.place_cd "
    if facility_group_cd != ""
      sql += " AND  a.facility_group_cd = '" + facility_group_cd + "'"
    end
    if facility_cd != ""
      sql += " AND  a.facility_cd = '" + facility_cd + "'"
    end

    sql += "ORDER BY sort_no"

    place_list = MFacility.find_by_sql(sql)
    return place_list
  end

  #施設予約データより情報を取得
  #select_flg:検索フラグ(0:スケジュールで検索, 1:施設で検索)
  #schedules_id:スケジュールid
  #plan_date_from:予定開始日
  #facility_cd:施設コード
  def get_facility_reserve(select_flg, schedules_id, plan_date_from, facility_cd)
    #スケジュールデータで検索の場合
    if select_flg == 0
      d_schedule_data = DSchedule.find(:first, :conditions => ["id = ? and delf = ?", schedules_id, 0])
      if !d_schedule_data.nil?
        invite_id = d_schedule_data.invite_id
      else
        invite_id = 0
      end
    end

    #施設M/施設予約データ
    #(1)組織コード='0'のデータ
    sql =  " SELECT f.*"
    sql += "     , '' as org_name4"
    sql += "     , '' as org_name3"
    sql += "     , '' as org_name2"
    sql += "     , '' as org_name1"
    sql += "     , '(' || h.name || ')' as case"
    sql += " FROM d_reserves e "
    sql += "     ,m_facilities f "
    sql += "     ,m_places h "
    sql += "     ,(SELECT DISTINCT(b.facility_cd) "
    sql += "       FROM m_facilities a "
    sql += "          , d_reserves b "
    sql += "       WHERE "
    sql += "            a.delf = '0'"
    sql += "       AND  b.delf = '0'"
    sql += "       AND  a.facility_cd = b.facility_cd "
    sql += "       AND  a.enable_flg = 0 "
    sql += "       ) g "
    #スケジュールデータで検索の場合
    if select_flg == 0
      #同時予約の場合
      if invite_id != 0
        sql += "  , (SELECT id "
        sql += "     FROM d_schedules "
        sql += "     WHERE delf = 0 "
        sql += "     AND invite_id = " + invite_id.to_s
        sql += "     AND plan_date_from = CAST('" + plan_date_from + "' AS DATE)"
        sql += "    ) c"
      end
    end
    sql += " WHERE h.delf = '0' "
    sql += " AND   f.org_cd = '0' "
    sql += " AND   e.facility_cd = g.facility_cd "
    sql += " AND   e.facility_cd = f.facility_cd "
    sql += " AND   f.place_cd = h.place_cd "
    #スケジュールデータで検索の場合
    if select_flg == 0
      #同時予約の場合
      if invite_id != 0
        sql += "   AND  e.d_schedule_id = c.id"
      else
        sql += "   AND  e.d_schedule_id = " + schedules_id.to_s
      end
    end
    #施設で検索の場合
    if select_flg == 1
      sql += " AND   e.facility_cd = '" + facility_cd + "'"
    end

    #(2)組織コード!='0'のデータ
    sql += " UNION"
    sql += " SELECT f.*"
    sql += "     , d.org_name4 as org_name4"
    sql += "     , d.org_name3 as org_name3"
    sql += "     , d.org_name2 as org_name2"
    sql += "     , d.org_name1 as org_name1"
    sql += "     , case "
    sql += "         when trim(org_name4) != '' then '(' || org_name4 || ')'"
    sql += "         when trim(org_name3) != '' then '(' || org_name3 || ')'"
    sql += "         when trim(org_name2) != '' then '(' || org_name2 || ')'"
    sql += "         when trim(org_name1) != '' then '(' || org_name1 || ')'"
    sql += "       end "
    sql += " FROM m_orgs d "
    sql += "     ,d_reserves e "
    sql += "     ,m_facilities f "
    sql += "     ,(SELECT DISTINCT(b.facility_cd) "
    sql += "       FROM m_facilities a "
    sql += "          , d_reserves b "
    sql += "       WHERE "
    sql += "            a.delf = '0'"
    sql += "       AND  b.delf = '0'"
    sql += "       AND  a.facility_cd = b.facility_cd "
    sql += "       AND  a.enable_flg = 0 "
    sql += "       ) g "
    #スケジュールデータで検索の場合
    if select_flg == 0
      #同時予約の場合
      if invite_id != 0
        sql += "  , (SELECT id "
        sql += "     FROM d_schedules "
        sql += "     WHERE delf = 0 "
        sql += "     AND invite_id = " + invite_id.to_s
        sql += "     AND plan_date_from = CAST('" + plan_date_from + "' AS DATE)"
        sql += "    ) c"
      end
    end
    sql += " WHERE d.delf = '0' "
    sql += " AND   d.org_cd = f.org_cd "
    sql += " AND   e.facility_cd = g.facility_cd "
    sql += " AND   e.facility_cd = f.facility_cd "
    #スケジュールデータで検索の場合
    if select_flg == 0
      #同時予約の場合
      if invite_id != 0
        sql += "   AND  e.d_schedule_id = c.id"
      else
        sql += "   AND  e.d_schedule_id = " + schedules_id.to_s
      end
    end
    #施設で検索の場合
    if select_flg == 1
      sql += " AND   e.facility_cd = '" + facility_cd + "'"
    end

    reserves = MFacility.find_by_sql(sql)
    return reserves
  end

  #施設予約データより情報を取得(日単位)
  #facility_cd:施設コード
  #start_time_disp:表示開始時間
  #end_time_disp:表示終了時間
  #allday_flg:終日フラグ(0:終日以外, 1:終日)
  def get_other_facility_all_list_day(facility_cd, start_time_disp, end_time_disp, allday_flg)
    #施設M/施設予約データ
    sql = "SELECT a.name as name, b.*, c.name as create_user_name"
    sql += " FROM m_facilities a "
    sql += "  , d_reserves b "
    sql += "  , m_users c "
    sql += " WHERE "
    sql += "      a.delf = '0'"
    sql += " AND  b.delf = '0'"
    sql += " AND  c.delf = '0'"
    sql += " AND  a.facility_cd = b.facility_cd "
    sql += " AND  b.created_user_cd = c.user_cd "
    sql += " AND  a.enable_flg = 0 "
    sql += " AND (b.plan_date_from = CAST('" + @current_date.to_s + "' AS DATE)"
    sql += " OR  (b.plan_date_from < CAST('" + @current_date.to_s + "' AS DATE)"
    sql += "       AND b.plan_date_to >= CAST('" + @current_date.to_s + "' AS DATE)))"
    sql += " AND (b.plan_time_from < CAST('" + end_time_disp.strftime("%H:%M").to_s + "' AS TIME)"
    sql += " AND  b.plan_time_to > CAST('" + start_time_disp.strftime("%H:%M").to_s + "' AS TIME))"
    sql += " AND  b.facility_cd = '" + facility_cd + "'"
    sql += " AND  b.plan_allday_flg = " + allday_flg.to_s
    sql += " ORDER BY b.plan_date_from, b.plan_time_from, b.id"

    reserves = MFacility.find_by_sql(sql)
    return reserves
  end

  #部署リストをカンマ編集する
  #org_list:部署リスト
  def edit_org_colon(org_list)
    org_colon_list = ""
    for i in 0..(org_list.size - 1)
      org = org_list[i]
      if i > 0
        org_colon_list += ","
      end
      org_colon_list += "'"
      org_colon_list += org.org_cd
      org_colon_list += "'"
    end
    return org_colon_list
  end

  #スケジュールIDリストをカンマ編集する
  #schedule_id_list:スケジュールIDリスト
  def edit_schedule_id_colon(schedule_id_list)
    id_colon_list = ""
    for i in 0..(schedule_id_list.size - 1)
      id = schedule_id_list[i].id
      if i > 0
        id_colon_list += ","
      end
      id_colon_list += id.to_s
    end
    return id_colon_list
  end

  #設定時間の間隔を取得
  def get_time_interval()
    #スケジュール設定テーブル
    setting_data = DScheduleSetting.find(:first, :conditions => ["user_cd = ? and delf = ?", current_m_user.user_cd, 0])
    #時間の設定間隔フラグを取得
    if setting_data.nil?
      set_time_interval_flg = 0
    else
      set_time_interval_flg = setting_data.set_time_interval_flg
    end

    #時間の設定間隔を設定
    if set_time_interval_flg == 0
      time_interval = 5
    elsif set_time_interval_flg == 1
      time_interval = 10
    else
      time_interval = 15
    end

    return time_interval
  end

  #表示用にデータ加工(日単位用)
  #配列[社員名, 行配列[行番号, スケジュール配列[時間, スケジュール, 表示日付]]]を作成
  #member_list:配列[社員コード, 社員名, 終日リスト, スケジュールリスト(終日以外)]
  #start_time_disp:表示開始時間
  #end_time_disp:表示終了時間
  def create_disp_day_list(member_list, start_time_disp, end_time_disp)
    #**表示用にデータ加工**
    #配列[社員コード, 社員名, 終日リスト, スケジュール配列[時間, スケジュール(終日以外), 表示日付]]を作成
    member_list_work = []
    for member in member_list
      #時間に紐付くスケジュールリスト作成
      cell_reserves = []
      reserves = member[3]
      reserves.each { |reserve|
        cell_reserves << [reserve.plan_time_from, reserve, ""]
      }
      member_list_work << [member[0], member[1], member[2], cell_reserves]
    end

    #表示用に、配列[社員名, 行配列[行番号, スケジュール配列[時間, スケジュール, 表示日付]]]を作成
    #スケジュールデータの開始日時/終了日時は、表示用に上書きする場合あり
    member_list_disp = []

    #member:メンバーごとのスケジュール配列[時間, スケジュールリスト]
    for member in member_list_work
      #配列[行番号, 時間に紐付くスケジュールリスト, 表示日付]のリスト
      day_row_list = []
      #メンバー各個人のスケジュールリスト
      reserve_list = member[3]
      #reserve:格納するスケジュール１件
      for reserve in reserve_list
        #ＤＢに登録されている日時
        start_date_old = reserve[1].plan_date_from
        end_date_old = reserve[1].plan_date_to
        start_time_old = Time.parse(start_date_old.strftime("%Y-%m-%d") + " " + reserve[1].plan_time_from.strftime("%H:%M"))
        end_time_old = Time.parse(end_date_old.strftime("%Y-%m-%d") + " " + reserve[1].plan_time_to.strftime("%H:%M"))

        disp_date = start_time_old.strftime("%H:%M") + "-" + end_time_old.strftime("%H:%M")

        #表示用に、開始日時/終了日時を上書きする
        reserve[1].plan_date_from = @current_date
        reserve[1].plan_date_to = @current_date
        if start_time_old < start_time_disp
          reserve[1].plan_time_from = Time.parse(@current_date.strftime("%Y-%m-%d") + " " + start_time_disp.strftime("%H:%M"))
        else
          reserve[1].plan_time_from = Time.parse(@current_date.strftime("%Y-%m-%d") + " " + reserve[1].plan_time_from.strftime("%H:%M"))
        end
        if end_time_old < end_time_disp
          reserve[1].plan_time_to = Time.parse(@current_date.strftime("%Y-%m-%d") + " " + reserve[1].plan_time_to.strftime("%H:%M"))
        else
          reserve[1].plan_time_to = Time.parse(@current_date.strftime("%Y-%m-%d") + " " + end_time_disp.strftime("%H:%M"))
        end

        #開始日(終了日は異なる)の場合
        if @current_date == start_date_old
          if @current_date != end_date_old
            #終了時間を上書き
            disp_date = start_time_old.strftime("%H:%M") + "-"
            reserve[1].plan_time_to = end_time_disp
          end

        #終了日(開始日は異なる)の場合
        elsif @current_date == end_date_old
          #開始時間を上書き
          disp_date = "-" + end_time_old.strftime("%H:%M")
          reserve[1].plan_time_from = start_time_disp

        #中間日の場合
        else
          #開始時間/終了時間を上書き
          disp_date = ""
          reserve[1].plan_time_from = start_time_disp
          reserve[1].plan_time_to = end_time_disp
        end

        #表示時間の格納
        reserve[2] = disp_date

        #該当スケジュールをどの行配列に格納するか判断
        ins_flg = 0 #行配列への格納フラグ(0:格納不可, 1:格納可能)
        row_num = 0 #格納する配列の行番号
        #day_row:配列[行番号, 時間に紐付くスケジュールリスト]]
        for day_row in day_row_list
          ins_flg = 1
          row_num = day_row[0]
          row_list = day_row[1] #格納されているスケジュールリスト

          #row_data:格納されているスケジュール１件
          for row_data in row_list
            if !(row_data[1].plan_time_from >= reserve[1].plan_time_to || row_data[1].plan_time_to <= reserve[1].plan_time_from)
              #該当行配列に格納できない
              ins_flg = 0
              break
            end
          end
        end

        #行配列リストの初期化
        if day_row_list.size == 0
          target_row_list = []
          target_row_list << reserve
          day_row_list << [0, target_row_list]
        else
          #既存行配列に格納する場合
          if ins_flg == 1
            target_day_row = day_row_list[row_num]
            target_row_list_work = target_day_row[1]
            target_row_list_work << reserve
            #開始時間でソート
            target_row_list = target_row_list_work.sort{ |a,b|
              a[0] <=> b[0]
            }
            day_row_list[row_num][1] = target_row_list
          else
            #新たな行配列を作成する
            target_row_list = []
            target_row_list << reserve
            day_row_list << [day_row_list.size, target_row_list]
          end
        end
      end

      member_list_disp << [member[0], member[1], member[2], day_row_list]
    end
    return member_list_disp
  end

  #選択した施設コードのハッシュを作成
  def get_select_facility_hash(facility_colon_list)
    facility_hash = Hash.new{|hash,key| hash[key]=[]}
    facility_list = facility_colon_list.split(",")
    facility_list.each { |facility_work|
      facility_hash[facility_work] << ""
    }

    return facility_hash
  end

  #期末の日付を設定
  #select_date:選択された日付(MMDD)
  #term_end:期末日付(MMDD)
  #over_flg:年を跨ぐフラグ(0:年を跨がない, 1:年を跨ぐ)
  def get_term_date(select_date, term_end, over_flg)
    #対象の年
    current_year = select_date.to_date.strftime("%Y")
    #年を跨ぐ場合
    if over_flg == 1
      term_end_yymmdd = ((select_date.to_date >> 12).strftime("%Y") + term_end).to_date
    else
      term_end_yymmdd = (current_year + term_end).to_date
    end
   return term_end_yymmdd
  end

  #参照可能な部署に所属するメンバーのハッシュを作成
  def get_visible_member_hash(index_org)
    visible_member_hash = Hash.new{|hash,key| hash[key]=[]}

    #参照可能な部署データを取得
    @belong_list.each { |belong|
      belong_flg = belong[0]
      #部署の場合
      if (belong_flg.to_s)[0..0].to_i == index_org
        #所属メンバーを取得
        org_cd = belong[1]
        m_users_all = get_other_org_list(belong_flg, current_m_user.user_cd, org_cd)
        #該当メンバーをリストに追加
        m_users_all.each { |user|
          visible_member_hash[user.user_cd] << ""
        }
      end
    }
    return visible_member_hash
  end
end
