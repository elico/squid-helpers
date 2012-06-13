#!/usr/bin/env ruby
# ---------------------------------------------------------------------------------------
# Echelon
# ICAP Prototype Server
# - By Alex Levinson
# - May 25th, 2012
# ---------------------------------------------------------------------------------------
require 'bundler'
require 'syslog'
require 'settingslogic'
Bundler.require(:icap)

# ---------------------------------------------------------------------------------------
class Settings < Settingslogic
  source "#{ARGV[0]}"
  load!
end
# ---------------------------------------------------------------------------------------
class Echelon < EM::Connection
@debug = (Settings.debug == 1)
@request = { "Request" =>{}, "Headers" => {} }
@resp = ""
  def post_init
    cleanup
  end

  def receive_data(packet)
	log("packet recived") if @debug
   @data_status = 0
    @data << packet
	log("recived data: " + @data ) if @debug
  	if @icap_header[:data] == "" and pos = (@data =~ /\r\n\r\n/)
      @icap_header[:data] = @data[0..pos+1]
      if @icap_header[:data] =~ /^((OPTIONS|REQMOD|RESPMOD) icap:\/\/([A-Za-z0-9\.\-:]+)([^ ]+) ICAP\/1\.0)\r\n/
        req                 = $1
        @icap_header[:mode] = $2
        @icap_header[:host] = $3
        @icap_header[:path] = $4
        @icap_header[:data][req.size+2..@icap_header[:data].size-1].scan(/([^:]+): (.+)\r\n/).each do |h|
          @icap_header[:hdr][h[0]] = h[1]
      end
      else
        log("Error with ICAP header!") if @debug
		# exit 1
		# puts "Error with ICAP header! Exiting!" ; exit 1
        # TODO: Having problems when this uncommented
      end
      log(@data) if @debug
	  @data = @data[pos+4..@data.size-1]
	  log(@data) if @debug
    end
#	log(@icap_header)
#	log(@data)
	log("Starting case") if @debug 
    case @icap_header[:mode]
    when 'OPTIONS'
      log("OPTIONS case")  if @debug 
	  method = @icap_header[:path] == '/request' ? 'REQMOD' : 'RESPMOD'
      send_data("ICAP/1.0 200 OK\r\nMethods: #{method}\r\n\r\n")
      cleanup
    when 'REQMOD'
	  log("REQMOD case")  if @debug
	  orderdata
	  log(@request) if @debug
		  case @request["Request"]["Method"]
			when /(GET|HEAD)/
			log("method is GET or HEAD") if @debug
			 #newdata =  seturl("http://www.yahoo.com/",request,@request[Headers])
			 #newdata = ""
			 
#######################################################
#insert here your code
#sample
# seturl("http://google.co.il/") if matcher(/^http:\/\/www\.google\.com/)
#
#matcher is a class to match regular expresions for validity only if true or false
#a more complex options can be written manullay.
###
# one more sample
#  if matcher(/^http:\/\/www\.google\.com/) 
#	uri = geturl.match(/http:\/\/[a-z\.]+\.com\/(.*)/)[1]
#	seturl("http://www.google.co.il/" + uri)
#	end
#
#  turns into these
#1339602675.159    305 192.168.10.100 TCP_MISS/404 1243 GET http://www.google.co.il/www - DIRECT/173.194.69.94 text/html
#1339602675.317    122 192.168.10.100 TCP_MISS/200 7618 GET http://www.google.co.il/images/errors/robot.png - DIRECT/173.194.69.94 image/png
#
#
# methods: 
###
# seturl(url)
# set rewrites the url in the request and also the host name on the request header.
###
#  @param header - the name of the header
#  @param data - the data you want to set in the header.
#  setheader(header,data)  
# if an header exists fills the new data. 
# for now you can only change or add a new header using:
###
#  @param header - the name of the header
#  @param data - the data you want to set in the header.
# addheader(header,data)
###
# geturl
# returns the full url of the request as a string
###












#####################################################
			 if @data_status  == 1
				log("Request was changed") if @debug
				log(@request) if @debug
				preresp 
				log(@request) if @debug
				send_data(compresp)
			else
			  log("GET or HEAD data wasnt modified") if @debug
			  log ("No Modification for: #{@request}")  if @debug
			  nocontent
			end
		else
		    log("method is not GET") if @debug
			log(@request["Request"]["Method"]) if @debug
			log ( "No Modification for: #{@request}")
			nocontent
		end
    when 'RESPMOD'
	  log("RESPMOD case") if @debug
   	  nocontent
    else
		log("else/RESPMOD") if @debug
    end
	cleanup
  end
  
  
  def nocontent
    send_data("ICAP/1.0 204 No Content.\r\n\r\n")
	log("no content 204 sent") if @debug
  end

  def cleanup
	log("starting cleanup") if @debug
	@data_status = 0
    @data        = ""
    @body        = ""
    @icap_header = { 
      :data => "", 
      :mode => "", 
      :path => "", 
      :hdr  => {}
    }
	@request = { "Request" =>{}, "Headers" => {} }
	@resp = ""
  end

  def orderdata
	  req_raw     = @data.dup.split(/\r\n/)
	  @request["Request"] = parserequest(req_raw[0])
      req_raw[1..-1].each do |line|
        line.scan(/([^:]+): (.+)/).each do |field|
    	 @request["Headers"][field[0]] = field[1]
	    end
	  end
  end
   
   def parserequest(req)
	k = req.scan(/(GET|POST|PUT|HEAD|PURGE)\ (http:\/\/.*)\ (.*)/)[0]
	log(k) if @debug
	h = {"Method" => k[0], "Url" => k[1], "Version"=> k[2]}
	log(h) if @debug
	log(h) if @debug
	return h
  end
  
  
  def compresp
 	#about the icap format:
	#the icap headers separated from the the response header with a clean line "\r\n"
	#the response header \end of the message ended with double clean lines "'\r\n\r\n"
	#
	#
	#
	#
	#  original compose
	#response = "ICAP/1.0 200 OK\r\nDate: #{Time.now.strftime("%a, %d %b %Y %X %Z")}\r\nServer: RubyICAP\r\nConnection: close\r\nEncapsulated: req-hdr=0, null-body=#{@data.bytesize}\r\n\r\n#{@data}"
	log("composing icap response") if @debug
	return  ("ICAP/1.0 200 OK\r\nDate: #{Time.now.strftime("%a, %d %b %Y %X %Z")}\r\nServer: RubyICAP\r\nEncapsulated: req-hdr=0, null-body=#{@request.bytesize}\r\nConnection: close\r\n\r\n#{@request}")
  end
  
 
  
  def seturl(url)
    @request["Request"]["Url"] = url
	@request["Headers"]["Host"] = extracthost(url)
	@data_status = 1
	  
  end
 
 def geturl
	return @request["Request"]["Url"] 
  end
  
	def getheader(header)
		if @request["Headers"][header]
			return @request["Headers"][header] 
		else
		
			return "not exists"
		end
    end
	
	def setheader(header,data)
		if @request["Headers"][header]
			@request["Headers"][header] = data
			@data_status = 1
			return "changed"
		else
			return "not exists"
		end
	end
	def addheader(header, data)
		if @request["Headers"][header]
			return "exists already"
		else
			@request["Headers"][header] = data
			@data_status = 1
			return "changed"
		end
	end
	
	  def preresp
		key = "" 
		key += @request["Request"]["Method"] + " " +  @request["Request"]["Url"] + " " +  @request["Request"]["Version"] + "\r\n"
		#request["Request"] + "\r\n"
		@request["Headers"].each_key do |n|
		key += n +": " + @request["Headers"][n] +"\r\n"
		
		end
		key += "\r\n\r\n"
		@request = key
	  end
	
	def parsereq(request)
	
		return request.scan(/(GET|POST|PUT)\ (http:\/\/.*)\ (.*)/)[0]
	end
	
		def divideurl(url)
			return url.scan(/^(http:\/\/)([0-9a-zA-Z\.\-\_]+)(\/.*)/)[0]
		end
	
	def extracthost(url)
		return divideurl(url)[1]
	end
	
	def matcher(regex)
		if regex.match(@request["Request"]["Url"])
			return true
		else
			return false
		end
		
	end
	
	
	
end

def log(msg)
	Syslog.log(Syslog::LOG_ERR, "%s", msg)
end



def main
	Syslog.open('Ruby_Icap', Syslog::LOG_PID)
	log("Started")
#	if (Settings.debug == 1)
		Settings.each do |l| 
		log(l)  
		end
#	end
  puts "== Ruby ICAP Server Started =="
	EM.run do
	  EM.start_server Settings.host, Settings.port, Echelon
	if Settings.forks.size > 0
    forks = Settings.forks.to_i
    puts "... forking #{forks} times => #{2**forks} instances"
    forks.times { fork }
	 
	end

	end
end

main
