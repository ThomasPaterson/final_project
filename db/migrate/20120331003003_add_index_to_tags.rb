class AddIndexToTags < ActiveRecord::Migration
  def change
  	add_index :tags, :name
  	add_index :tags, :event_id
  	add_index :tags, :item_id
  end
end
