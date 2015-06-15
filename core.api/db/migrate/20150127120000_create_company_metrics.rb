class CreateCompanyMetrics < ActiveRecord::Migration

  def get_tablenames
    return [:company_metrics_days, :company_metrics_weeks, :company_metrics_months, :company_metrics_years]
  end #get_tablenames()


  def self.up
    get_tablenames.each do |tablename|
      create_table tablename do |t|
        t.timestamps  :null => false
        t.datetime    :locked_at                    , :null => true   # NULL means this entry is not locked

        t.belongs_to  :company                      , :null => false  # foreign key created at bottom!
        t.index       [:company_id]                 # index for foreign key

        t.datetime    :start_datetime               , :null => false
        t.column      :data_json                    , :json

        t.index [:company_id, :start_datetime]      , unique: true
      end #create_table

      add_foreign_key tablename, :companies         , :on_update => :cascade
    end #each do
  end #self.up()

  def self.down
    get_tablenames.each do |tablename|
      drop_table tablename
      end #each do
  end #self.down()
end #class CreateCompanyMetrics

