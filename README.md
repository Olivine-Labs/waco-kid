# The Waco Kid

![](http://stream1.gifsoup.com/view4/1774385/waco-kid-o.gif)

![](https://33.media.tumblr.com/tumblr_md05053cwW1qfr6udo1_500.gif)

Waco Kid is a re-implementation of Mailgun's
[Vulcand](https://github.com/mailgun/vulcand) using Ngnix and lua for speed. It
aims to be completely compatible with Vulcand's etcd configuration syntax,
although it does not currently support configuration of SSL becuase of
limitations of the Nginx+Lua API.

## Building

`docker build -t waco-kid .`

## Configuration
Only two variables really matter, `WK_ETCD_URL`, which should be the full url
eg `http://10.0.0.1:2379` and `WK_ETCD_PREFIX` which defautls to `/vulcand`.

## Running
Run `docker run -it -e WK_ETCD_URL=http://${ETCD_SERVER_IP}:2379 -p 80:80
waco-kid` after building the image.

## Development
First build an image, then. Run
`docker run -it -e WK_ETCD_URL=http://${ETCD_SERVER_IP}:2379 -p 80:80 -v
$PWD:/app waco-kid` from the root of the repo. This mounts the current version
of the app into the image so you don't need to rebuild every time.

You can also run `./dev.sh` which will output the url to the container, but
_does_ rebuild the image every time.
