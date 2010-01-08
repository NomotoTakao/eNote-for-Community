require "date"
class Master::FacilityGroupController < ApplicationController
  layout "portal", :except => [:master_list]
  PANKUZU = "施設グループマスタ"

  def index
    #パンくずリストに表示させる
    @pankuzu += PANKUZU
  end

  #一覧を表示
  def master_list
    #施設グループマスタ
    @m_facility_groups = MFacilityGroup.get_facility_group_all_list
  end

  #登録画面を表示
  def new
    #パンくずリストに表示させる
    @pankuzu += PANKUZU

    #施設グループマスタ
    @m_facility_groups = MFacilityGroup.new
  end

  #登録処理
  def create
    begin
      #施設グループマスタ
      data = MFacilityGroup.new(params[:m_facility_groups])
      data.delf = 0
      data.created_user_cd = current_m_user.user_cd
      data.updated_user_cd = current_m_user.user_cd
      data.save!
      #施設グループコードを追加
      id = data.id
      data = MFacilityGroup.find(id)
      data.facility_group_cd = id.to_s
      data.save

    rescue => ex
      flash[:facility_group_err_msg] = "登録処理中に異常が発生しました。"
      logger.error "MFacilityGroup Err => #{ex}"
    end
    redirect_to :action => "index"
  end

  #編集画面を表示
  def edit
    #パンくずリストに表示させる
    @pankuzu += PANKUZU

    #施設グループマスタ
    @m_facility_groups = MFacilityGroup.find(params[:id])
  end

  #更新処理
  def update
    begin
      #施設グループマスタ
      data = MFacilityGroup.find(:first, :conditions => ['id = ? and delf = ?', params[:m_facility_groups]["id"], 0])
      data.updated_user_cd = current_m_user.user_cd
      data.update_attributes(params[:m_facility_groups])

    rescue => ex
      flash[:facility_group_err_msg] = "更新処理中に異常が発生しました。"
      logger.error "MFacilityGroup Err => #{ex}"
    end
    redirect_to :action => "index"
  end

  #削除処理
  def delete
    begin
      #施設グループマスタ
      MFacilityGroup.update(params[:id], {:delf=>1, :deleted_user_cd=>current_m_user.user_cd, :deleted_at=>Time.now})

    rescue => ex
      flash[:facility_group_err_msg] = "削除処理中に異常が発生しました。"
      logger.error "MFacilityGroup Err => #{ex}"
    end
    redirect_to :action => "index"
  end
end