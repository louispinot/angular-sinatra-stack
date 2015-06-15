require File.expand_path(File.dirname(__FILE__) + "/../spec_helper")

describe 'GET /connection_urls' do
  it "is successful" do
    @user = double('user')
    http_header = {'HTTP_X_API_SESSIONTOKEN' => "mock_token"} # you have to set this http header otherwise the route raises an error
    allow(User).to receive_message_chain(:eager_load, :find_by).and_return @user # you have to stub the current user because your mocking out the HTTP_X_API_SESSIONTOKEN
    get '/connection_urls', nil, http_header
    expect(last_response.status).to eq 200
  end
end
