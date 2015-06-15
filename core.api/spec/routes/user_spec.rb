require_relative '../spec_helper'
require File.expand_path(File.dirname(__FILE__) + "/../spec_helper")

# describe 'User routes' do
  describe 'POST /users (&create_user)' do
    before(:each) do
      @user = double('user', id: 55)
      allow(User).to receive(:where).and_return(@user)
      allow(@user).to receive(:first).and_return(@user) # to pass the requires_authentication method
    end
    it 'responds with 409 if user already exists' do
      allow(@user).to receive(:exists?).and_return(true)
      post '/users', {:email => 'example@email.com', password: '12345678'}.to_json
      expect(last_response.status).to eq 409
    end

    it 'responds with 200 if normal' do
      allow(@user).to receive(:exists?).and_return(false)
      allow(User).to receive(:create_user).and_return(@user)
      post '/users', {:email => 'example@email.com', password: '12345678'}.to_json
      expect(last_response.status).to eq 200
    end
  end # describe 'POST /users (&create_user)'


  # describe 'GET /users/:session_token (&get_user)' do
  #   before(:each) do
  #     @user = double('user', email: 'dummy@email.com', survey_state: 'survey_state')
  #     User.stub(:where).and_return(@user)
  #     allow(@user).to receive(:first).and_return(@user)# to pass the requires_authentication method
  #   end

  #   it 'responds with 404 if user is not found' do
  #     nil_user = double('nil_user')
  #     User.stub(:where).with({session_token: 'invalid_session_token'}).and_return(nil_user)
  #     allow(nil_user).to receive(:first).and_return(false)

  #     get '/users/invalid_session_token'
  #     expect(last_response.status).to eq 404
  #   end

  #   it 'responds with 200 if normal' do
  #     get '/users/some_session_token'
  #     expect(last_response.status).to eq 200
  #   end

  #   it 'responds with appropriate JSON if normal' do
  #     get '/users/some_session_token'
  #     expect(last_response.body).to include 'dummy@email.com'
  #     expect(last_response.body).to include 'survey_state'
  #   end
  # end # describe 'GET /users/:session_token (&get_user)'



  # describe 'PUT /users/update_user (&update_user)' do
  #   before(:each) do
      # @user_details = double('user_details', survey_state: 'survey_state')
      # allow(JSON).to receive(:parse).and_return @user_details
      # @user = double('user', email: "")
      # allow(User).to receive_message_chain(:eager_load, :find_by).and_return @user
      # allow(@user).to receive(:first).and_return(@user)# to pass the requires_authentication method
    # end

    # it 'responds with 404 if user is not found' do
      # nil_user = double('nil_user')
      # allow(User).to receive(:where).with({session_token: 'invalid_session_token'}).and_return(nil_user)
      # allow(nil_user).to receive(:first).and_return(false)
      # post '/users/update_user'
      # expect(last_response.status).to eq 404
    # end

    # it 'updates a user' do
      # expect(@user).to receive(:update_user)
      # put '/users/some_session_token'
      # expect(last_response.status).to eq 200
    # end

    # it 'responds with 200 if normal' do
      # allow(@user).to receive(:update_user)
      # put '/users/some_session_token'
      # expect(last_response.status).to eq 200
    # end
  # end # describe 'PUT /users/:session_token (&update_user)'





  # describe 'POST /users/reset_password (&send_reset_email)' do
  #   before(:each) do
  #     @user = double('user', email: "", reset_token: "")
  #     allow(User).to receive(:find_by).and_return(@user)
  #     allow(@user).to receive(:update_attributes)
  #     email_q = double('email_q', name: "hub_email")
  #     allow(HUB_CH).to receive(:queue).and_return(email_q)
  #     allow(HUB_EXCHANGE).to receive(:publish)
  #   end

  #   it 'responds with 404 if no user is found' do
  #     allow(User).to receive(:find_by).and_return(nil)
  #     post '/users/reset_password', {:email => 'example@email.com'}.to_json
  #     expect(last_response.status).to eq 404
  #   end

  #   it 'updates the user with a token if normal' do
  #     expect(@user).to receive(:update_attributes)
  #     post '/users/reset_password', {:email => 'example@email.com'}.to_json
  #   end
  #   it 'sends a message to the Hub if normal' do
  #     email_q = double('email_q', name: "hub_email")
  #     expect(HUB_CH).to receive(:queue).and_return(email_q)
  #     expect(HUB_EXCHANGE).to receive(:publish)
  #     post '/users/reset_password', {:email => 'example@email.com'}.to_json
  #   end

  #   it 'responds with 200 if normal' do
  #     post '/users/reset_password', {:email => 'example@email.com'}.to_json
  #     expect(last_response.status).to eq 200
  #   end
  # end # describe 'POST /users (&create_user)'

  describe 'POST /users/update_password (&update_password)' do
    before(:each) do
      @user = double('user', email: "the user's email", reset_token: "", update_attributes: @user)
      allow(User).to receive(:find_by).and_return(@user)
    end

    it 'responds with 404 if no user is found' do
      allow(User).to receive(:find_by).and_return(nil)
      post 'users/update_password', {reset_token: 'token', password: "new password"}.to_json
      expect(last_response.status).to eq 404
    end
    it "encrypts and save the user's new password" do
      expect(User).to receive(:encrypt_password)
      expect(@user).to receive(:update_attributes)
      post 'users/update_password', {reset_token: 'token', password: "new password"}.to_json
    end
    it "responds with the correct JSON" do
      post 'users/update_password', {reset_token: 'token', password: "new password"}.to_json
      expect(last_response.body).to include "the user's email"
    end
  end # describe 'POST /users/update_password (&update_password)''


# end # 'User routes'