# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
$(document).on "ready page:change", ->
  $(".delete").on('click', 'input', ->
    $('.current_item').removeAttr('class');
    $(this).closest('tr').attr('class', 'current_item');
  );
  # Show time
  # setInterval( ->
  #   $('#time').html($.now.getHours())
  # , 1000
  # );

  $( ->
    $('.spinner').spinner({min: 0, max: 50})
  )

  # Hide entry
  # $('.delete').on('click', ->
  #   $(this).closest('tr').fadeOut('fast').remove()
  # );


  # $('.cart_block').hover(
  #   -> $('#cart').stop().show(500)
  #   -> $('#cart').stop().hide(500)
  # )


$(document).on 'click', 'input.minus', ->
  input = $(this).closest('form').siblings('input[type=text]')
  i = parseInt(input.val()) - 1
  if i <= 0
    $(this).closest('.product').slideUp('fast', ->
      $(this).remove()
    )

$(document).on 'ajax:beforeSend', '.product', ->
  # alert ''

# Show cart
$(document).on 'click', '#cart_block .cart_link', ->
  #$('.cart_block #cart_panel').show();
  $('#cart_panel').stop().toggle('blind', 'fast');

$(document).on 'mousedown', (e) ->
    container = $('#cart_panel')
    if !container.is(e.target) && container.has(e.target).length == 0
        container.stop().hide('blind', 'fast')
