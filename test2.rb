#!/usr/bin/ruby
require "syslog"

class SquidRequest
	attr_accessor :url, :user
	attr_reader :client_ip, :method

	def method=(s)
		@method = s.downcase
	end

	def client_ip=(s)
		@client_ip = s.split('/').first
	end
end

def read_requests
	# URL <SP> client_ip "/" fqdn <SP> user <SP> method [<SP> kvpairs]<NL>
	STDIN.each_line do |ln|
		r = SquidRequest.new
		r.url, r.client_ip, r.user, r.method, *dummy = ln.rstrip.split(' ')
		(STDOUT << "#{yield r}\n").flush
	end
end

def log(msg)
	Syslog.log(Syslog::LOG_ERR, "%s", msg)
end

def main
	Syslog.open('url_rewrite.rb', Syslog::LOG_PID)
	log("Started")

	read_requests do |r|
idrx = /.*(id\=)([A-Za-z0-9]*).*/
itagrx = /.*(itag\=)([0-9]*).*/
rangerx = /.*(range\=)([0-9\-]*).*/

newurl = "http://video-srv.youtube.com.SQUIDINTERNAL/id_" + r.url.match(idrx)[2] + "_itag_" + r.url.match(itagrx)[2] + "_range_" + r.url.match(rangerx)[2]

	log("YouTube Video [#{newurl}].")

		newurl
	end
end

main

