squid-helpers
=============
this repo holds some squid-helpers i have written such as:

dynamic content squid + ICAP caching method
-------------------
this is not a squid2.7 store_url_rewrite method but ment for squid ver 3+
tested on squid 3.1.19 and works on squid 3.2.17 only as forward proxy and not as tproxy\intercept.
what we do is manipulating the requests of two proxies in a hierarchy order
squid1----->squid2--->youtube\dynamic content site.
  \          /
   \        /
    \      /
      ICAP
	|
      MYSQL

squid1 gets a request from client and sends the request to ICAP server.
ICAP server strips from the url the needed data then compose an url for internal use and
stores the url id + original url to DB as a pair.
squid1 acls prevent it to send an icap request to the icap server and uses squid2 as a cache peer
either as a tproxy router\bridge or a cache direct cache_peer.
(until now the client dosnt know a thing and thinks he is on the way to get the original url.
squid2 gets the request from squid1 as an internal url such as "http://youtube.squid.internal/dynamic_id_url"
squid2 then sends an ICAP request to the ICAP server.
the ICAP server is checking in the database if there is a url that matches the id of the dynamic content and
rewrites the url to the original one.
then squid2 gets the origianl rewritten url for squid1
(squid1 thinks he gets "http://youtube.squid.internal/dynamic_id_url")
and the dynamic content is served toi to the client.
next time someone will try to get the dynamic content he will get the cached data from squid1 if it's still in cache.


more detaild explanation and history on the process here:
[squid-users mailing list post on the topic](http://squid-web-proxy-cache.1019090.n4.nabble.com/Youtube-dynamic-content-caching-with-squid-3-2-DONE-td4655311.html)
how to implement and needed scripts are in /squid-helpers/youtubetwist

NEW StoreID perl helper that helps cache youtube videos.
-------------
http://wiki.squid-cache.org/Features/StoreID

I also have store_url_rewrite for squid2.7 that ment to help store youtube videos in cache.

there are samples for codes that other people wrote.

  Caching youtube videos using this above method will not work since Google have changed their static way of publishing videos.
If you want more details on the subject contact me via my private email eliezer@ngtech.co.il or via squid user mailing list at:squid-users@lists.squid-cache.org

proxy_hb_check
--------------
two scripts:
proxyhb.sh - heartbeat checker for a http proxy status using a specific http target.
proxystatcheck.sh - external acl helper for squid to retrive the status of the proxy.
those scripts can be used with snmp to check the load of the proxy.
will be ported into a routing HB mechanism.

