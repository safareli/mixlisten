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
