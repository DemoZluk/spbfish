# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$('.thumb a').on 'click', ->
  url = $(this).data('remote')
  src = $('.product-image img').attr('src')
  if url != src
    $('.product-image a').attr('href', $(this).attr('href'))
    $('.product-image img').attr('src', url)

$(document).on 'ajax:beforeSend', '.output', ->
  $('#log code').append('<p>Начинаем обновление. Это может занять несколько минут. Пожалуйста, подождите...</p>')

$(document).on 'ajax:complete', '.output', (data, xhr, status) ->
  $('#log code').append('<p>' + xhr.responseJSON.output.join("\n") + '</p>')
