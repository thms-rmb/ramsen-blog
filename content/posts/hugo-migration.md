---
title: "Hugo Migration"
date: 2019-05-02T22:54:56+02:00
categories: ["Articles"]
---

This site used to be implemented in
[WordPress](https://wordpress.org/). I had a nice setup but ended up
being concerned all the time about updates, script insecurities and
managing my changes to the theme. After not managing an update with my
Git workflow, I started to look for alternatives. In the end, I
converted my site to [Hugo](https://gohugo.io/). I'm going to try to
document my current setup in this article.

<!--more-->

# Apache & Varnish

The actual server is a small VPS rented at
[DigitalOcean](https://www.digitalocean.com/), running the
[Debian](https://www.debian.org) Linux distribution. It's using
[Apache HTTP Server](https://httpd.apache.org/) in cooperation with
[Varnish HTTP Cache](https://varnish-cache.org/). Varnish makes for
a very nimble site, while Debian and Apache provide a stable service
with peace of mind.

I've setup Apache HTTP Server to _cooperate_ with Varnish. It uses
three related `VirtualHosts`, identified by the ports they respond
to. The actual files are served with Apache on port `8080`, with port
`80` redirecting to secure TLS on port `443`, which in turn proxies the
request to Varnish running on port `6081`. The secure `VirtualHost` uses
certificates from [Let's Encrypt](https://letsencrypt.org/). Varnish
keeps a cache of the responses served from the backend on port `8080`.

Varnish isn't really configured that much as I use the default
behavior in every case. I think the only thing I have configured is
the default _origin_ for the cache, which is port `8080` on the
`localhost`.

The files themselves are located in my home directory on the server,
where I've set some `ACL` attributes to allow Apache to read the files.

## Hugo

Hugo is used to generate the site from a set of content files. I use
the [Hugo Bootstrap v4
Blog](https://github.com/alanorth/hugo-theme-bootstrap4-blog) theme
which makes for a simple and responsive user interface. On my server I
download the latest Hugo binary instead of installing from the Debian
package repository.

## Continuous integration

I don't use a complicated build service, although I've experimented
with that before. It's simply unneccessary for my needs with this
site.

In order to build and deploy this site, I've simply cloned the
repository to the parent directory of the `DocumentRoot` on the
server. In addition, I've created a simple script that Git runs during
its `post-receive` hook, which builds the site using the `Makefile`
and places the built site in the `DocumentRoot`. Building the site
using Hugo is very fast and uses little resources.

{{< highlight makefile "linenos=table" >}}
SOURCES := $(shell find . -name '*.toml' -or -name '*.md')

build : $(SOURCES)
	hugo

clean :
	rm -r -f public
{{< / highlight >}}

In effect, I push my local changes to the server and it'll build the
site automatically.
