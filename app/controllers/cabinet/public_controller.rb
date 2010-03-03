class Cabinet::PublicController < ApplicationController
  layout "portal", :except=>[:cabinet_list_tab, :cabinet_list, :cabinet_detail, :cabinet_create_tab, :cabinet_create, :create, :dialog, :confirm_cabinet,
                             :download, :create_cabine, :edit, :delete, :cabinet_settings_tab, :create_cabinet, :edit_cabinet, :delete_cabinet,
                             :public_cabinet, :company_cabinet, :sectional_cabinet, :project_cabinet, :tmp_list, :tmp_list2, :delete_file, :settings, :settings_finish]

  #
  #
  #
  def index
    #パンくずリストに表示させる
    @pankuzu += "共有キャビネット"
    @auto = params[:auto]
  end

  #
  # キャビネットのタブが押下された時のアクション
  #
  def cabinet_list_tab #DEBUG
    # 画面左のツリーに必要なデータを取得
    # 全社キャビネット
    @company_cabinet_indices = DCabinetIndex.get_cabinet_indices 1, 0, 1, current_m_user.user_cd
    # 部内キャビネット
    @sectional_cabinet_indices = DCabinetIndex.get_cabinet_indices -1, 0, 1, current_m_user.user_cd
    # プロジェクトキャビネット
    @project_cabinet_indices = DCabinetIndex.get_cabinet_indices 3, 0, 1, current_m_user.user_cd
  end

  #
  # キャビネット一覧を取得する処理
  #
  def cabinet_list

    @cabinet_id = params[:cabinet_id]

    @edit_id = params[:edit_id]

    @cabinet_kbn = params[:cabinet_kbn]

    @m_cabinet_setting = MCabinetSetting.new.get_cabinet_settings

#    select_sql = " DISTINCT d_cabinet_bodies.* "
#    joins_sql = ""
#    conditions_sql = ""
#    conditions_param = Hash.new
    order_sql = ""

    @index_id = params[:id]
    order = params[:order]
    mode = params[:mode]

    if order.nil?
      order = "updated_at"
    end
    order_sql = order

    if mode.nil? or mode.empty? or mode == "1"
      order_sql += " DESC"
      next_mode = "2"
    else
      order_sql += " ASC"
      next_mode = "1"
    end

    if order == "title"
      @title_next = next_mode
    elsif order == "updated_at"
      @updated_at_next = next_mode
    elsif order == "post_org_cd"
      @post_org_cd_next = next_mode
    elsif order == "post_user_name"
      @post_user_name_next = next_mode
    end

    @cabinet_list = DCabinetBody.get_cabinet_bodies(params[:page],
                                                    @m_cabinet_setting.page_max_count,
                                                    @cabinet_kbn,
                                                    params[:cabinet_id],
                                                    current_m_user.user_cd,
                                                    params[:date_from],
                                                    params[:date_to],
                                                    params[:keyword],
                                                    order,
                                                    mode,
                                                    nil)
  end

  #
  # キャビネット一覧でタイトルが押下されたときのアクション
  #
  def cabinet_detail

    @orgs = {}

    body_id = params[:id]
    @cabinet_detail = DCabinetBody.find(:first, :conditions=>{:delf=>0, :id=>body_id})
    @cabinet_file = DCabinetFile.new.get_cabinetfile_by_cabinet_body_id body_id

    @orgs = MOrg.new.get_hash_cd_and_name
  end

  #
  # 新規保存タブが押下された時のアクション
  #
  def cabinet_create_tab

  end

  #
  # 新規保存タブの表示内容を取得します。
  #
  def cabinet_create
    edit_id = params[:edit_id]

    if edit_id.empty?
      @d_cabinet_body = DCabinetBody.new
    else
      @d_cabinet_body = DCabinetBody.find(:first, :conditions=>{:delf=>0, :id=>edit_id})
    end

    @auths = {}

    #@cabinet_indices = DCabinetIndex.new.get_cabinet_indices
    @company_cabinet_indices_list = DCabinetIndex.get_cabinet_indices 1, 0, 2, current_m_user.user_cd
    @project_cabinet_indices_list = DCabinetIndex.get_cabinet_indices 2, 0, 2, current_m_user.user_cd
    @sectional_cabinet_indices_list = DCabinetIndex.get_cabinet_indices -1, 0, 2, current_m_user.user_cd

    @sectional_cabinet = DCabinetIndex.get_cabinet_indices -1, 0, 2, current_m_user.user_cd

    @auths = DCabinetAuth.new.get_hash_id_and_kbn current_m_user.user_cd, (MUserBelong.new.get_main_org current_m_user.user_cd).org_cd

    @belongs = MUserBelong.new.get_belong_org current_m_user.user_cd

    @morgs = MOrg.new.get_hash_cd_and_name
    @m_orgs = MOrg.new.get_public_orgs
  end

  #
  # キャビネットを新規登録するアクション
  #
  def create

    # 公開対象組織CD(CSV形式)
    select_orgs = params[:selected_public_org_list]
    delete_orgs = params[:deleted_public_org_list]
    public_org_list = ""
    delete_org_list = ""

    unless select_orgs.empty?
      select_orgs.gsub!("_", "")
      public_org_list = select_orgs.split(",")
    end

    unless delete_orgs.empty?
      delete_orgs.gsub!("_", "")
      delete_org_list = delete_orgs.split(",")
    end

    head_id = params[:d_cabinet_body][:d_cabinet_head_id]
    body_id = params[:d_cabinet_body][:id]

    cabinet_head = DCabinetHead.find(:first, :conditions=>{:delf=>0, :id=>head_id})

    # 保存するキャビネットに、「部内キャビネット」「プロジェクト」が選択された場合は公開対象組織は選択されない。
    # d_cabinet_headsテーブルのprivate_org_cdテーブルの値を代用する。
    if public_org_list.empty? and cabinet_head.cabinet_kbn == 2
      public_org_list << cabinet_head.private_org_cd
    end


    if body_id.empty?
      cabinet_body = DCabinetBody.new(params[:d_cabinet_body])

      cabinet_body.post_org_cd = (MUserBelong.new.get_main_org current_m_user.user_cd).org_cd
      cabinet_body.post_user_cd = current_m_user.user_cd
      cabinet_body.post_user_name = current_m_user.name
      cabinet_body.post_date = Time.now

      cabinet_body.created_user_cd = current_m_user.user_cd
      cabinet_body.created_at = Time.now

      cabinet_body.updated_user_cd = current_m_user.user_cd
      cabinet_body.updated_at = Time.now
    else
      # 既存ファイルの取得
      cabinet_body = DCabinetBody.find(:first, :conditions=>{:delf=>0, :id=>body_id})

      cabinet_body.d_cabinet_head_id = params[:d_cabinet_body][:d_cabinet_head_id]
      cabinet_body.title = params[:d_cabinet_body][:title]
      cabinet_body.body = params[:d_cabinet_body][:body]
      cabinet_body.post_user_name = current_m_user.name
      cabinet_body.post_date = Time.now
      cabinet_body.public_org_cd = params[:d_cabinet_body][:public_org_cd]
      cabinet_body.public_flg = params[:d_cabinet_body][:public_flg]
      cabinet_body.public_date_from = params[:d_cabinet_body][:public_date_from]
      cabinet_body.public_date_to = params[:d_cabinet_body][:public_date_to]
      cabinet_body.meta_tag = params[:d_cabinet_body][:meta_tag]
      cabinet_body.updated_user_cd = current_m_user.user_cd
      cabinet_body.updated_at = Time.now
    end

    begin
      cabinet_body.save

      # 公開対象組織を登録
      if public_org_list.length > 0
        public_org_list.each do |org_cd|
          if body_id.empty?
            begin
              DCabinetPublicOrg.new.create_public_org cabinet_body.id, org_cd, current_m_user.user_cd
            rescue
              # 保存エラー
            end
          else
            conditions_sql = ""
            conditions_param = {}

            conditions_sql = " delf = :delf "
            conditions_param[:delf] = 0
            conditions_sql += " AND d_cabinet_body_id = :body_id "
            conditions_param[:body_id] = body_id
            conditions_sql += " AND org_cd = :public_org_cd "
            conditions_param[:public_org_cd] = org_cd

            d_cabinet_public_orgs = DCabinetPublicOrg.find(:all, :conditions=>[conditions_sql, conditions_param])
            if d_cabinet_public_orgs.length == 0
              begin
                # 公開対象組織を追加するとき
                DCabinetPublicOrg.new.create_public_org cabinet_body.id, org_cd, current_m_user.user_cd
              rescue
                # 保存エラー
              end
            else
              # 既に登録されている公開対象組織のレコードを更新
              d_cabinet_public_orgs.each do |public_org|
                public_org.updated_user_cd = current_m_user.user_cd
                public_org.updated_at = Time.now
                begin
                  public_org.save
                rescue
                  # 保存エラー
                end
              end
            end
          end
        end
      end

      # 公開対象組織の削除
      if delete_org_list.length > 0
        delete_org_list.each do |org_cd|
          begin
            DCabinetPublicOrg.new.delete_public_org body_id, org_cd, current_m_user.user_cd
          rescue
            # 保存エラー
          end
        end
      end

      cabinet_head.lastpost_date = Time.now
      cabinet_head.lastpost_body_id = cabinet_body.id
      cabinet_head.save
    rescue
      # 保存エラー
    end

    # 添付ファイルの保存
    attachment = params[:attachment]
    next_page = ""
    unless attachment.nil?
      begin
        DCabinetFile.save_upload(params, current_m_user, cabinet_body.d_cabinet_head_id, cabinet_body.id, "cabinet_public")
        next_page = "alert('アップロードが完了しました');location.href='#{@base_uri}/cabinet/public/index';"
      else
        # 保存エラー
      end
    else
      next_page = "location.href='#{@base_uri}/cabinet/public/index'"
    end

    responds_to_parent do
      render :update do |page|
        page << next_page
      end
    end
  end

  #
  # 共有キャビネットの選択されたファイル情報を編集します。
  #
  def edit
    #TODO
    body_id = params[:body_id]

    redirect_to :action=>'cabinet_list', :edit_id=>body_id
  end

  #
  # 共有キャビネットから選択されたファイルを削除します。
  #
  def delete

    cabinet_kbn = params[:cabinet_kbn]
    cabinet_id = params[:cabinet_id]
    delete_id = params[:delete_id]

    unless delete_id.empty?
      DCabinetBody.new.delete_by_id delete_id, current_m_user.user_cd
    end

    redirect_to :action=>:cabinet_list, :cabinet_kbn=>cabinet_kbn, :cabinet_id=>cabinet_id
  end

  #
  # 添付されているファイルのみを削除します。
  #
  def delete_file

    body_id = params[:body_id]
    file_id = params[:file_id]

    DCabinetFile.new.delete_by_id file_id, current_m_user.user_cd

    @d_cabinet_body = DCabinetBody.find(:first, :conditions=>{:delf=>0, :id=>body_id})

    render :action=>"_attachment_file"
  end

  #
  # キャビネットの説明ダイアログを生成します。
  #
  def dialog
    cabinet_id = params[:id]

    @d_cabinet_body = DCabinetBody.new.get_cabinetbody_by_id cabinet_id
    @cabinet_file = DCabinetFile.find(:first, :conditions=>{:d_cabinet_body_id=>cabinet_id})

    # 組織名の取得 組織名と組織コードのハッシュマップを作ります。
    @orgs = {}

    @orgs = MOrg.new.get_hash_cd_and_name

    render :action=>"_dialog"
  end

  #
  # キャビネットファイルのダウンロード
  #
  def download

    cabinet_id = params[:id]

    file_rec = DCabinetFile.new.get_cabinetfile_by_id cabinet_id

    dirname = "#{RAILS_ROOT}/data/cabinet_public/"

    send_file dirname + file_rec.real_file_name, :filename => file_rec.file_name.tosjis
  end

  #
  # 部内キャビネットの下にキャビネットを作成します。
  #
  def create_cabinet

    parent_id = params[:parent_id].split("_")[1]

    # 取得したキャビネットを登録する.
    d_cabinet_head = DCabinetHead.new
    d_cabinet_head.title = params[:title]
    d_cabinet_head.private_org_cd = (DCabinetHead.new.get_cabinethead_by_id parent_id).private_org_cd
    d_cabinet_head.cabinet_kbn = 2 # 部内キャビネット
    d_cabinet_head.created_user_cd = current_m_user.user_cd
    d_cabinet_head.updated_user_cd = current_m_user.user_cd

    begin
      d_cabinet_head.save

      last_order_display = DCabinetIndex.new.get_last_order_display_by_parent_cabinet_head_id parent_id

      d_cabinet_index = DCabinetIndex.new
      d_cabinet_index.title = params['title']
      d_cabinet_index.cabinet_kbn = 2
      d_cabinet_index.index_type = "b"
      d_cabinet_index.parent_cabinet_head_id = parent_id
      d_cabinet_index.order_display = last_order_display + 1
      d_cabinet_index.d_cabinet_head_id = d_cabinet_head.id
      d_cabinet_index.created_user_cd = current_m_user.user_cd
      d_cabinet_index.updated_user_cd = current_m_user.user_cd

      d_cabinet_auth = DCabinetAuth.new
      d_cabinet_auth.auth_kbn = 2
      d_cabinet_auth.d_cabinet_head_id = d_cabinet_head.id
      d_cabinet_auth.org_cd = d_cabinet_head.private_org_cd
      #d_cabinet_auth.user_cd = "9999999"
      d_cabinet_auth.created_user_cd = current_m_user.user_cd
      d_cabinet_auth.created_user_cd = current_m_user.user_cd

      d_cabinet_index.save
      d_cabinet_auth.save
    rescue
      # 登録に失敗した場合の処理
p $!
    end

    @auths = {}

    @cabinet_indices = nil#TODO DCabinetIndex.new.get_cabinet_indices  #(MUserBelong.new.get_main_org current_m_user.user_cd).org_cd

    #@auths = DCabinetAuth.new.get_hash_id_and_kbn current_m_user.user_cd, current_m_user.org_cd
    @auths = DCabinetAuth.new.get_hash_id_and_kbn current_m_user.user_cd, (MUserBelong.new.get_main_org current_m_user.user_cd).org_cd
    # 画面遷移
    @index = "1"
    redirect_to :action=>"sectional_cabinet"
  end

  #
  # 部内キャビネットを編集する。
  #
  def edit_cabinet
    head_id = params[:head_id]
    cabinet_title = params[:title]

    # 指定されたIDのキャビネットヘッダを取得し、タイトルを変更する。
    d_cabinet_head = DCabinetHead.new.get_cabinethead_by_id head_id
    d_cabinet_head.title = cabinet_title
    d_cabinet_head.updated_user_cd = current_m_user.user_cd

    begin
      d_cabinet_head.save

      # 指定されたIDのキャビネットヘッダに関連付けされたキャビネットインデックスを取得し、名称変更する。
      d_cabinet_head.d_cabinet_index.title = cabinet_title
      d_cabinet_head.d_cabinet_index.updated_user_cd = current_m_user.user_cd
      d_cabinet_head.d_cabinet_index.save
    rescue
      # 保存エラー
    end

    redirect_to :action=>"sectional_cabinet"
  end

  #
  # 部内キャビネットを削除する。
  #
  def delete_cabinet
    head_id = params[:head_id]
    # d_cabinet_headsテーブルから指定IDのレコードを検索
    d_cabinet_head = DCabinetHead.new.get_cabinethead_by_id head_id

    #TODO ヘッドに紐づけられているbodyを削除する。
    d_cabinet_head.d_cabinet_bodies.each do |body|
      body.delete_by_id body.id, current_m_user.user_cd
    end

    # d_cabinet_headsテーブルから指定IDのレコードを削除(delf="1")
    d_cabinet_head.d_cabinet_index.delf = "1"
    d_cabinet_head.d_cabinet_index.deleted_user_cd = current_m_user.user_cd
    d_cabinet_head.d_cabinet_index.deleted_at = Time.now
    begin
      d_cabinet_head.d_cabinet_index.save
      # d_cabinet_indexテーブルから指定IDのレコードを削除(delf="1")
      d_cabinet_head.delf = "1"
      d_cabinet_head.deleted_user_cd = current_m_user.user_cd
      d_cabinet_head.deleted_at = Time.now
      d_cabinet_head.save
    rescue
      # 保存エラー
    end

    redirect_to :action=>"sectional_cabinet"
  end

  #
  # 「保存するキャビネットの選択」の内容を更新します。
  #
  #
  #
  def public_cabinet

    kbn_id = params[:cabinet_kbn]
    @cabinet_list = DCabinetIndex.new.get_cabinet_list_by_kbn kbn_id

    render :action=>"_cabinet_list"
  end

  #
  # 保存するキャビネットの種類で、「全社」が選択された時のアクション
  #
  # @return ツリー表示するキャビネットのリスト
  #
  def company_cabinet
    @select = params[:select]
    @cabinet_list = DCabinetIndex.new.get_cabinet_list_by_kbn 1
  end

  #
  # 保存するキャビネットの種類で「部内キャビネット」が選択された時のアクション
  #
  # @return ツリーに表示するキャビネットのリスト
  #
  def sectional_cabinet
    org_cd = (MUserBelong.new.get_main_org current_m_user.user_cd).org_cd
    @select = params[:select]

    @cabinet_list = DCabinetIndex.get_cabinet_indices(-1, 0, 2, current_m_user.user_cd)
  end

  #
  # 保存するキャビネットの種類で「プロジェクト」が選択された時のアクション
  #
  # @return ツリーに表示するキャビネットのリスト
  #
  def project_cabinet
    @select = params[:select]
    @project_cabinet_list = MProject.get_project_all_enable_list Date.today
  end

  # 「キャビネット」タブの「共有キャビネット」の中のツリーを取得します。
  def tmp_list

    tmp_kbn = params[:kbn]
    tmp_id = params[:id]
    org_cd = params[:org_cd]
    auth = params[:auth]

    if tmp_kbn == "1"
      # 全社キャビネットを取得する。
      #      @cabinet_list = DCabinetIndex.new.get_cabinet_list_by_kbn 1
#      @cabinet_list = DCabinetIndex.get_cabinet_list(tmp_kbn, tmp_id)
       @cabinet_list = DCabinetIndex.get_cabinet_indices(tmp_kbn, nil, auth, current_m_user.user_cd)
    elsif tmp_kbn == "3"
      # プロジェクトを取得する。
#      @project_cabinet_list = MProject.get_project_all_enable_list Date.today
      @cabinet_list = DCabinetIndex.new.get_cabinet_list_by_kbn 3
    else
      # 部内キャビネットを取得する。
      @cabinet_list = DCabinetIndex.get_cabinet_indices 2, tmp_id, 2, current_m_user.user_cd
    end

    unless org_cd.nil?
      # 部内キャビネットのうち、管理組織コードがorg_cdと一致するものを抽出
      @cabinet_list = DCabinetIndex.new.get_sectional_cabinet_list current_m_user.user_cd
    end
  end

  # 「新規保存」タブの「保存するキャビネットの選択」の中のツリーを取得します。
  def tmp_list2

    tmp_kbn = params[:kbn]
    org_cd = params[:org_cd]

    if tmp_kbn == "1"
      @cabinet_list = DCabinetIndex.new.get_cabinet_list_by_kbn 1
      #    elsif tmp_kbn == "2"
      #      @morgs = MOrg.new.get_hash_cd_and_name
      #      @org_list = MUserBelong.new.get_belong_org_info_for_cabinet current_m_user.user_cd
    elsif tmp_kbn == "3"
      @cabinet_list = DCabinetIndex.new.get_cabinet_list_by_kbn 3
    else
      @cabinet_list = DCabinetIndex.new.get_child_cabinet_list tmp_kbn
    end

    unless org_cd.nil?
      # 部内キャビネットのうち、管理組織コードがorg_cdと一致するものを抽出
      @cabinet_list = DCabinetIndex.new.get_sectional_cabinet_list current_m_user.user_cd
    end
  end

  #
  # 設定画面を呼び出すときのアクション
  #
  def settings
    @org_list = MOrg.new.get_public_orgs
  end

  #
  # 設定内容を確定するときのアクション
  #
  def settings_finish
    authorities = params[:authority]
    authorities.each do |key, authority|
      # 共有キャビネットの書き込み権限を与える
      p authority
      DCabinetHead.new.create_authority authority, current_m_user.user_cd
    end

    redirect_to :action=>:index
  end

  #
  # 部内キャビネットを削除する前のアクション
  # 削除対象のキャビネットが要素をもっていないかをチェックする。
  #
  def confirm_cabinet

    head_id = params[:head_id]

    @d_cabinet_bodies_list = DCabinetBody.get_cabinet_bodies_list head_id
  end
end
