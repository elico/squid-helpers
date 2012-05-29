#!/usr/bin/ruby
while 1 == 1 
#puts "enter line and press enter key"
name = gets
#url = name.split(/ /).first
url = name

#puts name
#puts url
idrx = /.*(id\=)([A-Za-z0-9]*).*/
itagrx = /.*(itag\=)([0-9]*).*/
rangerx = /.*(range\=)([0-9\-]*).*/
#puts url.match(idrx)[2]
#puts url.match(itagrx)[2]
#puts url.match(rangerx)[2]

puts "http://video-srv.youtube.com.SQUIDINTERNAL/id_" + url.match(idrx)[2] + "_itag_" + url.match(itagrx)[2] + "_range_" + url.match(rangerx)[2]
end
