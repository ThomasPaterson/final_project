class UserMailer < ActionMailer::Base
  default from: "user@example.com"
  
  def reset_email(user, password)
    @user = user
    @password = password
    #our eventual site's url to the reminder page
    @url  = "http://cmpt470.csil.sfu.ca:8001/signin"
    mail(:to => @user.email, :subject => "New Password for Plan It")
  end
  
end
