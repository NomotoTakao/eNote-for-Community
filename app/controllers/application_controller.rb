# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details

  include AuthenticatedSystem

  # Scrub sensitive parameters from your log
  # filter_parameter_logging :password

  before_filter :login_required

  #  before_filter :authorize, :except => [:login]
  before_filter :disp_head

  #ヘッダ部やメニュー用のデータを生成します
  def disp_head
    @pankuzu = "eNote > "
    if logged_in?
      @user_message = "お疲れさまです。" + current_m_user.name + " さん。"
      @user_message += MCompany.get_company_all_list[0].scroll_text

      #ヘッダー部に表示用のメニューインスタンス
      @head_menus = MMenu.get_menu_head_data(current_m_user.user_cd)
      #サイドメニュー部表示用のメニューインスタンス
      @side_menus = MMenu.get_menu_side_data(current_m_user.user_cd)
    end
  end

end
