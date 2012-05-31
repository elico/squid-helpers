#!/usr/bin/ruby 
require "syslog"

class ProxyStat

	def info
	      return "proxy name: #{@name} proxy file: #{@path}"
	end

	def set_path(_loca)
		@path = _loca
	end

	def set_status(_stat)
	    @status = _stat
	end

	def get_status
#	     @check_status
	     return @status
	end

	def set_now  # a writer
	    @now = Time.now
		
	end

	def get_now 	# a reader
	    return @now		
	end

	def get_last
	    return @lasttime
	end

	def set_last
	    @lasttime = Time.now
	end
	
	
	def get_path
	    return @path
	end

	def check_status
	    set_now
	    if ( ( get_now - 30 ) > get_last ) 
		 disk_check
	         return @status
		else
		 return @status
	    end
	
	end

	def disk_check
	    if  File::exists?(get_path)	
		@status = "1"
		set_last
		return @status
	    else
		@status = "0"
		set_last
		return @status
	    end
	end

	def initialize( k, _name )
		
		@lasttime = Time.now
		@now = Time.now
	        @status = "0"
		@path = k
		@name = _name
#		disk_check		
	end

end

def log(msg)
        Syslog.log(Syslog::LOG_ERR, "%s", msg)
end

def main
	proxy1 = ProxyStat.new( "/tmp/proxy1.err", "youtube" )

     Syslog.open('proxyhbstatus.rb', Syslog::LOG_PID)
	        log("Started #{proxy1.info}")

	

     while 1 == 1
	dummy = gets
          if ( proxy1.check_status == "0" )
		   puts "OK"
	  else
		   puts "ERR"
	  end
     end


end

main

