# App Server Arena
## Comparison of Ruby Application Servers

### Lonestar Ruby Conference, Austin, TX: July 19th, 2013

This repository contains code, notes and other assets pertaining to my talk entitled
"App Server Arena" that was given at Lonestar Ruby Conf in 2013.

#### The app

There's a very simple Sinatra application here designed to have some basic capabilities:

* Spit out the name of the app server running it at the moment and other process/env info
* Compute Pi to 20,000 decimal places
* Hit Twitter and get the last 10 tweets from @devops_borat
* Sleep for 5 seconds
* Randomly do one of the above with a 50% chance to do the first (except Twitter because of API rate limitations)

The idea here is to provide diagnostic information (first point), do some mildly computationaly expensive task,
and then have a way to see how things perform when waiting on network response.

#### The slides

TODO: Put slides online somewhere. Check back later and maybe this will be updated with something useful!

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

