class CreateLifestage < ActiveRecord::Migration
  def self.up
    create_table :lifestages do |t|
      t.timestamps  :null => false

      t.belongs_to  :company                    # foreign key created at bottom!
      t.index       [:company_id]               # index for foreign key

      t.decimal     :modeled_lifestage
      t.index       [:modeled_lifestage]        # used in where-clause when querying for peers

      t.integer     :users
      t.integer     :payers
      t.integer     :employees
      t.integer     :engineers
      t.decimal     :revenue_last_month
      t.decimal     :expenses_last_month
      t.decimal     :customer_lifetime

      t.index       [:company_id, :created_at]  , :unique => true
    end #create_table do

    add_foreign_key :lifestages   , :companies , :on_update => :cascade
    # Note: By adding this foreign-key in the DB, we create a dependency-loop! See self.down() for resultion.
    add_foreign_key :companies    , :lifestages , :on_update => :cascade, :column => :current_lifestage
  end #self.up()

  def self.down
    remove_foreign_key  :companies, :column => :current_lifestage
    drop_table :lifestages
  end #self.down()
end
