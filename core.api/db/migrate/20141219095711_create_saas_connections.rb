class CreateSaasConnections < ActiveRecord::Migration
  def self.up
    create_table :saas_connections do |t|
      t.timestamps  :null => false

      t.belongs_to  :company                      # foreign key created at bottom!
      t.index       [:company_id]                 # index for foreign key

      t.string      :service_type
      t.boolean     :is_valid                     , :default => false
      t.text        :encrypted_auth_data_string

      # =========================================================================
      # historic, may be deleted after we get rid of MongoDB
      t.string      :old_mongoid                  , :limit  => 24       # old BSON-Mongo IDs used for old credentials
      t.index       [:old_mongoid]                , :unique => true
      t.text        :old_mongoid_auth_data        # before new encoding (please, delete later)

      t.datetime    :successfully_used_first      # the first time (after 2014-03-24) that these credentials were successfully used (ie. created an entry in preprocessed_service_data)
      t.datetime    :successfully_used_last       # the last time (until now) that these credentials were successfully used

      t.integer     :current_error_state			    # 0,1,2,3+:  0 currently no error; 1 rescheduled 1 time (for one hour); 2 rescheduled (at least) 2+ times (last time for a week)
      t.datetime    :current_error_since          # since when are these Credentials in an error-state? Since when does there seem to be an error? This field should only be set if current_error_date is not 0
      t.string      :last_error_reason            # same as :invalidation_reason, will be saved once there is an error; should help with debugging current error cases
      t.datetime    :last_error_occurred_at       # when did the last error occur with these credentials
      t.string      :invalidation_reason          # to be able to distinguish between invalidations we are sure about and those we have to check (maybe unwanted invalidation)
      t.datetime    :invalidation_at              # to be able to identify when (valid) credentials were disconnected (by the user)

      t.index       [:company_id, :service_type, :is_valid] , :name => 'index_valid_company_service_credentials'
    end #create_table do

    add_foreign_key :saas_connections, :companies , :on_update => :cascade
  end #self.up()

  def self.down
    drop_table :saas_connections
  end
end #CreateSaasConnections


