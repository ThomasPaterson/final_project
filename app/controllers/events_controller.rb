class EventsController < ApplicationController
  layout :choose_layout
  before_filter :authenticate
  before_filter :correct_user_or_friend, :except => [:update]
  before_filter :correct_user_or_poster, :only => [:destroy]
  before_filter :check_if_banned
  
  # for some reason paginate doesn't work when filtering events unless
  # the following line is included
  require 'will_paginate/array'

  def index
    @title = "View Event"
    @event = Event.new
    @month = (params[:month] || (Time.zone || Time).now.month).to_i
    @year = (params[:year] || (Time.zone || Time).now.year).to_i

    @shown_month = Date.civil(@year, @month)

    if params[:name] == nil and params[:user_id] == nil
      # the name parameter is not specified when a user goes to his own events page
      # in this case, the event strips (shown in the calendar) and the events
      # will be those created for the current user
      @events = Event.where("user_id = ? AND confirmed = ?", current_user.id, true)
      @events_today = @events.where("start_at BETWEEN ? AND ?", Time.now.beginning_of_day, Time.now.end_of_day)
      @event_strips = @events.event_strips_for_month(@shown_month)
      @pending = Event.where("user_id = ? AND confirmed = ?", current_user.id, false)
    else
      if not params[:name].nil?
        # if the name parameter is specified, then find the matching user (not case-sensitive)
        @user = User.find(:first, :conditions => ["lower(name) = ?", params[:name].downcase]) || not_found
      else
        @user = User.find(params[:user_id]) || not_found
      end

      if @user.id == current_user.id or admin?
        @pending = Event.where("user_id = ? AND confirmed = ?", @user.id, false)
      end

      # get the event strips and events for the user found
      # note that the events displayed will be events have been made public OR events that
      # the viewer has created for this user
      # only confirmed events will be displayed
      if admin?
        @events = Event.where("user_id = ? AND confirmed = ?", @user.id, true)
      else
        @events = Event.where("user_id = ? AND (is_public = ? OR poster_id = ?) AND confirmed = ?", @user.id, true, current_user.id, true)
      end
      @events_today = @events.where("start_at BETWEEN ? AND ?", Time.now.beginning_of_day, Time.now.end_of_day)
      @event_strips = @events.event_strips_for_month(@shown_month)
    end

    @filter_type = params[:filter_type]
    # code for handling upcoming event filter    
    if not @filter_type.nil?
      @query = params[:search]
      #select the current filter based on the url to current page
      @url = request.fullpath
      @friendfilter = check_filter(@url, "friendfilter=true")
      @events = get_events_from_search(@friendfilter, params[:search], current_user)

      # if nothing is entered for either filter (as is the case when you just go to your events page),
      # just list all your events
      if @events.count > 0
        @events = @events.paginate( :per_page => 5, :page => params[:page], :order => 'start_at ASC' )
      end
    else 
      @events = @events.paginate( :per_page => 5, :page => params[:page], :order => 'start_at ASC' )
    end
    store_location
  end

  def show
    @event = Event.find(params[:id])
  end

  def new
    @title = "Create an Event"
    @event = Event.new
    @day = params[:day]
    @month = params[:month]
    @year = params[:year]

    if params[:name] == nil
      @user = current_user
    else
      @user = User.find(:first, :conditions => ["lower(name) = ?", params[:name].downcase])
    end

    @friends = @user.following

    respond_to do |format|
      format.html
      # we would like to show a lightbox if the link leading to this action added
      # class="modalbox" to the link tag
      format.js   { render :action => :redirect }
    end
  end

  def edit
    @title = "Edit Event"
    @event = Event.find(params[:id])

    # we only render the edit page if the event is confirmed or created by the user
    if not @event.confirmed
      redirect_to dashboard_url
    end

    @friends = current_user.following
    @tags = @event.get_tags
    # only allow editing events created by or for the current user
    if @event.user_id != current_user.id and @event.poster_id != current_user.id
      @event == nil
    else
      @user = User.find(@event.user_id)
    end
  end

  def create
    @event = Event.new(params[:event])

    respond_to do |format|
    	
      if @event.save
        
        # create the tags for this event
        @tags = (params[:tag][:text]).split(",")
        @tags << "#{@event.name}"
        @tags = @tags.uniq
        @tags.each do |tag|
          @event.create_item_tag!(tag)
        end

  	    if params[:check] == "reminder"
          # create a reminder to go with the event if the user has selected the option on the form
	      	@reminder = Reminder.new
	      	Reminder.create(:name => "Reminder for: #{@event.name}", :content => "#{@event.name} starts in 30 minutes", :user_id => @event.user_id, :poster_id => @event.poster_id, :time => @event.start_at - 30.minutes, :event_id => @event.id)
		
	      	if @reminder.save
          end
        end

        @end_date = DateTime.new(params[:end_repeat]['date(1i)'].to_i, 
                                 params[:end_repeat]['date(2i)'].to_i, 
                                 params[:end_repeat]['date(3i)'].to_i)
        @stop = false
        if params[:repeat] != "none"
          @new_start_at = @event.start_at
          @new_end_at = @event.end_at
          @counter = 1
          until @stop
            if params[:repeat] == "daily"
              @new_start_at = @event.start_at + (@counter * 1).days
              @new_end_at = @event.end_at + (@counter * 1).days
            elsif params[:repeat] == "weekly"
              @new_start_at = @event.start_at + (@counter * 1).week
              @new_end_at = @event.end_at + (@counter * 1).week
            elsif params[:repeat] == "biweekly"
              @new_start_at = @event.start_at + (@counter * 2).week
              @new_end_at = @event.end_at + (@counter * 2).week
            elsif params[:repeat] == "monthly"
              @new_start_at = @event.start_at + (@counter * 1).month
              @new_end_at = @event.end_at + (@counter * 1).month
            elsif params[:repeat] == "yearly"
              @new_start_at = @event.start_at + (@counter * 1).year
              @new_end_at = @event.end_at + (@counter * 1).year
            end

            if @new_start_at.strftime('%Y%m%d') > @end_date.strftime('%Y%m%d')
              @stop = true
            else            
              @new_event = @event.dup
              @new_event.start_at = @new_start_at
              @new_event.end_at = @new_end_at
              @new_event.save
              @counter = @counter + 1

              # create the tags for the recurring event
              @tags = (params[:tag][:text]).split(",")
              @tags << "#{@event.name}"
              @tags = @tags.uniq
              @tags.each do |tag|
                @new_event.create_item_tag!(tag)
              end

              if params[:check] == "reminder"
                # create a reminder to go with the recurring event if the user has selected the option on the form
                @reminder = Reminder.new
                Reminder.create(:name => "Reminder for: #{@new_event.name}", :content => "#{@new_event.name} starts in 30 minutes", :user_id => @new_event.user_id, :poster_id => @new_event.poster_id, :time => @new_event.start_at - 30.minutes, :event_id => @new_event.id)
          
                if @reminder.save
                end
              end
            end
          end
        end
        
        if @event.user_id == current_user.id
          format.html { redirect_back_or user_events_url(current_user), notice: 'Event was successfully created.' }
        else
          @user = User.find(@event.user_id)
          format.html { redirect_back_or display_events_path(:name => @user.name), notice: 'Event was successfully created.' }
        end
      else
        @user = current_user
        format.html { render action: "new" }
        format.js
      end
    end
  end

  def update
    @event = Event.find(params[:id])

    @type = params[:type]

    if not @type.nil? and @type == "invite"

      if not params[:invitee].nil?
        send_invite(@event, params[:invitee])
      end

      redirect_to user_events_path(current_user), notice: 'Invitations sent.'
    elsif @type == "update" and @event.update_attributes(params[:event])

      if not params[:tag].nil?
        # retrieve the existing tags created for this event
        @existing_tags = Tag.where("event_id = ?", @event.id)

        # create the additional tags for this event
        @tags = (params[:tag][:text]).split(",")
        @tags.each do |tag|
          # we don't want to recreate existing tags
          if @existing_tags.nil? || @existing_tags.find_by_name(tag.to_s.strip).nil?
            @event.create_item_tag!(tag)
          end
        end
      end

      if params[:check] == "reminder"
        # create a reminder to go with the event if the user has selected the option on the form
        @reminder = Reminder.new
        Reminder.create!(:name => "Reminder for: #{@event.name}", :content => "#{@event.name} starts in 30 minutes", :user_id => @event.user_id, :poster_id => @event.poster_id, :time => @event.start_at - 30.minutes, :event_id => @event.id)
  
        if @reminder.save
        end
      end

      redirect_to user_events_path(current_user), notice: 'Event was successfully updated.'
    else
      redirect_to user_events_path(current_user), notice: 'Error updating event'
    end
  end

  def destroy
    @event = Event.find(params[:id])
    @event.destroy

    redirect_to user_events_url(current_user)
  end

  def destroy_event
    destroy
  end

  def decline
    destroy
  end

  def confirm_event
    @event = Event.find(params[:id])
    @event.update_attributes(:confirmed => true)
    redirect_to user_events_url(current_user)
  end

  def confirm
    @event = Event.find(params[:id])
    @event.update_attributes(:confirmed => true)
    redirect_to user_events_url(current_user)
  end

  def invite
    @title = "Invite Friends"
    @event = Event.find(params[:id])
    @friends = current_user.following
    @tags = @event.get_tags
    # only allow editing events created by or for the current user
    if @event.user_id != current_user.id and @event.poster_id != current_user.id
      @event == nil
    else
      @user = User.find(@event.user_id)
    end
  end

  private 

  def send_invite(original_event, invitees)
    # removes duplicate invitees so only one invite is created per unique user selected
    @invitees = Array.new(invitees).uniq

    # create a new pending event for each invitee listed by the user
    for username in @invitees
      @user = User.find_by_name(username)

      # we only want to send an invite if the invitee does not already have
      # a pending invite to the same event
      @existing_event = Event.where("name = ? AND start_at = ? AND end_at = ? AND 
                                     description = ? AND poster_id = ? AND user_id = ? AND confirmed = ?",
                                    original_event.name,
                                    original_event.start_at,
                                    original_event.end_at,
                                    original_event.description,
                                    original_event.poster_id,
                                    @user.id,
                                    false)
      if username == current_user.name or username.empty? or @existing_event.count > 0
        next
      end
      @user_event = original_event.dup
      @user_event.user_id = @user.id

      # allows the invitee to confirm/deny event
      @user_event.confirmed = false
      @user_event.save
    end
  end

  #gets the events for the page based on if the friend filter is on, the search string, and 
  #whose page it is currently
  def get_events_from_search(friendfilter, search_string, user)
    
    @search_string = '%' + search_string + '%'
    
    if @user == current_user
      if friendfilter
        @events = Event.joins(:user).joins("LEFT OUTER JOIN tags ON tags.event_id = events.id").where("(users.name LIKE ? OR events.name LIKE ? OR events.description LIKE ? OR tags.name LIKE ?) AND (events.poster_id = ? AND events.user_id = ?)", @search_string, @search_string, @search_string, @search_string, current_user.id, user.id)
      else
        @events = Event.joins(:user).joins("LEFT OUTER JOIN tags ON tags.event_id = events.id").where("(users.name LIKE ? OR events.name LIKE ? OR events.description LIKE ? OR tags.name LIKE ?) AND (events.user_id = ?)", @search_string, @search_string, @search_string, @search_string, user.id)
      end
    else
        @events = Event.joins(:user).joins("LEFT OUTER JOIN tags ON tags.event_id = events.id").where("(users.name LIKE ? OR events.name LIKE ? OR events.description LIKE ? OR tags.name LIKE ?) AND (events.poster_id = ? AND events.user_id = ?)", @search_string, @search_string, @search_string, @search_string, current_user.id, user.id)
    end

    return @events.uniq
    
  end

  def choose_layout  
    (request.xhr?) ? nil : 'application'  
  end  
end
