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

blockBind = _.callNext (f, c, args...) ->
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
    blockBind(
      $startBtn.attr
      $startBtn
      "disabled"
      true))

#valid
validUrls
  .filter(Boolean)
  .subscribe(
    blockBind(
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

nextURL = null
audioElement = document.createElement('audio')
audioElement.setAttribute('autoplay', 'autoplay')
audioElement.addEventListener "playing", ()->
  setState('playing')
  audioElement.play()



audioElement.addEventListener "ended", ->
  setState('loading')
  loadURL(nextURL)

$playingUrl = $player.find('.playing-url')

loadURL = (url) ->
  setState('loading')
  $.getJSON(url).then (res) ->
    nextURL = res.next.self
    $playingUrl.attr('href',res.original)
    audioElement.setAttribute "src", res.audio
    return


$pauseBtn.on 'click', ()->
  setState('paused')
  audioElement.pause()

$startBtn.on 'click', ()->
  loadURL(apiUrl($inputUrl.val()))
  
$playBtn.on 'click', ()->
  setState('playing')
  audioElement.play()

$nextBtn.on 'click', ()->
  audioElement.pause()
  loadURL(nextURL)
  