require "date"
class Master::PositionController < ApplicationController
  layout "portal", :except => [:master_list]
  PANKUZU = "職位マスタ"

  def index
    #パンくずリストに表示させる
    @pankuzu += PANKUZU
  end

  #一覧を表示
  def master_list
    #職位マスタ
    @m_positions = MPosition.get_position_all_list
  end

  #登録画面を表示
  def new
    #パンくずリストに表示させる
    @pankuzu += PANKUZU

    #職位マスタ
    @m_positions = MPosition.new
  end

  #登録処理
  def create
    begin
      #重複チェック
      position_data = MPosition.duplicate_check_data(0, params[:m_positions][:position_cd])
      if position_data.size > 0
        flash[:position_err_msg] = "同じ職位コードが既に登録されています。他のコードを指定してください。"
        redirect_to :action => "new"
        return
      end

      #職位マスタ
      data = MPosition.new(params[:m_positions])
      data.delf = 0
      data.created_user_cd = current_m_user.user_cd
      data.updated_user_cd = current_m_user.user_cd
      data.save

    rescue => ex
      flash[:position_err_msg] = "登録処理中に異常が発生しました。"
      logger.error "MPosition Err => #{ex}"
    end
    redirect_to :action => "index"
  end

  #編集画面を表示
  def edit
    #パンくずリストに表示させる
    @pankuzu += PANKUZU

    #職位マスタ
    @m_positions = MPosition.find(params[:id])
  end

  #更新処理
  def update
    begin
      #重複チェック
      position_data = MPosition.duplicate_check_data(params[:m_positions][:id], params[:m_positions][:position_cd])
      if position_data.size > 0
        flash[:position_err_msg] = "同じ職位コードが既に登録されています。他のコードを指定してください。"
        redirect_to :action => "edit", :id => params[:m_positions][:id]
        return
      end

      #職位マスタ
      data = MPosition.find(:first, :conditions => ['id = ? and delf = ?', params[:m_positions]["id"], 0])
      data.updated_user_cd = current_m_user.user_cd
      data.update_attributes(params[:m_positions])

    rescue => ex
      flash[:position_err_msg] = "更新処理中に異常が発生しました。"
      logger.error "MPosition Err => #{ex}"
    end
    redirect_to :action => "index"
  end

  #削除処理
  def delete
    begin
      #職位マスタ
      MPosition.update(params[:id], {:delf=>1, :deleted_user_cd=>current_m_user.user_cd, :deleted_at=>Time.now})

    rescue => ex
      flash[:position_err_msg] = "削除処理中に異常が発生しました。"
      logger.error "MPosition Err => #{ex}"
    end
    redirect_to :action => "index"
  end
end