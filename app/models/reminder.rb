class Reminder < ActiveRecord::Base
  
  belongs_to :user
  
  validates :name,  :presence => true,
                    :length   => { :maximum => 65 }
  validates :content, :length   => { :maximum => 140 }
  validates :user_id, :poster_id, :time, :presence => true     
  
  default_scope :order => 'reminders.time ASC' 
  
  attr_accessible :name, :time, :content, :user_id, :poster_id, :event_id
  
  #Checks each reminder that is due, sends them, then deletes them from the database
  def self.email_reminder
    @reminders =  Reminder.where("time < ?", DateTime.now)
    
    @reminders.each do |reminder|
		ReminderMailer.reminder_email(User.find(reminder.user_id), reminder).deliver
		reminder.destroy
	end 

  end

end
