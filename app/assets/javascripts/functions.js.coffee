
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