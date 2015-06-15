# require 'rspec'
# require File.dirname(__FILE__) + '/../../services/benchmark.rb'
require File.expand_path(File.dirname(__FILE__) + "/../spec_helper")

describe 'Benchmark::segment_type' do
  before(:each) do
    @company = double('company', id: 1)
    @companies = double('companies')
    @company_ids = double('company_ids')
    allow(@company).to receive(:segment_type)
    allow(Company).to receive_message_chain(:joins, :joins, :where, :order, :to_a).and_return(@companies)
    allow(@companies).to receive(:map).and_return(@company_ids)
  end
  it "returns [] unless it finds the company's id in company_ids" do
    allow(@company_ids).to receive(:find_index).and_return(nil)
    expect(Benchmark.get_neighbours(@company)).to eq []
  end
  it 'returns [] if companies.length <= 1' do
    allow(@company_ids).to receive(:find_index).and_return(100)
    allow(@companies).to receive(:length).and_return(0)
    expect(Benchmark.get_neighbours(@company)).to eq []
  end
  it 'returns an array of neighbor companies' do
    allow(@company_ids).to receive(:find_index).and_return(1)
    allow(@companies).to receive(:length).and_return(3)
    expect(@companies).to receive(:[]).and_return @companies
    expect(Benchmark.get_neighbours(@company)).to eq @companies
  end
end # describe 'Benchmark::segment_type'

describe 'Benchmark::neighbours_google_analytics' do
  before(:each) do
    @company = double('company')
    @neighbours = double('neighbours')
    allow(Benchmark).to receive(:get_neighbours).and_return(@neighbours)
    allow(@neighbours).to receive_message_chain(:select, :map)
  end

  it 'returns neighbours metrics from both old MongoDB companies and new companies' do
    allow(@neighbours).to receive(:map)
    allow(CompanyMetricsMonth).to receive_message_chain(:where, :where).and_return ["dummy array item"]
    expect(Benchmark.neighbours_google_analytics(@company, nil, nil)).to eq ["dummy array item"]
  end

end # describe 'Benchmark::neighbours_google_analytics'

describe 'Benchmark::most_recent_month' do
  before(:each) do
    @neighbours_metrics = double('neighbours')
    @metrics = double('metrics_months', start_datetime: 6)
    @company_metrics = [@metrics, @metrics, @metrics]
    @excluded_google_data = double('excluded_google_data')
    allow(@company_metrics).to receive_message_chain(:first, :company, :id)
    allow(@neighbours_metrics).to receive(:select).and_return(@excluded_google_data)
  end

  it 'finds the most recent metrics that we have for both neighbours and company so as to calculate quantile' do
    allow(@excluded_google_data).to receive(:map).and_return [1, 2, 6, 7]
    allow(@company_metrics).to receive(:map).and_return [1, 5, 6]
    expect(Benchmark.most_recent_month(@neighbours_metrics, @company_metrics)).to eq @metrics
  end
end # describe "Benchmark::most_recent_month"