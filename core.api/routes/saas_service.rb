require 'compassshared/constants/services'

saas_service_url = lambda do
  available_services = ['GOOGLE', 'STRIPE']
  urls = {}
  available_services.each do |service_name|
    service = service_name.constantize
    url = service[:authorize_url] +
        '?response_type='   + 'code' +
        '&scope='           + service[:authorize_opts][:scope] +
        '&client_id='       + service[:CLIENT_KEY] +
        '&redirect_uri='    + sprintf( service[:redirect_uri_raw], request.env['rack.url_scheme'], request.env['HTTP_HOST'].sub(':80$','') ) +
        '&state='           + request.env['HTTP_X_API_SESSIONTOKEN'] +
        service[:additional_oauth_options]
      urls[service[:name]] = url
    logger.info( sprintf('Service-connect: Creating URL for %s: %s.', service[:name],  url) )
  end

  {url: urls}.to_json
end #saas_service_url

saas_service_callback = lambda do
  user = User.find_by(session_token: params[:state])
  logger.info( 'Service-connect: Receiving callback from %s for %s (id: %s)' % [params[:service_name], user.email, user.id] )
  content_type 'text/html'
  service = params[:service_name].upcase.constantize

  if params[:error]
    logger.info('Error getting the auth_ or refresh_token from %s: %s' % [service[:name], params[:error]])
    return File.read "#{Dir.pwd}/core.client/close_popup.html"
  end

  logger.info( 'Connecting %s: Creating credentials for %s.' % [service[:name], user.email] )
  client = Saas.client(service)
  access_token = client.auth_code.get_token(params[:code], :redirect_uri => sprintf( service[:redirect_uri_raw], request.env['rack.url_scheme'], request.env['HTTP_HOST'].sub(':80$','') ))

  saas_connection = user.company.saas_connections.find_or_create_by(service_type: service[:name])
  # NB: setting is_valid to true unless the service is google, in which case you also need to set the profile in order for it to be valid
  saas_connection.update_attributes(auth_data_string: {access_token: access_token.token, refresh_token: access_token.refresh_token, expires_in: access_token.expires_in}.to_json,
                                  is_valid: (service[:name] != 'GOOGLE'))

  unless service[:name] == 'GOOGLE'
    logger.info( 'Publishing MESSAGE_SERVICE_CONNECTED: for user %s: saving credentials (@id: %s), sending Rabbit-message.' % [user.email, saas_connection.id] )
    # Publisher.simple_publish('hub_service_connected', {message: 'MESSAGE_SERVICE_CONNECTED', opts: {credentials_id: saas_connection.id, postgres_company_id: user.company.id, service_type: service[:name]}}.to_json)
    Publisher.simple_publish('hub_meta_service_connected', {message: 'MESSAGE_DEFAULT', opts: {credentials_id: saas_connection.id, company_id: user.company.id, service_type: service[:name]}}.to_json)

  end

  return File.read "#{Dir.pwd}/core.client/index.html"
end

###################################################################
####################   GOOGLE SPECIFIC ROUTES  ####################
###################################################################

google_profiles = lambda do
  user          = current_user
  logger.info( 'Service-connect: About to analyse GA profiles for new connection (%s).' % user.email )
  credential    = user.company.saas_connections.find_by(service_type: 'GOOGLE')
  auth_client   = OAuth2::AccessToken.new(Saas.client(GOOGLE), credential.auth_data['access_token'])
  logger.info( 'Service-connect: Analyzing GA profiles for new connection.' )
  accounts      = Saas.google_analytics_profiles(auth_client)
  unless accounts
    halt 403, {message: "There was a problem fetching your account information, please try again later."}.to_json
  end
  logger.info( 'Service-connect: Finished analyzing GA profiles for new connection.' )
  accounts.to_json
end

google_set_profile = lambda do
  user = current_user
  json = JSON.parse(request.body.read, :symbolize_names => true)
  logger.info( 'Service-connect: Setting profiles as final step of GA hookup (%s/%s): saving credentials, sending Rabbit-message.' % [user.email, (json[:data] rescue '???')] )
  saas_connection = user.company.saas_connections.find_by(service_type: 'GOOGLE')
  saas_connection.auth_data = saas_connection.auth_data.merge(json[:data])
  saas_connection.is_valid = true
  saas_connection.save
  # quickfix by Rayo on 2015-01-31, replacing publish() call
  logger.info( 'Publishing MESSAGE_SERVICE_CONNECTED: for user %s: saving credentials (@id: %s), sending Rabbit-message.' % [user.email, saas_connection.id] )
  # Publisher.simple_publish('hub_service_connected', {message: 'MESSAGE_SERVICE_CONNECTED', opts: {credentials_id: saas_connection.id, postgres_company_id: user.company.id, service_type: 'GOOGLE'}}.to_json)
  Publisher.simple_publish('hub_meta_service_connected', {message: 'MESSAGE_DEFAULT', opts: {credentials_id: saas_connection.id, company_id: user.company.id, service_type: 'GOOGLE'}}.to_json)
  status 200
end

####################  end GOOGLE SPECIFIC ROUTES  ####################

get '/connection_urls', requires_authentication: true, &saas_service_url
get '/callback/:service_name', requires_authentication: false, &saas_service_callback
get '/google/profiles', requires_authentication: true, &google_profiles
post '/google/profile', requires_authentication: true, &google_set_profile