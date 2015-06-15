get_traffic_lights_data = lambda do
  company = current_user.company
  company_metrics_months = company.company_metrics_months.order(start_datetime: :desc)[0..1] # i.e. current and last month

  if company_metrics_months.length == 0
    return {
      status: :no_data,
      data: {
        bounce_rate: {tier: :notDefined}.merge(TrafficLights::METRICS_INFO[:bounce_rate]),
        avg_time_on_site: {tier: :notDefined}.merge(TrafficLights::METRICS_INFO[:avg_time_on_site]),
        pages_per_visit: {tier: :notDefined}.merge(TrafficLights::METRICS_INFO[:pages_per_visit]),
        returning_visitors: {tier: :notDefined}.merge(TrafficLights::METRICS_INFO[:returning_visitors]),
        avg_time_page_load: {tier: :notDefined}.merge(TrafficLights::METRICS_INFO[:avg_time_page_load]),
        bounce_rate_direct_new: {tier: :notDefined}.merge(TrafficLights::METRICS_INFO[:bounce_rate_direct_new]),
        bounce_rate_display_new: {tier: :notDefined}.merge(TrafficLights::METRICS_INFO[:bounce_rate_display_new]),
        bounce_rate_paid_new: {tier: :notDefined}.merge(TrafficLights::METRICS_INFO[:bounce_rate_paid_new]),
        bounce_rate_organic_new: {tier: :notDefined}.merge(TrafficLights::METRICS_INFO[:bounce_rate_organic_new]),
        bounce_rate_email_new: {tier: :notDefined}.merge(TrafficLights::METRICS_INFO[:bounce_rate_email_new]),
        bounce_rate_referral_new: {tier: :notDefined}.merge(TrafficLights::METRICS_INFO[:bounce_rate_referral_new]),
        bounce_rate_social_new: {tier: :notDefined}.merge(TrafficLights::METRICS_INFO[:bounce_rate_social_new])
      }
    }.to_json
  end

  hash = {status: :has_data, data: {}}
  hash[:data][:bounce_rate] = TrafficLights.get_simple_metric(:bounce_rate, company_metrics_months)
  hash[:data][:avg_time_on_site] = TrafficLights.get_simple_metric(:avg_time_on_site, company_metrics_months)
  hash[:data][:pages_per_visit] = TrafficLights.get_ratio_metric(:pages_per_visit, company_metrics_months)
  hash[:data][:returning_visitors] = TrafficLights.get_ratio_metric(:returning_visitors, company_metrics_months)
  hash[:data][:avg_time_page_load] = TrafficLights.get_simple_metric(:avg_time_page_load, company_metrics_months)
  hash[:data][:bounce_rate_direct_new] = TrafficLights.get_simple_metric(:bounce_rate_direct_new, company_metrics_months)
  hash[:data][:bounce_rate_display_new] = TrafficLights.get_simple_metric(:bounce_rate_display_new, company_metrics_months)
  hash[:data][:bounce_rate_paid_new] = TrafficLights.get_simple_metric(:bounce_rate_paid_new, company_metrics_months)
  hash[:data][:bounce_rate_organic_new] = TrafficLights.get_simple_metric(:bounce_rate_organic_new, company_metrics_months)
  hash[:data][:bounce_rate_email_new] = TrafficLights.get_simple_metric(:bounce_rate_email_new, company_metrics_months)
  hash[:data][:bounce_rate_referral_new] = TrafficLights.get_simple_metric(:bounce_rate_referral_new, company_metrics_months)
  hash[:data][:bounce_rate_social_new] = TrafficLights.get_simple_metric(:bounce_rate_social_new, company_metrics_months)

  hash.to_json
end

get '/traffic_lights', requires_authentication: true, &get_traffic_lights_data

