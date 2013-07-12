# App Server Arena: Comparison of Ruby Application Servers

## Lonestar Ruby Conference, Austin, TX: July 19th, 2013

This repository contains code, notes and other assets pertaining to my talk entitled
"App Server Arena" that was given at Lonestar Ruby Conf in 2013.

### The app

There's a very simple Sinatra application here designed to perform some mildly computationally expensive
task (nothing huge, like computing Pi or anything, but nothing trivial either) and then render a response.
It doesn't talk to a data store of any kind or connect to various external APIs over REST/HTTP or anything
like that since we don't want to test the speed of *those* things, just the speed of the application servers
and their ability to execute code concurrently.

### The slides

TODO: Put slides online somewhere. Check back later and maybe this will be updated with something useful!