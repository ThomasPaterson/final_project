class AddIndexToReminderTime < ActiveRecord::Migration
  def change
    add_index :reminders, :time
  end
end
