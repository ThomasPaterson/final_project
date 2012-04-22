$(function() {

  //============================ Event Pagination ============================

  $("#upcoming_events_results th a, #upcoming_events_results .pagination a").live("click", function() {
    $.getScript(this.href);
    return false;
  });
  
  //==========================================================================
  //============================= List Pagination ============================
  $("#lists_search_results th a, #lists_search_results .pagination a").live("click", function() {
    $.getScript(this.href);
    return false;
  });

  //==========================================================================
  //========================== Reminder Pagination ===========================
  $("#reminders_search_results th a, #reminders_search_results .pagination a").live("click", function() {
    $.getScript(this.href);
    return false;
  });

  //============================= Filter Forms ===============================
  // Search form.
  $('#search_form').submit(function () {
    $("#upcoming_events_results").html("<br />Searching...");
    $("#lists_search_results").html("Searching...");
    $("#reminders_search_results").html("Searching...");
    $.get(this.action, $(this).serialize(), null, 'script');
    return false;
  });

  // Clear form.
  $('#search_clear').submit(function () {
    $("#search").attr("value", "");
    $("#list_name").attr("value", "");
    $("#reminder_name").attr("value", "");
    $.get(this.action, $(this).serialize(), null, 'script');
    return false;
  });
});