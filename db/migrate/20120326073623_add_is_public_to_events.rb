class AddIsPublicToEvents < ActiveRecord::Migration
  def change
    add_column :events, :is_public, :boolean
  end
end
