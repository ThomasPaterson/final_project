module CalendarHelper
  # used by event_calendar

  def month_link(month_date)
    link_to(I18n.localize(month_date, :format => "%B"), {:month => month_date.month, :year => month_date.year})
  end
  
  # custom options for this calendar
  def user_event_calendar_opts
    { 
      :year => @year,
      :month => @month,
      :event_strips => @event_strips,
      :month_name_text => I18n.localize(@shown_month, :format => "%B %Y"),
      :previous_month_text => link_to("<< #{I18n.t("date.month_names")[@shown_month.prev_month.month]}", user_events_path(current_user, :month => @shown_month.prev_month.month, :year => @shown_month.prev_month.year)),
      :next_month_text => link_to("#{I18n.t("date.month_names")[@shown_month.next_month.month]} >>", user_events_path(current_user, :month => @shown_month.next_month.month, :year => @shown_month.next_month.year)),
      :abbrev => true,
      :first_day_of_week => 0, # first day of the week is Sunday
      :show_today => true,
      :show_header => true,  

      # it would be nice to have these in the CSS file
      # but they are needed to perform height calculations
      :width => 900, # in pixels
      :height => 450, # in pixels
      :day_names_height => 18,
      :day_nums_height => 18,
      :event_height => 18,
      :event_margin => 1,
      :event_padding_top => 1,

      :use_all_day => true, # enable users to create 'all-day' events
      :use_javascript => true,
      :link_to_day_action => "new" # load the form for creating a new event when the day is clicked 
    }
  end
    
  # custom options for this calendar
  def event_calendar_opts
    { 
      :year => @year,
      :month => @month,
      :event_strips => @event_strips,
      :month_name_text => I18n.localize(@shown_month, :format => "%B %Y"),
      :previous_month_text => link_to("<< #{I18n.t("date.month_names")[@shown_month.prev_month.month]}", user_events_path(@user, :month => @shown_month.prev_month.month, :year => @shown_month.prev_month.year)),
      :next_month_text => link_to("#{I18n.t("date.month_names")[@shown_month.next_month.month]} >>", user_events_path(@user, :month => @shown_month.next_month.month, :year => @shown_month.next_month.year)),
      :abbrev => true,
      :first_day_of_week => 0, # first day of the week is Sunday
      :show_today => true,
      :show_header => true,  

      # it would be nice to have these in the CSS file
      # but they are needed to perform height calculations
      :width => 900, # in pixels
      :height => 450, # in pixels
      :day_names_height => 18,
      :day_nums_height => 18,
      :event_height => 18,
      :event_margin => 1,
      :event_padding_top => 1,

      :use_all_day => true, # enable users to create 'all-day' events
      :use_javascript => true
    }
  end

  def event_calendar(opts)
    # args is an argument hash containing :event, :day, and :options
    calendar opts do |args|
      event, day = args[:event], args[:day]

      # turns the events into links that will be displayed in a lightbox when clicked
      html = %(<a href="/users/#{@user.id}/events/#{event.id}" title="#{h(event.name)}" class="modalbox">)
      html << display_event_time(event, day)
      html << %(#{h(event.name)}</a>)
      html += event_tooltip(event)
    end
  end

  def event_tooltip(event)
    # show a tooltip when hovering over an event (useful for events that have long names)
    raw "<div id='event_#{event.id}'' class='event-tooltip' style='display:none'>#{event.name}</div>"
  end
end
