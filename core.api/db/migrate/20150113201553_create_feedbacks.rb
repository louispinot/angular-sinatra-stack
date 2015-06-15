class CreateFeedbacks < ActiveRecord::Migration
  def self.up
    create_table :feedbacks do |t|
      t.timestamps  :null => false

      t.belongs_to  :user                     # foreign key created at bottom!
      t.index       [:user_id]                # index for foreign key

      t.string      :feedback_type
      t.string      :feedback_body
    end #create_table do

    add_foreign_key :feedbacks, :users  , :on_update => :cascade
  end #self.up()

  def self.down
    drop_table :feedbacks
  end
end
