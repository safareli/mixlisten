_ = require 'underscore'
ytdl    = require 'ytdl-core'
Transcoder = require 'stream-transcoder'
express = require 'express'
coffeeMiddleware = require('coffee-middleware')
jsdom = require 'jsdom'
serveStatic = require 'serve-static'
app = express()

l = (item)->
  console.log.apply(console,arguments)
  item

youtubeVideoURLFromV = (v)->
  "http://www.youtube.com/watch?v=#{v}"

youtubeVideoURLFromVandList = (v,list)->
  "http://www.youtube.com/watch?v=#{v}&list=#{list}"

apiURLFromVandList = (v,list)->
  "/api?v=#{v}&list=#{list}"

audioURLFromV = (v)->
  "/listen?v=#{v}"

fileFromVandList = (v,list)->
  original : youtubeVideoURLFromVandList(v,list)
  self : apiURLFromVandList(v,list)
  audio : audioURLFromV(v)

nextVideoElement = (geter)->
  next = geter('.currently-playing + li')
  if not next
    next = geter('#playlist-autoscroll-list li:first-child')
  next

nextVideoV = (next)->
  next.getAttribute('data-video-id')


app.use serveStatic(__dirname + '/public')
app.use coffeeMiddleware
  src: __dirname + '/public'

app.get '/listen', (req, res)->
  v = req.query.v
  res.contentType('mp3');
  new Transcoder(ytdl(youtubeVideoURLFromV(v)))
    .audioCodec('mp3')
    .sampleRate(44100)
    .channels(2)
    .audioBitrate(128 * 1000)
    .format('mp3')
    .stream().pipe(res);

app.get '/api', (req, res)->
  v = req.query.v
  list = req.query.list
  
  jsdom.env
    url:l(youtubeVideoURLFromVandList(v,list))
    done: (errors, window) ->
      res.end(l(errors)) if errors
      geter = window.document.querySelector.bind window.document
      nextV = nextVideoV(nextVideoElement(geter))
      res.jsonp _.extend(
        fileFromVandList(v, list), 
        next: fileFromVandList(nextV, list)
      )

server = app.listen 3000, process.env.IP, ->
  host = server.address().address
  port = server.address().port
  console.log('Example app listening at http://%s:%s', host, port)