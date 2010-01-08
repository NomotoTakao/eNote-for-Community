module AuthenticatedTestHelper
  # Sets the current m_user in the session from the m_user fixtures.
  def login_as(m_user)
    @request.session[:m_user_id] = m_user ? (m_user.is_a?(MUser) ? m_user.id : m_users(m_user).id) : nil
  end

  def authorize_as(m_user)
    @request.env["HTTP_AUTHORIZATION"] = m_user ? ActionController::HttpAuthentication::Basic.encode_credentials(m_users(m_user).login, 'monkey') : nil
  end
  
end
