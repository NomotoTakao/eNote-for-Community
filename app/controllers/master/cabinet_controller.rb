class Master::CabinetController < ApplicationController
  layout "portal",
  :except=>[:common_tab, :mine_tab, :sectional_tab, :company_tab, :company_cabinet_list, :edit_company_cabinet, :detail_company_cabinet, :tree_org, :undecided_member, :user_list, :_mine_info, :save_mine_info, :_common_info]

  def index
    @pankuzu += "キャビネット設定"
    @result = params[:result]
  end

  #
  # 共通タブを開く
  #
  def common_tab
    # _common_info.html.erbはパーシャルファイルなので、タブ切り替え時には_common_infoアクションは呼び出されない。
    # タブ切り替え時には初期情報はcommon_tabアクションで取得する。
    @m_cabinet_settings = MCabinetSetting.find(:first, :conditions=>{:delf=>0})
  end

  #
  # Webメモリタブを開く
  #
  def mine_tab

  end

  #
  # 部内キャビネットタブを開く
  #
  def sectional_tab
    #TODO 共有キャビネットがある組織を選択
    @section_list = DCabinetHead.get_sectional_cabinet_section
    @org_list = MOrg.new.get_public_orgs
  end

  #
  # 部内キャビネットタブの内容を保存する
  #
  def sectional_setting

    selected_org_list = params[:selected_org_list][0].gsub("_", "")
    deleted_org_list = params[:deleted_org_list][0].gsub("_", "")

    unless selected_org_list.empty?
      selected_org_list = selected_org_list.split(",")
    end

    unless deleted_org_list.empty?
      deleted_org_list = deleted_org_list.split(",")
    end

    begin
      selected_org_list.each do |org_cd|
        # 共有キャビネットの書き込み権限を与える
        DCabinetHead.create_authority org_cd, current_m_user.user_cd
      end

      not_delete_org_name = ""  #削除不可能なキャビネットの組織名称
      deleted_org_list.each do |org_cd|
        # 共有キャビネットの書き込み権限を削除する。
        not_delete_org_cd = DCabinetHead.delete_authority org_cd, current_m_user.user_cd

        # 削除できないキャビネットが存在した場合
        if not_delete_org_cd != ""
          #組織名称取得
          org_name = MOrg.get_org_name not_delete_org_cd
          not_delete_org_name = not_delete_org_name + org_name + " "
        end
      end
      result = 1
    end

    #エラー文言設定
    if not_delete_org_name != ""
      err_msg = not_delete_org_name + "は下階層にフォルダが存在する為、削除できませんでした。"
      flash[:sectional_cabinet_err_msg] = err_msg
      redirect_to :action=>:index
      return
    end

    redirect_to :action=>:index, :result=>result
  end

  #
  # 全社キャビネットタブを開く
  #
  def company_tab
    #1階層目のデータを取得する
    @first_cabinet_list = DCabinetIndex.get_company_cabinet_list 0
  end

  #
  # 該当の全社キャビネットデータを取得する
  # 1,2階層のデータをクリックした際に次の階層データを取得する
  #
  def company_cabinet_list
    parent_id = params[:parent_id].to_i
    @target_level = params[:target_level].to_i
    if @target_level == 2
      #2階層目のデータを取得する
      @second_cabinet_list = DCabinetIndex.get_company_cabinet_list parent_id
    elsif @target_level == 3
      #3階層目のデータを取得する
      @third_cabinet_list = DCabinetIndex.get_company_cabinet_list parent_id
    end
  end

  #
  # 編集キャビネットの階層データを取得する(階層データ全て)
  #
  def edit_company_cabinet
    parent_id = params[:parent_id].to_i
    if parent_id == 0
      @parent_index_type = "f"
    else
      parent_index_data = DCabinetIndex.get_cabinetindex_by_head_id parent_id
      @parent_index_type = parent_index_data.index_type
    end
    @edit_cabinet_list = DCabinetIndex.get_company_cabinet_list parent_id
  end

  #
  # 編集キャビネットの詳細情報を取得する(該当データ1件のみ)
  #
  def detail_company_cabinet
    @head_id = params[:head_id].to_i #編集するデータのhead_id
    #キャビネットインデックス
    @target_cabinet_data = DCabinetIndex.find(:first, :conditions=>["d_cabinet_head_id = ? and delf = ?", @head_id, 0])
    #キャビネット権限データ
    @org_auth_decide_r = DCabinetAuth.get_cabinet_auth_list @head_id, 1, 0   #参照可能組織
    @user_auth_decide_r = DCabinetAuth.get_cabinet_auth_list @head_id, 1, 1  #参照可能社員
    @org_auth_decide_w = DCabinetAuth.get_cabinet_auth_list @head_id, 2, 0   #書き込み可能組織
    @user_auth_decide_w = DCabinetAuth.get_cabinet_auth_list @head_id, 2, 1  #書き込み可能社員
  end

  #
  # 全社キャビネットタブの内容を保存する
  #
  def save_company_cabinet
    begin
      submit_flg = params[:submit_flg].to_i  #1:登録,2:更新,3:削除
      head_id = params[:head_id].to_i #ヘッダID(更新,削除の場合のみ値が入っている)

      #** データチェック **
      #更新の場合
      if submit_flg == 2
        err_msg = "更新しようとしたキャビネットの下階層にデータが存在する為、階層を変更できません。"
        index_type_old = params[:index_type_old]
        index_type_new = params[:index_type]

        #index_typeをfからbに変更する場合
        if index_type_old == "f" and index_type_new == "b"
          #更新するキャビネットを親とするデータがないかチェック
          child_data = DCabinetIndex.find(:all, :conditions=>["parent_cabinet_head_id = ? and delf = ?", head_id, 0])
          if !child_data.nil? && child_data.size > 0
            flash[:company_cabinet_err_msg] = err_msg
            redirect_to :action=>:index
            return
          end

        #index_typeをbからfに変更する場合
        #更新するキャビネットに登録しているデータがないかチェック
        elsif index_type_old == "b" and index_type_new == "f"
          body_data = DCabinetBody.find(:all, :conditions=>["d_cabinet_head_id = ? and delf = ?", head_id, 0])
          if !body_data.nil? && body_data.size > 0
            flash[:company_cabinet_err_msg] = err_msg
            redirect_to :action=>:index
            return
          end
        end

      #削除の場合
      elsif submit_flg == 3
        err_msg = "削除しようとしたキャビネットの下階層にデータが存在する為、削除できませんでした。"

        #削除するキャビネットを親とするデータがないかチェック
        child_data = DCabinetIndex.find(:all, :conditions=>["parent_cabinet_head_id = ? and delf = ?", head_id, 0])
        if !child_data.nil? && child_data.size > 0
          flash[:company_cabinet_err_msg] = err_msg
          redirect_to :action=>:index
          return
        end
        #削除するキャビネットに登録しているデータがないかチェック
        body_data = DCabinetBody.find(:all, :conditions=>["d_cabinet_head_id = ? and delf = ?", head_id, 0])
        if !body_data.nil? && body_data.size > 0
          flash[:company_cabinet_err_msg] = err_msg
          redirect_to :action=>:index
          return
        end
      end

      #** データ登録 **
      #キャビネットヘッダ
      if submit_flg == 3  #削除
        DCabinetHead.update_all("delf=1, deleted_user_cd='#{current_m_user.user_cd}', deleted_at=current_date", ["id = ?", head_id])
      else
        if submit_flg == 1  #登録
          m_cabinet = DCabinetHead.new
        elsif submit_flg == 2 #更新
          m_cabinet = DCabinetHead.find(:first, :conditions=>["id = ? and delf = ?", head_id, 0])
        end
        m_cabinet.title = params[:target_cabinet_data][:title]
        m_cabinet.cabinet_kbn = 1
        m_cabinet.created_user_cd = current_m_user.user_cd
        m_cabinet.updated_user_cd = current_m_user.user_cd
        m_cabinet.save!
        head_id = m_cabinet.id  #ヘッダID
      end

      #キャビネットインデックス
      if submit_flg == 3  #削除
        DCabinetIndex.update_all("delf=1, deleted_user_cd='#{current_m_user.user_cd}', deleted_at=current_date", ["d_cabinet_head_id = ?", head_id])
      else
        if submit_flg == 1  #登録
          m_cabinet = DCabinetIndex.new
        elsif submit_flg == 2 #更新
          m_cabinet = DCabinetIndex.find(:first, :conditions=>["d_cabinet_head_id = ? and delf = ?", head_id, 0])
        end
        m_cabinet.cabinet_kbn = 1
        m_cabinet.index_type = params[:index_type]
        m_cabinet.parent_cabinet_head_id = params[:parent_id]
        m_cabinet.d_cabinet_head_id = head_id
        m_cabinet.title = params[:target_cabinet_data][:title]
        m_cabinet.order_display = params[:target_cabinet_data][:order_display]
        m_cabinet.created_user_cd = current_m_user.user_cd
        m_cabinet.updated_user_cd = current_m_user.user_cd
        m_cabinet.save
      end

      #キャビネット権限データ
      if submit_flg == 3  #削除
        DCabinetAuth.update_all("delf=1, deleted_user_cd='#{current_m_user.user_cd}', deleted_at=current_date", ["d_cabinet_head_id = ?", head_id])
      else
        if submit_flg == 2  #更新
          DCabinetAuth.delete_all(["d_cabinet_head_id = ?", head_id])
        end

        #参照可能データ,書き込み可能データを作成する
        for i in 1..2
          orgs = '0'  #組織
          users = ''  #社員
          if i == 1 #参照権限
            if !params[:decided_auth_org_all_r].nil? && params[:decided_auth_org_all_r] != ""
              orgs = params[:decided_auth_org_all_r].split(",")
            end
            if !params[:decided_auth_user_all_r].nil? && params[:decided_auth_user_all_r] != ""
              users = params[:decided_auth_user_all_r].split(",")
            end
          else  #書き込み権限
            if !params[:decided_auth_org_all_w].nil? && params[:decided_auth_org_all_w] != ""
              orgs = params[:decided_auth_org_all_w].split(",")
            end
            if !params[:decided_auth_user_all_w].nil? && params[:decided_auth_user_all_w] != ""
              users = params[:decided_auth_user_all_w].split(",")
            end
          end
          #組織
          if !(orgs == '0' && users != '')  #不要なデータを作らない為の制御
            orgs.each { |org|
              m_cabinet = DCabinetAuth.new
              m_cabinet.d_cabinet_head_id = head_id
              m_cabinet.org_cd = org
              m_cabinet.user_cd = ''
              m_cabinet.auth_kbn = i
              m_cabinet.created_user_cd = current_m_user.user_cd
              m_cabinet.updated_user_cd = current_m_user.user_cd
              m_cabinet.save
            }
          end
          #社員
          users.each { |user|
            m_cabinet = DCabinetAuth.new
            m_cabinet.d_cabinet_head_id = head_id
            m_cabinet.org_cd = '0'
            m_cabinet.user_cd = user
            m_cabinet.auth_kbn = i
            m_cabinet.created_user_cd = current_m_user.user_cd
            m_cabinet.updated_user_cd = current_m_user.user_cd
            m_cabinet.save
          }
        end
      end

    rescue => ex
      flash[:company_cabinet_err_msg] = "登録処理中に異常が発生しました。"
      logger.error "DCabinetHead Err => #{ex}"
      redirect_to :action=>:index
      return
    end

    redirect_to :action=>:index
  end

  #
  #社員ツリーエリアを表示
  #
  def tree_org
    #組織マスタ
    @m_orgs = MOrg.new.get_orgs
  end

  #
  #選択候補エリアを表示
  #
  def undecided_member
    @org_cd = params[:orgcd]
    @org_name = params[:orgnm]
    #ユーザー所属マスタより、組織コードに含まれるデータを取得
    @member_undecide = MUserBelong.get_belong_member_list(params[:orgcd])
  end

  #
  #Webメモリのユーザ一覧を取得する(選択押下時)
  #
  def user_list
    keyword = params[:keyword]
    @user_list = MUser.get_user_by_keyword keyword
  end

  def _common_info
    @result = params[:result]
    @m_cabinet_settings = MCabinetSetting.find(:first, :conditions=>{:delf=>0})
  end

  def save_common_info

    new_icon_days = params[:m_cabinet_settings][:new_icon_days]
    page_max_count = params[:m_cabinet_settings][:page_max_count]
    enable_day_default = params[:m_cabinet_settings][:enable_day_default]

    m_cabinet = MCabinetSetting.find(:first, :conditions=>{:delf=>0})
    m_cabinet.new_icon_days = new_icon_days
    m_cabinet.page_max_count = page_max_count
    m_cabinet.enable_day_default = enable_day_default
    m_cabinet.updated_user_cd = current_m_user.user_cd
    begin
      m_cabinet.save
      result = 1
    end

    redirect_to :action=>:_common_info, :result=>result
  end

  #
  #Webメモリのユーザ情報を取得する(ユーザ選択時)
  #
  def _mine_info
    user_cd = params[:user_cd]
    @result = params[:result]
    unless user_cd.nil?
      # ユーザーCDをもとに、キャビネットヘッダを取得する。
      @d_cabinet_heads = DCabinetHead.get_cabinethead_by_user_cd user_cd

      # キャビネットヘッダが存在しない場合
      if @d_cabinet_heads.nil?
        # ヘッダレコードを作る
        DCabinetHead.new.create_private_cabinet user_cd
        @d_cabinet_heads = DCabinetHead.get_cabinethead_by_user_cd user_cd
      end
    end
  end

  #
  #Webメモリのユーザ情報を更新する
  #
  def save_mine_info

    private_user_cd = params[:d_cabinet_heads][:private_user_cd]
    default_enable_day = params[:d_cabinet_heads][:default_enable_day]
    max_disk_size = params[:d_cabinet_heads][:max_disk_size]

    d_cabinet_head = DCabinetHead.get_cabinethead_by_user_cd private_user_cd
    unless d_cabinet_head.nil?
      d_cabinet_head.default_enable_day = default_enable_day
      d_cabinet_head.max_disk_size = max_disk_size
      d_cabinet_head.updated_user_cd = current_m_user.user_cd
      begin
        d_cabinet_head.save
        result = 1
      end
    end

    redirect_to :action=>:_mine_info, :user_cd=>private_user_cd, :result=>result
  end
end
