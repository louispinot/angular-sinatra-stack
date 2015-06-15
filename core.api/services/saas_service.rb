
class Saas

  def self.client(service)
    OAuth2::Client.new(service[:CLIENT_KEY], service[:CLIENT_SECRET], {
                                               :site => service[:site],
                                               :authorize_url => service[:authorize_url],
                                               :token_url => service[:token_url]
                                           })
  end #client()


  ###################################################################
  ####################   GOOGLE SPECIFIC METHODS   ##################
  ###################################################################
  def self.google_analytics_profiles( auth_client )
    accounts = []
    resp = Saas.auth_client_request_with_quickfix_error_handling( auth_client, 'https://www.googleapis.com/analytics/v3/management/accounts' )
    data = JSON.parse(resp.body)
    if data['items']
      data['items'].each do |d|
        account = {}
        web_properties = []
        resp = Saas.auth_client_request_with_quickfix_error_handling( auth_client, d['childLink']['href'] )
        wps = JSON.parse(resp.body)
        if wps['items']
          wps['items'].each do |wp|
            web_property = {}
            profiles = []
            resp = Saas.auth_client_request_with_quickfix_error_handling( auth_client, wp['childLink']['href'] )
            ps = JSON.parse(resp.body)
            if ps['items']
              ps['items'].each do |p|
                profile = {:name => p['name'], :id => p['id']}
                profiles.push(profile)
              end
            end
            web_property[:name] = wp['name']
            web_property[:profiles] = profiles
            if profiles.count > 0
              web_properties.push(web_property)
            end
          end
        end
        account[:name] = d['name']
        account[:web_properties] = web_properties
        if web_properties.count > 0
          accounts.push(account)
        end
      end
    end
    accounts
  rescue
    nil
  end

  def self.auth_client_request_with_quickfix_error_handling( auth_client, url )
    begin
      resp = auth_client.get( url )
    rescue OAuth2::Error, StandardError
      # error ignored. this is a quickfix
      # I assume that it's a userRateLimitExceeded-problem, wait a second and try again :)
      sleep 1
      resp = auth_client.get( url )
    end #begin-rescue

    return resp
  end #auth_client_request_with_quickfix_error_handling()

  ####################  (end) GOOGLE SPECIFIC METHODS   ##################

end