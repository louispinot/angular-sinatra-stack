require File.expand_path(File.dirname(__FILE__) + "/../spec_helper")

describe "POST /sessions" do
  before(:each) do
    @user_json = double("user_json", :[] => "")
    @user = double('user')
    allow(JSON).to receive(:parse).and_return @user_json
    allow(User).to receive(:authenticate).and_return @user
  end

  it "creates a session for the user" do
    expect(@user).to receive(:create_session)
    post '/sessions'
  end
  it 'responds with 401 if no user is found' do
    allow(User).to receive(:authenticate).and_return nil
    post '/sessions'
    expect(last_response.status).to eq 401
  end
  # TO DO: write more tests for this route.

end