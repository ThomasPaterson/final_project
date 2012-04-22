class UpdatePostsColumnName < ActiveRecord::Migration
  def change
    rename_column :posts, :messageboard_id, :dashboard_id
  end
end
