require "date"
class Master::PlaceController < ApplicationController
  layout "portal", :except => [:master_list]
  PANKUZU = "拠点マスタ"

  def index
    #パンくずリストに表示させる
    @pankuzu += PANKUZU
  end

  #一覧を表示
  def master_list
    #拠点マスタ
    @m_places = MPlace.get_place_all_list
  end

  #登録画面を表示
  def new
    #パンくずリストに表示させる
    @pankuzu += PANKUZU

    #拠点マスタ
    @m_places = MPlace.new
  end

  #登録処理
  def create
    begin
      #重複チェック
      position_data = MPlace.duplicate_check_data(0, params[:m_places][:place_cd])
      if position_data.size > 0
        flash[:place_err_msg] = "同じ拠点コードが既に登録されています。他のコードを指定してください。"
        redirect_to :action => "new"
        return
      end

      #拠点マスタ
      data = MPlace.new(params[:m_places])
      data.delf = 0
      data.created_user_cd = current_m_user.user_cd
      data.updated_user_cd = current_m_user.user_cd
      data.save

    rescue => ex
      flash[:place_err_msg] = "登録処理中に異常が発生しました。"
      logger.error "MPlace Err => #{ex}"
    end
    redirect_to :action => "index"
  end

  #編集画面を表示
  def edit
    #パンくずリストに表示させる
    @pankuzu += PANKUZU

    #拠点マスタ
    @m_places = MPlace.find(params[:id])
  end

  #更新処理
  def update
    begin
      #重複チェック
      position_data = MPlace.duplicate_check_data(params[:m_places][:id], params[:m_places][:place_cd])
      if position_data.size > 0
        flash[:place_err_msg] = "同じ拠点コードが既に登録されています。他のコードを指定してください。"
        redirect_to :action => "edit", :id => params[:m_places][:id]
        return
      end

      #拠点マスタ
      data = MPlace.find(:first, :conditions => ['id = ? and delf = ?', params[:m_places]["id"], 0])
      data.updated_user_cd = current_m_user.user_cd
      data.update_attributes(params[:m_places])

    rescue => ex
      flash[:place_err_msg] = "更新処理中に異常が発生しました。"
      logger.error "MPlace Err => #{ex}"
    end
    redirect_to :action => "index"
  end

  #削除処理
  def delete
    begin
      #拠点マスタ
      MPlace.update(params[:id], {:delf=>1, :deleted_user_cd=>current_m_user.user_cd, :deleted_at=>Time.now})

    rescue => ex
      flash[:place_err_msg] = "削除処理中に異常が発生しました。"
      logger.error "MPlace Err => #{ex}"
    end
    redirect_to :action => "index"
  end
end