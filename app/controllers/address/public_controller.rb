require "date"
class Address::PublicController < ApplicationController
  layout "portal", :except => [:group_list, :undecided_member, :tree_org]
  PANKUZU = "共用アドレス帳"

  def index
    #パンくずリストに表示させる
    @pankuzu += PANKUZU
  end

  #一覧を表示
  def group_list
    #アドレス帳グループ
    @m_address_groups = DAddressGroup.get_all_user_group(0)
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

    #初期化
    @title = ""
    @user_decide = []
  end

  #登録処理
  def create
    begin
      #重複チェック
      group_data = DAddressGroup.duplicate_check_data(0, params[:title], 0)
      if group_data.size > 0
        flash[:address_err_msg] = "同じグループ名のデータが既に登録されています。他の名前を指定してください。"
        redirect_to :action => "new"
        return
      end

      #アドレス帳グループ関連テーブルにデータ挿入
      data_insert
    rescue => ex
      flash[:address_err_msg] = "登録処理中に異常が発生しました。"
      logger.error "DAddressGroup Err => #{ex}"
    end
    redirect_to :action => "index"
  end

  #編集画面を表示
  def edit
    #パンくずリストに表示させる
    @pankuzu += PANKUZU

    #アドレス帳グループ関連データ(idに該当する全データを取得)
    d_public_groups = DAddressGroupList.get_data_by_group_id(params[:id])
    @id = params[:id]
    @title = d_public_groups[0].title
    @member_decide = []
    d_public_groups.each { |data|
      @member_decide << [data.user_cd, data.name]
    }
  end

  #更新処理
  def update
    begin
      #重複チェック
      group_data = DAddressGroup.duplicate_check_data(params[:id], params[:title], 0)
      if group_data.size > 0
        flash[:address_err_msg] = "同じグループ名のデータが既に登録されています。他の名前を指定してください。"
        redirect_to :action => "edit", :id => params[:id]
        return
      end

      #アドレス帳グループ関連テーブルのデータ更新
      data_update
    rescue => ex
      flash[:address_err_msg] = "更新処理中に異常が発生しました。"
      logger.error "DAddressGroup Err => #{ex}"
    end
    redirect_to :action => "index"
  end

  #削除処理
  def delete
    begin
      #アドレス帳グループ関連テーブルのデータ削除
      data_delete
    rescue => ex
      flash[:address_err_msg] = "削除処理中に異常が発生しました。"
      logger.error "DAddressGroup Err => #{ex}"
    end
    redirect_to :action => "index"
  end

private
  #データ挿入
  def data_insert
    #アドレス帳グループ(INSERT)
    data_insert_group

    #アドレス帳グループリスト(INSERT)
    data_insert_group_list(@group_data.id)
  end

  #データ更新
  def data_update
    #アドレス帳グループ(UPDATE)
    data = DAddressGroup.find(params[:id])
    data.title = params[:title]
    data.updated_user_cd = current_m_user.user_cd
    data.save

    #アドレス帳グループリスト(DELETE)
    DAddressGroupList.delete_all(["d_address_group_id = ?", params[:id]])
    #アドレス帳グループリスト(INSERT)
    data_insert_group_list(params[:id])
  end

  #データ削除
  def data_delete
    #アドレス帳グループ(UPDATE)
    DAddressGroup.update(params[:id], {:delf=>1, :deleted_user_cd=>current_m_user.user_cd, :deleted_at=>Time.now})
    #アドレス帳グループリスト(DELETE)
    DAddressGroupList.delete_all(["d_address_group_id = ?", params[:id]])
  end

  #データ挿入(アドレス帳グループ)
  def data_insert_group
    @group_data = DAddressGroup.new()
    @group_data.title = params[:title]
    @group_data.private_user_cd = '0'
    @group_data.delf = 0
    @group_data.created_user_cd = current_m_user.user_cd
    @group_data.updated_user_cd = current_m_user.user_cd
    @group_data.save!
  end

  #データ挿入(アドレス帳グループリスト)
  def data_insert_group_list(group_id)
    if !params[:decided_member_all].nil? && params[:decided_member_all] != ""
      selected_user_cd = params[:decided_member_all].split(",")
      selected_user_cd.each { |user_cd|
        list_data = DAddressGroupList.new()
        list_data.private_user_cd = '0'
        list_data.d_address_group_id = group_id.to_i
        list_data.d_address_id = DAddress.get_address_by_user(user_cd)[0].id
        list_data.delf = 0
        list_data.created_user_cd = current_m_user.user_cd
        list_data.updated_user_cd = current_m_user.user_cd
        list_data.save
      }
    end
  end
end