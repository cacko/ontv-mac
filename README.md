# crapTV

iptv app

## features

* `a` - toggles always on op behaviour
* `f` - toggles full screen mode
* `m` - toggle sound
* `/` - search dialog
* `p` - current channel EPG
* `l` - all channels EPG
  * `g` - toggle EPG view between recently watched and favs and all
* `c` - show other streams in that category
* cmd `up / down` - scrolls thru streams in the current category
* cmd `left / right` - scrolls thru recent streams
* `t` - toggle title
* `b` - boomark stream as a shortcut
* `1/2/3` - opens saved streams at the given position
* `r` - reload current stream
* `cmd ,`_ - username/password thing, probalby do not need it once it is set
* `cmd =` - englarge the window
* `cmd -` - make window smaller
* `i` - stream info

## install

download installation file from [packages](https://gitlab.com/cacko/craptv/-/packages) or look at next section if you want to build it yourself

## building

* `brew install go-task/tap/go-task`
* `task init`
* `task install`
