class CreateCurrencyRates < ActiveRecord::Migration
  def self.up
    create_table :currency_rates do |t|
      t.timestamps  :null => false

      # =========================================================================
      # historic, may be deleted after we get rid of MongoDB
      t.string      :old_mongoid          , :limit  => 24       # old BSON-Mongo IDs used for old currency-rates
      t.index       [:old_mongoid]        , :unique => true

      t.date        :date
      t.column      :currency_rates       , :json

      t.index       [:date]               , :unique => true     # every date has only one set of currency rates
    end #create_table do
  end #self.up()

  def self.down
    drop_table :currency_rates
  end #self.down()
end #CreateCurrencyRates


