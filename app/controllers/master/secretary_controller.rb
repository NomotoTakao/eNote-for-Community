require "date"
class Master::SecretaryController < ApplicationController
  layout "portal", :except => [:master_list, :undecided_member, :tree_org]
  PANKUZU = "秘書マスタ"

  def index
    #パンくずリストに表示させる
    @pankuzu += PANKUZU
  end

  #一覧を表示
  def master_list
    #秘書マスタ(同じ社員に対する重複データは１つにまとめる)
    @m_secretaries = MSecretary.get_secretary_user_list
  end

  #選択候補エリアを表示
  def undecided_member
    @org_cd = params[:orgcd]
    @org_name = params[:orgnm]
    #ユーザー所属マスタより、組織コードに含まれるデータを取得
    @member_undecide = MUserBelong.get_belong_member_list(params[:orgcd])
  end

  #社員ツリーエリアを表示
  def tree_org
    #組織マスタ
    @m_orgs = MOrg.new.get_orgs
  end

  #登録画面を表示
  def new
    #パンくずリストに表示させる
    @pankuzu += PANKUZU

    #秘書マスタ
    @m_secretaries = MSecretary.new
  end

  #登録処理
  def create
    begin
      #重複チェック
      secretary_data = MSecretary.duplicate_check_data(0, params[:decided_user_cd])
      if secretary_data.size > 0
        flash[:secretary_err_msg] = "同じ社員の方のデータが既に登録されています。他の社員を指定してください。"
        redirect_to :action => "new"
        return
      end

      #秘書マスタにデータ挿入
      data_insert
    rescue => ex
      flash[:secretary_err_msg] = "登録処理中に異常が発生しました。"
      logger.error "MSecretary Err => #{ex}"
    end
    redirect_to :action => "index"
  end

  #編集画面を表示
  def edit
    #パンくずリストに表示させる
    @pankuzu += PANKUZU

    @decided_user_cd = MSecretary.find(params[:id]).user_cd #社員コード
    @decided_user_name = MUser.find(:first, :conditions => ["user_cd = ? and delf = ?", @decided_user_cd, 0]).name  #社員名

    #秘書マスタ(idに該当する社員の全データを取得)
    @m_secretaries = MSecretary.get_secretary_data(@decided_user_cd)
    @user_auth_decide = []  #認定者
    @org_auth_decide = []   #認定組織
    @m_secretaries.each { |data|
      if !data.authorize_user_cd.nil? && data.authorize_user_cd != ""
        @user_auth_decide << [data.authorize_user_cd, data.authorize_user_name]
      end
      if !data.authorize_org_cd.nil? && data.authorize_org_cd != ""
        @org_auth_decide << [data.authorize_org_cd, data.authorize_org_name]
      end
    }
  end

  #更新処理
  def update
    begin
      #秘書マスタのデータ削除
      MSecretary.update_all("delf=1, deleted_user_cd='#{current_m_user.user_cd}', deleted_at=current_date", ["user_cd = ?", params[:decided_user_cd]])
      #秘書マスタにデータ挿入
      data_insert
    rescue => ex
      flash[:secretary_err_msg] = "更新処理中に異常が発生しました。"
      logger.error "MSecretary Err => #{ex}"
    end
    redirect_to :action => "index"
  end

  #削除処理
  def delete
    begin
      #秘書マスタ(idに該当する社員の全データを削除)
      decided_user_cd = MSecretary.find(params[:id]).user_cd #社員コード
      MSecretary.update_all("delf=1, deleted_user_cd='#{current_m_user.user_cd}', deleted_at=current_date", ["user_cd = ?", decided_user_cd])
    rescue => ex
      flash[:secretary_err_msg] = "削除処理中に異常が発生しました。"
      logger.error "MSecretary Err => #{ex}"
    end
    redirect_to :action => "index"
  end

private
  #データ挿入
  def data_insert
    #秘書マスタ
    #認定者のデータ
    if !params[:decided_auth_user_all].nil? && params[:decided_auth_user_all] != ""
      selected_user_cd = params[:decided_auth_user_all].split(",")
      selected_user_cd.each { |user_cd|
        data = MSecretary.new(params[:m_secretaries])
        data.user_cd = params[:decided_user_cd]
        data.authorize_user_cd = user_cd
        data.delf = 0
        data.created_user_cd = current_m_user.user_cd
        data.updated_user_cd = current_m_user.user_cd
        data.save
      }
    end
    #認定組織のデータ
    if !params[:decided_auth_org_all].nil? && params[:decided_auth_org_all] != ""
      selected_org_cd = params[:decided_auth_org_all].split(",")
      selected_org_cd.each { |org_cd|
        data = MSecretary.new(params[:m_secretaries])
        data.user_cd = params[:decided_user_cd]
        data.authorize_org_cd = org_cd
        data.delf = 0
        data.created_user_cd = current_m_user.user_cd
        data.updated_user_cd = current_m_user.user_cd
        data.save
      }
    end
  end
end