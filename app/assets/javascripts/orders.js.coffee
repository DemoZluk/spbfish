# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
$(document).on "page:change", ->
  $( "#datepicker" ).datepicker( $.datepicker.regional[ "ru" ] );
  $( "#order_shipping_date" ).datepicker({
    constrainInput: true,
    autoSize: true,
    showAnim: 'blind',
    showOtherMonths: true,
    selectOtherMonths: true,
    dateFormat: 'yy-mm-dd',
    showOn: "both",
    buttonImage: "/images/calendar.gif",
    buttonImageOnly: true,
    minDate: +1,
    maxDate: +14,
    showWeek: true,
    firstDay: 1,
    defaultDate: +1,
    hideIfNoPrevNext: true
  });