class AddForeignToLists < ActiveRecord::Migration
  def change
    add_column :lists, :content, :string
  end
end
