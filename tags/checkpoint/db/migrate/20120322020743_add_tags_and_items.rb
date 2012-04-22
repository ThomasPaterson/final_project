class AddTagsAndItems < ActiveRecord::Migration

  def change
    create_table :event_tags do |t|
      t.string :name
      t.integer :event_id
      t.integer :user_id

      t.timestamps
    end

    create_table :items do |t|
      t.text :content
      t.integer :list_id
      t.integer :user_id

      t.timestamps
    end


    create_table :item_tags do |t|
      t.string :name
      t.integer :item_id
      t.integer :user_id

      t.timestamps
    end
    
  end
  
end
