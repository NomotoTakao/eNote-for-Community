require "date"
class Master::ProjectController < ApplicationController
  layout "portal", :except => [:master_list]
  PANKUZU = "プロジェクトマスタ"

  def index
    #パンくずリストに表示させる
    @pankuzu += PANKUZU
  end

  #一覧を表示
  def master_list
    #プロジェクトマスタ
    @m_projects = MProject.get_project_all_list(Date.today.strftime("%Y-%m-%d"))
    #フラグ名取得
    get_flg_name
  end

  #登録画面を表示
  def new
    #パンくずリストに表示させる
    @pankuzu += PANKUZU

    #プロジェクトマスタ
    @m_projects = MProject.new
    @m_projects.enable_date_from = Date.today
    @m_projects.enable_date_to = Date.today >> 12
  end

  #登録処理
  def create
    begin
      #プロジェクトマスタ
      data = MProject.new(params[:m_projects])
      data.delf = 0
      data.created_user_cd = current_m_user.user_cd
      data.updated_user_cd = current_m_user.user_cd
      data.save

      DCabinetHead.create_project_cabinet data.id, current_m_user.user_cd
    rescue => ex
      flash[:project_err_msg] = "登録処理中に異常が発生しました。"
      logger.error "MProject Err => #{ex}"
    end
    redirect_to :action => "index"
  end

  #編集画面を表示
  def edit
    #パンくずリストに表示させる
    @pankuzu += PANKUZU

    #プロジェクトマスタ
    @m_projects = MProject.find(params[:id])
  end

  #更新処理
  def update
    begin
      #プロジェクトマスタ
      data = MProject.find(:first, :conditions => ['id = ? and delf = ?', params[:m_projects]["id"], 0])
      data.updated_user_cd = current_m_user.user_cd
      data.update_attributes(params[:m_projects])

      # キャビネット
      d_cabinet_head = DCabinetHead.find(:first, :conditions=>{:private_project_id=>data.id})
      d_cabinet_head.d_cabinet_index.title = data.name
      d_cabinet_head.d_cabinet_index.updated_user_cd = current_m_user.user_cd
      d_cabinet_head.d_cabinet_index.updated_at = Time.now
      d_cabinet_head.d_cabinet_index.save!
      d_cabinet_head.title = data.name
      d_cabinet_head.updated_user_cd = current_m_user.user_cd
      d_cabinet_head.updated_at = Time.now
      d_cabinet_head.save!
      
    rescue => ex
      flash[:project_err_msg] = "更新処理中に異常が発生しました。"
      logger.error "MProject Err => #{ex}"
    end
    redirect_to :action => "index"
  end

  #削除処理
  def delete
    begin
      #プロジェクトマスタ
      MProject.update(params[:id], {:delf=>1, :deleted_user_cd=>current_m_user.user_cd, :deleted_at=>Time.now})
      # キャビネット
      # d_cabinet_headを求める。
      d_cabinet_head = DCabinetHead.find(:first, :conditions=>{:private_project_id=>params[:id]})
      # d_cabinet_indexを削除
      d_cabinet_head.d_cabinet_index.delf = "1"
      d_cabinet_head.d_cabinet_index.deleted_user_cd = current_m_user.user_cd
      d_cabinet_head.d_cabinet_index.deleted_at = Time.now
      d_cabinet_head.d_cabinet_index.save!
      # d_cabinet_headを削除
      d_cabinet_head.delf = "1"
      d_cabinet_head.deleted_user_cd = current_m_user.user_cd
      d_cabinet_head.deleted_at = Time.now
      d_cabinet_head.save!

    rescue => ex
      flash[:project_err_msg] = "削除処理中に異常が発生しました。"
      logger.error "MProject Err => #{ex}"
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