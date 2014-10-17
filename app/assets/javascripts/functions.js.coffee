$(document).on "page:change page:load ready", ->
  # Hide notice after 2 seconds
  $('#error').delay(2000).slideUp(500);

$(document).on 'click', '.toggle_text', ->
  # Substitute current text with 
  # the one in data-sub-text attribute
  $div = $(this)
  text = $div.text()
  sub_text = $div.data('sub-text')
  $div.text(sub_text)
  $div.data('sub-text', text)

$.get_url_params = () ->
  params_string = window.location.search.substring 1
  obj = {}
  $.each(params_string.split('&'), (i, string) ->
    a = string.split('=')
    obj[a[0]] = a[1]
  )
  obj
