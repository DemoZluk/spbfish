# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
actions = ->
  # Toggle Shipping date text field active state
  $('#date').on 'focus', ->
    $('.ui-datepicker-trigger').addClass('active')
  $('#date').on 'blur', ->
    $('.ui-datepicker-trigger').removeClass('active')


$(document).ready actions
$(document).on "page:change", actions