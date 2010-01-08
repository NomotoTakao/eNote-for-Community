require 'digest/md5'

class Notice::MainController < ApplicationController
  layout "portal", :except => [:notice_list_tab, :notice_create_tab, :notice_settings_tab, :notice_list_right, :add_list, :delete_file,
                   :create, :public_org, :notice_index, :notice_list, :notice_create, :notice_settings, :search_member, :setting]

  ADMIN_USER_CD = "9999999"

  #
  # INDEXアクション
  #
  def index
    #パンくずリストに表示させる
    @pankuzu += "お知らせ"

    # メニューから呼ばれた時には、このパラメータで表示カテゴリを取得する。
    @id = params[:id]
    @message_id_def = params[:message_id_def]
    @category_id = @id

    conditions_sql = ""
    conditions_param = {}
    joins_sql = ""
    order_sql = ""

    joins_sql = " INNER JOIN d_notice_auths ON d_notice_indices.d_notice_head_id = d_notice_auths.d_notice_head_id "

    conditions_sql = " d_notice_indices.delf = :delf "
    conditions_sql += " AND d_notice_auths.delf = :delf "
    conditions_param[:delf] = "0"
    conditions_sql += " AND (d_notice_auths.org_cd = :org_cd OR d_notice_auths.user_cd = :user_cd OR d_notice_auths.org_cd = '0') "
    #conditions_param[:org_cd] = current_m_user.org_cd
    conditions_param[:org_cd] = (MUserBelong.new.get_main_org current_m_user.user_cd).org_cd
    conditions_param[:user_cd] = current_m_user.user_cd

    order_sql = " d_notice_indices.id ASC"

    @notice_index = DNoticeIndex.find(:all, :select=>" DISTINCT d_notice_indices.* ", :joins=>joins_sql, :conditions=>[conditions_sql, conditions_param], :order=>order_sql)
    #@index_list = DNoticeIndex.new.get_list current_m_user.user_cd, current_m_user.org_cd
    #@index_list = DNoticeIndex.new.get_list current_m_user.user_cd, (MUserBelong.new.get_main_org current_m_user.user_cd).org_cd

    @index_name = "すべて"
  end

  #
  # 「お知らせ」タブが選択されたときのアクション
  #
  def notice_list_tab
    # お知らせINDEXを取得する
    @id = params[:id];
    @message_id_def = params[:message_id_def]

    #@index_list = DNoticeIndex.new.get_list current_m_user.user_cd, current_m_user.org_cd
    #@index_list = DNoticeIndex.new.get_list current_m_user.user_cd, (MUserBelong.new.get_main_org current_m_user.user_cd).org_cd
    @index_list = DNoticeIndex.get_index_list 0, current_m_user.user_cd, 1
  end

  #
  # 「新規投稿」タブが選択されたときのアクション
  #
  def notice_create_tab

  end

  #
  # 「設定」タブが選択されたときのアクション
  #
  def notice_settings_tab

  end

  #
  # お知らせ一覧を取得するメソッド
  #
  def notice_list

    id_head = params[:id]
    @message_id = params[:message_id]
    @message_id_def = params[:message_id_def]
    @order = params[:order]
    @date_from = params[:date_from]
    @date_to = params[:date_to]
    @keyword = params[:keyword]
    @owner = params[:owner]
    @hottopic_flg = params[:hottopic_flg]

    if !@order
      @order = "DESC"
    end

    # お知らせ一覧の取得
    select_sql = " DISTINCT d_notice_bodies.* "
    conditions_sql = ""
    conditions_param = {}
    joins_sql = ""
    
    joins_sql = " INNER JOIN d_notice_heads ON d_notice_heads.id = d_notice_bodies.d_notice_head_id "
    joins_sql += " INNER JOIN d_notice_public_orgs ON d_notice_bodies.id = d_notice_public_orgs.d_notice_body_id "
    joins_sql += " LEFT JOIN d_notice_files ON d_notice_bodies.id = d_notice_files.d_notice_body_id "
    
    # 削除フラグを確認する。
    conditions_sql = " d_notice_bodies.delf = :delf "
    conditions_sql += " AND d_notice_heads.delf = :delf "
    conditions_sql += " AND d_notice_public_orgs.delf = :delf "
    # 添付ファイルはファイル単位で削除できるので、削除フラグの条件からは除外する。
    #conditions_sql += " AND d_notice_files.delf = :delf "
    conditions_param[:delf] = '0'
    unless @message_id_def.nil?
      conditions_sql += " AND d_notice_bodies.id = :body_id"
      conditions_param[:body_id] = @message_id_def
    end
    # 自分の投稿のみを検索するかどうか。
    if @owner == "on"
      conditions_sql += " AND d_notice_bodies.post_user_cd = :post_user_cd "
      conditions_param[:post_user_cd] = current_m_user.user_cd
    end
    # ログインユーザの所属する組織の組織コードが公開対象組織になっているかを確認する。
    conditions_sql += " AND (d_notice_public_orgs.org_cd = '0' "
    user_org_list = MUserBelong.new.get_belong_org current_m_user.user_cd
    # 複数組織に所属するときは、そのすべてに対して閲覧が可能
    user_org_list.each do |user_org|
      # ※ ツリーで指示できる組織の階層に、ユーザーの所属組織コードを合わせている。
      user_org_cd = user_org.org_cd
      if user_org_cd.length > 6
        user_org_cd = user_org_cd[0...6]
      end
      #conditions_sql += " OR d_notice_public_orgs.org_cd = ':public_org_cd' "
      conditions_sql += " OR d_notice_public_orgs.org_cd = SUBSTR(':public_org_cd', 0, LENGTH(d_notice_public_orgs.org_cd) + 1) "
      conditions_sql.gsub!(":public_org_cd", user_org_cd)
    end
    conditions_sql += " OR d_notice_public_orgs.etcstr1 = :user_cd "
    conditions_sql += "  OR d_notice_public_orgs.created_user_cd = :user_cd)"
    conditions_param[:user_cd] = current_m_user.user_cd
    # 公開前ではないかをチェック(但し、投稿者については公開期間を考慮しない。)
    conditions_sql += " AND (d_notice_bodies.public_date_from <= cast(:public_date_from as date) OR d_notice_bodies.public_date_from ISNULL OR d_notice_bodies.post_user_cd = :post_user_cd) "
    conditions_param[:public_date_from] = Time.now
    # 公開終了でないかをチェック(但し、投稿者については公開期間を考慮しない。)
    conditions_sql += " AND (d_notice_bodies.public_date_to >= cast(:public_date_to as date) OR d_notice_bodies.public_date_to ISNULL OR d_notice_bodies.post_user_cd = :post_user_cd ) "
    conditions_param[:public_date_to] = Time.now
    conditions_param[:post_user_cd] = current_m_user.user_cd

    conditions_sql += " AND (d_notice_bodies.public_flg = 0 OR (d_notice_bodies.public_flg = 1 AND d_notice_bodies.post_user_cd = cast(:post_user_cd as varchar)))"
    conditions_param[:post_user_cd] = current_m_user.user_cd

    if @hottopic_flg and @hottopic != ""
      conditions_sql += " AND d_notice_bodies.hottopic_flg = :hottopic_flg"
      conditions_param[:hottopic_flg] = @hottopic_flg
    end

    if @date_from and @date_from != ""
      conditions_sql += " AND cast(d_notice_bodies.post_date as date) >= :post_date_from "
      conditions_param[:post_date_from] = @date_from
    end

    if @date_to and @date_to != ""
      conditions_sql += " AND cast(d_notice_bodies.post_date as date) <= :post_date_to "
      conditions_param[:post_date_to] = @date_to
    end

    if @keyword and @keyword != ""
      conditions_sql += " AND (d_notice_bodies.body like :body OR d_notice_bodies.title like :body OR d_notice_bodies.meta_tag like :body)"
      conditions_param[:body] = "%" + @keyword + "%"
    end

    unless id_head.nil? or id_head.empty?
      #notice_head = DNoticeHead.new.get_by_id id_head, current_m_user.user_cd, current_m_user.org_cd
      notice_head = DNoticeHead.new.get_by_id id_head, current_m_user.user_cd, (MUserBelong.new.get_main_org current_m_user.user_cd).org_cd
      @index_name = notice_head.title
      @index_id = notice_head.id
      conditions_sql += " AND d_notice_bodies.d_notice_head_id = :d_notice_head_id "
      conditions_param[:d_notice_head_id] = @index_id
    else
      @index_name = "すべて"
    end


    if @hottopic_flg == "0"
      @index_name = "ホットトピック"
    end

    # 組織名の取得
    @orgs = {}
    @orgs = MOrg.new.get_hash_cd_and_name
    @users = {}
    MUser.find(:all).each do |user|
      @users[user.user_cd] = MUserBelong.new.get_main_org current_m_user.user_cd
    end

    m_notice_setting = MNoticeSetting.find(:all)
    @notice_list = DNoticeBody.paginate(:page => params[:page], :per_page => m_notice_setting[0]["page_max_count"], :select=>select_sql, :joins=>joins_sql, :conditions=>[conditions_sql, conditions_param], :order=>'post_date ' + @order)
  end

  #
  # 新規投稿を記録するメソッド
  #
  def create

    edit_id = params[:d_notice_body][:id]
    board_id = params[:d_notice_body][:d_notice_head_id]
    selected_public_orgs = params[:selected_public_org_list]
    deleted_public_orgs = params[:deleted_public_org_list]
    public_orgs_list = ""
    delete_orgs_list = ""

    unless selected_public_orgs.to_s.empty?
      selected_public_orgs.gsub!("_", "")
      public_orgs_list = selected_public_orgs.split(",")
    end
    unless deleted_public_orgs.empty?
      deleted_public_orgs.gsub!("_", "")
      delete_orgs_list = deleted_public_orgs.split(",")
    end

    top_disp_kbn = params[:d_notice_body][:top_disp_kbn]
    if top_disp_kbn == "6"
      top_disp_kbn = "99"
    end

    unless edit_id.nil? or edit_id.empty?

      d_notice_body = DNoticeBody.find(:first, :conditions=>{:delf=>0, :id=>edit_id})
      
      d_notice_body.d_notice_head_id = params[:d_notice_body][:d_notice_head_id]
      d_notice_body.title = params[:d_notice_body][:title]
      d_notice_body.body = params[:d_notice_body][:body]
      d_notice_body.public_date_from = params[:d_notice_body][:public_date_from]
      d_notice_body.public_date_to = params[:d_notice_body][:public_date_to]
      d_notice_body.public_flg = params[:d_notice_body][:public_flg]
      d_notice_body.top_disp_kbn = top_disp_kbn.to_i
      d_notice_body.hottopic_flg = params[:d_notice_body][:hottopic_flg]
      d_notice_body.meta_tag = params[:d_notice_body][:meta_tag]
      d_notice_body.updated_user_cd = current_m_user.user_cd
    else

      d_notice_body = DNoticeBody.new(params[:d_notice_body])
      d_notice_body.post_org_cd = (MUserBelong.new.get_main_org current_m_user.user_cd).org_cd
      d_notice_body.post_user_cd = current_m_user.user_cd
      d_notice_body.post_user_name = current_m_user.name
      d_notice_body.post_date = Time.new
      d_notice_body.created_user_cd = current_m_user.user_cd
      d_notice_body.updated_user_cd = current_m_user.user_cd
    end

    begin
      d_notice_body.save!
      # 除外された公開対象組織
      if delete_orgs_list.length > 0
        delete_orgs_list.each do |code_d|

          DNoticePublicOrg.new.delete_public_org d_notice_body.id, code_d, current_m_user.user_cd
        end
      end
      # 公開対象組織を登録する。
      public_orgs_list.each do |code_p|
        if edit_id.nil? or edit_id.empty?
          begin
            DNoticePublicOrg.new.create_public_org d_notice_body.id, code_p, current_m_user.user_cd
          rescue
            # 保存エラー
#p $!
          end
        else
          conditions_sql = ""
          conditions_param = Hash.new

          conditions_sql = " delf = :delf "
          conditions_param[:delf] = "0"
          conditions_sql += " AND d_notice_body_id = :id "
          conditions_param[:id] = d_notice_body.id
          conditions_sql += " AND org_cd = :public_org_cd "
          conditions_param[:public_org_cd] = code_p

          d_notice_public_org = DNoticePublicOrg.find(:all, :conditions=>[conditions_sql, conditions_param])
          if d_notice_public_org.length == 0
            begin
              # 公開対象組織を追加するとき
              DNoticePublicOrg.new.create_public_org d_notice_body.id, code_p, current_m_user.user_cd
            rescue
              # 保存エラー
            end
          else
            d_notice_public_org.each do |record|
              record.updated_user_cd = current_m_user.user_cd
              record.updated_at = Time.now
              record.save
            end
          end
        end
      end
    rescue
      # 保存エラー
#p "★" + $!
#      redirect_to :action => 'notice_create'
    end

    # 添付ファイルの保存
    attachment = params[:attachment]
    next_page = ""
    unless attachment.nil?
      begin
        DNoticeFile.save_upload(params, current_m_user, board_id, d_notice_body.id)
        next_page = "alert('アップロードが完了しました');location.href='/notice/main/index';"
      else
        # 保存エラー
      end
    else
      next_page = "location.href='/notice/main/index'"
    end

    responds_to_parent do
      render :update do |page|
        page << next_page
      end
    end


  end

  #
  # 編集ボタンが押下されたときのアクション
  #
  def edit
    # 編集
    message_id = params[:message_id]

    redirect_to :action => "notice_list", :message_id => message_id
  end

  #
  # 削除ボタンが押下されたときのアクション
  #
  def delete
    message_id = params[:message_id]

    unless message_id.empty?
      DNoticeBody.new.delete_body_by_id message_id, current_m_user.user_cd
    end

    redirect_to :action => 'notice_list'
  end

  #
  # 新規投稿タブを構成する情報を取得するメソッド
  #
  def notice_create
    # 編集の時はメッセージIDを受け取る。
    message_id = params[:message_id]
    if message_id == ""
      @d_notice_body = DNoticeBody.new
    else
      @d_notice_body = DNoticeBody.new.get_body_by_id message_id
    end
    @tab_index = params[:tab_index]
#    @notice_heads = DNoticeHead.find(:all, :order=>"id")
#    @notice_heads = DNoticeIndex.get_select_board_list current_m_user.user_cd
    @d_notice_indices = DNoticeIndex.get_select_board_list current_m_user.user_cd

    # 公開対象組織の一覧を取得
    @m_orgs = MOrg.new.get_public_orgs

    @org_table = MOrg.new.get_hash_cd_and_name

    # お知らせボード選択に表示する項目を判断するための情報を取得
    #@auths = DNoticeAuth.new.get_hash_headid_and_orgcd current_m_user.user_cd, current_m_user.org_cd
    @auths = DNoticeAuth.new.get_hash_headid_and_orgcd current_m_user.user_cd, (MUserBelong.new.get_main_org current_m_user.user_cd).org_cd

    # 区分マスタから情報を取得
    # TOP表示区分
    @notice_bodies_top_disp_kbn = MKbn.get_notice_bodies_top_disp_kbn current_m_user.user_cd

    # ホットトピック
    @hot_topic_kbn = MKbn.get_hot_topic_kbn

    if message_id.nil? or message_id.empty?
      @d_notice_body = DNoticeBody.new
    else
      @d_notice_body = DNoticeBody.new.get_body_by_id message_id
    end

    unless @d_notice_body.nil?
      if @d_notice_body.public_date_from.nil?
        @d_notice_body.public_date_from = Date.today
      end
      if @d_notice_body.public_date_to.nil?
        @d_notice_body.public_date_to = Date.today + 14
      end
    end

  end

  #
  # 設定タブを構成する情報を取得するメソッド
  #
  def notice_settings

    conditions_sql = ""
    conditions_param = {}
    order_sql = ""

    conditions_sql = " delf = :delf"
    conditions_param[:delf] = "0"
    conditions_sql += " AND d_notice_head_id != :d_notice_head_id "
    conditions_param[:d_notice_head_id] = "0"
    order_sql = " id ASC "
    @board_list = DNoticeIndex.find(:all, :conditions=>[conditions_sql, conditions_param], :order=>order_sql)

    conditions_sql = " delf = :delf "
    conditions_param[:delf] = "0"
    order_sql = " org_cd ASC "
    @org_list = MOrg.find(:all, :conditions=>[conditions_sql, conditions_param], :order=>order_sql)
  end

  def download
    file_rec = DNoticeFile.find(params[:id])

    dirname = "#{RAILS_ROOT}/data/notice"

    send_file dirname + file_rec.real_file_name, :filename => file_rec.file_name  #, :type => file_rec.mime_type
  end


  def search_member

    conditions_sql = ""
    conditions_param = {}
    order_sql = ""
    org_cd = params[:org_cd]

    conditions_sql = " delf = :delf "
    conditions_param[:delf] = "0"

    # org_cdが"0"の場合は「全社」なので、組織コードを検索条件に含めない。
    if org_cd != "0"
      conditions_sql += " AND org_cd = :org_cd "
      conditions_param[:org_cd] = org_cd
    end

    order_sql = " user_cd asc "

    @member_list = MUser.find(:all, :conditions=>[conditions_sql, conditions_param], :order=>order_sql)

    render :action=>"_member_list"
  end

  #
  # 「設定」タブで選択した権限の設定をデータベースに書き込みます。
  #
  def setting

    array_member_cd = params[:add_array][0].split(",")
    board_id = params[:board_list];

    array_member_cd.each do |cd|
      unless cd.empty?
        d_notice_auth = DNoticeAuth.new
        d_notice_auth.d_notice_head_id = board_id
        # 権限を付与する対象を特定するため、ビューでIDに接頭辞を付けてから送信されています。
        # "p"(personal)がついていればuser_cd、"o"(organization)がついていればorg_cdです。
        if cd[0, 1] == "p"
          d_notice_auth.user_cd = cd.gsub("p", "")
        elsif cd[0, 1] == "o"
          d_notice_auth.org_cd = cd.gsub("o", "")
        end
        d_notice_auth.auth_kbn = "2" #TODO 権限：0,1,2の選択方法が未定
        d_notice_auth.created_user_cd = current_m_user.user_cd
        d_notice_auth.updated_user_cd = current_m_user.user_cd

        begin
          d_notice_auth.save
        rescue
         # 保存エラー
        end
      end
    end

    redirect_to :action=>:index
  end

  #
  # 設定タブの右側のセレクトボックスの内容を更新するアクション
  #
  # @param id - お知らせヘッダID
  #
  def add_list

    notice_head_id = params[:notice_head_id]

    # 組織マスタより、組織CDと組織名のハッシュテーブルを取得する
    @orgs = MOrg.new.get_hash_cd_and_name
    # ユーザーマスタより、ユーザーCDと名前のハッシュテーブルを取得する。
    @users = MUser.new.get_hash_cd_and_name
    # お知らせ権限マスタより、お知らせヘッダIDをキーにした組織CD、ユーザーCDのハッシュテーブルを取得する。
    @auths = DNoticeAuth.new.get_hash_noticehead_id_and_orgcd_usercd notice_head_id

    render :action=>"_add_list"
  end

  #
  # 添付ファイルのアイコンがクリックされた時のアクション
  #
  def download

    file_id = params[:id]

    file_rec = DNoticeFile.new.find_by_id file_id

    dirname = "#{RAILS_ROOT}/data/notice/"

    send_file dirname + file_rec.real_file_name, :filename => file_rec.file_name.tosjis
  end

  #
  # 添付ファイル名の右端の[×]アンカーがクリックされた時のアクション
  #
  def delete_file

    body_id = params[:body_id]
    file_id = params[:file_id]

    DNoticeFile.new.delete_by_id file_id, current_m_user.user_cd

    @d_notice_body = DNoticeBody.new.get_body_by_id body_id

    render :action=>"_attachment_file"
  end

  #
  # ホットトピック一覧を表示する。
  #
  def hottopic
    @index_name = "ホットトピック"
  end

end
