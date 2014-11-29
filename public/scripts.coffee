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

$startingState = $states.filter('[name="starting"]')
$startBtn = $startingState.find('.start')
$inputUrl = $startingState.find('.starting-url')

urlkeyups = Rx.Observable.fromEvent(
  $inputUrl,
  'keyup')

validUrlKeyups = urlkeyups.filter(
  callArgs(
    isValidPlaylistUrl
    _.bind(
      $inputUrl.val
      $inputUrl)))

invalidUrlKeyups = urlkeyups.filter(
  _.negate(
    callArgs(
      isValidPlaylistUrl
      _.bind(
        $inputUrl.val
        $inputUrl))))

validUrlKeyups.subscribe(
  blockBind(
    $startBtn.removeAttr,
    $startBtn,
    'disabled'))

invalidUrlKeyups.subscribe(
  blockBind(
    $startBtn.attr,
    $startBtn,
    "disabled",
    true))

