$(document).on "ready page:change", ->
  $('#price-slider').slider({
    range: true,
    min: $("#minPrice").data('min')
    max: $("#maxPrice").data('max')
    values: [$("#minPrice").data('current'), $("#maxPrice").data('current')]
    change: (event, ui) ->
      $(this).closest('form').submit()
    slide: (event, ui) ->
      $("#minPrice").val(ui.values[0])
      $("#maxPrice").val(ui.values[1])
    })
  $(document).on 'click', '.select ul li', ->
    $(this).closest('.select').find('select').val($(this).data('value'))
    $(this).closest('form').submit()
  $(document).on 'change', '#filter input, #control_form input[type=checkbox]', ->
    $(this).closest('form').submit()

  # Block interface with notification on ajax event
  # and change url
  $(document).on 'ajax:beforeSend', '#content', ->
    $('#loading').fadeIn('fast')
  $(document).on 'ajax:error', (xhr, error) ->
    #console.log error
    $('#error').html('Внимание! Произошла ошибка! Перезагрузите сраницу. Если это не в первый раз, <a href="/report_error">сообщите о ней</a> администратору!').show('blind')
  $(document).on 'ajaxSuccess', (data, status, xhr) ->
    $('#error').hide('blind')
    $('#loading').fadeOut('fast')

  # Control selections
  $(document).on {mouseenter: ->
    $(this).find('ul').stop().show('blind')
  mouseleave: ->
    $(this).find('ul').stop().hide('blind')}
  , '.select'

  # Sorting params and filtering ajax processing
  $(document).on 'ajax:beforeSend', '#filters form, .control form', (event, xhr, settings) ->
    filters = $.param $('#filters form, .control form').serializeArray()
    settings.url = this.action + '?' + filters
    history.pushState('', document.title, settings.url)

  $('.show_hide_tree').on 'click', ->
    $(this).toggleClass 'active'
    $('nav.menu_side>ul').slideToggle()