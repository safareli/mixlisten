$player = $('player')
$states = $player.find('state')

# init
$states.each ()->
  $(this).hide()
.filter ()->
  $(this).is('[default]')
.show()

_.mixin
  call: (f)->
    f()
  callNext : (f)->
    (args...) ->
      ()->
        f.apply(undefined,args)

callArgs = _.callNext (f, argProviders...) ->
  f.apply(undefined, argProviders.map(_.call))

unaryBind = _.callNext (f, c, args...) ->
  f.apply(c, args)

isValidPlaylistUrl = (url) ->
  RegExp = /^https?:\/\/(?:www\.)?youtube.com\/watch\?(?=.*v=\w+)(?=.*list=\w+)(?:\S+)?$/
  RegExp.test(url)

$startBtn = $states.find('.start')
$pauseBtn = $states.find('.pause')
$playBtn = $states.find('.play')
$nextBtn = $states.find('.next')
$inputUrl = $states.find('.starting-url')

validUrls = Rx.Observable
  .fromEvent(
    $inputUrl
    'keyup')
  .map(
    callArgs(
      isValidPlaylistUrl
      _.bind(
        $inputUrl.val
        $inputUrl)))

#invalid
validUrls
  .filter(
    _.negate(Boolean))
  .subscribe(
    unaryBind(
      $startBtn.attr
      $startBtn
      "disabled"
      true))

#valid
validUrls
  .filter(Boolean)
  .subscribe(
    unaryBind(
      $startBtn.removeAttr
      $startBtn
      'disabled'))


validUrls
  .subscribe(
    _.bind(
      console.log
      console
      'validUrls ='))

apiUrl = (url)->
  'api/' + url.split('watch')[1]


setState = (stateName)->
  $states.hide()
  $states.find("[name='#{stateName}']").parents('state').andSelf().show()

stater = (stateName, f)->
  (args...)->
    setState(stateName)
    f.apply()

$playingUrl = $player.find('.playing-url')

just = (wat)->
  (it)->
    wat = it if typeof it isnt 'undefined'
    wat

decorate = (beafore,one,after)->
  ()->
    beafore() if beafore
    one.apply(this,arguments)
    after() if after

nextURL = just(null)
audioElement = document.createElement('audio')
audioElement.setAttribute('autoplay', 'autoplay')
loadURL = decorate _.bind(setState,undefined,'loading'), (url) ->
    $.getJSON(url).then (res) ->
      nextURL(res.next.self)
      $playingUrl.attr('href',res.original)
      audioElement.setAttribute "src", res.audio
      return
loadNext = callArgs(loadURL,nextURL);

audioElement.addEventListener "playing", decorate(
  _.bind(setState,undefined,'playing')
  unaryBind(audioElement.play, audioElement))
audioElement.addEventListener "ended", loadNext








$pauseBtn.on 'click', decorate(
  _.bind(setState,undefined,'paused')
  unaryBind(audioElement.pause, audioElement))

$startBtn.on 'click', callArgs(
  _.compose(loadURL,apiUrl)
  unaryBind(
    $inputUrl.val
    $inputUrl))

$playBtn.on 'click', decorate(
  _.bind(setState,undefined,'playing')
  unaryBind(audioElement.play, audioElement))

$nextBtn.on 'click', decorate(
  null,
  unaryBind(audioElement.pause, audioElement)
  loadNext)
  
  