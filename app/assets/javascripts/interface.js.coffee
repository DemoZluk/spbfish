$(document).on "ready page:change", ->
  $(document).on 'click', '.select ul li', ->
    $(this).closest('.select').find('select').val($(this).data('value'))
  $(document).on 'click', '.select ul li, #control_form input[type=checkbox]', ->
    $(this).closest('form').submit()

  # Block interface with notification on ajax event
  $(document).on 'ajax:beforeSend', '#content', ->
    $('#loading').fadeIn('fast')
  $(document).on 'ajaxError', ->
    $('#notification').html('<img alt="loading" src="/assets/alert.png"><p style="color: #F00; font-size: 14px; font-weight: bold;">Произошла ошибка, перезагрузите страницу. Если подобное повторится, сообщите администратору сайта.</p>')
  $(document).on 'ajaxSuccess', ->
    #window.history.pushState '', 'Title', 'new'
  $(document).on 'ajaxComplete', ->
    $('#loading').fadeOut('fast')

  # Control selections
  $(document).on {mouseenter: ->
    $(this).find('ul').stop().show('blind')
  mouseleave: ->
    $(this).find('ul').stop().hide('blind')}
  , '.select'

  $('.control form').on 'ajax:beforeSend', (event, xhr, settings) ->
    console.log settings.data = $('#filter *[value != ""]').serialize().replace('utf8=%E2%9C%93&?', '')

  $('.show_hide_tree').on 'click', ->
    $(this).toggleClass 'active'
    $('nav.menu_side>ul').slideToggle()