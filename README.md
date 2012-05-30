squid-helpers
=============
this repo holds some squid-helpers i have written such as:
store_url_rewrite for squi2.7 that ment to help store youtube videos in cache.

there are samples for codes that other people wrote.

proxy_hb_check
--------------
two scripts:
proxyhb.sh - heartbeat checker for a http proxy status using a specific http target.
proxystatcheck.sh - external acl helper for squid to retrive the status of the proxy.
those scripts can be used with snmp to check the load of the proxy.
will be ported into a routing HB mechanism.

