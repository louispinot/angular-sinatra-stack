class CreateManualMetrics < ActiveRecord::Migration

  def self.up
    create_table :company_metrics_manual_months do |t|
      t.timestamps  :null => false

      t.belongs_to  :company                      , :null => false  # foreign key created at bottom!
      t.index       [:company_id]                 # index for foreign key

      t.datetime    :start_datetime               , :null => false
      t.column      :data_json                    , :json, default: {}

      t.index [:company_id, :start_datetime]      , unique: true, name: "index_metrics_manual_months_on_company_id_and_start_datetime"
    end #create_table

    add_foreign_key :company_metrics_manual_months, :companies         , :on_update => :cascade
  end #self.up()

  def self.down
    drop_table :company_metrics_manual_months
  end #self.down()
end #class CreateCompanyMetrics

