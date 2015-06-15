login_as = lambda do
  user = current_user

  if user.nil? || !settings.admins.include?(user.email)
    halt 401, {message: "You have been logged out for security reasons, you are welcome to sign in again"}.to_json
  end

  requested_user = User.find(params[:user_id]) rescue nil

  if requested_user.nil? || (params[:user_id] != requested_user.id.to_s)
    # this is to guarantee an exact match because if for instance params[:user_id] == "1076abc", .find could return the user whose id is 1076
    halt 401, {message: "You have been logged out for security reasons, you are welcome to sign in again"}.to_json
  end

  requested_user.session_token = SecureRandom.hex
  requested_user.session_expiry = Time.now.utc + (15*60)
  requested_user.save
  
  return {session_token: requested_user.session_token}.to_json
end

get '/login_as/:user_id', requires_authentication: true, &login_as
