# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
$(document).on "page:change", ->
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

  # Show cart
  $('#cart_block .cart_link').click( ->
    #$('.cart_block #cart_panel').show();
    $('#cart_block #cart_panel').stop().toggle('blind', 500);
  ) if $('#cart_panel[disabled]').length == 0;