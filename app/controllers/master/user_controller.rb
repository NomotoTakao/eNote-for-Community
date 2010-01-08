require "date"
class Master::UserController < ApplicationController
  layout "portal", :except => [:master_list, :condition, :tree_org, :create, :update, :belong]
  PANKUZU = "ユーザマスタ"

  def index
    #パンくずリストに表示させる
    @pankuzu += PANKUZU

    #組織マスタ
    @m_orgs = MOrg.new.get_orgs
  end

  #検索条件エリアを表示
  def condition
  end

  #検索結果を表示
  def master_list
    #組織で検索
    if params[:select_mode].to_s == "1"
      #条件句用に形式を整える
      org_cds = edit_org_colon(params[:decided_org_all])
      #ユーザー関連情報
      @m_users = MUser.get_user_relation_list(org_cds, "", "")
    #あいまい検索
    else
      #ユーザー関連情報
      @m_users = MUser.get_user_relation_list("", params[:sword], "")
    end
    #ハッシュ[ユーザーCD, 組織名]を作成
    @org_hash = get_user_org_hash(@m_users)
  end

  #社員ツリーエリアを表示
  def tree_org
    #組織マスタ
    @m_orgs = MOrg.new.get_orgs
  end

  #所属エリアを表示
  def belong
    #ユーザー関連情報
    @main_belong_cd = ""
    @main_belong_name = ""
    @sub_belong = []
    if !params[:user_cd].nil? && params[:user_cd] != ""
      @m_users_all = MUser.get_user_relation_list("", "", params[:user_cd])

      #所属情報作成
      @m_users_all.each { |user|
        #主所属
        if user.belong_kbn.to_s == "0"
          @main_belong_cd = user.org_cd
          @main_belong_name = user.org_name
        #兼任所属
        else
          @sub_belong << [user.org_cd, user.org_name]
        end
      }
    end
  end

  #登録画面を表示
  def new
    #パンくずリストに表示させる
    @pankuzu += PANKUZU

    #ユーザー関連情報の初期化
    @m_users = MUser.data_init
    #職位マスタ
    @m_positions = MPosition.get_position_all_list
    #所属情報作成
    @main_belong = []
    @sub_belong = []
  end

  #登録処理
  def create
    begin
      #重複チェック
      user_data = MUser.duplicate_check_data(0, params[:m_users][:user_cd], params[:m_users][:login])
      if user_data.size > 0
        flash[:user_err_msg] = "同じ社員の方のデータが既に登録されています。他の社員(ログインID、社員CD)を指定してください。"
        redirect_to :action => "new"
        return
      end
      #ユーザー関連マスタにデータ挿入
      data_insert(1)

    rescue => ex
      flash[:user_err_msg] = "登録処理中に異常が発生しました。"
      logger.error "MUser Err => #{ex}"
    end
    redirect_to :action => "index"
  end

  #編集画面を表示
  def edit
    #パンくずリストに表示させる
    @pankuzu += PANKUZU

    #ユーザー関連情報
    @m_users_all = MUser.get_user_relation_list("", "", params[:user_cd])
    @m_users = @m_users_all[0]
    #職位マスタ
    @m_positions = MPosition.get_position_all_list
  end

  #更新処理
  def update
    begin
      #ユーザー関連マスタのデータ更新
      data_insert(2)

    rescue => ex
      flash[:user_err_msg] = "更新処理中に異常が発生しました。"
      logger.error "MUser Err => #{ex}"
    end
    redirect_to :action => "index"
  end

  #削除処理
  def delete
    begin
      #ユーザー関連マスタのデータ削除
      data_delete(params[:user_cd])

    rescue => ex
      flash[:user_err_msg] = "削除処理中に異常が発生しました。"
      logger.error "MUser Err => #{ex}"
    end
    redirect_to :action => "index"
  end

private
  #部署を文字列編集する
  #orgs - 部署コード(カンマ区切り  cf:10,1010)
  #return - 部署コード(文字列編集後のカンマ区切り  cf:'10','1010')
  def edit_org_colon(org_cds)
    org_list = org_cds.split(",")
    org_colon_list = ""
    for i in 0..(org_list.size - 1)
      org = org_list[i]
      if i > 0
        org_colon_list += ","
      end
      org_colon_list += "'"
      org_colon_list += org
      org_colon_list += "'"
    end
    return org_colon_list
  end

  #部署を文字列編集する
  #m_users - ユーザー情報
  #return - ハッシュ[ユーザーCD, 組織名]
  def get_user_org_hash(m_users)
    org_hash = Hash.new{|hash,key| hash[key]=[]}
    m_users.each { |user|
      org_hash[user.user_cd] << user.org_name
    }
    return org_hash
  end

  #データ登録/更新(ユーザーマスタ/ユーザー属性マスタ/ユーザー所属マスタ)
  #mode - 1:登録, 2:更新
  #但しメールアカウント設定テーブルは必須ではない為、判断方法は別とする
  def data_insert(mode)
    #ユーザーマスタ
    if mode == 1  #登録
      data = MUser.new(params[:m_users])
    else  #更新
      data = MUser.find(params[:m_users][:id])
      data.login = params[:m_users][:login]
      data.user_cd = params[:m_users][:user_cd]
      data.name = params[:m_users][:name]
      data.email = params[:m_users][:email]
      data.passwd = params[:m_users][:passwd]
    end
    data.delf = 0
    data.created_user_cd = current_m_user.user_cd
    data.updated_user_cd = current_m_user.user_cd
    data.save

    #ユーザー属性マスタ
    if mode == 1  #登録
      data = MUserAttribute.new()
    else  #更新
      att_id = MUserAttribute.get_data_by_user(params[:m_users][:user_cd])[0].id
      data = MUserAttribute.find(att_id)
    end
    data.user_cd = params[:m_users][:user_cd]
    data.name_kana = params[:m_users][:name_kana]
    data.position_cd = params[:select_position_cd]
    data.job_kbn = params[:m_users][:job_kbn]
    data.authority_kbn = params[:m_users][:authority_kbn]
    data.joined_date = params[:m_users][:joined_date]
    data.memo = params[:m_users][:memo]
    data.delf = 0
    data.created_user_cd = current_m_user.user_cd
    data.updated_user_cd = current_m_user.user_cd
    data.save

    #ユーザー所属マスタ
    if mode == 2  #更新
      MUserBelong.update_all("delf=1, deleted_user_cd='#{current_m_user.user_cd}', deleted_at=current_date", ["user_cd = ?", params[:m_users][:user_cd]])
    end
    data = MUserBelong.new()
    data.user_cd = params[:m_users][:user_cd]
    data.org_cd = params[:m_users][:main_belong_cd]
    data.belong_kbn = 0
    data.delf = 0
    data.created_user_cd = current_m_user.user_cd
    data.updated_user_cd = current_m_user.user_cd
    data.save

    #兼任所属
    if !params[:decided_sub_org_all].nil? && params[:decided_sub_org_all] != ""
      sub_belongs = params[:decided_sub_org_all].split(",")
      sub_belongs.each { |belong|
        data = MUserBelong.new()
        data.user_cd = params[:m_users][:user_cd]
        data.org_cd = belong
        data.belong_kbn = 1
        data.delf = 0
        data.created_user_cd = current_m_user.user_cd
        data.updated_user_cd = current_m_user.user_cd
        data.save
      }
    end

    #アドレス帳
    if mode == 1  #登録
      data = DAddress.new()
    else  #更新
      add_id = DAddress.get_address_by_user(params[:m_users][:user_cd])[0].id
      data = DAddress.find(add_id)
    end
    data.address_kbn = 1
    data.user_cd = params[:m_users][:user_cd]
    data.name = params[:m_users][:name]
    data.name_kana = params[:m_users][:name_kana]
    data.email_name = params[:m_users][:name]
    data.email_address1 = params[:m_users][:email_address1]
    data.mobile_no = params[:m_users][:mobile_no]
    data.mobile_address = params[:m_users][:mobile_address]
    data.mobile_company = params[:m_users][:mobile_company]
    data.mobile_kind = params[:m_users][:mobile_kind]
    data.delf = 0
    data.created_user_cd = current_m_user.user_cd
    data.updated_user_cd = current_m_user.user_cd
    data.save
  end

  #データ削除(ユーザーマスタ/ユーザー属性マスタ/ユーザー所属マスタ/アドレス帳)
  #user_cd - ユーザーCD
  def data_delete(user_cd)
    #ユーザー関連マスタのデータ削除
    MUser.update_all("delf=1, deleted_user_cd='#{current_m_user.user_cd}', deleted_at=current_date", ["user_cd = ?", user_cd])
    MUserAttribute.update_all("delf=1, deleted_user_cd='#{current_m_user.user_cd}', deleted_at=current_date", ["user_cd = ?", user_cd])
    MUserBelong.update_all("delf=1, deleted_user_cd='#{current_m_user.user_cd}', deleted_at=current_date", ["user_cd = ?", user_cd])
    DAddress.update_all("delf=1, deleted_user_cd='#{current_m_user.user_cd}', deleted_at=current_date", ["user_cd = ?", user_cd])
  end
end
