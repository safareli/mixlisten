$player = $('player')
$states = $player.find('state')

# init
$states.each ->
  $(this).hide()
.filter ->
  $(this).is('[default]')
.show()

call = (f)->
  f()

nullary = (f)->
  _.bind(call, undefined, f)

callNext = (f)->
  () ->
    nullary( _.bind(f.apply, f, undefined, arguments))

applayInvokedArguments = (f, argProviders...) ->
  f.apply(undefined, argProviders.map(call))

callArgs = callNext(
  applayInvokedArguments)

nullaryBind = callNext (f, c, args...) ->
  f.apply(c, args)


isValidPlaylistUrl = (url) ->
  RegExp = /^https?:\/\/(?:www\.)?youtube.com\/watch\?(?=.*v=\w+)(?=.*list=\w+)(?:\S+)?$/
  RegExp.test(url)

$startBtn = $states.find('.start')
$pauseBtn = $states.find('.pause')
$playBtn = $states.find('.play')
$nextBtn = $states.find('.next')
$inputUrl = $states.find('.starting-url')
$playingUrl = $player.find('.playing-url')

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
    nullaryBind(
      $startBtn.attr
      $startBtn
      "disabled"
      true))

#valid
validUrls
  .filter(Boolean)
  .subscribe(
    nullaryBind(
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

staterFor = ($el)->
  (stateName)->
    $el.hide()
    $el.find("[name='#{stateName}']").parents('state').andSelf().show()

setStateThen = _.compose(callNext, staterFor)($states)

just = (wat)->
  (it)->
    wat = it if typeof it isnt 'undefined'
    wat

wrap = (beafore,one,after)->
  ->
    beafore() if beafore
    one.apply(this,arguments)
    after() if after

beafore = (beafore,code)->
  wrap(beafore,code)

after = (after,code)->
  wrap(undefined, code, after)

nextURL = just()
audioElement = document.createElement('audio')
audioElement.setAttribute('autoplay', 'autoplay')
loadURL = beafore setStateThen('loading'), (url) ->
  $.getJSON(url).then (res) ->
    nextURL(res.next.self)
    $playingUrl.attr('href',res.original)
    audioElement.setAttribute "src", res.audio
    return

loadNext = callArgs(loadURL,nextURL);

audioElement.addEventListener(
  'ended'
  loadNext)

audioElement.addEventListener(
  'playing'
  beafore(
    setStateThen(
      'playing')
    nullaryBind(
      audioElement.play
      audioElement)))


$pauseBtn.on(
  'click'
  beafore(
    setStateThen(
      'paused')
    nullaryBind(
      audioElement.pause
      audioElement)))

$startBtn.on(
  'click'
  callArgs(
    _.compose(
      loadURL
      apiUrl)
    nullaryBind(
      $inputUrl.val
      $inputUrl)))

$playBtn.on(
  'click'
  beafore(
    setStateThen(
      'playing')
    nullaryBind(
      audioElement.play
      audioElement)))

$nextBtn.on(
  'click'
  after(
    loadNext,
    nullaryBind(
      audioElement.pause
      audioElement)))
