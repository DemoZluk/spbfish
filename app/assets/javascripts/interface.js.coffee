$(document).on "ready", ->

  $('.show_hide_tree').click ->
    $(this).toggleClass 'active'
    $('nav.menu_side>ul').slideToggle()


  window.onpopstate = (e) ->
    location.reload()
  #   array = decodeURIComponent(location.search.substring(1)).split('&')
  #   params = {}

  #   $.each array, (index, value) ->
  #     v = value.split('=')
  #     if params[v[0]]
  #       params[v[0]] = $.makeArray(params[v[0]])
  #       params[v[0]].push(v[1])
  #     else
  #       params[v[0]] = v[1]

  #   if params['minPrice'] && params['maxPrice']
  #     $('#price .slider').slider( "option", "values", [ params['minPrice'], params['maxPrice'] ] )
  #     $('#minPrice').val(params['minPrice'])
  #     $('#maxPrice').val(params['maxPrice'])

  #   $('.numerical').each (i) ->
  #     id = $(this).data('id')
  #     if p = params['r['+id+'][]']
  #       $(this).children('.min').val(p[0])
  #       $(this).children('.max').val(p[1])
  #       $(this).children('.slider').slider( "option", "values", [ p[0], p[1] ] )

  # window.onload = (e) ->
  #   history.replaceState(null, null, document.URL)


  $('.slider').each ->
    obj = $(this)
    min = parseFloat $(this).data('min')
    max = parseFloat $(this).data('max')
    $(this).slider({
      range: true,
      min: min,
      max: max,
      values: [obj.siblings('.min').val() || min, obj.siblings('.max').val() || max],
      animate: 'fast'
      slide: (event, ui) ->
         $(this).closest('.slider').siblings('.min').val(ui.values[0])
         $(this).closest('.slider').siblings('.max').val(ui.values[1])
      stop: (event, ui) ->
        $(this).closest('form').submit()
    })


#--- Ajax hooks' processing ---#
$(document).on 'ajax:beforeSend', '#content', ->
  $('#loading').fadeIn('fast')

$(document).on 'ajax:error', (xhr, error) ->
  #console.log error
  $('#error').html('Внимание! Произошла ошибка! Перезагрузите сраницу. Если это не в первый раз, <a href="/report_error">сообщите о ней</a> администратору!').show('blind')

$(document).on 'ajaxSuccess', (data, status, xhr) ->
  $('#error').hide('blind')
  $('#loading').fadeOut('fast')
#------------------------------#


# Control selections
$(document).on {mouseenter: ->
  $(this).find('ul').stop().show('blind')
mouseleave: ->
  $(this).find('ul').stop().hide('blind')}
, '.select'


# Block interface with notification on ajax event
# and change url
$(document).on 'click', '.select ul li', ->
  $(this).closest('.select').find('select').val($(this).data('value'))
  $(this).closest('form').submit()
$(document).on 'change', '#filter input, #control_form input[type=checkbox]', ->
  $(this).closest('form').submit()


# Sorting params and filtering ajax processing
$(document).on 'ajax:beforeSend', '#filters form, .control form', (event, xhr, settings) ->
  filters = $.param $('#filters form, .control form').serializeArray()
  settings.url = this.action + '?' + filters
  history.pushState('', document.title, settings.url)

  # $('#price-slider').slider({
  #   range: true,
  #   min: $("#minPrice").data('min')
  #   max: $("#maxPrice").data('max')
  #   values: [$("#minPrice").data('current'), $("#maxPrice").data('current')],
  #   animate: 'fast'
  #   slide: (event, ui) ->
  #     $("#minPrice").val(ui.values[0])
  #     $("#maxPrice").val(ui.values[1])
  #   stop: (event, ui) ->
  #     $(this).closest('form').submit()
  #   })
