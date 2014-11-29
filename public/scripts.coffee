#setup all states (initial) and get state machine
loadURL = (url) ->
  $radio.attr "data-state", "loading"
  $.getJSON(url).then (res) ->
    nextURL = res.next.self
    $itsURL.attr "href", res.original
    audioElement.setAttribute "src", res.audio
    return

  return

(($player) ->
  mechine = stateMachineFromStates($player.find("state"))
  log = (first)->
    console.log(arguments)
    return first

  player.once 'setup' ()->
    machine.setState('starting')

    @audio = document.createElement("audio")
    @audio.setAttribute "autoplay", "autoplay"
    @audio.addEventListener "loadstart", ()=>
      machine.setState('loading')

    @audio.addEventListener "loadeddata", ()=>
      machine.setState('loaded')

  mechine.on
    starting:
      init:(el)->
        @urlInput = $(el).find('.starting-url')
        @startBtn = $(el).find('[for-state]')
        @startBtn.on 'click', ()=>
          @setState('started',@urlInput.val())

      in:()->
        @urlInput.val('')

    started:
      in:(url)->
        @setState('loading')
        $.getJSON(url).then (res) =>
          @nextURL = res.next.self
          @setState('loaded',res)
          

          $itsURL.attr "href", res.original
          audioElement.setAttribute "src", res.audio
          return
        @audio.src = url
        # is aut play set so no need to play
        # @audio.play()
        
      out:()->
        @audio.removeAttribute('src')

      loading:
        in:(objToLoad)->

        out:()->

      loaded:
        in:()->

        out:()->

        paused:
          in:()->

          out:()->

        playing:
          in:()->

          out:()->

  
  states.filter("[initial]").show()
  audioElement = document.createElement("audio")
  audioElement.setAttribute "autoplay", "autoplay"
  audioElement.addEventListener "playing", (->
    $radio.attr "data-state", "playing"
    audioElement.play()
    return
  ), true
  return
) $("player")
nextURL = null
$itsURL = $radio.find(".playing-url")
audioElement.addEventListener "ended", (->
  $radio.attr "data-state", "loading"
  loadURL nextURL
  return
), true
$radio.find(".playing-play").on "click", ->
  if audioElement.paused
    audioElement.play()
  else
    audioElement.pause()
  return

$radio.find(".playing-next").on "click", ->
  audioElement.pause()
  loadURL nextURL
  return

$radio.find(".starting-start").on "click", ->
  url = $radio.find(".starting-url").val()
  sufix = url.split("watch")[1]
  loadURL "/api" + sufix
  return
