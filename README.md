# RTMP-Playlist

## Overview

The purpose of this example/tutorial is to show you how to create an FFMPEG, or in this case, a LIBAV output to an RTMP server using a playlist. FFMPEG/LIBAV can do this without any help, but, the playlist is not dynamic. It reads the playlist on start and then stops (or loops) when it gets to the end.

My way to fix this is to use GStreamer/Libav for the decoding and encoding, along with Liquidsoap for playlist management. With this setup you can have Liquidsoap to generate a dynamic playlist that you can update and the stream will update itself dynamically as well.

Optionally I will also go over how to create your own RTMP server using nginx and the nginx-rtmp-module.

## Prerequisites

* A Ubuntu 14.XX (or higher) or other Debian based linux server.
* 8 or more GB of RAM
* A CPU that can handle encoding/decoding (I do not recommend a VPS with a shared CPU)
* A sudo enabled user (not root)


## Installing GStreamer

GStreamer is a multimedia framework that will be handling the linking together of the enconding and decoding components. It is important that you install all of the encoders with it, so that way you can play all media types.

So let's go ahead and install GStreamer first:

```
sudo apt-get -y install libgstreamer1.0-0 gstreamer1.0-plugins-base \
   gstreamer1.0-plugins-ugly gstreamer1.0-plugins-good \
   gstreamer1.0-plugins-bad gstreamer1.0-tools gstreamer1.0-libav
```

## Installaing LiquidSoap

LiquidSoap handles playlists for multimedia. This will even allow you to schedule playlists and do more advanced playlist and scheduling functions. While you do not need the entire package for this specific playlist that we will be creating, you may want to add more advanced features later.

```
sudo apt-get -y install liquidsoap liquidsoap-plugin-all
```

## Installation nginx & nginx-rtmp-module (OPTIONAL)

If you want to run your own RTMP server, you will want to install nginx and the nginx-rtmp-module. You can also install this on a seperate server. All this does is host your RTMP server, it has nothing to do with the streaming portion. If you want to just stream to Facebook Live, Twitch, or any other RTMP server then you do not have to follow these steps.

You can find the installation instructions [in the official nginx-rtmp-module wiki](https://github.com/arut/nginx-rtmp-module/wiki/Getting-started-with-nginx-rtmp).

(It's best to use the installation instructions above instead of me writing it so that way you get the most recent way of doing it.)

## Configuring Liquidsoap

There are several different ways you can configure your Liquidsoap file. In this README I am going to show you 2 examples. I will also include these examples in the repo along with others. On your server, create a new file called `liquidsoap.liq` and use one of the configurations below, or in the repo

### Facebook Live Configuration

This configuration is if you want to stream to Facebook Live.

```
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
    "audioconvert ! voaacenc bitrate=44100 ! queue ! mux.",
  pipeline=
    "flvmux name=mux ! rtmpsink location=\"rtmp://rtmp-api.facebook.com:80/rtmp/[INSERT API CODE]?ds=1&s_l=1&a=[INSERT API CODE] live=1\"",
  s)
```

Just be sure to edit the `location=` with your Facebook Live RTMP URL and be sure you have a playlist.pls file (Don't worry I mention this below). Also note that you can change `reload_mode` to other options as well. Currently it is configured to watch the playlist file for any changes. If it detects a new playlist, it will then finish the current video that it is playing and then move to the top of the new playlist.

### nginx Configuration

This configuration is if you want to stream to your nginx server.

```
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
```

Just be sure to edit the `location=` with your RTMP URL, which can be different from above depending on how you configured your nginx server.Be sure you have a playlist.pls file (Don't worry I mention this below). Also note that you can change `reload_mode` to other options as well. Currently it is configured to watch the playlist file for any changes. If it detects a new playlist, it will then finish the current video that it is playing and then move to the top of the new playlist.

## Creating your Playlist

Create a new file and call it `playlist.pls`. You can insert whatever you want to be played from top to bottom. Just be sure you use the proper formatting.

Example:

```
[playlist]
Title3=Untitled
File3=/path/to/video1.mp4
Title3=Untitled
File3=/path/to/video2.mp4
Title3=Untitled
File3=/path/to/video3.mp4
NumberOfEntries=3
```

Note: Other playlist types are supported. http://savonet.sourceforge.net/doc-svn/playlist_parsers.html

## Running Your Stream

Once everything is installed and configured, you now can run your stream. Simply just `cd` to where your liquidsoap configuration file is and run:

`liquidsoap liquidsoap.liq`

Note: If you exit your console the stream will end. You may want to do `screen` or similar before you run this command.

## Vagrant

We now have a vagrant box:
```
vagrant init fyroc/RTMP-Playlist \
  --box-version 1
vagrant up
```
