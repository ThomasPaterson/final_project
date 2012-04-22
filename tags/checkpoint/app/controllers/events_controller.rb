class EventsController < ApplicationController
  layout :choose_layout
  before_filter :authenticate, :except => [:new, :create]

  def index
    @event = Event.new
    @month = (params[:month] || (Time.zone || Time).now.month).to_i
    @year = (params[:year] || (Time.zone || Time).now.year).to_i

    @shown_month = Date.civil(@year, @month)

    if params[:name] == nil
      # the name parameter is not specified when a user goes to his own events page
      # in this case, the event strips (shown in the calendar) and the events
      # will be those created for the current user
      @event_strips = current_user.events.event_strips_for_month(@shown_month)
      @events = Event.where("user_id = ?", current_user.id).limit(3)
    else
      # if the name parameter is specified, then find the matching user (not case-sensitive)
      @user = User.find(:first, :conditions => ["lower(name) = ?", params[:name].downcase]) || not_found

      # get the event strips and events for the user found
      # note that the events displayed will be events have been made public OR events that
      # the viewer has created for this user
      @events = Event.where("user_id = ? AND (is_public = ? OR poster_id = ?)", @user, true, current_user.id)
      @event_strips = @events.event_strips_for_month(@shown_month)
    end
  end

  def show
    @event = Event.find(params[:id])
  end

  def new
    @event = Event.new
    @day = params[:day]
    @month = params[:month]
    @year = params[:year]

    if params[:name] == nil
      @user = current_user
    else
      @user = User.find(:first, :conditions => ["lower(name) = ?", params[:name].downcase])
    end
    respond_to do |format|
      format.html
      # we would like to show a lightbox if the link leading to this action added
      # class="modalbox" to the link tag
      format.js   { render :action => :redirect }
    end
  end

  def edit
    @event = Event.find(params[:id])
    @user = User.find(@event.user_id)
  end

  def create
    @event = Event.new(params[:event])

    respond_to do |format|
    	
      if @event.save
  	    if params[:check] == "reminder"
          #create a reminder to go with the event if the user has selected the option on the form
	      	@reminder = Reminder.new
	      	Reminder.create(:name => "Reminder for: #{@event.name}", :content => "#{@event.name} starts in 30 minutes", :user_id => @event.user_id, :poster_id => @event.poster_id, :time => @event.start_at - 30.minutes, :event_id => @event.id)
		
	      	if @reminder.save
          end
        end
    
        format.html { redirect_to events_url, notice: 'Event was successfully created.' }
      else
        format.html { render action: "new" }
        format.js
      end
    end
  end

  def update
    @event = Event.find(params[:id])

    if @event.update_attributes(params[:event])
      redirect_to events_url, notice: 'Event was successfully updated.'
    else
      render action: "edit"
    end
  end

  def destroy
    @event = Event.find(params[:id])
    @event.destroy

    redirect_to events_url
  end

  def destroy_event
    destroy
  end

  private  
  def choose_layout  
    (request.xhr?) ? nil : 'application'  
  end  
end
