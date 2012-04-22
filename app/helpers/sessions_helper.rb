module SessionsHelper

  def sign_in(user)
    cookies.permanent.signed[:remember_token] = [user.id, user.salt]
    self.current_user = user
  end
  
  def sign_out
    cookies.delete(:remember_token)
    self.current_user = nil
  end
    
  def deny_access
    store_location
    redirect_to signin_path, :notice => "Please sign in to access this page."
  end
  
  def authenticate
    deny_access unless signed_in?
  end

  def check_if_banned
    if banned?
      cookies.delete(:remember_token)
      self.current_user = nil
      redirect_to signin_path, :alert => "Your account has been disabled."
    end
  end

  def correct_user_or_friend
    @user = get_effected_user
    deny_access unless current_user?(@user) or self.current_user.confirmed_friend(@user) or admin?
  end


  
  def correct_user
    @user = User.find(params[:id])
    deny_access unless current_user?(@user)
  end
  
  def redirect_back_or(default = root_path, notice = "")
    if notice.length > 0
      redirect_to(session[:return_to] || default, notice)
    else
      redirect_to(session[:return_to] || default)
    end
    clear_return_to
  end

  #gets the user from the url params, checks both user_id and the id params
  def get_effected_user
   if params[:user_id].nil?
  	  User.find(params[:id])
    else
      User.find(params[:user_id])
    end
  end   
  
  def current_user=(user)
    @current_user = user
  end
  
  def current_user?(user)
    self.current_user == user
  end
  
  def current_user
    @current_user ||= user_from_remember_token
  end
  
  def signed_in?
    !current_user.nil?
  end


  private
  
    def store_location
      session[:return_to] = request.fullpath
    end

    def clear_return_to
      session[:return_to] = nil
    end

    def user_from_remember_token
      User.authenticate_with_salt(*remember_token)
    end

    def remember_token
      cookies.signed[:remember_token] || [nil, nil]
    end
end
  
