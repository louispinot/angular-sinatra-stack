helpers do
  def current_user
    # return unless request.env['HTTP_X_API_SESSIONTOKEN']
    # @user ||= User.eager_load(:company).find_by(session_token: request.env['HTTP_X_API_SESSIONTOKEN'])
  end
end