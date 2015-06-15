class AddLoginsTrackingToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :number_of_logins, :integer, default: 0
    add_column :users, :last_login_at, :datetime
  end #self.up()

  def self.down
    remove_column :users, :number_of_logins
    remove_column :users, :last_login_at
  end
end
