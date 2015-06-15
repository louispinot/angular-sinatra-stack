# FactoryGirl.define do
#   factory :user do |f|
#     f.email "factorygirl@mail.com"
#     f.encrypted_password ""
#     f.survey_completed false
#     f.session_token ""
#     f.session_expiry { Time.now.utc + (15*60) }
#     f.survey_state :none
#   end
# end