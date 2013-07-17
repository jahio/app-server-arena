# App Server Arena
## Comparison of Ruby Application Servers

### Lonestar Ruby Conference, Austin, TX: July 19th, 2013

# NOTE: THIS DOCUMENT IS A WORK IN PROGRESS.

There may be technical inaccuracies or omissions at this point. These are being fact checked
prior to the conference.

This repository contains code, notes and other assets pertaining to my talk entitled
"App Server Arena" that was given at Lonestar Ruby Conf in 2013.

#### The app

There's a very simple Sinatra application here designed to have some basic capabilities:

* Spit out the name of the app server running it at the moment and other process/env info
* Compute Pi to 20,000 decimal places
* Hit Twitter and get the last 10 tweets from @devops_borat
* Sleep for 1 second
* Randomly do one of the above with a 50% chance to do the first (except Twitter because of API rate limitations)

The idea here is to provide diagnostic information (first point), do some mildly computationaly expensive task,
and then have a way to see how things perform when waiting on network response.

#### The slides

TODO: Put slides online somewhere. Check back later and maybe this will be updated with something useful!

## Comparing Application Servers

The application servers in question here - Puma, Unicorn, Thin and Passenger (v3) - were compared
in several categories:

+ Mode of Operation (Fighting Style)
+ Use Cases (Strategy)
+ Configuration (Training)
+ Performance (Combat)

### Mode of Operation (Fighting Style)

Ancient gladiators had preferences for certain weapons and fighting styles in the Collesseum (TODO: Spelling).
Some would use sword and shield, a net to trap opponents, a trident or polearm, perhaps even projectile weapons like a bow
and arrow.

These application servers also operate in different ways.

#### Passenger

Phusion Passenger operates by embedding itself into nginx or Apache. In this example, I only examined nginx simply because
Engine Yard does not use Apache in our stack.

There's one interesting side effect of using nginx with Passenger, however: because nginx doesn't have a "plugin-like"
architecture, similar to the way Apache does, nginx has to be *recompiled from scratch using Phusion's nginx source code*
with their modifications to compile and run Passenger. This is usually not a big deal, and to Phusion's credit they generally
do a pretty good job with it, but it should be noted that now instead of being able to get nginx straight from its maintainers,
now you'll have to get it through Phusion for their updates (unless you're merging nginx and Passenger code yourself,
which, let's face it, is kinda crazy).

Once compiled and installed, Passenger is basically a part of nginx. You then configure Passenger by modifying nginx
configuration - usually somewhere like /etc/nginx/ or /opt/nginx.

Passenger has a huge array of configuration options to choose from to suit nearly any environment. However, it should
be noted that under its default configuration, Passenger will use an elastic worker spawning method that Phusion calls
"smart spawning". This spawning method essentially *waits until a worker is necessary before starting one*. This has
numerous benefits and unintended side effects, however, that we'll get into later.

When Passenger is configured, it's set as a "location" in nginx configuration. Further configuration instructs
nginx to forward requests to that location, which is how Passenger then takes over. It takes a given request, finds
and available worker, and then forwards the request to it. There are two ways to configure this request routing internally:

+ per-worker
+ pool-wide (global queue)

With the per-worker feature, Passenger maintains a separate queue for each worker. This can be problematic if
a request comes in that takes a while and other requests are queued up behind it in the same worker.

The second option, a global queue, allows Passenger to put all requests on the same queue "stack". Workers then
are given whatever is next on this stack, thus making the long request situation a little less problematic.

#### Unicorn

Unicorn, by contrast to Passenger, doesn't have an internal "tie-in" with nginx, nor does it have a single router
process. Instead, Unicorn launches a master process that contains one single copy of your application in memory, and then
forks itself into worker processes. The number of worker processes depends on how Unicorn is configured; it could be one to
as many as the machine can reasonably hold.

Unicorn is then configured to bind to a unix socket on the local machine. Requests from nginx, then, are placed in this
socket. Each worker then, of its own volition, dips into the socket, finds the next request to handle, works it, then
returns a response to nginx.

The Unicorn master process, in this case, stands by and observes each of its workers. If any worker becomes unresponsive,
the master kills the worker and simply forks itself again. In this way, Unicorn's overall architecture is rather stable,
and allows for hot restarts - restarting only one worker at a time after having code deployed.

#### Thin

Thin works much like Unicorn, except that when started in cluster mode, each Thin worker opens its own socket, or is
bound to its own port. Nginx can then be configured to "round-robin" balance requests between as many Thin sockets/ports
as you have configured to start. It doesn't have a master process (by default) that runs and monitors the workers like
Unicorn does, but it is capable of a "hot restart" using the "onebyone" option in configuration, which restarts one
worker at a time for zero-downtime deploys.

Under the hood, Thin relies on an EventMachine-based architecture. This is not a fully asynchronous architecture
like Puma, launching new requests in threads, but in theory it should allow for significant speed improvements by taking
action only when enough data has been received from the client, for example.

#### Puma

Puma can be configured to bind to ports, or to pull from a socket, just like Thin and Unicorn. However, unlike Thin
and Unicorn, Puma will open a new thread for each incoming request. This means that blocking actions that aren't
necessarily heavy on CPU usage should not be a problem for Puma.

However, when discussing threading, we must constantly be aware of Ruby's Global VM Lock (GVL). This is a limitation
 - possibly a feature - of the language that ensures that even when launching new threads, except in specific cases,
Ruby will only execute one **ruby** code instruction at a time. MRI can still hand off async instructions to underlying
C-based drivers, for example, but as for executing actual Ruby code, the GVL ensures that only one instruction is processed
at a time per each Ruby process.

For this reason, Puma will run best under JRuby or Rubinius. Unfortunately, I didn't have time to profile Puma under
either of these interpreters; instead performance benchmarking below is based on MRI 2.0.

### Performance Testing

In no case can any of the performance tests here be taken as "gospel", or in any way interpreted that
these simplistic use cases are in any way all-encompassing. These are really straight-forward and simple
tests that show different servers under different situations, but are not generalizable and applicable to even
a majority of applications out there, especially those in complex problem domains.

In other words, **your mileage may vary.**

My goal was to see which servers performed best under different circumstances. The application servers
tested here were:

+ puma
+ Passenger 3 (we don't have Passenger 4 on Engine Yard Cloud yet)
+ Thin (I had to write a lot of custom chef to rip out our Unicorn stack and shove Thin in there, but it works)
+ Unicorn

#### Testing hardware

This app was deployed to four different environments on Engine Yard Cloud backed by Amazon EC2 in US East 1.
All VMs are High CPU Mediums. They come with 2 VCPU cores each and 1.7GB of memory. No database was used and no
external data store (with the exception of the Twitter example, since a REST API could be considered a data store)
was used in the app because I didn't want to artificially slow down tests because the app server was waiting on, for example,
the database driver for whatever reason - that'd just skew the tests in a weird way.

#### Testing methodology

I used a tool called [Siege](http://www.joedog.org/siege-home/) by [Jeff Fulmer](http://www.joedog.org/author/jdfulmer/).
I'd had major problems getting apache bench to work right and stumbled on Siege, which has a lot of very interesting options.

(Tip: you can install this crazy easy on OS X via ```brew install siege```.
If you don't have [Homebrew](http://mxcl.github.io/homebrew/), you really should get it.)

I used the following command/syntax to perform these tests,
then put the results in flat files you can read under the "performance" subdirectory:

```
siege -r 1000 -c 100 -b -q http://asa-puma/sleep > puma.txt 2>&1
```

I'm not concerned with doing anything too fancy here, I just want a straight up, "how fast can you do it?" test.
The arguments used:

+ ```-r``` repetitions. Do this test N number of times, in this case, 1000.
+ ```-c``` concurrency. How many simultaneous requests are we doing? In this case, 100 simultaneous requests, a thousdand times over.
+ ```-b``` benchmark. Removes internal throttling from siege. Really tries to hit the server crazy hard.
+ ```-q``` quiet. Suppresses output that otherwise shows every. single. get. request. ever. made. throughout the entire test.

