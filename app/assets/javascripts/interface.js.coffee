clearForm = (form) ->
  # iterate over all of the inputs for the form
  # element that was passed in
  form.find('input').each ->
    type = $(this).attr 'type';
    tag = this.tagName.toLowerCase(); # normalize case
    # it's ok to reset the value attr of text inputs,
    # password inputs, and textareas
    if (type == 'text' || type == 'password' || tag == 'textarea')
      this.value = ""
    # checkboxes and radios need to have their checked state cleared
    # but should *not* have their 'value' changed
    else if (type == 'checkbox' || type == 'radio')
      this.checked = null
    # select elements need to have their 'selectedIndex' property set to -1
    # (this works for both single and multiple select elements)
    else if (tag == 'select')
      this.selectedIndex = -1

$(document).on 'page:change page:load ready', ->

    
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



$(document).on 'click', '#reset_button', (e) ->
  e.preventDefault()
  form = $(this).closest('form')
  clearForm(form)
  form.submit()



#--- Ajax hooks' processing ---#
$(document).on 'ajax:beforeSend', '#content', ->
  $('input:not(.primary_button)').attr('disabled', true)
  $('#loading').fadeIn('fast')

$(document).on 'ajax:error', (xhr, error) ->
  #console.log error
  $('input.primary_button').attr('disabled', true)
  $('#error').html('Внимание! Произошла ошибка! Перезагрузите сраницу. Если это не в первый раз, <a href="/report_error">сообщите о ней</a> администратору!').show('blind')

$(document).on 'ajaxSuccess', (data, status, xhr) ->
  $('#error').hide('blind')
  $('#loading').fadeOut('fast')
  $('input').removeAttr('disabled')
#------------------------------#


# Control selections
$(document).on {mouseenter: ->
  $(this).find('ul').stop().show('blind', 'fast')
mouseleave: ->
  $(this).find('ul').stop().hide('blind', 'fast')}
, '.select'


# Block interface with notification on ajax event
# and change url
$(document).on 'click', '.select ul li', ->
  $(this).closest('.select').find('select').val($(this).data('value'))
  $(this).closest('form').submit()
$(document).on 'change', '#filter input, #control_form input[type=checkbox]', ->
  $(this).closest('form').submit()

$(document).on 'click', '.show_hide_tree', ->
  $(this).toggleClass 'active'
  $('nav.menu_side>ul').slideToggle('fast')
  if $(this).hasClass 'active'
    $(this).text '▲ Каталог ▲'
  else
    $(this).text '▼ Каталог ▼'


# Sorting params and filtering ajax processing
$(document).on 'ajax:beforeSend', '#filters form, .control form', (event, xhr, settings) ->
  arr = $.map $('#filters form, .control form').serializeArray(), (e) ->
    if (e.value == '' || $.inArray(e.name, ['authenticity_token', 'utf8']) != -1) then null else e
  filters = $.param arr
  settings.url = this.action + '?' + filters
  history.pushState('document', document.title, settings.url)

$(document).on 'click', '#close_cart', ->
  $('#cart_panel').hide('blind')

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