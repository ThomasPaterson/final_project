class CreateTags < ActiveRecord::Migration
  def change
    create_table :tags do |t|
      t.string :name
      t.integer :user_id
      t.integer :event_id
      t.integer :item_id

      t.timestamps
    end
  end
end
