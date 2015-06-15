# create_user = lambda do
#   user = JSON.parse(request.body.read, :symbolize_names => true)

#   if User.where(email: user[:email]).exists?
#     halt 409, {status: 'error', message: 'User alredy exists.'}.to_json
#   end
#   user = User.create_user(user[:email], user[:password], user[:phone_number], user[:company_name])
#   {user_id: user.id}.to_json # to set the mixpanel people id
# end

# get_user = lambda do
#   user = current_user

#   unless user
#     halt 404, {status: 'error', message: 'Invalid credentials.'}.to_json
#   end

#   if user.onboarding_status == "signed_up" && !user.company.segment_type.blank? # ie when a user has signed up, filled out the clustering survey and is gonna see the dashboard for the 1st time
#     status = (user.company.saas_connections.blank? ? "survey_complete" : "data_connected")
#     user.update_attributes(onboarding_status: status)
#     user.onboarding_report
#     # TO-DO: send a new onboarding_report when user connects his first data source if he hadn't already done so during the survey
#     # Hence the 2 different status survey_complete and data_connected
#     # by Louis
#   end

#   # binding.pry for CW-122, segment_type should be nil upon signup
#   { id: user.id,
#     email: user.email,
#     survey_state: user.company.survey_state || nil,
#     lifestage_state: user.company.lifestage_state || nil,
#     survey_answers: user.company.survey_answers,
#     data_connections: user.company.data_connections,
#     phone_number: user.phone_number,
#     company_name: user.company.name,
#     website: user.company.website,
#     peergroup: user.company.peergroup,
#     company_segment: user.company.segment_type,
#     is_admin: ( (settings.admins.include? user.email ) ? true : false),
#     weekly_logins: user.weekly_logins,
#     consecutive_weeks_login: user.consecutive_weeks_login
#   }.to_json
# end

# update_user = lambda do
#   json = JSON.parse(request.body.read, :symbolize_names => true)
#   user = current_user
#   user.assign_attributes(phone_number: json[:newUser][:phone_number])
#   user.company.assign_attributes(name: json[:newUser][:company_name], website: json[:newUser][:website])

#   user.assign_attributes(encrypted_password: User.encrypt_password(json[:newPass])) if json[:newPass] #checks to see if newPass then encrypts/sets if exists

#   if user.email != json[:newUser][:email] && !User.exists?(email: json[:newUser][:email])
#     user.assign_attributes(email: json[:newUser][:email])
#   elsif user.email != json[:newUser][:email] && User.exists?(email: json[:newUser][:email])
#     user.save
#     halt 409, {status: 'error', message: 'Email has already been assigned to a user.'}.to_json
#   end
#   user.save
# end

# send_reset_email = lambda do
#   email = JSON.parse(request.body.read, :symbolize_names => true)[:email]
#   user = User.find_by(email: email)
#   unless user
#     logger.info "User was not found with email: #{email}."
#     halt 401, {status: 'error', message: 'Invalid user.'}.to_json
#   end
#   reset_token = SecureRandom.hex

#   user.update_attributes(reset_token: reset_token)
#   # send a message to the hub to send email
#   Publisher.simple_publish('hub_email', {
#                                    email_type: :password_reset,
#                                    args: {
#                                        to: user.email,
#                                        reset_token: user.reset_token
#                                    }
#                                }.to_json)
#   status 200
# end

# update_password = lambda do
#   json = JSON.parse(request.body.read, :symbolize_names => true)

#   user = User.find_by(reset_token: json[:reset_token])

#   unless user
#     logger.info "User was not found with reset_token #{json[:reset_token]}."
#     halt 404
#   end

#   user.update_attributes(encrypted_password: User.encrypt_password(json[:password]))
#   {email: user.email}.to_json
# end


# post '/users', &create_user
# get '/users', requires_authentication: true, &get_user
# post '/users/update_user', requires_authentication: true, &update_user
# post '/users/reset_password', &send_reset_email
# post '/users/update_password', &update_password




















