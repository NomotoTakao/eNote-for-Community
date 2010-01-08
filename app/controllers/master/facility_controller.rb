require "date"
class Master::FacilityController < ApplicationController
  layout "portal", :except => [:master_list, :condition]
  PANKUZU = "施設マスタ"

  def index
    #パンくずリストに表示させる
    @pankuzu += PANKUZU

    #施設グループマスタ
    @m_facility_groups = MFacilityGroup.get_facility_group_all_list
  end

  #検索条件表示
  def condition
    #施設グループマスタ
    @m_facility_groups = MFacilityGroup.get_facility_group_all_list
    #拠点マスタ
    @m_places = MPlace.get_place_all_list
    #組織マスタ
    @m_orgs = MOrg.get_orgs_consider_name
  end

  #一覧を表示
  def master_list
    #施設マスタより、施設グループコードに含まれるデータを取得(拠点、組織名称も取得)
    #組織が検索条件に指定されていない場合
    if params[:org_cd].nil? || params[:org_cd] == "" || params[:org_cd] == "-1"
      @m_facilities = MFacility.get_facility_group_list_by_group(params[:facility_group_cd], params[:place_cd])
    else
      @m_facilities = MFacility.get_facility_group_list_by_org(params[:facility_group_cd], params[:place_cd], params[:org_cd])
    end
    #フラグ名取得
    get_flg_name
  end

  #登録画面を表示
  def new
    #パンくずリストに表示させる
    @pankuzu += PANKUZU

    #施設グループマスタ
    @m_facility_groups = MFacilityGroup.get_facility_group_all_list
    #施設マスタ
    @m_facilities = MFacility.new
    #拠点マスタ
    @m_places = MPlace.get_place_all_list
    #組織マスタ
    @m_orgs = MOrg.get_orgs_consider_name
  end

  #登録処理
  def create
    begin
      #施設マスタ
      data = MFacility.new(params[:m_facilities])
      data.facility_group_cd = params[:select_facility_group_cd]
      data.place_cd = params[:select_place_cd]
      data.org_cd = params[:select_org_cd]
      data.delf = 0
      data.created_user_cd = current_m_user.user_cd
      data.updated_user_cd = current_m_user.user_cd
      data.save!
      #施設コードを追加
      id = data.id
      data = MFacility.find(id)
      data.facility_cd = id.to_s
      data.save

    rescue => ex
      flash[:facility_err_msg] = "登録処理中に異常が発生しました。"
      logger.error "MFacility Err => #{ex}"
    end
    redirect_to :action => "index"
  end

  #編集画面を表示
  def edit
    #パンくずリストに表示させる
    @pankuzu += PANKUZU

    #施設グループマスタ
    @m_facility_groups = MFacilityGroup.get_facility_group_all_list
    #施設マスタ
    @m_facilities = MFacility.find(params[:id])
    #拠点マスタ
    @m_places = MPlace.get_place_all_list
    #組織マスタ
    @m_orgs = MOrg.get_orgs_consider_name
  end

  #更新処理
  def update
    begin
      #施設マスタ
      data = MFacility.find(:first, :conditions => ['id = ? and delf = ?', params[:m_facilities]["id"], 0])
      data.facility_group_cd = params[:select_facility_group_cd]
      data.place_cd = params[:select_place_cd]
      data.org_cd = params[:select_org_cd]
      data.updated_user_cd = current_m_user.user_cd
      data.update_attributes(params[:m_facilities])

    rescue => ex
      flash[:facility_err_msg] = "更新処理中に異常が発生しました。"
      logger.error "MFacility Err => #{ex}"
    end
    redirect_to :action => "index"
  end

  #削除処理
  def delete
    begin
      #施設マスタ
      MFacility.update(params[:id], {:delf=>1, :deleted_user_cd=>current_m_user.user_cd, :deleted_at=>Time.now})

    rescue => ex
      flash[:facility_err_msg] = "削除処理中に異常が発生しました。"
      logger.error "MFacility Err => #{ex}"
    end
    redirect_to :action => "index"
  end

private
  def get_flg_name
    #有効フラグ
    @enable_hash = Hash.new{|hash,key| hash[key]=[]}
    @enable_hash[0] << "有効"
    @enable_hash[1] << "無効"
  end
end