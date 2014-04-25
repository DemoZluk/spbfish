# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$(document).on 'click', '.bookmarks_list .bookmarks', (event) ->
  event.preventDefault()
  $('.bookmarks').toggleClass('active')
  $('.bookmarks_list .list').stop().fadeToggle('fast')

$(document).on 'mousedown', (e) ->
    container = $('.bookmarks_list')
    if !container.is(e.target) && container.has(e.target).length == 0
      $('.bookmarks').removeClass('active')
      $('.bookmarks_list .list').fadeOut('fast')