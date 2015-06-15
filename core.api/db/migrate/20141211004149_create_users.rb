class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
      t.timestamps  :null => false
      t.timestamp   :session_expiry

      # =========================================================================
      # historic, may be deleted after we get rid of MongoDB
      t.string      :old_mongoid          , :limit  => 24       # old BSON-Mongo IDs used for old users
      t.index       [:old_mongoid]        , :unique => true

      t.string      :session_token
      t.string      :email
      t.string      :encrypted_password
      t.string      :reset_token
      t.string      :phone_number

      t.index       [:email]              , unique: true
      t.index       [:reset_token]        , unique: true
    end #create_table do
  end #self.up()

  def self.down
    drop_table :users
  end
end
