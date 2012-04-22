class RemindersController < ApplicationController
  
  layout :choose_layout
  # GET /reminders
  # GET /reminders.json
  def index
  	    
  	@user = get_user
    if params[:user_id].nil?
    	@reminders = Reminder.where(:user_id => current_user.id)
    else
    	if current_user.id == @user.id
    	  @reminders = Reminder.where(:user_id => current_user.id)
		else
		  @reminders = Reminder.where("poster_id = ? AND user_id = ?", current_user.id, @user.id)
		end
    	
    end
    
  end

  # GET /reminders/1
  # GET /reminders/1.json
  def show
    @reminder = Reminder.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @reminder }
    end
  end

  # GET /reminders/new
  # GET /reminders/new.json
  def new
    @reminder = Reminder.new
    
    if params[:user_id].nil?
      @user = current_user
    else
      @user = User.find(params[:user_id])
    end
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @reminder }
    end
  end


  # GET /reminders/1/edit
  def edit
  	@user = get_user
    @reminder = Reminder.find(params[:id])
  end




  def create
	@reminder = Reminder.new(params[:reminder])
    respond_to do |format|
      if @reminder.save
        format.html { redirect_to user_reminders_path(User.find(@reminder.user_id)), notice: 'Reminder was successfully created.' }
      else
        format.html { render action: "new" }
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
        format.html { render action: "edit" }
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
