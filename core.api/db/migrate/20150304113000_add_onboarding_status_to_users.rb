class AddOnboardingStatusToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :onboarding_status, :string
  end #self.up()

  def self.down
    remove_column :users, :onboarding_status
  end
end
