# Client
# ======

# ## Initialization

# ##### created()
Template.sparkline.created = ->
  Template.sparkline.templateInstance = @
  Template.sparkline.log "created", @
  Template.sparkline.prepareSelector()
  Template.sparkline.prepareRefreshTime()
  Template.sparkline.prepareStyles()
  Template.sparkline.prepareOptions()
  Template.sparkline.prepareType()
  Template.sparkline.prepareLoadingMessage()
  Template.sparkline.prepareDataSeries()

# ##### rendered()
# When the component is first rendered datatables is initialized `templateInstance.__component__` is the this context
Template.sparkline.rendered = ->
  that=@
  Template.sparkline.log "rendered", @
  Template.sparkline.initialize()
  ###listen to window resize event and reinitialize to refresh chart for responsive themes###
  ###refreshCharts=_.debounce Template.sparkline.initialize(),200###
  $(window).on 'resize',=> _.debounce(@$('div').sparkline @data.dataSeries,@data.options)

# ##### destroyed()
# Currently nothing is done when the component is destroyed.UPDATE-:We remove resize events on destroying template
Template.sparkline.destroyed = ->
  Template.sparkline.log "destroyed", @
  $(window).off 'resize'

Template.sparkline.initialize =(template,dc)->
  #===== Sparkline charts =====//
  Template.instance().$("div").sparkline @getDataSeries(), @getOptions()
  # Activate hidden Sparkline on tab show
  $("a[data-toggle=\"tab\"]").on "shown.bs.tab", -> $.sparkline_display_visible()

  # Activate hidden Sparkline
  $(".collapse").on "shown.bs.collapse", -> $.sparkline_display_visible()

  @log "initialized", @

Template.sparkline.prepareLoadingMessage = ->
  @setData 'loadingMessage', @getLoadingMessage()

Template.sparkline.getLoadingMessage = ->
  if @getData().loadingMessage
    return @getData().loadingMessage
  else return @getOptions().loadingMessage or false

# #### `selector` String ( required )
# The table selector for the dataTable instance you are creating, must be unique in the page scope or you will get
# datatable mulit-render error.
Template.sparkline.setSelector = ( selector ) ->
  Match.test selector, String
  @setData 'selector', selector

# ##### getSelector()
Template.sparkline.getSelector = ->
  return @getData().selector or false

# ##### prepareSelector()
Template.sparkline.prepareSelector = ->
  selector = @getSelector()
  unless selector
    selector = "sparkline-#{ @getGuid() }"
  @setSelector selector

# ##### setRefresTime
Template.sparkline.setRefreshTime=(time)->
  Match.test time,Number
  @setData 'refreshTime',time

# ##### getRefresTime
Template.sparkline.getRefreshTime=->
  @getData().refreshTime or false

# ##### prepareRefresTime()
Template.sparkline.prepareRefreshTime=->
  time=@getRefreshTime()
  unless time
    time=200
  @setRefreshTime time

# #### `dataSeries` String or Array ( optional )
# The initial dataSeries passed in via the component declaration
Template.sparkline.setDataSeries = ( dataSeries ) ->
  Match.test dataSeries, Array
  @setData 'dataSeries', dataSeries

# ##### getDataSeries()
Template.sparkline.getDataSeries = ->
  return @getData().dataSeries or false

# ##### getProperty()
Template.sparkline.getProperty = ->
  return @getData().property or false

Template.sparkline.getArray = ->
  return @getData().array or false

Template.sparkline.getCSV = ->
  return @getData().csv or false

Template.sparkline.getCursor = ->
  return @getData().cursor or false

# ##### prepareDataSeries()
Template.sparkline.prepareDataSeries = ->
  if @getCSV()
    @setDataSeries @getCSV().split ","
  else if @getArray()
    @setDataSeries @getArray()
  else if @getProperty() and @getCursor()
    array = []
    @getCursor().forEach ( document ) =>
      unless _.has document, @getProperty()
        @error "Document lacks property #{ @getProperty() }", document
      array.push document[ @getProperty() ]
    @setDataSeries array
  else if @isDomSource()
    @setDataSeries 'html'

# #### `styles` String ( optional )
# A string of the css classes to be applied to this sparkline.
# If a css class matches a preset option it will be merged into the options object.
Template.sparkline.setStyles = ( styles ) ->
  Match.test styles, String
  @setData 'styles', styles

# ##### getStyles()
Template.sparkline.getStyles = ->
  return @getData().styles or false

# ##### prepareStyles()
Template.sparkline.prepareStyles = -> return

# #### `options` Object ( optional )
# ##### defaultOptions
Template.sparkline.defaultOptions =
  loadingMessage: "Loading..."
  disableHiddenCheck: true

# ##### setOptions()
Template.sparkline.setOptions = ( options ) ->
  Match.test options, Object
  @setData 'options', options

# ##### getOptions()
Template.sparkline.getOptions = ->
  return @getData().options or @getPresetOptions( @getStyles() )

# ##### prepareOptions()
# Prepares the sparklines options object by merging the options passed in with the defaults and presets.
Template.sparkline.prepareOptions = ->
  options = @getOptions() or {}
  @setOptions _.defaults( options, @defaultOptions )

# #### `type` String ( optional )
# ##### setType()
Template.sparkline.setType = ( type ) ->
  Match.test type, String
  @setData 'type', type

# ##### getType()
Template.sparkline.getType = ->
  return @getData().type or false

# ##### prepareType()
# Prepares the sparklines options object by merging the options passed in with the defaults and presets.
Template.sparkline.prepareType = ->
  if @getType()
    options = @getOptions()
    options.type = @getType()
    @setOptions options

# #### `debug` String ( optional )
# A handy option for granular debug logs.
# `true` logs all messages from datatables.
# Set debug to any string to only log messages that contain that string
# ##### examples
#   + `rendered` logs the instantiated component on render
#   + `destroyed` logs when the component is detroyed
#   + `initialized` logs the inital state of the datatable after data is acquired
#   + `options` logs the datatables options for that instantiated component
#   + `fnServerData` logs each request to the server by the component

# ##### isDebug()
Template.sparkline.isDebug = ->
  return @getData().debug or false

# ##### log()
Template.sparkline.log = ( message, object ) ->
  if @isDebug()
    if message.indexOf( @isDebug() ) isnt -1 or @isDebug() is "all"
      console.log "sparkline:#{ @getSelector() }:#{ message } ->", object

# ## Utility Methods

# ##### getTemplateInstance()
Template.sparkline.getTemplateInstance = ->
  return @templateInstance or false

# ##### getGuid()
Template.sparkline.getGuid = ->
  return @guid or false

# ##### getData()
Template.sparkline.getData = ->
  return Template.currentData() or false
# return @getTemplateInstance().data or false

# ##### setData()
Template.sparkline.setData = ( key, data ) ->
  Template.currentData()[ key ] = data
  @log "#{ key }:set", data

# ##### isDomSource()
Template.sparkline.isDomSource = ->
  return @getData().domSource or false

Template.sparkline.getPresetOptions = ( key ) ->
  if key
    keys = key.split " "
    presetOptions = {}
    _.extend( presetOptions, @presetOptions[ key ] ) for key in keys
    return presetOptions
  else return false

Template.sparkline.presetOptions =
  "bar-default":
    type: "bar"
    barColor: "#ffffff"
    height: "35px"
    barWidth: "5px"
    barSpacing: "2px"
    zeroAxis: "false"
  "bar-info":
    type: "bar"
    barColor: "#3CA2BB"
    height: "35px"
    barWidth: "5px"
    barSpacing: "2px"
    zeroAxis: "false"
  "bar-warning":
    type: "bar"
    barColor: "#EE8366"
    height: "35px"
    barWidth: "5px"
    barSpacing: "2px"
    zeroAxis: "false"
  "bar-primary":
    type: "bar"
    barColor: "#32434D"
    height: "35px"
    barWidth: "5px"
    barSpacing: "2px"
    zeroAxis: "false"
  "bar-success":
    type: "bar"
    barColor: "#65B688"
    height: "35px"
    barWidth: "5px"
    barSpacing: "2px"
    zeroAxis: "false"
  "bar-danger":
    type: "bar"
    barColor: "#D65C4F"
    height: "35px"
    barWidth: "5px"
    barSpacing: "2px"
    zeroAxis: "false"