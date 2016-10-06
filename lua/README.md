# Lua Platform

The Lua platform supports code deployment, the application is built in the
target.


## Code deployment

If you just run a ``git push`` of your code, tsuru will try and build the
application using ``cargo build`` – which fetches all the dependencies
automatically.