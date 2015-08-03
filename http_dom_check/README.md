http_dom_check
---------------
This is a part of a filtering solution that is suppose to give concurrency in couple levels, client side usig Golang version and server.

This is the client to a DB such PGSQL that supplies api to query the DB with cache support for the responses.

For now I am releasing also the server side that contains most of the check logic vs the DB.

This part doesn't reveale the DB strucutre for now but later might also includes that.

I have used pgsql since it was the faster from all in loading\adding from files into the DB.

This service is better used with squid or varnish infront to utilizie fast cachability.
