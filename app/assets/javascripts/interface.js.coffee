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

  $('#search_help').tooltip({container: 'body'})
  $('.add_to_bookmarks button').tooltip()

to = 0
$(document).on "mouseenter", '.gap', ->
  clearTimeout(to)

  $(this).find('.gap_pages').fadeIn(50)

  obj = $(this).find('.page_slider')
  min = parseInt(obj.closest('li').prev().children('a, span').text()) + 1
  max = parseInt(obj.closest('li').next().children('a, span').text()) - 1
  obj.slider({
    min: min,
    max: max,
    step: 1,
    slide: (e, ui) ->
      $a = $(this).closest('.pagination').find('.page:last > a').clone()
      $a.attr('href', $a[0].href.replace(/page=\d+/, 'page=' + ui.value))
      $a.text(ui.value)
      obj.closest('.gap').children('a, span').replaceWith($a)
  })

$(document).on 'mouseleave', '.gap', ->
  obj = $(this)
  to = setTimeout ->
    obj.find('.gap_pages').fadeOut(100)
  , 500


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

$(document).on 'click', '#reset_button', (e) ->
  e.preventDefault()
  form = $(this).closest('form')
  clearForm(form)
  form.submit()

#--- Ajax hooks' processing ---#
$(document).on 'ajax:beforeSend', '#side', ->
  #$('input:not(.primary_button)').attr('disabled', true)
  $('#loading').fadeIn(50)

$(document).on 'ajax:error', (xhr, error) ->
  #console.log error
  #$('input.primary_button').attr('disabled', true)
  $('#error').html('Внимание! Произошла ошибка! Перезагрузите сраницу. Если это не в первый раз, <a href="/report_error">сообщите о ней</a> администратору!').show('blind')

$(document).on 'ajaxSuccess', (data, status, xhr) ->
  $('#error').hide('blind')
  $('#loading').fadeOut(50)
  #$('input').removeAttr('disabled')
#------------------------------#


# Control selections
$(document).on 'click', '.select', ->
  $(this).find('ul').stop().slideToggle('fast')


# Block interface with notification on ajax event
# and change url
$(document).on 'click', '.select ul li', ->
  $(this).closest('.select').find('select').val($(this).data('value'))
  $(this).closest('form').submit()
$(document).on 'change', '#filter input, #control_form input[type=checkbox]', ->
  $(this).closest('form').submit()

$(document).on 'click', '.show_hide_tree, nav.menu_side a', ->
  $(this).toggleClass 'active'
  obj = $(this).closest('.show_hide_tree')
  $('nav.menu_side>ul').slideToggle('fast')


# Sorting params and filtering ajax processing
$(document).on 'ajax:beforeSend', '#filters form, .control form', (event, xhr, settings) ->
  arr = $.map $('#filters form, .control form').serializeArray(), (e) ->
    if (e.value == '' || $.inArray(e.name, ['authenticity_token', 'utf8']) != -1) then null else e
  filters = $.param arr
  settings.url = this.action + '?' + filters
  history.pushState({turbolinks: true, url: settings.url}, document.title, settings.url)

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