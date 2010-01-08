require "date"
class Master::PasswordController < ApplicationController
  layout "portal"

  def index
    #パンくずリストに表示させる
    @pankuzu += "パスワード設定"

    #ユーザーマスタ
    id = MUser.find(:first, :conditions => ["user_cd = ? and delf = ?", current_m_user.user_cd, 0]).id
    @m_users = MUser.find(id)
  end

  def update
    begin
      #ユーザーマスタのupdate処理
        update_table()

      #画面遷移(TOP画面へ)
      redirect_to('/')

    rescue => ex
      flash[:password_err_msg] = "更新処理中に異常が発生しました。"
      logger.error "MUser Err => #{ex}"
      redirect_to :action => "index"
    end
  end

private
  #ユーザーマスタのupdate処理
  def update_table()
    #ユーザーマスタ
    id = MUser.find(:first, :conditions => ["user_cd = ? and delf = ?", current_m_user.user_cd, 0]).id
    @m_users = MUser.find(id)
    @m_users.passwd = params[:password_new]
    @m_users.created_user_cd = current_m_user.user_cd
    @m_users.updated_user_cd = current_m_user.user_cd
    @m_users.save
  end
end
