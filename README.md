
# Dev Host Mapper

Easily deploy local vhosts.
No need to install reverse proxies.
No need to edit `/etc/hosts`

Though there are some requirements still:
- add `nameserver 127.0.0.1` ([or custom address](#custom-listen-address)) to `/etc/resolv.conf` - onetime action
- make sure nothing bound to following ports: `53/udp`, `80/tcp`, `443/tcp`
- having `Docker` (and `docker-compose`) installed (with current user added to `docker` group)

`git clone` this repo in your home folder and open `docker-compose.yml` in your editor.

To add vhosts simply add `volumes` (do not remove default volumes already in the file).

Eg. to add `dev.my-cool-blog.com` vhost simply add it to `volumes` like:

```yml
- /path/to/my-cool-blog:/etc/vhosts/dev.my-cool-blog.com
```

Long syntax:

```yml
- type: bind
  source: /path/to/my-cool-blog
  target: /etc/vhosts/dev.my-cool-blog.com

```

And the last requirement is the `/path/to/my-cool-blog/vhost.conf` file.

It is an `nginx` vhost config, though "shortened" a bit.
Put here any vhost config that usually placed in `server` section, like `location`, `header`, `root` etc. except `listen` and `server_name`.
Also do not add `server` section itself.

```conf
# remove or comment server section
# server {

# remove or comment listen directive
# listen 80;

# remove or comment server_name directive
# server_name dev.my-cool-blog.com;

set $basedir "/etc/vhosts/$host";

root "$basedir/public";

location / {
  try_files $uri @front;
}

location @front {
  proxy_pass http://127.0.0.1:5000;
}

# remove or comment server section end
# }
```

Now back to `dev-host-mapper` folder and run it in foreground mode, to make sure there are no errors:

`docker-compose up --build`

And try `http://dev.my-cool-blog.com` in your browser.

If everything works, `Ctrl-C` to stop mapper service and run it in backgroud:

`docker-compose up --wait`

## Custom listen address

Under the hood there is a `dnsmasq` service running on port `53/udp` and an `nginx` server running on `80/tcp` and `443/tcp`.

By default they will listen on `127.0.0.1` address.

If you have something else running on this address:port or just want `dev-host-mapper` to run on another address, edit `LISTEN_ADDRESS` environment in `docker-compose.yml`

After you update `LISTEN_ADDRESS` make sure to add corresponfing nameserver line to `/etc/resolv.conf`

## Limitations

Only tested on Linux.

To avoid port mapping for every vhost (or use port ranges), switched to `network_mode: host`

Thus it wont work as expected on `MacOS`.

But one can delete/comment `network_mode` line and add `ports` instead.

Forward only ports used by `dev-host-mapper` and your vhosts:

```yml
ports:
  - "53/udp"
  - 80
  - 443
  # vhosts ports
  - 5000
  - 6000
```

Or use ranges to forward specific ports used by your vhosts:

```yml
ports:
  - "53/udp"
  - 80
  - 443
  # my vhosts listens on ports from 40_000 to 60_000
  - "40000-60000:40000-60000"
```

This way should also work well on `MacOS`.

Not sure about `Windows`, would work on `WSL`?

