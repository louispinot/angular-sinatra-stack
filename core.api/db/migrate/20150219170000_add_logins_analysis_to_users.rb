class AddLoginsAnalysisToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :weekly_logins, :json, default: {}.to_json
    add_column :users, :consecutive_weeks_login, :integer, default: 0
  end #self.up()

  def self.down
    remove_column :users, :weekly_logins
    remove_column :users, :consecutive_weeks_login
  end
end
