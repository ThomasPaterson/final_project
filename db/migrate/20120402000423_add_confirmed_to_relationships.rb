class AddConfirmedToRelationships < ActiveRecord::Migration
  def change
    add_column :relationships, :confirmed, :boolean
  end
end
