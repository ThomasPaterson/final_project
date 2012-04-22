class UsersController < ApplicationController
  before_filter :authenticate, :except => [:new, :create]

  def index
    @users = User.all
  end

  def show
    if params[:id] == nil
      @user = current_user
    elsif params[:id] =~ /^[-+]?[0-9]*$/
      @user = User.find(params[:id])
    else
      @user = User.find_by_name(params[:id])
    end

    if @user == nil
      not_found
    end
  end

  def new
    @user = User.new
  end

  def edit
    @user = User.find(params[:id])
  end

  def create
    @user = User.new(params[:user])
    
    if @user.save
      sign_in @user
      Dashboard.create(:user_id => @user.id)
      redirect_to @user, notice: 'User was successfully created.'
    else
      render action: "new"
    end
  end


  def update
    @user = User.find(params[:id])

    if @user.update_attributes(params[:user])
      redirect_to @user, notice: 'User was successfully updated.'
    else
      render action: "edit"
    end
  end

  def destroy
    @user = User.find(params[:id])
    @user.destroy

    redirect_to users_url
  end
  
  def following
    @title = "Following"
    @user = User.find(params[:id])
    @users = @user.following.paginate(:page => params[:page])
  end

  def followers
    @title = "Followers"
    @user = User.find(params[:id])
    @users = @user.followers.paginate(:page => params[:page])
  end
  
  
  def add_friend
    
    @search = User.new	
    @user = User.find(params[:id])
    if params[:user].nil?
    	conditions = ''
    else
    	conditions = '(name like "%' + params[:user][:name] + '%" or email like "%' + params[:user][:name] + '%")'

    end
    @users = User.paginate  :per_page => 10, :page => params[:page],
                            	:conditions => conditions,
                            	:order => 'created_at'	
  end

  def user_dashboard
    @title = "Dashboard"

    if signed_in?
      @user = current_user
      @dashboard = current_user.dashboard
      
      # need to setup a new post since we're giving a user the option to create
      # new posts on their dashboard
      @post = Post.new

      # retrieve all the posts on the user's dashboard
      # we are using paginate to display the posts in different pages
      @posts = @dashboard.posts.paginate :per_page => 7, :page => params[:page], :order => 'created_at DESC'

      # retrieve five upcoming events in ascending order of when the event starts
      # only retrieve events that are ending or starting later than the current time
      @events = Event.order("start_at ASC").where("user_id = ? AND (end_at > ? OR start_at > ?)", current_user.id, Time.now, Time.now).limit(5)
      
      # retrieve the next 5 reminders for the user
      @reminders = Reminder.where("user_id = ?", current_user.id).limit(5)
    end

    render :action => "dashboard"
  end

  def dashboard
    @title = "Dashboard"
    if signed_in?
      @user = User.find(params[:id])
      @dashboard = @user.dashboard

      # need to setup a new post since we're giving a user the option to create
      # new posts on their dashboard
      @post = Post.new

      # retrieve all the posts on the user's dashboard
      # we are using paginate to display the posts in different pages
      @posts = @dashboard.posts.paginate :per_page => 7, :page => params[:page], :order => 'created_at DESC'

      # retrieve five upcoming events in ascending order of when the event starts
      # only retrieve events that are ending or starting later than the current time
      @events = Event.order("start_at ASC").where("user_id = ? AND (end_at > ? OR start_at > ?)", current_user.id, Time.now, Time.now).limit(5)
      
      # retrieve the next 5 reminders for the user
      @reminders = Reminder.where("user_id = ?", current_user.id).limit(5)
    end
  end
  
  def statistics
    @title = "Statistics"
    @user = User.find(params[:id])
  end
  
end
