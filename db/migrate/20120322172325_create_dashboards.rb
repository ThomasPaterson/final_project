class CreateDashboards < ActiveRecord::Migration
  def change
    create_table :dashboards do |t|
      t.datetime :created_at
      t.datetime :updated_at

      t.timestamps
    end
  end
end
