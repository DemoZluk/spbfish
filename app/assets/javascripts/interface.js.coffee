actions = ->
  $(document).on 'click change', '.select ul li, input', ->
    $(this).closest('.select').find('select').val($(this).data('value'))
    $(this).closest('form').submit()

  $(document).on 'submit', 'form', ->
    $.ajax {
      beforeSend: ->
        $('#loading').fadeIn('fast')
        $('input, select').prop('disabled', true)
      complete: ->
        $('input, select').prop('disabled', false)
        $('#loading').fadeOut('fast')
    }

  # $('#control_form').submit( ->
  #   $.ajax({
  #     url: $(this).attr('action')
  #     type: 'GET'
  #     data: $(this).serialize()
  #     dataType: 'html'
  #     error: (data) ->
  #       console.log data
  #   }).success( (data) ->
  #     $('#product_index').html(data)
  #   )
  #   return false
  # )

  # Control selections
  $(document).on {mouseenter: ->
    $(this).find('ul').stop().show('blind')
  mouseleave: ->
    $(this).find('ul').stop().hide('blind')}
  , '.select'
    
$(document).on "ready", actions
$(document).on "page:change", actions