class MissingIndexes < ActiveRecord::Migration
  def self.up
    add_index :users, :session_token
    add_index :saas_connections, :service_type
  end

  def self.down
    remove_index :users, :session_token
    remove_index :saas_connections, :service_type
  end
end
