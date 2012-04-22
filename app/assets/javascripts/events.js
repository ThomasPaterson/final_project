$("#all_day_checkbox").live("click",function() {
  var is_checked = $(this).is(":checked");
  if(is_checked) {
  	// we don't want users to be able to select the start/end times for all-day events
    $("#event_start_at_4i").attr("disabled", true)
    $("#event_start_at_5i").attr("disabled", true)
    $("#event_end_at_4i").attr("disabled", true)
    $("#event_end_at_5i").attr("disabled", true)

    // if the checkbox is selected, the values currently selected are changed to 
    // 00:00 (12AM) and 23:59 (11:59PM) for the start/end times
    $("#event_start_at_4i").attr("value", "00")
    $("#event_start_at_5i").attr("value", "00")
    $("#event_end_at_4i").attr("value", 23)
    $("#event_end_at_5i").attr("value", 59)
  }
  else {
  	// if the user deselects the checkbox, then enable the selection for start/end times again
    $("#event_start_at_4i").removeAttr("disabled")
    $("#event_start_at_5i").removeAttr("disabled")
    $("#event_end_at_4i").removeAttr("disabled")
    $("#event_end_at_5i").removeAttr("disabled")
  }
});

function validate_selection(start_or_end) {
	var start_year = parseInt($("#event_start_at_1i").val());
	var end_year = parseInt($("#event_end_at_1i").val());

	var start_month = parseInt($("#event_start_at_2i").val());
	var end_month = parseInt($("#event_end_at_2i").val());
    
	var start_day = parseInt($("#event_start_at_3i").val());
	var end_day = parseInt($("#event_end_at_3i").val());

	var start_hour = parseInt($("#event_start_at_4i").val());
	var end_hour = parseInt($("#event_end_at_4i").val());

	var start_min = parseInt($("#event_start_at_5i").val());
	var end_min = parseInt($("#event_end_at_5i").val());

	if ( start_year > end_year || 
		(start_year == end_year && start_month > end_month) ||
		(start_year == end_year && start_month == end_month && start_day > end_day) || 
		(start_year == end_year && start_month == end_month && start_day == end_day && start_hour > end_hour) ||
		(start_year == end_year && start_month == end_month && start_day == end_day && start_hour == end_hour && start_min > end_min)) {
		if ( !$('p').hasClass('warning')) {
			// show the appropriate warning message in the appropriate location
			if(start_or_end == "start") {
    			$('.start_info').append('<p class="warning">Start date cannot be after the end date.</p>');
    		}
    		else {
				$('.end_info').append('<p class="warning">End date cannot be before the start date.</p>');
    		}
    	}
    	// disable the submit button
    	$(".submit_button").attr("disabled", true)
    }
    else {
    	// remove the warning message
    	$('p').remove(".warning");
    	// enable the submit button
		$(".submit_button").removeAttr("disabled")
    }
}

// display a warning on the form and disable the update/create event button
// if the start date is greater than the end date after making a change
// to a year/month/day from selection on events/_form.html.erb
$("#event_start_at_1i").live("change", function() {
	validate_selection("start");
});

$("#event_start_at_2i").live("change", function() {
	validate_selection("start");
});

$("#event_start_at_3i").live("change", function() {
	validate_selection("start");
});

$("#event_start_at_4i").live("change", function() {
	validate_selection("start");
});

$("#event_start_at_5i").live("change", function() {
	validate_selection("start");
});

$("#event_end_at_1i").live("change", function() {
	validate_selection("end");
});

$("#event_end_at_2i").live("change", function() {
	validate_selection("end");
});

$("#event_end_at_3i").live("change", function() {
	validate_selection("end");
});

$("#event_end_at_4i").live("change", function() {
	validate_selection("end");
});

$("#event_end_at_5i").live("change", function() {
	validate_selection("end");
});
