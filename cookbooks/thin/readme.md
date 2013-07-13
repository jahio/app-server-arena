# thin on Engine Yard Cloud

NOTICE: This recipe is NOT SUPPORTED. That's important so I'll say it again:

# THIS RECIPE IS NOT SUPPORTED. USE IT AT YOUR OWN RISK. IF IT BREAKS, YOU'RE ON YOUR OWN.

There, I think I've sufficiently covered that point now.

Now, understand that this recipe exists only because I hacked it together to get basic,
really hacky control and automation in place for running thin on Cloud for a conference talk.
Otherwise it wouldn't be here. 

If you really, really wanna use it, realize that IT WON'T WORK FOR ENVIRONMENTS WITH MORE
THAN ONE APPLICATION. Generally speaking, if you're running more than one Ruby app in prod
in a single environment, (a) that's bad, and (b) if you absolutely have to, use Passenger for
its pseudo "lazy loading" thing it does with workers - that's way better because otherwise
you're going to kill memory.