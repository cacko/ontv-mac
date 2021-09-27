# crapTV

iptv app

## features

* `a` - toggles always on op behaviour
* `f` - toggles full screen mode
* `m` - toggle sound
* `[`  `]` = volume up/down for the app context
* `/` - search dialog, hit `esc` to clear or close the dialog
* `p` - current channel EPG
* `l` - all channels EPG
* `cmd + l` - favourite channels on top, then the recent streams
* `c` - show other streams in that category
* `cmd up / down` - scrolls through streams in the current category
* `cmd left / right` - scrolls thru recent streams
* `t` - toggle title
* `b` - boomark stream as a shortcut
* `1/2/3/4/5` - opens saved streams at the given position
* `cmd r` - reload current stream, cos sometimes shit just stops working
* `cmd ,`_ - username/password thing, probalby do not need it once it is set
* `cmd =` - englarge the window
* `cmd -` - make window smaller
* `r` - show livescore sidebar
* `cmd t` - toggle livescore ticker

double click on the video makes toggles fullscreen mode, since click hides the shown if any toggle view

also you can switch the renderer engine from FFMPEG to the MacOS native AVFoundation, which will reduce the CPU load, but it codec support is limited hence some streams may not work.

## install

download installation file from [packages](https://gitlab.com/cacko/ontv-mac/-/packages) or look at next section if you want to build it yourself

## building

* `brew install go-task/tap/go-task`
* `task init`
* `task install`
* `task archive` - will produce app package in Application folder or you can go straight to `task install` which will build and install the app into /Applications
