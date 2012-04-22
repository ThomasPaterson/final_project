class SessionsController < ApplicationController

  def new
    # we only want to display the signin page if the user
    # is not signed in
    if not signed_in?
      @title = "Sign in"
    else
      redirect_to dashboard_path
    end
  end

  def create
    user = User.authenticate(params[:session][:email],
                             params[:session][:password])
    if user.nil?
      flash.now[:error] = "Invalid email/password combination."
      @title = "Sign in"
      render 'new'
    else
    	reset_session
        sign_in user
        redirect_back_or dashboard_path
    end
  end
  
  
  def destroy
    sign_out
    redirect_to root_path
  end
  
  
end