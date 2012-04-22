class AddParentIdToLists < ActiveRecord::Migration
  def change
  	add_column :lists, :parent_id, :integer
  end
end
