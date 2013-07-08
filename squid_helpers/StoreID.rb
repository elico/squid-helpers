#!/usr/bin/ruby
# encoding: utf-8

require "rubygems"
require "net/http"
require "open-uri"
require 'timeout'
require 'libxml'

require 'syslog'


module Crawler
 class NetHttp
   def initialize(proxy_host, proxy_port=80, proxy_user = nil, proxy_pass = nil)
     @proxy_host =  proxy_host;
     @proxy_port =  proxy_port;
     @proxy_user =  proxy_user;
     @proxy_pass =  proxy_pass;
   end

   def request_response(uri_str, limit = 10)
     begin
       http = Net::HTTP::Proxy(@proxy_host, @proxy_port, @proxy_user, @proxy_pass)
       result = http.get_response(URI.parse(uri_str))
       case result
       when Net::HTTPSuccess     then result
       when Net::HTTPRedirection then request_response(result['location'], limit - 1)
       else
         result.error!
       end
     rescue Exception => e
         puts e.message
         return false
     end
   end

  def self.head(url)
    url = URI.parse(url)

    begin
      res = Net::HTTP.start(url.host, url.port) {|http|
        http.head(url.path)
      }
    rescue =>e
      return nil
    end
    return res
  end

  def self.get(url)
    url = URI.parse(url)

    begin
      res = Net::HTTP.start(url.host, url.port) {|http|
        http.get(url.path)
      }
    rescue =>e
      return nil
    end
    return res
  end

  def getmeta4(url)
   return self.get(url + ".meta4") if !url.end_with?(".meta4")
  end



  def self.redirect?(url)
   res = nil
   begin
   status = Timeout::timeout(0.5) {
   res = self.head(url)
   }
   rescue => e
     $stderr.puts "Redirect Check Timedout"
     res = false
   end
   if res && res.code == "301" && res.code == "302"
      return true
    elsif res && res.code == "200"
      return false
    else
      return nil
    end
  end

  def self.digest?(url)
   res = nil
   begin
   status = Timeout::timeout(2) {
   res = self.head(url)
   }
   rescue => e
     $stderr.puts "Redirect Check Timedout"
     res = false
   end
   if res["Digest"]
      return true
    else
      return false
    end
  end

 end
end

#c = Crawler::NetHttp.new("<http proxy URL>", "<port >", "Proxy user name", "Proxy Password")


class Cache
        def initialize
        @host = "localhost"
        @db = "0"
        @port = 6379
        #@redis = Redis.new(:host => @host, :port => @port)
        #@redis.select @db
        end

        def setvid(url,vid)
           #return @redis.setex  "md5(" + vid+ ")",1200 ,url
           return true;
        end

        def geturl(vid)
           return @redis.get "md5(" + vid + ")"
        end


        def sfdlid(url)
                        m = url.match(/^http:\/\/.*\.dl\.sourceforge\.net\/(.*)/)
                        if m[1]
                                return m[1]
                        else
                                return nil
                        end
        end

        def vimid(url)
            m = url.match(/.*\.com\/(.*)\?(.*)/)
            offset =  m[2].match( /(aktimeoffset\=([\d\.]+))/ ) if m != nil
            return m[1] + "?offset=" + offset[2] if  offset != nil
            return m[1] if m != nil
            return nil
        end

        def imdbid(url)
            m = url.match(/.*\.com\/(.*)\?(.*)/)
            return m[1] if m != nil
            return nil
        end

        def dmvid(url)
            m = url.match(/.*(\.net|\.com)\/(.*)\?.*/)
            ec_seek = url.match(/.*(\&ec_seek\=[\d\.]+|\&start\=[\d\.]+).*/)
            return m[2] + ec_seek[1] if m != nil && ec_seek != nil
            return m[2] if m != nil
            return nil
        end

        def vsvid(url)
            m = url.match(/http:\/\/(proxy[\d]+\.videoslasher\.com)\/(.*)\?.*/)
            ec_seek = url.match(/.*(\&ec_seek\=[\d\.]+|\&start\=[\d\.]+).*/)
            return m[2] + ec_seek[1] if m != nil && ec_seek != nil
            return m[2] if m != nil
            return nil
        end


        def ytimg(url)
                m = url.match(/.*\.ytimg.com\/(.*\.jpg|.*\.gif|.*\.js)/)
                if m[1]
                        return m[1]
                else
                        return nil
                end
        end

        def ytvid(url)

                id = getytid(url)
                itag = getytitag(url)
                range = getytrange(url)
                redirect = getytredirect(url)
                if id == nil
                        return nil
                else
                        vid = id
                end
                if itag != nil
                        vid = vid + "&" + itag
                end
                if range != nil
                        vid = vid + "&" + range
                end
                if redirect != nil
                        vid = vid + "&" + redirect
                end
                if Crawler::NetHttp.redirect?(url)
                        vid = vid + "&non_cache=1"
                end
                return vid
        end

        private
                def getytid(url)
                        m = url.match(/(id\=[a-zA-Z0-9\-\_\%]+)/)
                        return m.to_s if m != nil
                end

                def getytitag(url)
                        m = url.match(/(itag\=[0-9\-\_]+)/)
                        return m.to_s if m != nil
                end

                def getytrange(url)
                        m = url.match(/(range\=[0-9\-]+)/)
                        return m.to_s if m != nil
                end

                def getytredirect(url)
                        m = url.match(/(redirect\=)([a-zA-Z0-9\-\_]+)/)
                        return (m.to_s + Time.now.to_i.to_s) if m != nil
                end


end

def rewriter(request)
                case request

                when /^http:\/\/[a-zA-Z0-9\-\_\.]+\.squid\.internal\/.*/
                   url = $cache.geturl(request)
                   if url != nil
                      return url
                    else
                      return ""
                  return ""
                    end
                when /^http:\/\/[a-zA-Z0-9\-\_\.]+\.dl\.sourceforge\.net\/.*/
                  vid = $cache.sfdlid(request)
                  $cache.setvid(request, "http://dl.sourceforge.net.squid.internal/" + vid) if vid != nil
                  url = "http://dl.sourceforge.net.squid.internal/" + vid if vid != nil
                  return url
                when /^http:\/\/av\.vimeo\.com\/.*/
                  vid = $cache.vimid(request)
                  $cache.setvid(request, "http://vimeo.squid.internal/" + vid) if vid != nil
                  url = "http://vimeo.squid.internal/" + vid if vid != nil
                  return url
                when /^http:\/\/[a-zA-Z0-9\-\_\.]+\.c\.youtube\.com\/videoplayback\?.*id\=.*/
                  vid = $cache.ytvid(request)
                  $cache.setvid(request, "http://youtube.squid.internal/" + vid) if vid != nil
                  url = "http://youtube.squid.internal/" + vid if vid != nil
                  return url
                when /^http:\/\/[a-zA-Z0-9\-\_\.]+\.ytimg\.com\/(.*\.jpg|.*\.gif|.*\.js)/
                  vid = $cache.ytimg(request)
                  $cache.setvid(request, "http://ytimg.squid.internal/" + vid) if vid != nil
                  url = "http://ytimg.squid.internal/" + vid if vid != nil
                  return url
                when /^http:\/\/video\-http\.media\-imdb\.com\/.*\.mp4\?.*/
                  vid = $cache.imdbid(request)
                  $cache.setvid(request, "http://imdbv.squid.internal/" + vid) if vid != nil
                  url = "http://imdbv.squid.internal/" + vid if vid != nil
                  return url
                when /^http:\/\/(vid\.ec\.dmcdn\.net|proxy\-[\d]+\.dailymotion\.com)\/.*(mp4|flv).*/
                  vid = $cache.dmvid(request)
                  $cache.setvid(request, "http://dmv.squid.internal/" + vid) if vid != nil
                  url = "http://dmv.squid.internal/" + vid if vid != nil
                  return url
                when /http:\/\/proxy[\d]+\.videoslasher\.com\/free\/.*\.flv?.*/
                  vid = $cache.vsvid(request)
                  $cache.setvid(request, "http://videoslasher.squid.internal/" + vid) if vid != nil
                  url = "http://videoslasher.squid.internal/" + vid if vid != nil
                  return url  
		when /http:\/\/(.*torrage\.com|.*zoink\.it|.*torrage\.ws|.*torcache\.net)\/(torrent\/[A-Z0-9]+\.torrent)/
      	          url = "http://torrentcache.squid.internal/" + $2 if $2
		  return url
		when /http:\/\/(ca\.isohunt\.com)\/download\/[\d]+\/([a-z0-9]+)\.torrent/
		  url = "http://torrentcache.squid.internal/torrent/" + $2.upcase + ".torrent" if $2
                  return url
		when /http:\/\/(pd-vdp-cdn[\d]+-nap.terra.com)\/(terratv\/[0-9]+\.mp4)?.*/
		  url = "http://terratv.squid.internal/" + $2 if $2
                  return url
		when /http:\/\/(dl[\d]+\.torrentreactor\.net)\/download.php\?id=([\d]+).*/
		  url = "http://torrentreactor.squid.internal/" + $2 + ".torrent"if $2
                  return url
		when /http:\/\/(i|vid)[\d]+\.photobucket\.com\/(.*)\.(mp4|jpg)/  
		  url = "http://photobucket.squid.internal/" + $2 + ".jpg" if $3 == "jpg"
		  url = "http://photobucket.squid.internal/" + $2 + ".mp4" if $3 == "mp4"
                  return url
		when /http:\/\/(khm|mt)[\d]+\.google\.[a-z\.]+\/(.*)\&s\=[a-zA-Z]+/
 		  url = "http://googlemapskhm.squid.internal/" + $2 if $1 == "khm"
                  url = "http://googlemapsmt.squid.internal/" + $2 if $1 == "mt"
		  return url
                when /http:\/\/([\-a-z0-9\.]+)\.c\.android\.clients\.google\.com\/(market\/GetBinary\/[\/0-9a-z\.\-]+)\?.*/
		  url = "http://androidmarket.squid.internal/" + $2 if $2
		  return url
		when /http:\/\/download\.oracle\.com\/(otn\-pub[a-zA-Z0-9\-\/\.]+)\?.*/
		  url = "http://oracleotn.squid.internal/" + $1 if $1
		  return url
		when /http:\/\/image\.slidesharecdn\.com\/(.*\.jpg)\?[0-9]+/
		  url = "http://slidesharecdn.squid.internal/" + $1 if $1 
		  return url
		when /http:\/\/cdn\.slidesharecdn\.com\/(.*jpg)\?[0-9]+/
		   url = "http://slidesharecdn.squid.internal/" + $1 if $1
		   return url
		when /^quit.*/
                  exit 0
                else
                 return ""
                end
end

def log(msg)
 Syslog.log(Syslog::LOG_ERR, "%s", msg)
end

def eval
        request = gets
        if (request && (request.match /^[0-9]+\ /))
         conc(request)
         return true
        else
         noconc(request)
         return false
        end

end


def conc(request)
                return if !request
                request = request.split
                if request[0] && request[1]
                        log("original request [#{request.join(" ")}].") if $debug
                        result = rewriter(request[1])
                        if result
                          url = request[0] +" OK store-id=" + result
                        else
                          url = request[0] +" ERR"
                        end
                        log("modified response [#{url}].") if $debug
                        puts url
                else
                        log("original request [had a problem].") if $debug
                        url = request[0] + "ERR"
                        log("modified response [#{url}].") if $debug
                        puts url
                end

end

def noconc(request)
                return if !request
                request = request.split
                if request[0]
                        log("Original request [#{request.join(" ")}].") if $debug
                        result = rewriter(request[0])
                        if result && (result.size > 10)
                                url = "OK store-id=" + rewriter(request[0])
                                #url = "OK store-id=" + request[0] if ( ($empty % 2) == 0 )
                        else
                                url = "ERR"
                        end
                        log("modified response [#{url}].") if $debug
                        puts url
                else
                        log("Original request [had a problem].") if $debug
                        url = "ERR"
                        log("modified response [#{url}].") if $debug
                        puts url
                end
end

def validr?(request)
  if (request.ascii_only? && request.valid_encoding?)
    return true
  else
    STDERR.puts("errorness line#{request}")
    #sleep 2
    return false
  end


end

def main

        Syslog.open('cordinator.rb', Syslog::LOG_PID)
        log("Started")

        c = eval

         if c
          while request = gets
             conc(request) if validr?(request)
          end
         else
          while request = gets
#            $empty += 1
             noconc(request) if validr?(request)
          end
         end
end

$debug = true
$cache = Cache.new
STDOUT.sync = true
#$empty = 1
main

