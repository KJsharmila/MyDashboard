class Dashing.Codeclimate extends Dashing.Widget

  @accessor 'arrow', ->
    if @get('last')
      if parseFloat(@get('current')) > parseFloat(@get('last')) then 'icon-arrow-up' else 'icon-arrow-down'
      

      if parseFloat(@get('current')) >= 3.5 
        $(@get('node')).css("background-color", "green")
      if parseFloat(@get('current')) < 3.5 && parseFloat(@get('current')) >= 2.5
        $(@get('node')).css("background-color", "#ff9122")
      if parseFloat(@get('current')) < 2.5
        $(@get('node')).css("background-color", "red")
        $(@get('node')).addClass("blink")



  onData: (data) ->
    if data.status
      $(@get('node')).addClass("status-#{data.status}")
