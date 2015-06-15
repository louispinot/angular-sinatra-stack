# require 'rspec'
# require File.dirname(__FILE__) + '/../../services/performance.rb'
require File.expand_path(File.dirname(__FILE__) + "/../spec_helper")

describe 'Performance::calculate_effective' do
  before(:each) do
    pending # these tests are not functional yet

    @month = double('month', :NO_OF_VISITORS_NEW => {'value' => 2 })
    allow(@month).to receive(:data[:visitors]).and_return({'value' => 101})
    allow(@month).to receive(:data[]).with(:bounce).and_return({'value' => 1})
    allow(@month).to receive(:data[]).with(:visits).and_return({'value' => 2})
    allow(@month).to receive(:data).and_return(true)
  end

  it 'returns visitors divided by new visitors multiplied by 100' do
    expect(Performance.calculate_effective(@month, :visitors, :bounce, :visits)[0]).to eq 5050.0
  end

  it 'returns 100 subtract bounces divided by visits multiplied by 100' do
    expect(Performance.calculate_effective(@month, :visitors, :bounce, :visits)[1]).to eq 50.0
  end

end

describe "Performance::benchmark_google_analytics" do
  before(:each) do
    @neighbours_metrics = double("neighbours_metrics")
    @company_metrics = double("company_metrics")
    @metric = double("metric")

    @most_recent_data = double('most_recent_data', :[] => "data")
    @most_recent_metric = double('most_recent_metric', start_datetime: Date.today, data: @most_recent_data)
    allow(Benchmark).to receive(:most_recent_month).and_return(@most_recent_metric)
  end

  it "returns blank values if no most_recent_metric is found" do
    allow(Benchmark).to receive(:most_recent_month).and_return(nil)
    expect(Performance.benchmark_google_analytics(@neighbours_metrics, @company_metrics, @metric)).to eq [ [], 0, [], 1, [], [] ]
  end

  it "returns blank values if most_recent_metric has no data" do
    allow(@most_recent_metric).to receive_message_chain(:data, :[]).and_return nil
    expect(Performance.benchmark_google_analytics(@neighbours_metrics, @company_metrics, @metric)).to eq [ [], 0, [], 1, [], [] ]
  end

  # it "calculates the company's quantile" do
  #   expect(@neighbours_metrics).to receive_message_chain(:select, :map, :quantile_of_score).and_return(0.67)
  #   Performance.benchmark_google_analytics(@neighbours_metrics, @company_metrics, @metric)
  # end
  it "calculates top and bottom quantile values for every given month"
  it "finds the company_metrics' values for every given month"

# arriver au resto a 6h30 = sortir de la gym a 6h15 = finir workout a 6h, ie go there in 20 min
end