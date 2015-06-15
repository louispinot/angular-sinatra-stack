require "pry"

NESTING = {
  ONLINE_ADS: ["ADWORDS",
               "SEO",
               "SOCIAL",
               "AFFILIATE_AND_LEAD_GENERATION",
               "CONTENT_MARKETING",
               "MOBILE",
               "EMAIL",
               "DISPLAY_ADS"]
}

STD_METRICS = [
  "ADWORDS",
  "SEO",
  "SOCIAL",
  "AFFILIATE_AND_LEAD_GENERATION",
  "CONTENT_MARKETING",
  "MOBILE",
  "EMAIL",
  "DISPLAY_ADS",
  "OFFLINE_ADS",
  "DIRECT_SALES",
  "PR",
  "VIRAL_AND_REFERRAL",
  "APPSTORES_AND_MARKETPLACES"
]
save_metrics = lambda do
  raw_data = JSON.parse(request.body.read, :symbolize_names => true)
  company = current_user.company
  unnested_data = unnest(raw_data)

  six_recent_months(true).each do |m|
    record = CompanyMetricsManualMonth.where(company_id: company.id).find_or_initialize_by(start_datetime: m)
    data_json = record.data_json
    unnested_data.each do |metric|
      metric_name = metric[:name]
      if metric[:remove] && !STD_METRICS.include?(metric_name) # /!\ only custom metrics can be deleted
        data_json.delete(metric_name)
        next
      end

      metric[:data].each do |hash|
        data_json[metric_name] = {value: hash[:value], source: "manual", custom_metric: metric[:custom]} if symbol_to_formatted_datetime(hash[:month]) == m
      end
    end
    record.update_attributes(data_json: data_json)
  end

  return 200
end

get_metrics = lambda do
  company = current_user.company
  six_month_ago = symbol_to_formatted_datetime(Date.today.strftime('%b %Y')) - 5.month
  manual_metrics = company.company_metrics_manual_months.where("start_datetime >= ?", six_month_ago)

  if manual_metrics.empty?
    return blank_data.to_json
  end

  metrics_list = get_metrics_list(manual_metrics)
  data = []

  metrics_list.each do |metric_name|
    metric_hash = {name: metric_name}

    temp_array = []
    manual_metrics.each do |record|
      record.data_json.each do |key, value_hash|
        if key == metric_name
          metric_hash[:custom] = value_hash["custom_metric"]
          temp_array << {value: value_hash["value"], month: record.start_datetime.strftime('%b %Y')}
        end
      end
    end

    metric_hash[:data] = temp_array.sort {|x, y| symbol_to_formatted_datetime(x[:month]) <=> symbol_to_formatted_datetime(y[:month])}
    # inserts empty values for a blank column if we've entered a new month
    metric_hash[:data] << {value: nil, month: Date.today.strftime('%b %Y')} if manual_metrics.count == 5

    data << metric_hash
  end
  data = nest(data)

  return {manual_metrics: data, months: six_recent_months}.to_json
end

post '/manual_metrics', &save_metrics
get '/manual_metrics', &get_metrics

def nest(data)
  NESTING.each do |top_level, nested|
     nested_metrics = data.select {|metric| nested.include? metric[:name]}
     data.unshift({
              name: top_level,
              nested:nested_metrics
            }) # unshift inserts in first spot of the array
     data.delete_if {|metric| nested.include? metric[:name]}
  end
  return data
end

def get_metrics_list(records)
  # extracts the list of different manual metrics we have for that company
  metrics_array = []
  records.each do |record|
    metrics_array << record.data_json.keys
  end
  metrics_array.flatten.uniq
end


def unnest(data)
  data.each do |metric|
    if metric[:nested]
      metric[:nested].each do |nested_metric|
        data << nested_metric
      end
      data.delete(metric)
    end
  end
  return data
end

def symbol_to_formatted_datetime(month)
  # transform array of months formatted as string into array of dates formatted like company_metrics_months.start_datetime
  Time.parse(month.to_s).utc - Time.parse(month.to_s).utc.hour.hours()
end

def six_recent_months(time_format = false)
  this_month = Date.today.strftime('%b %Y')
  this_month = symbol_to_formatted_datetime(this_month)
  months = [this_month]
  5.times { months.unshift(months[0]-1.month) } # .unshift insert at index 0

  # returns an array of the 6 most recent months formatted for like a string or like our metrics' start_datetime
  time_format ? months : (months.map {|m| m.strftime('%b %Y') })
end

def blank_data
  data = []
  STD_METRICS.each do |metric_name|
    metric_hash = {name: metric_name, data: [], custom: false}
    six_recent_months.each do |month|
      metric_hash[:data] << {month: month, value: nil}
    end
    data << metric_hash
  end
  {manual_metrics: nest(data), months: six_recent_months}
end
