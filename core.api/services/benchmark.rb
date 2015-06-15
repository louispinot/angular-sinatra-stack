module Benchmark
  # for a given company return neighbours that have google analytics
  def self.get_neighbours(company)
    segment = company.segment_type

    companies = Company.joins(:lifestages).joins(:saas_connections).where(segment_type: segment, 'saas_connections.service_type' => 'GOOGLE').order('lifestages.modeled_lifestage').to_a
    company_ids =  companies.map {|x| x.id}
    i = company_ids.find_index(company.id)
    return [] unless i
    size = companies.length / 20.0
    return [] if companies.length <= 1
    companies[i-size..i+size]
  end

  # get google analytics for neighbours
  def self.neighbours_google_analytics(company, min_date, max_date)
    neighbours = get_neighbours(company)
    CompanyMetricsMonth.where(company_id: neighbours.map{|x| x.id}).where(start_datetime: min_date..max_date).to_a
  end


  def self.most_recent_month(neighbours_metrics, company_metrics)
    # filter out company_metrics from neighbours_metrics
    company_id = company_metrics.first.company.id
    excluded_google_data = neighbours_metrics.select{|x| x.company_id != company_id}

    # most recent date that we have for both neighbours_metrics and company_metrics
    most_recent_date = (excluded_google_data.map{|x| x.start_datetime} & company_metrics.map{|x| x.start_datetime}).max

    # most recent record that we have for both neighbours_metrics and company_metrics so as to calculate quantile
    company_metrics.find {|x| x.start_datetime == most_recent_date}
  end
end