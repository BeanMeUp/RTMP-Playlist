set("frame.video.width", 1280)
set("frame.video.height", 720)
set("frame.video.samplerate", 25)
set("gstreamer.add_borders", false)

s = playlist.safe("playlist.pls",reload_mode="watch") 

s = fallback([s, blank()])

output.gstreamer.audio_video(
  video_pipeline=
    "videoconvert ! x264enc bitrate=2000 ! video/x-h264,profile=baseline ! queue ! mux.",
  audio_pipeline=
    "audioconvert ! voaacenc bitrate=128000 ! queue ! mux.",
  pipeline=
    "flvmux name=mux ! rtmpsink location=\"rtmp://[YOUR_IP]:1935/example/live live=1\"",
  s)

  output.gstreamer.audio_video(
  video_pipeline=
    "videoconvert ! x264enc bitrate=2000 ! video/x-h264,profile=baseline ! queue ! mux.",
  audio_pipeline=
    "audioconvert ! voaacenc bitrate=44100 ! queue ! mux.",
  pipeline=
    "flvmux name=mux ! rtmpsink location=\"rtmp://rtmp-api.facebook.com:80/rtmp/[API_CODE]?ds=1&s_l=1&a=[API_CODE] live=1\"",
  s)