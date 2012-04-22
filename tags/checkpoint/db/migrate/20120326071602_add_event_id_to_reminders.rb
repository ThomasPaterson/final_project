class AddEventIdToReminders < ActiveRecord::Migration
  def change
  	add_column :reminders, :event_id, :integer
  end
end
