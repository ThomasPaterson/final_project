class AddForeignToEvents < ActiveRecord::Migration
  def change
    add_column :events, :description, :text
    add_column :events, :user_id, :integer
    add_column :events, :poster_id, :integer
  end
end
