create_company = lambda do
  company = JSON.parse(request.body.read, :symbolize_names => true)
  user = current_user
  user.company.update(monetiz_direct_freemium: company[:monetiz] == 'monetiz_direct_freemium', monetiz_direct_standard: company[:monetiz] == 'monetiz_direct_standard', monetiz_indirect_standard: company[:monetiz] == 'monetiz_indirect_standard', monetiz_indirect_two_sided: company[:monetiz] == 'monetiz_indirect_two_sided')
  if company[:monetiz] == 'monetiz_direct_standard' #monetiz_direct_standard skips '/users' ::: monetiz_indirect_standard skips '/customers'
    user.company.update(user_consumer: company[:user] = false, user_sme: company[:user] = false, user_enterprise: company[:user] = false, user_other: company[:user] = false)
  elsif company[:monetiz] == 'monetiz_indirect_standard'
    user.company.update(payer_consumer: company[:payer] = false, payer_sme: company[:payer] = false, payer_enterprise: company[:payer] = false, payer_other: company[:payer] = false)
  end #end skipping questions
  status 200
end

set_users = lambda do
  company = JSON.parse(request.body.read, :symbolize_names => true)
  user = current_user
  user.company.update(user_consumer: company[:user] == 'user_consumer', user_sme: company[:user] == 'user_sme', user_enterprise: company[:user] == 'user_enterprise', user_other: company[:user] == 'user_other')
  status 200
end

set_customers = lambda do
  company = JSON.parse(request.body.read, :symbolize_names => true)
  user = current_user
  user.company.update(payer_consumer: company[:payer] == 'payer_consumer', payer_sme: company[:payer] == 'payer_sme', payer_enterprise: company[:payer] == 'payer_enterprise', payer_other: company[:payer] == 'payer_other')
  status 200
end

set_conversion = lambda do
  company = JSON.parse(request.body.read, :symbolize_names => true)
  user = current_user
  user.company.update(conv_lead_payer: company[:conv_lead_payer]||false, conv_other: company[:conv_other]||false, conv_user_payer: company[:conv_user_payer]||false, conv_visitor_lead: company[:conv_visitor_lead]||false, conv_visitor_payer: company[:conv_visitor_payer]||false, conv_visitor_user: company[:conv_visitor_user]||false)
  status 200
end

set_life_cycle = lambda do
  company = JSON.parse(request.body.read, :symbolize_names => true)
  user = current_user
  user.company.update(life_day: company[:lifecycle] == 'life_day', life_week: company[:lifecycle] == 'life_week', life_month: company[:lifecycle] == 'life_month', life_quarter: company[:lifecycle] == 'life_quarter', life_year: company[:lifecycle] == 'life_year',
                      life_two_years: company[:lifecycle] == 'life_two_years', life_three_years: company[:lifecycle] == 'life_three_years', life_four_years: company[:lifecycle] == 'life_four_years',
                      life_five_years: company[:lifecycle] == 'life_five_years', life_more_five_years: company[:lifecycle] == 'life_more_five_years')
  status 200
end

set_acquisition = lambda do
  company = JSON.parse(request.body.read, :symbolize_names => true)
  user = current_user
  acquisition_channel =  company[:acquisition_channel]
  user.company.update(acqu_affiliate: acquisition_channel == 'acqu_affiliate', acqu_app_store: acquisition_channel == 'acqu_app_store',
    acqu_biz_dev: acquisition_channel == 'acqu_biz_dev', acqu_blogs: acquisition_channel == 'acqu_blogs', acqu_campaigns: acquisition_channel == 'acqu_campaigns',
    acqu_conferences: acquisition_channel == 'acqu_conferences', acqu_direct_sales: acquisition_channel == 'acqu_direct_sales', acqu_domains: acquisition_channel == 'acqu_domains',
    acqu_email: acquisition_channel == 'acqu_email', acqu_other: acquisition_channel == 'acqu_other', acqu_pr: acquisition_channel == 'acqu_pr', acqu_sem: acquisition_channel == 'acqu_sem',
    acqu_seo: acquisition_channel == 'acqu_seo', acqu_social_media: acquisition_channel == 'acqu_social_media', acqu_sponsorship: acquisition_channel == 'acqu_sponsorship',
    acqu_telemarketing: acquisition_channel == 'acqu_telemarketing', acqu_tv: acquisition_channel == 'acqu_tv', acqu_viral_referral: acquisition_channel == 'acqu_viral_referral',
    acqu_widgets: acquisition_channel == 'acqu_widgets', acqu_word_of_mouth: acquisition_channel == 'acqu_word_of_mouth', acqu_radio: acquisition_channel == 'acqu_radio')
  status 200
end

set_revenue = lambda do
  company = JSON.parse(request.body.read, :symbolize_names => true)
  user = current_user
  revenue_channel = company[:revenue_channel]
  user.company.update(rev_advertising: revenue_channel == 'rev_advertising', rev_consulting: revenue_channel == 'rev_consulting',
                      rev_data: revenue_channel == 'rev_data', rev_hardware: revenue_channel == 'rev_hardware',
                      rev_lead_generation: revenue_channel == 'rev_lead_generation', rev_license: revenue_channel == 'rev_license',
                      rev_listing: revenue_channel == 'rev_listing', rev_ownership: revenue_channel == 'rev_ownership',
                      rev_rental: revenue_channel == 'rev_rental', rev_sponsorship: revenue_channel == 'rev_sponsorship',
                      rev_subscription: revenue_channel == 'rev_subscription', rev_transaction: revenue_channel == 'rev_transaction',
                      rev_unit_selling: revenue_channel == 'rev_unit_selling', rev_virtual_goods: revenue_channel == 'rev_virtual_goods')
  status 200

  ### (Analysis R) SEGMENT-CLUSTERING ##########################################################
  r_result    = AnalysisR.segment_cluster(user.company.id)

  # if result != true, the execution exited with an error-code != 0 (false) or failed completely (nil)
  if ! r_result
    printf "There was an error executing the (segment-cluster) Analysis R code: %s (%s)\n", $?, r_result.inspect    # $? will hold the bash-error-code in case of an execution-error
    status 500
  end #if-else
end


post '/company', requires_authentication: true, &create_company
post '/company/monetization', requires_authentication: true, &create_company
post '/company/users', requires_authentication: true, &set_users
post '/company/customers', requires_authentication: true, &set_customers
post '/company/conversion', requires_authentication: true, &set_conversion
post '/company/lifecycle', requires_authentication: true, &set_life_cycle
post '/company/acquisition', requires_authentication: true, &set_acquisition
post '/company/revenue', requires_authentication: true, &set_revenue