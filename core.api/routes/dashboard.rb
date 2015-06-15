def graph(metric, company_metrics, neighbours_metrics)
  area_values, bottom_quantile, bottom_values, top_quantile, top_values, company_values = Performance.benchmark_google_analytics(neighbours_metrics, company_metrics, metric)
  {area: area_values, top_quantile: (top_quantile * 100).round(2), top: top_values.map{|x| {date: x[:date], value: x[:value] } },
   company: company_values, bottom_quantile: (bottom_quantile * 100).round(2), bottom: bottom_values.map{|x| {date: x[:date], value: x[:value] }}}
end

performance = lambda do

  user = current_user
  company = user.company
  company_metrics = user.company.company_metrics_months.to_a
  google_connected = user.google_connected?

  halt 200, {unique_visitors: nil, time_on_site: nil, bounce_rate: nil, returning_visitors: nil, google_connected: google_connected}.to_json if company_metrics.empty?

  min_date, max_date = company_metrics.min_by{|d| d.start_datetime}.start_datetime, company_metrics.max_by{|d| d.start_datetime}.start_datetime
  neighbours_metrics = Benchmark.neighbours_google_analytics(company, min_date, max_date)

  halt 200, {unique_visitors: nil, time_on_site: nil, bounce_rate: nil, returning_visitors: nil, google_connected: google_connected}.to_json if neighbours_metrics.empty?

  unique_visitors = graph('NO_OF_VISITORS', company_metrics, neighbours_metrics)
  time_on_site = graph('AVG_TIME_ON_SITE', company_metrics, neighbours_metrics)
  bounce_rate = graph('BOUNCE_RATE', company_metrics, neighbours_metrics)

  # with bounce rate you invert as a high bounce rate is a poor outcome
  bounce_rate[:top_quantile], bounce_rate[:bottom_quantile] = bounce_rate[:bottom_quantile], bounce_rate[:top_quantile]
  bounce_rate[:top], bounce_rate[:bottom] = bounce_rate[:bottom], bounce_rate[:top]

  returning_visitors = graph('NO_OF_VISITORS_RETURNING', company_metrics, neighbours_metrics)

  {unique_visitors: unique_visitors, time_on_site: time_on_site, bounce_rate: bounce_rate, returning_visitors: returning_visitors, google_connected: google_connected}.to_json
end

effective_sources = lambda do
  user = current_user
  google_connected = user.google_connected?
  most_recent_metric = CompanyMetricsMonth.where(company_id: user.company.id).max_by{|x| x.start_datetime}

  halt 200, {google_connected: google_connected}.to_json unless most_recent_metric

  neighbours = Benchmark.get_neighbours(user.company)

  halt 200, {google_connected: google_connected}.to_json if neighbours.empty?

  neighbours_metrics_max = CompanyMetricsMonth.where(company_id: neighbours.map{|x| x.id}).maximum(:start_datetime)
  neighbours_metrics = CompanyMetricsMonth.where(company_id: neighbours.map{|x| x.id}).where(start_datetime: neighbours_metrics_max).to_a

  channels = [:direct, :organic, :display, :email, :paid, :referral, :social]
  neighbours_effectiveness = {}

  neighbours_metrics.each{|m|
    channels.each {|k|
      channel_visitors = k.to_s.upcase + '_NO_OF_VISITORS_NEW'
      # only include neigbour if channel has more than 100 visitors
      if m.data[channel_visitors] && m.data[channel_visitors]['value'] > 100
        unless neighbours_effectiveness[k]
          neighbours_effectiveness[k] = []
        end
        neighbours_effectiveness[k] << Performance.calculate_effective(m,  channel_visitors, k.to_s.upcase + '_NO_OF_BOUNCES_NEW', k.to_s.upcase + '_NO_OF_VISITS_NEW')
      end
    }
  }

  effective_sources = {google_connected: google_connected}

  channels.each do |c|
    # ony plot channel if greater than 100 visits
    channel_visitors = c.to_s.upcase + '_NO_OF_VISITORS_NEW'
    if !most_recent_metric.data[channel_visitors] || most_recent_metric.data[channel_visitors]['value'] < 100
      effective_sources[c] = {value: [], top: [], bottom: []}
      next
    end
      value = Performance.calculate_effective(most_recent_metric, channel_visitors, c.to_s.upcase + '_NO_OF_BOUNCES_NEW', c.to_s.upcase + '_NO_OF_VISITS_NEW')
      # only benchmark if at least three neighbours
    if neighbours_effectiveness[c].count > 2
      top = [neighbours_effectiveness[c].select { |x| x.first && x.last }.map { |x| x.first }.quantile(0.9), neighbours_effectiveness[c].select { |x| x.first && x.last }.map { |x| x.last }.quantile(0.9)]
      bottom = [neighbours_effectiveness[c].select { |x| x.first && x.last }.map { |x| x.first }.quantile(0.1), neighbours_effectiveness[c].select { |x| x.first && x.last }.map { |x| x.last }.quantile(0.1)]
    end
    top ||= []
    bottom ||= []
    validate_top_quantile(value, top)
    validate_bottom_quantile(value, bottom)
    effective_sources[c] = {value: value, top: top, bottom: bottom}

  end
  effective_sources.to_json
end

# ensure benchmarks always fall around company values
def validate_top_quantile(company, benchmark)
  return if benchmark.length == 0 || company.length != 2

  if company[0] > benchmark[0]
    benchmark[0] = company[0]
  end
  if company[1] > benchmark[1]
    benchmark[1] = company[1]
  end
end

def validate_bottom_quantile(company, benchmark)
  return if benchmark.length == 0 || company.length != 2

  if company[0] < benchmark[0]
    benchmark[0] = company[0]
  end
  if company[1] < benchmark[1]
    benchmark[1] = company[1]
  end
end

resource_allocation = lambda do
  user = current_user
  recent_manual_metrics = user.company.company_metrics_manual_months.last_six_months.to_a
  resource_values = recent_manual_metrics.map{|m| m.data.map{|k,v| {metric_name: k, value: v['value'], date: m.start_datetime}}}.
      flatten.group_by{|m| m[:metric_name]}.
      map{|k, v| {name: k, data: v.sort_by{|m| m[:date]}.map{|m| m[:value]}}}

  monthly_totals = recent_manual_metrics.map do |m|
    sum = 0
    m.data.each{|k, v| sum += v['value'] if v['value'] }
    [m.start_datetime.strftime('%b %Y'), sum]
  end
  monthly_totals = Hash[monthly_totals] # Hash[[:a,:b],[:c,:d]] produces {:a => :b, :c => :d}

  {months: recent_manual_metrics.map{|x| x.start_datetime.strftime('%b %Y')}, values: resource_values, monthly_totals: monthly_totals}.to_json
end

get '/dashboard/performance', requires_authentication: true, &performance
get '/dashboard/effective_sources', requires_authentication: true, &effective_sources
get '/dashboard/resource_allocation', requires_authentication: true, &resource_allocation
