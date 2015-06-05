
class Dashing.SprintProgress extends Dashing.Widget
  
  @accessor 'value', Dashing.AnimatedValue
  
  constructor: ->
    super
    @observe 'value', (value) ->
      $(@node).find(".meter").val(value).trigger('change')
      if value < 30 
        $(@node).css("background-color", "red")
      if value >= 30 && value <= 50 
        $(@node).css("background-color", "#ff9122")
      if value > 50 
        $(@node).css("background-color", "green")

  ready: ->
    meter = $(@node).find(".meter")
    meter.knob()