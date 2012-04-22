class RemindersController < ApplicationController
  before_filter :authenticate
  before_filter :correct_user_or_friend
  before_filter :correct_user_or_poster, :only => [:destroy, :update]
  before_filter :check_if_banned
  
  layout :choose_layout


  def index
  	@title = "View Reminders"
  	@user = get_user
  	
  	@search = Reminder.new
	
	#select the current filter based on the url to current page
  	@url = request.fullpath
  	@friendfilter = check_filter(@url, "friendfilter=true")

	#if there isn't a search right now, get list based on page, friendfilter
	if params[:reminder].nil?
	  @reminders = get_reminders(@friendfilter, @user)
    else
      if params[:reminder][:name] == ''
      	@reminders = get_reminders(@friendfilter, @user)
      else
      	@search_string = params[:reminder][:name]
      	@reminders = get_reminders_from_search(@friendfilter, params[:reminder][:name], @user)
  	  end
      
    end
    
    if @reminders.count > 0
      @reminders = @reminders.paginate(:page => params[:page], :per_page => 10)
    end
    
  end


  def show
  	@title = "View Reminder"
    @reminder = Reminder.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @reminder }
    end
  end

  
  def new
  	@title = "Create a Reminder"
    @reminder = Reminder.new
    @friends = @user.following
    @user = get_user
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @reminder }
    end
  end


  def edit
    @title = "Edit Reminder"
  	@user = get_user
    @reminder = Reminder.find(params[:id])
    @friends = @user.following
  end



  #goes to the reminder page of the person for whom the list is for
  def create
	@reminder = Reminder.new(params[:reminder])
    respond_to do |format|
      if @reminder.save
      	
      	# removes duplicate invitees so only one invite is created per unique user selected
    	@invitees = Array.new(params[:invitee]).uniq
		send_reminders(@invitees, params[:reminder])
		
        format.html { redirect_to user_reminders_path(User.find(@reminder.user_id)), notice: 'Reminder was successfully created.' }
      else
      	params[:user_id] ||= User.find(@reminder.user_id).id
        @title = "Create a Reminder"
        @friends = @user.following
        @user = get_user
        format.html { render 'new'}
        format.json { render json: @reminder.errors, status: :unprocessable_entity }
        format.js
      end
    end
  end
  


  def update
    @reminder = Reminder.find(params[:id])

    respond_to do |format|
      if @reminder.update_attributes(params[:reminder])
        format.html { redirect_to user_reminders_path(User.find(@reminder.user_id)), notice: 'Reminder was successfully updated.' }
        format.json { head :ok }
      else
        format.html { redirect_to :back, notice: 'Error updating reminder' }
        format.json { render json: @reminder.errors, status: :unprocessable_entity }
      end
    end
  end


  def destroy
    @reminder = Reminder.find(params[:id])
    @reminder.destroy

    respond_to do |format|
      format.html { redirect_to :back }
      format.json { head :ok }
    end
  end

  def destroy_reminder
    destroy
  end
  
  private  
  def choose_layout  
    (request.xhr?) ? nil : 'application'  
  end  
  
  def get_user 
   if params[:user_id].nil?
	  current_user
    else
      User.find(params[:user_id])
    end
  end   

  
end
