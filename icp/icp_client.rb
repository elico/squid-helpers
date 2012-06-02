#!/usr/bin/ruby

# documentation: this program is an ICP client version 2
# Written by Eliezer Croitoru 
# feel free to use the code as you pleased for non proofit usage.
# the code is open source and the licence for the code is kind of BSD 
# with some exceptions: if you want to use the code on a production system
# please leave details about the system at eliezer<at>ngtech.co.il
# 
# feel free to ask questions.
# plans: to make the code work with threding and or concurrency 
# also to add some cache using a local DB.
# porting the client into server to allow webservers in a cluster communicate with
# the reverse proxy cache.
#
#
# 
# 



require 'socket.so'

class UDPClient
  attr_accessor :icpopt, :icpver, :len, :sender, :line, :reqnum, :host, :port, :debug

  def initialize(host, port, debug)
    @host = host
    @port = port
    @debug = debug
    @icpver = [2].pack('C')
    @icpopt = [1]
    @reqnum = [ 0 ]
    @unusedopt = [ 0, 0, 0, 0].pack('C*').to_s
    @unusedopt1 = [ 255, 255, 255, 255].pack('C*').to_s
  end

  def start
    puts "connecting to server: " + @host.to_s + " on port: " + @port.to_s if @debug == 1 
    @socket = UDPSocket.open
    @socket.connect(@host, @port) 
    puts "udp socket info: " + @socket.to_s  if @debug == 1 
      @port = ARGV[1].to_i
      @sender = @socket.getsockname.unpack('C*')
      puts "that source ip is: " + [ @sender[4], @sender[5], @sender[6], @sender[7]].to_s  if @debug == 1
      @sender = [ @sender[4], @sender[5], @sender[6], @sender[7]].pack('C*').to_s
      while true
	@reqnum[0] += 1 
	puts "current icp request code: " + @icpopt.to_s
        puts "current icp request number: "+ @reqnum[0].to_s  if @debug == 1
	puts "enter url to check: "
#	STDIN.sync = true




	@line = STDIN.gets
	if @line[0] == "q" ||  @line[0] == "Q"
	then
		puts "exiting"
		exit
	end
	if @line[0] == "d" ||  @line[0] == "D"
	then
		puts "rasing debug mode to on"
		@debug = 1
	end
	if line.match(/(^[\d]+)/)
	then
	   puts @icpopt
	   @icpopt = [line.split(/(^[\d]+)/)[1].to_i]

	   puts @icpopt

	end
	puts "the requested url is: " + @line.to_s  if @debug == 1
        
	if @line.match(/^http|^ftp/)
	then
	@len = 24.to_i + @line.size 
	puts "packet length: " + @len.to_s if @debug == 1
	@len = [ @len ].pack('n').to_s
	
	@request = @icpopt.pack('C*').to_s + @icpver + @len + @reqnum.pack('N*').to_s + @unusedopt1 + @unusedopt + @sender + @unusedopt + @line.strip + [0].pack('C').to_s 
	@socket.send( @request.to_s , 0) if @line.match(/^http|^ftp/)
	puts "the requested packet:\n" + @request.unpack('C2nNC16A*').to_s if @debug == 1

	puts "wating for cache server resoponse..." if @debug == 1
	
	 
	packet = @socket.recvfrom(1024)  
	
	puts packet[0].unpack('C2nNC12A*').to_s if @debug == 1

	@inicpopt = packet[0].unpack('C2nNC12A*')[0].to_s
	
	case @inicpopt.to_i
	
	when 0
		puts @host.to_s + " ICP_INVALID "
	when 2
		puts @host.to_s + " UDP_HIT "
	when 3
		puts @host.to_s + " UDP_MISS "
	when 4
		puts @host.to_s + " UDP_ERR "
	when 5 .. 9
		puts @host.to_s + " ICP_UNUSED_YET "
	when 10
		puts @host.to_s + " ICP_SECHO "
	when 11
		puts @host.to_s + " ICP_DECHO"
	when 12 .. 20
		puts @host.to_s + " ICP_UNUSED_YET "
	when 21
		puts @host.to_s + " UDP_MISS_NOFETCH "
	when 22
		puts @host.to_s + " UDP_DENIED "
	when 23
		puts @host.to_s + " UDP_HIT_OBJ "
	end
	
	end
	sleep 1
    end
  end
end

def main
STDIN.sync = true

unless ARGV[0] && ARGV[1] 
        puts "Please supply an APC hostname/ip and ICP port"
	puts "to add debug info add -d in the in end"
	puts "example: ./icp_client.rb 127.0.0.1 3130 -d"
	puts "to rasied the debug level enter: d or D"
	puts "to exit enter: q of Q"
	exit
end
if ARGV[2] != nil && ARGV[2] == "-d" 
 then 
 @debug = 1 
 puts "debug mode: " 
 puts "args are: 1. " + ARGV[0].to_s + " 2. " + ARGV[1].to_s
 else
 @debug = 0
end


client = UDPClient.new(ARGV[0], ARGV[1].to_i, @debug) # 10.10.129.139 is the IP of UDP server
client.start
end

main
