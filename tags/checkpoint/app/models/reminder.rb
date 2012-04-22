class Reminder < ActiveRecord::Base
  
  has_one :user
  
  validates :name,  :presence => true,
                    :length   => { :maximum => 50 }
  validates :content, :presence => true,
                      :length   => { :maximum => 140 }
  validates :user_id, :poster_id, :time, :presence => true      
  
  
  def self.email_reminder
    @reminders =  Reminder.where("time < ?", DateTime.now)
    
    @reminders.each do |reminder|
		ReminderMailer.reminder_email(User.find(reminder.user_id), reminder).deliver
		reminder.destroy
	end 

  end

end
