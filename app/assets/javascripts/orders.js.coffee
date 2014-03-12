# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

# Toggle 'order_address' required attribute
$(document).on 'change', '#order_pay_type', ->
  if $(this).val() == "Доставка"
    $('#order_address').attr('required', true)
    $('#order_address').parent().find('span').text('*')
  else
    $('#order_address').attr('required', false)
    $('#order_address').parent().find('span').text('')
$( "#datepicker" ).datepicker( $.datepicker.regional[ "ru" ] );
$( "#order_shipping_date" ).datepicker({
constrainInput: true,
autoSize: true,
showAnim: 'fade',
showOtherMonths: true,
selectOtherMonths: true,
dateFormat: 'yy-mm-dd',
# showOn: "both",
# buttonImage: "/images/calendar.gif",
# buttonImageOnly: true,
minDate: +1,
maxDate: +14,
showWeek: true,
firstDay: 1,
defaultDate: +1,
hideIfNoPrevNext: true
});