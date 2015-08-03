require "riak"
require "base64"

path1 = "/buckets/blocked_odms/keys/domain"
path2 = "/buckets/blocked_urls/keys/url"

$client = Riak::Client.new(:host => "filterdb", :pb_port => 8087)

def block_dom(domain)
	my_bucket = $client.bucket("blocked_doms")

	val1 = "ERR"
	obj1 = my_bucket.new(domain)
	obj1.data = val1
	obj1.store()
end

def block_url(url)
	my_bucket = $client.bucket("blocked_urls")

	val1 = "ERR"
	obj1 = my_bucket.new(Base64.encode64(url))
	obj1.data = val1
	obj1.store()
end

def test_dom(dom)
	begin
	  my_bucket = $client.bucket("blocked_doms")
	  fetched1 = my_bucket.get(dom)
	  puts "ERR" if fetched1.data == "ERR"
	rescue Riak::ProtobuffsFailedRequest => e
	  puts "OK"
	rescue => e
	   STDERR.puts "ERR Exception"
	   puts "ERR Exception"
	end
end

def test_url(url)
	begin
	  my_bucket = $client.bucket("blocked_urls")
	  fetched1 = my_bucket.get(Base64.encode64(url))
	  puts "ERR" if fetched1.data == "ERR"
	rescue Riak::ProtobuffsFailedRequest => e
	  puts "OK"
	rescue => e
	   STDERR.puts "ERR Exception"
	   puts "ERR Exception"
	end
end

examples = []
examples << "http://ruby-doc.org/stdlib-2.2.2/libdoc/base64/rdoc/Base64.html#method-i-strict_encode64"
examples << "https://github.com/arthurtumanyan/sqRiakRedirector"
examples << "https://www.google.co.il/search?q=riak+ruby+client&ie=utf-8&oe=utf-8&gws_rd=cr&ei=ZfG_VfCYBfKV7AbW0Ya4BA"
examples << "http://www.rimon.net.il/sites/www1.rimon.net.il/files/styles/change_pictures/public/banner_rashi_1.jpg?itok=aHNA8ndJ"

dom_examples = []
dom_examples << "sex.com"
dom_examples << "inn.co.il"
dom_examples << "yahoo.com"
dom_examples << "walla.co.il"

bad_doms = ["sex.com"]


bad_doms.each do |d|
  block_dom d
end

dom_examples.each do |d|
  test_dom d
end
