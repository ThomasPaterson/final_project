class UsersController < ApplicationController
  require 'stat_array'
  layout :choose_layout
  before_filter :authenticate, :except => [:new, :create, :retrieve_password, :send_password]
  before_filter :correct_user, :only => [:update, :destroy]
  before_filter :correct_user_or_friend, :except => [:new, :create, :show, :dashboard, :update, 
    :index, :edit_permissions, :permissions_update, :ban, :unban, :retrieve_password, :send_password]
  before_filter :admin_required, :only => [:index, :edit_permissions, :permissions_update, :ban, :unban]
  before_filter :check_if_banned, :except => [:new, :create, :retrieve_password, :send_password]
  
  # for some reason paginate doesn't work when filtering users unless
  # the following line is included
  require 'will_paginate/array'

  #member list
  def index
  	@title = "Member List"
    @users = User.all.paginate :per_page => 10, :page => params[:page]
  end

  #profile
  def show
  	@title = "Profile"
    if params[:id] == nil
      @user = current_user
    elsif params[:id] =~ /^[-+]?[0-9]*$/
      @user = User.find(params[:id])
    else
      @user = User.find_by_name(params[:id])
    end

    if @user == nil
      not_found
    elsif @user == current_user
      @friends = @user.following
    end

    @dashboard = @user.dashboard

    # need to setup a new post since we're giving a user the option to create new posts
    @post = Post.new

    # retrieve all the posts for the user
    # we are using paginate to display the posts in different pages
    @posts = @dashboard.posts.paginate :per_page => 7, :page => params[:page], :order => 'created_at DESC'
    store_location
  end
  
  
  def retrieve_password
  	@title = "Retrieve Password"
  	@user = User.new
  	
  end
  
  #sends the user his password
  def send_password
  	if (!params[:email].nil?)
  		@user = User.find_by_email(params[:email])
  		if (!@user.nil?)
  		  @user.reset_password
  		  if @user.save
  		    redirect_to signin_path, notice: "Email sent" 
  		  else
  		  	redirect_to password_recovery_path, notice: "Error in entry" 
  		  end
  		else
  		  redirect_to password_recovery_path, notice: "Error in entry" 
  		end
  	else
  		redirect_to password_recovery_path, notice: "Error in entry" 
  	 end
  end


  def new
  	@title = "Sign Up"
    # we only want to display the signup page if the user
    # is not signed in
    if not signed_in?
      @user = User.new
    else
      redirect_to dashboard_path
    end
  end

  def edit
  	@title = "Edit Profile"
    @user = current_user
  end

  def create
    @user = User.new(params[:user])
    @user.permission_level = 2
    @user.photo = nil
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
    @title = "Friend Search"
    @search = User.new	
    @user = User.find(params[:id])
    if params[:user].nil?
      @users = User.all
    else
      @search_string = '%' + params[:user][:name] + '%'
      @users = User.where("name LIKE ? OR email LIKE ?", @search_string, @search_string)
    end

    @users = @users.paginate  :per_page => 10, :page => params[:page],
                            	:order => 'created_at'	
  end
  
  #for confirming friends who have sent you invites
  def confirm
  	@title = "Friend Management"
  	@user = User.find(params[:id])
    @users = @user.following.paginate(:page => params[:page])
  end

  def dashboard
    @title = "Dashboard"
    if signed_in?
      if not params[:id].nil? and params[:id] != current_user.id
        redirect_to dashboard_path
      end
      store_location
      @user = get_user
      @friends = @user.following
      @dashboard = @user.dashboard

      # need to setup a new post since we're giving a user the option to create
      # new posts on their dashboard
      @post = Post.new

      # retrieve all the posts on the user's dashboard
      # we are using paginate to display the posts in different pages
      @posts = @dashboard.posts.paginate :per_page => 7, :page => params[:page], :order => 'created_at DESC'

      # retrieve five upcoming events in ascending order of when the event starts
      # only retrieve events that are ending or starting later than the current time
      @events = Event.order("start_at ASC").where("user_id = ? AND confirmed = ? AND (end_at > ? OR start_at > ?)", current_user.id, true, Time.now, Time.now).limit(5)
      
      @pending_events = Event.order("start_at ASC").where("user_id = ? AND confirmed = ? AND (end_at > ? OR start_at > ?)", current_user.id, false, Time.now, Time.now).limit(5)
      # retrieve the next 5 reminders for the user
      @reminders = Reminder.where("user_id = ?", current_user.id).limit(5)
    end
  end
  
  def statistics
    @title = "Statistics"
    @user = User.find(params[:id])
    
    #select the current filters based on the url to current page
  	@url = request.fullpath
  	@listfilter = check_filter(@url, "listfilter=true")
  	@eventfilter = check_filter(@url, "eventfilter=true")
  	@linefilter = check_filter(@url, "linefilter=true")
  	@tagfilter = check_tagfilter(params[:tagfilter])
  	@time_units = check_timeunits(params[:time], params[:time_unit])
  	@time = check_time(params[:time])


   #condition for the filter
  	@tag_conditions = get_statistic_conditions(@linefilter, @listfilter, @eventfilter, @time, @time_units )
  	
  	if @tagfilter.nil?
  		@conditions = @tag_conditions
  	else
	  	# removes duplicate invitees so only one invite is created per unique user selected
	    #condition for the actual graph
          @conditions = get_statistic_conditions(@linefilter, @listfilter, @eventfilter, @time, @time_units, @tagfilter)
        
	end
	
    @filter_tag_counts = Tag.count( :group => "NAME", 
                   :conditions => @tag_conditions, 
                   :order => "DATE(created_at) ASC"
                 ).collect do |name,  count| 
                   TagCountByName.new(name, count)   
                   end 
                   
	
  if !@linefilter

    @tag_counts = Tag.count( :group => "NAME", 
                   :conditions => @conditions, 
                   :order => "DATE(created_at) ASC"
                 ).collect do |name, count| 
                   TagCountByName.new(name, count)   
                   end 
                   
   else

    @filter_tag = Tag.count( :group => "NAME", 
                   :conditions => @conditions, 
                   :order => "DATE(created_at) ASC"
                 ).collect do |name,  count| 
                   TagCountByName.new(name, count)   
                   end    	

    @tag_counts = get_line_points(@time, @time_units, @filter_tag)
    @colors = generate_colors(@filter_tag_counts.count)    
   end

                  
                   
    respond_to do |format|  
    	format.html
        format.js   
    end
  end
  
  def edit_permissions
    @user = User.find(params[:id])
  end

  def permissions_update
    @user = User.find(params[:id])
    
    @new_permission_level = params[:user][:permission_level].to_i      
    User.update_all("permission_level = #{@new_permission_level}", ["users.id = ?", params[:id]])

    redirect_to users_url, :notice => "Permissions for '" + @user.name + "' have been updated."
  end
  
  def destroy_user
    destroy
  end

  def ban
    @user = User.find(params[:id])
    
    @new_permission_level = 10    
    User.update_all("permission_level = #{@new_permission_level}", ["users.id = ?", params[:id]])

    redirect_to users_url, :notice => @user.name + "'s account has been disabled."
  end

  def unban
    @user = User.find(params[:id])
    
    @new_permission_level = 2
    User.update_all("permission_level = #{@new_permission_level}", ["users.id = ?", params[:id]])

    redirect_to users_url, :notice => @user.name + "'s account has been enabled."
  end

  def choose_layout  
    (request.xhr?) ? nil : 'application'  
  end 
end
