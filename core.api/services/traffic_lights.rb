module TrafficLights

  METRICS_INFO = {
      :bounce_rate        => { thresholds: {red: 70, yellow: 57},
                               rounding: 1,
                               unit: '%',
                               name: 'Bounce rate'
      },
      :avg_time_on_site   => { thresholds: {red: 93, yellow: 128},
                               rounding: 0,
                               unit: 's',
                               name: 'Time on site'
      },
      :returning_visitors => { thresholds: {red: 8, yellow: 24},
                               rounding: 1,
                               unit: '%',
                               name: 'Returning visitors'
      },
      :pages_per_visit    => { thresholds: {red: 1.9, yellow: 2.7},
                               rounding: 2,
                               unit: nil,
                               name: 'Pages per visit'
      },
      :avg_time_page_load => { thresholds: {red: 15, yellow: 7.7},
                               rounding: 1,
                               unit: 's',
                               name: 'Page load time'
      },
      :bounce_rate_direct_new => { thresholds: {red: 65.95, yellow: 54.18},
                               rounding: 1,
                               unit: '%',
                               name: 'Direct Quality'
      },
      :bounce_rate_display_new => { thresholds: {red: 77.67, yellow: 62.9},
                               rounding: 1,
                               unit: '%',
                               name: 'Display Quality'
      },
      :bounce_rate_paid_new => { thresholds: {red: 78.28, yellow: 62.33},
                               rounding: 1,
                               unit: '%',
                               name: 'Paid Quality'
      },
      :bounce_rate_organic_new => { thresholds: {red: 65.77, yellow: 51.99},
                               rounding: 1,
                               unit: '%',
                               name: 'Organic Quality'
      },
      :bounce_rate_email_new => { thresholds: {red: 62.03, yellow: 47.31},
                               rounding: 1,
                               unit: '%',
                               name: 'Email Quality'
      },
      :bounce_rate_referral_new => { thresholds: {red: 70.15, yellow: 57.14},
                               rounding: 1,
                               unit: '%',
                               name: 'Referral Quality'
      },
      :bounce_rate_social_new => { thresholds: {red: 84.84, yellow: 73.5},
                               rounding: 1,
                               unit: '%',
                               name: 'Social Quality'
      }

  }

  def self.get_simple_metric(metric, metrics_months)

    value = metrics_months.first.data[metric.upcase.to_s]['value'] rescue nil

    if value.nil?
      return {tier: :notDefined}.merge(METRICS_INFO[metric])
    end

    tier = benchmark(metric, value)
    rounded_value = value.round(METRICS_INFO[metric][:rounding])

    value_last_month = metrics_months.second.data[metric.upcase.to_s]['value'] rescue nil

    if value_last_month
      delta = (value <= value_last_month ? :down : :up)
    else
      delta = nil
    end

    {value: rounded_value, delta: delta, tier: tier}.merge(METRICS_INFO[metric])
  end

  def self.get_ratio_metric(metric, metrics_months)
    if metric == :pages_per_visit
      base, divider, multiplier = :NO_OF_PAGEVIEWS, :NO_OF_VISITS, 1
    elsif metric == :returning_visitors
      base, divider, multiplier = :NO_OF_VISITORS_RETURNING, :NO_OF_VISITORS, 100
    end

    value = (metrics_months.first.data[base.to_s]['value'].to_f / metrics_months.first.data[divider.to_s]['value']) * multiplier rescue nil

    if value.nil?
      return {tier: :notDefined}.merge(METRICS_INFO[metric])
    end

    tier = benchmark(metric, value)
    rounded_value = value.round(METRICS_INFO[metric][:rounding])

    value_last_month = metrics_months.second.data[base.to_s]['value'].to_f / metrics_months.second.data[divider.to_s]['value'] rescue nil

    if value_last_month
      delta = (value <= value_last_month ? :down : :up)
    else
      delta = nil
    end

    {value: rounded_value, delta: delta, tier: tier}.merge(METRICS_INFO[metric])
  end

  def self.benchmark(metric, value)
    thresholds = METRICS_INFO[metric][:thresholds]
    if thresholds[:red] > thresholds[:yellow] # ie. the lower the better
      if value < thresholds[:yellow]
        'upper'
      elsif value > thresholds[:red]
        'lower'
      else
        'middle'
      end
    else       # ie. the higher the better
      if value > thresholds[:yellow]
        'upper'
      elsif value < thresholds[:red]
        'lower'
      else
        'middle'
      end
    end
  end
end