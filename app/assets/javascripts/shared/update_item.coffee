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




((root) ->
  root.toggleExamine = (target) ->
  	$this = $(target)
    #$i_tag = $($this.children())
  	product_draft_id = $this.data('product-draft-id')
   i_tag = $($this.children())
   tr_tag = $($this.parent().parent() )
   console.log 'tr_tag', tr_tag
  	$.ajax
  	  url: "/examine_product_drafts/#{product_draft_id}/toggle_examine"
  	  type: 'POST'
  	  data: { authenticity_token: window._token}
  	  success: (res) ->
  	    console.log "res", res
  	    if res['state'] == 'true'
          console.log 'true'
          i_tag.addClass('fa-times')
          i_tag.removeClass('fa-check')
          tr_tag.addClass('bg-green')
          $this.removeClass('btn-success')
          $this.addClass('btn-warning')
  	    if res['state'] == 'false'
          console.log 'false'
          i_tag.removeClass('fa-times')
          i_tag.addClass('fa-check')
          tr_tag.removeClass('bg-green')
          $this.removeClass('btn-warning')
          $this.addClass('btn-success')
        if res['error']
          alert(res['error'])
          $this.val('')
  	  error: (data, status, e) ->
  	    console.log data, status, e
  	    alert("操作错误")


)(window)

