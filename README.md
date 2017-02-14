# RTMP-Playlist

## Overview

The purpose of this example/tutorial is to show you how to create an FFMPEG, or in this case, a LIBAV output to an RTMP server using a playlist. FFMPEG/LIBAV can do this without any help, but, the playlist is not dynamic. It reads the playlist on start and then stops (or loops) when it gets to the end.

My way to fix this is to use GStreamer/Libav for the decoding and encoding, along with Liquidsoap for playlist management. With this setup you can have Liquidsoap to generate a dynamic playlist that you can update and the stream will update itself dynamically as well.

Optionally I will also go over how to create your own RTMP server using nginx and the nginx-rtmp-module. 
