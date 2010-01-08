class Home::TopController < ApplicationController
  layout "portal", :except => [:message,:topic,:gadget_notice,:gadget_hottopic,:gadget_blog_long, :gadget_kbn99, :gadget_cabinet_long, :gadget_beginnig_of_month]

  def index
    #パンくずリストに表示させる
    @pankuzu += "トップページ"
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
    case params[:top_disp_kbn].to_i
      when 0
        @gadget_title = "公式通達"
        @gadget_size = "long"
      when 1
        @gadget_title = "営業本部からの通達"
        @gadget_size = "long_harf"
      when 2
        @gadget_title = "管理本部からの通達"
      when 3
        @gadget_title = "DI情報"
      when 4
        @gadget_title = "人事情報"
      when 5
        @gadget_title = "慶弔情報"
      else
        @gadget_title = "その他"
    end

    if @gadget_size == "long"
      render :action => "gadget_notice_long"
    end

  end


  def message
    params[:page] = "1" unless params[:page]

    @msgs = []

    i = 1
    @sql = ["SELECT * FROM d_messages WHERE user_cd = ? ORDER BY post_date DESC ", current_m_user.user_cd]
    @messages = DMessage.paginate_by_sql @sql, :page => params[:page], :per_page => 5


    @messages.each { |msg|
      #日報入力のお知らせ
      if msg.kbn == 1
          msg.subject = "<a href='/nippou/boss/main?id=#{msg.post_date.strftime('%Y-%m-%d')}&user_cd=#{msg.from_user_cd}' title='#{msg.body}'>#{msg.subject}</a>"
      end
      #得意先情報の追加のお知らせ
      #ヘルパーでやってる
      if msg.kbn == 3
        msg.subject = "<a href='/bbs/bbs/topic?bid=#{msg.params}' title='#{msg.body}'>#{msg.subject}</a>"
      end

      @msgs << msg

      if i >= 10    #とりあえず10件までということで
        break
      end
    }

#    @pages, @items = paginate_by_sql(:en_d_messages, @sql, 5)
  end



end
