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
* Randomly do one of the above with a 50% chance to do the first

The idea here is to provide diagnostic information (first point), do some mildly computationaly expensive task,
and then have a way to see how things perform when waiting on network response.

#### The slides

TODO: Put slides online somewhere. Check back later and maybe this will be updated with something useful!