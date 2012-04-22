class ReminderMailer < ActionMailer::Base
  default from: "reminder@example.com"
  
  def reminder_email(user, reminder)
    @user = user
    @reminder = reminder
    #our eventual site's url to the reminder page
    #@url  = "http://example.com/login"
    mail(:to => @user.email, :subject => "Reminder: #{@reminder.name}")
  end
  
end
