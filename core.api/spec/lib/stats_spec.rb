# require 'rspec'
# require File.dirname(__FILE__) + '/../../services/stats.rb'
require File.expand_path(File.dirname(__FILE__) + "/../spec_helper")

describe 'calculating quantile' do

  it 'should return number at rank if divides evenly' do
    expect([1,2,3,4,5,6,7].quantile(0.5)).to eq 4
  end

  it 'should interpolate if not dividing equally' do
    # test cases taken from http://pandas.pydata.org/pandas-docs/dev/generated/pandas.DataFrame.quantile.html
    expect([1,2,3,4].quantile(0.1)).to eq 1.3
    expect([1,10,100,100].quantile(0.1)).to eq 3.7
    expect([1,2,3,4].quantile(0.5)).to eq 2.5
    expect([1,10,100,100].quantile(0.5)).to eq 55.0
  end
end

describe 'calculating quantile of score' do

  it 'should return the quantile for the provided score' do
    expect([1,2,3,4,5].quantile_of_score(2)).to eq 0.25
    expect([1,2,3,4,5].quantile_of_score(3)).to eq 0.5
  end

end