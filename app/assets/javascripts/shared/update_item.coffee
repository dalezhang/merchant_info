$(document).on 'change', '.update_item', ->
  $this = $(this)
  resource_val = $this.val()
  resource_path = $this.attr('data-url')
  resource_attrname = $this.attr('data-attrname')
  $.ajax
    url: resource_path
    type: 'POST'
    data: {resource_val:  resource_val, authenticity_token: window._token, resource_attrname: resource_attrname}
    success: (res) ->
      console.log "res", res
      if res['error']
        alert(res['error'])
        $this.val('')
      if res['validate']
        $this.addClass('bg-yellow')
        $this.attr('data-message',res['validate'])
      else
        $this.removeClass('bg-yellow')
        $this.attr('data-message','')
    error: (data, status, e) ->
      console.log data, status, e
      alert("操作错误")


