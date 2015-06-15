create_session = lambda do
  user_json = JSON.parse(request.body.read, :symbolize_names => true)
  user = User.authenticate(user_json[:email], user_json[:password])

  unless user
    logger.info 'User %s not found.' % user_json[:email]
    halt 401, {status: 'error', message: 'Invalid credentials.'}.to_json
  end

  user.create_session
  logger.info 'Session created for %s.' % user.email

  # publish service connected message if no data on dashboard. Helps handle migration of existing users.
  if user.google_connected? && !CompanyMetricsMonth.where(company_id: user.company.id).exists?
    logger.info( 'Publishing MESSAGE_SERVICE_CONNECTED again because no metrics when on dashboard: for user %s' % [user.email] )
    Publisher.simple_publish('hub_service_connected', {message: 'MESSAGE_SERVICE_CONNECTED', opts: { postgres_company_id: user.company.id, service_type: 'GOOGLE'}}.to_json)
  end

  {session_token: user.session_token}.to_json
end

post '/sessions', &create_session