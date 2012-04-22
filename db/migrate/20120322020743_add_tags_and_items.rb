class AddTagsAndItems < ActiveRecord::Migration


    create_table :items do |t|
      t.text :content
      t.integer :list_id
      t.integer :user_id

      t.timestamps
    end



    
  
end
