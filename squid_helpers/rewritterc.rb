#!/usr/bin/ruby
require 'syslog'

class Cache
        def initialize
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
                        m = url.match(/.*\.com\/(.*)(\?.*)/)
                        if m[1]
                                return m[1]
                        else
                                return nil
                        end
        end

        def ytimg(url)
                m = url.match(/.*\.ytimg.com\/(.*)/)
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
                return vid
        end

        private
                def getytid(url)
                        m = url.match(/(id\=[a-zA-Z0-9\-\_]+)/)
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

		when /^http:\/\/[a-zA-Z0-9\-\_\.]+\.dl\.sourceforge\.net\/.*/
		  vid = $cache.sfdlid(request)
		  url = "http://dl.sourceforge.net.squid.internal/" + vid if vid != nil
		  return url				
		when /^http:\/\/av\.vimeo\.com\/.*/
		  vid = $cache.vimid(request)
		  url = "http://vimeo.squid.internal/" + vid if vid != nil
		  return url
		when /^http:\/\/[a-zA-Z0-9\-\_\.]+\.c\.youtube\.com\/videoplayback\?.*id\=.*/
		   vid = $cache.ytvid(request)
          	   url = "http://youtube.squid.internal/" + vid if vid != nil
          	   return url
		when /^http:\/\/[a-zA-Z0-9\-\_\.]+\.ytimg\.com\.*/
		   vid = $cache.ytimg(request)
           	   url = "http://ytimg.squid.internal/" + vid if vid != nil
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

def main

	Syslog.open('rewritter.rb', Syslog::LOG_PID)
	log("Started")

	#read_requests do |request|
	while 	request = gets
		request = request.split
		if request[0] && request[1]
			log("original request [#{request.join(" ")}].") if $debug
			url = request[0] +" " + rewriter(request[1])
			log("modified response [#{url}].") if $debug
			puts url
		else
			puts ""
		end
	end
end
$debug = false
$cache = Cache.new
STDOUT.sync = true
main
