class CreateReminders < ActiveRecord::Migration
  def change
    create_table :reminders do |t|
      t.string :name
      t.text :content
      t.integer :user_id
      t.integer :poster_id
      t.datetime :time

      t.timestamps
    end
  end
end
