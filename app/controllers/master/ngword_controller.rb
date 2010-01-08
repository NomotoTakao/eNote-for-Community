require "date"
class Master::NgwordController < ApplicationController
  layout "portal", :except => [:master_list]
  PANKUZU = "ＮＧワードマスタ"

  def index
    #パンくずリストに表示させる
    @pankuzu += PANKUZU
  end

  #一覧を表示
  def master_list
    #ＮＧワードマスタ
    @m_ngwords = MNgword.get_ngword_all_list()
  end

  #登録画面を表示
  def new
    #パンくずリストに表示させる
    @pankuzu += PANKUZU

    #ＮＧワードマスタ
    @m_ngwords = MNgword.new
  end

  #登録処理
  def create
    begin
      #ＮＧワードマスタ
      data = MNgword.new(params[:m_ngwords])
      data.delf = 0
      data.created_user_cd = current_m_user.user_cd
      data.updated_user_cd = current_m_user.user_cd
      data.save

    rescue => ex
      flash[:ngword_err_msg] = "登録処理中に異常が発生しました。"
      logger.error "MNgword Err => #{ex}"
    end
    redirect_to :action => "index"
  end

  #編集画面を表示
  def edit
    #パンくずリストに表示させる
    @pankuzu += PANKUZU

    #ＮＧワードマスタ
    @m_ngwords = MNgword.find(params[:id])
  end

  #更新処理
  def update
    begin
      #ＮＧワードマスタ
      data = MNgword.find(:first, :conditions => ['id = ? and delf = ?', params[:m_ngwords]["id"], 0])
      data.updated_user_cd = current_m_user.user_cd
      data.update_attributes(params[:m_ngwords])

    rescue => ex
      flash[:ngword_err_msg] = "更新処理中に異常が発生しました。"
      logger.error "MNgword Err => #{ex}"
    end
    redirect_to :action => "index"
  end

  #削除処理
  def delete
    begin
      #ＮＧワードマスタ
      MNgword.update(params[:id], {:delf=>1, :deleted_user_cd=>current_m_user.user_cd, :deleted_at=>Time.now})

    rescue => ex
      flash[:ngword_err_msg] = "削除処理中に異常が発生しました。"
      logger.error "MNgword Err => #{ex}"
    end
    redirect_to :action => "index"
  end
end