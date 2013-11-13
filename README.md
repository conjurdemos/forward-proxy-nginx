Nginx Conjur Forward Proxy
==========================

This example shows how to use nginx as a forward proxy to conjur services that
automatically adds a conjur authentication token header.  The header is cached
automatically so you don't have to worry about this in your host's client logic.

To provision the demo, create a .netrc file in the project directory containing
credentials like this:

```
machine https://authn-sandbox-conjur.herokuapp.com
  login myusername
  password 2py9a9g1jtasdfewnccs10t2p8z2gba6jn1yhx038111aj9czx3e84
```

Then run `vagrant up` to boot and provision the vm.  Once the vm has booted,
you can ssh to it with `vagrant ssh` and try out the forward proxy, which listens
on port `8080`:

```bash
curl -x localhost:8080 http://core-sandbox-conjur.herokuapp.com/environments
```

will show a (probably empty) list of conjur environments for the identity you provided
in the .netrc file.

You might have noticed that the above request was via *http* and not *https*.  This is because
nginx does not support the https `CONNECT` request protocol.  The nginx proxy will
set the forward url scheme to https no matter what, since all conjur services use https.
If you really want to use the `CONNECT` protocol (for example if you're making requests from
non local machines and need to secure trafic), consider using a forward proxy like Squid, 
with a similar scripting technique.
