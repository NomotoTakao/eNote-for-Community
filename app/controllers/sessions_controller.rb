# This controller handles the login/logout function of the site.
class SessionsController < ApplicationController
  layout "login"
  # Be sure to include AuthenticationSystem in Application Controller instead
  include AuthenticatedSystem

  before_filter :login_required, :except => [ :new, :create]

  # render new.rhtml
  def new
  end

  #パスワード変更画面表示
  def change_passwd
  end

  #パスワード変更時
  def create_after_change_passwd
    #ユーザMを更新
    @m_users = MUser.find(:first, :conditions => ['user_cd = ? and delf = ?', current_m_user.user_cd, 0])
    m_users_update = {:passwd => params[:password_new],
                      :last_change_passwd_at => Time.now,
                      :updated_user_cd => current_m_user.user_cd}
    if @m_users.update_attributes(m_users_update)
      redirect_back_or_default('/')
    else
      @message = "パスワードの変更に失敗しました。"
      render :action => 'change_passwd'
    end
  end

  #ログイン時
  def create
    logout_keeping_session!
    m_user = MUser.authenticate(params[:login], params[:password])
    if m_user
      # Protects against session fixation attacks, causes request forgery
      # protection if user resubmits an earlier form using back
      # button. Uncomment if you understand the tradeoffs.
      # reset_session
      self.current_m_user = m_user

      new_cookie_flag = (params[:remember_me] == "1")
      handle_remember_cookie! new_cookie_flag
      flash[:notice] = "Logged in successfully"

      #最終ログイン日時を更新する
      MUser.new.update_lastlogin(m_user.id)

      #パスワード変更画面へ遷移する場合(初期ログイン時, 最終パスワード変更日から半年経過時)
      last_change_passwd_at = current_m_user.last_change_passwd_at
      if last_change_passwd_at.nil? || last_change_passwd_at == ""  || ((last_change_passwd_at.to_date >> 6) < Date.today)
        render :action => 'change_passwd'
      else
        redirect_back_or_default('/')
      end
    else
      note_failed_signin
      @login       = params[:login]
      @remember_me = params[:remember_me]
      flash[:login_err_msg] = "ログインIDまたはパスワードが間違っています。<br>確認してください。"
      render :action => 'new'
    end
  end

  def destroy
    logout_killing_session!
    flash[:notice] = "You have been logged out."
    redirect_back_or_default('/')
  end

protected
  # Track failed login attempts
  def note_failed_signin
    flash[:error] = "Couldn't log you in as '#{params[:login]}'"
    logger.warn "Failed login for '#{params[:login]}' from #{request.remote_ip} at #{Time.now.utc}"
  end
end
