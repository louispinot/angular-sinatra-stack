require File.expand_path(File.dirname(__FILE__) + "/../spec_helper")

describe 'POST /feedback/submit' do
  before(:each) do
    @http_header = {'HTTP_X_API_SESSIONTOKEN' => "mock_token"} # you have to set this http header otherwise the route raises an error
    @user = double('user', email: "")
    @feedback = double('feedback', :[] => "")
    allow(User).to receive_message_chain(:eager_load, :find_by).and_return @user
    allow(JSON).to receive(:parse).and_return @feedback
  end

  it 'creates a new instance of feedback on the user' do
    expect(@user).to receive_message_chain(:feedbacks, :create)
    post '/feedback/submit', nil, @http_header
  end

  it 'publishes a message to the Hub' do
    allow(@user).to receive_message_chain(:feedbacks, :create)
    expect(Publisher).to receive(:simple_publish)
    post '/feedback/submit', nil, @http_header
  end

  it 'responds with 200' do
    allow(@user).to receive_message_chain(:feedbacks, :create)
    allow(Publisher).to receive(:simple_publish)
    post '/feedback/submit', nil, @http_header
    expect(last_response.status).to eq 200
  end

end
