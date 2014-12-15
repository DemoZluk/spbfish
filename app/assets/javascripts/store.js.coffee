# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$(document).on 'click', '.show_more .btn', ->
  $(this).siblings('.body').stop().slideToggle('fast')

$(document).on 'click', '.properties_header', (e) ->
  table = $(this).siblings('.properties_table')
  e.preventDefault()
  table.stop().slideToggle('fast')

changeImgs = (imgs) ->
  l = imgs.length

  i = l-1
  index = Math.abs(i % l)
  $(imgs[index]).fadeOut('slow')

  i--
  index = Math.abs(i % l)
  $(imgs[index]).fadeIn('slow')

loop_change = (imgs) ->
  int = parseInt(Math.random()*8+3)*1000
  setTimeout ->
    changeImgs(imgs)
    loop_change(imgs)
  , int

$(document).ready ->
  # $('.group_images').each ->
  #   imgs = $(this).find('img')
  #   loop_change(imgs)


  # loop_change
  $('.group_images').each ->
    imgs = $(this).find('img')
    l = imgs.length
    i = l-1
    int = parseInt(Math.random()*9+2)*1000
    setInterval ->
      index = Math.abs(i % l)
      $(imgs[index]).fadeOut('slow')
      i--
      new_i = Math.abs(i % l)
      $(imgs[new_i]).fadeIn('slow')
      int = parseInt(Math.random()*9+2)*1000
    , int
