$radio = $('.radio');
nextURL = null
$itsURL = $radio.find('.playing-url')

audioElement = document.createElement('audio');
audioElement.setAttribute('autoplay', 'autoplay');
audioElement.addEventListener("playing", function() {
  $radio.attr('data-state','playing');
  audioElement.play();
}, true);

audioElement.addEventListener("ended", function() {
  $radio.attr('data-state','loading');
  loadURL(nextURL);
}, true);

function loadURL (url) {
  $radio.attr('data-state','loading');
  $.getJSON(url).then(function(res){
    nextURL = res.next.self;
    $itsURL.attr('href',res.original)
    audioElement.setAttribute('src', res.audio);
  });
}

$radio.find('.playing-play').on('click',function(){
  if(audioElement.paused){
    audioElement.play()
  }else{
    audioElement.pause();
  }
});

$radio.find('.playing-next').on('click',function(){
  audioElement.pause();
  loadURL(nextURL);
});
$radio.find('.starting-start').on('click',function(){
  url = $radio.find('.starting-url').val();
  sufix = url.split('watch')[1];
  loadURL('/api' + sufix)
})