module Performance

  def self.benchmark_google_analytics(neighbours_metrics, company_metrics, metric)

    most_recent_metric = Benchmark.most_recent_month(neighbours_metrics, company_metrics)

    if most_recent_metric == nil || !most_recent_metric.data[metric]
      return [], 0, [], 1, [], []
    end

    my_quantile = neighbours_metrics.
        select { |x| x.start_datetime == most_recent_metric.start_datetime && x.data[metric]}.
        map { |x| x.data[metric]['value'] }.
        quantile_of_score(most_recent_metric.data[metric]['value'])

    top_quantile = 1-(1-my_quantile)/2.0
    bottom_quantile = my_quantile/2.0

    months = company_metrics.map { |x| x.start_datetime }.uniq.sort
    top_values, bottom_values, area_values, company_values = [], [], [], []

    months.each do |m|
      if neighbours_metrics.any? {|e| e.start_datetime == m && e.id != company_metrics.first.id} && company_metrics.any? {|x| x.start_datetime == m}
        monthset = neighbours_metrics.select { |x| x.start_datetime == m && x.data[metric]}
        top = monthset.map { |x| x.data[metric]['value'] }.quantile(top_quantile).round(2) rescue nil # quickfix by Louis: when the value is nil, .round() raises an error
        bottom = monthset.map { |x| x.data[metric]['value'] }.quantile(bottom_quantile).round(2) rescue nil # quickfix by Louis: when the value is nil, .round() raises an error
      end
      if company_metrics.find{|x| x.start_datetime == m}.data[metric]
        company = company_metrics.find{|x| x.start_datetime == m}.data[metric]['value']
      end
      top_values << {date: m.strftime('%b %y'), value: top}
      bottom_values << {date: m.strftime('%b %y'), value: bottom}
      area_values << {value: [m.strftime('%b %y'), bottom, top]}
      company_values << {date: m.strftime('%b %y'), value: company}
    end

    return area_values, bottom_quantile, bottom_values, top_quantile, top_values, company_values

  end

  def self.calculate_effective(month, metric_visitors, metric_bounce, metric_visits)
    # TO DO: the "&& month.data['NO_OF_VISITORS_NEW']" part of that statement, and maybe the others too, are just quickfixes.
    # "&& month.data['NO_OF_VISITORS_NEW']" rescues the case where the company doesn't have such metric, so calling ['value'] on it throws an error
    unless month && month.data[metric_visitors] && month.data[metric_bounce] && month.data[metric_visits] && month.data['NO_OF_VISITORS_NEW']
      return []
    end
    x = 100 * month.data[metric_visitors]['value'] / month.data['NO_OF_VISITORS_NEW']['value'].to_f
    y = 100 - 100 * month.data[metric_bounce]['value'] / month.data[metric_visits]['value'].to_f
    [x.round(2), y.round(2)]
  end

end