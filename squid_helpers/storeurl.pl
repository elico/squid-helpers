#!/usr/bin/perl
##by elico
#this script was take as an example from:
# http://aacable.wordpress.com/2012/01/19/youtube-caching-with-squid-2-7-using-storeurl-pl/
##

# This script is NOT written or modified by me, I only copy pasted it from the internet.
# It was First originally Writen by chudy_fernandez@yahoo.com
# & Have been modified by various persons over the net to fix/add various functions.
# For Example this ver was modified by member of comstuff.net to satisfy common and dynamic content.
# th30nly @comstuff.net a.k.a invisible_theater ,
# For more info, http://wiki.squid-cache.org/ConfigExamples/DynamicContent/YouTube
$|=1;
while (<>) {
@X = split;
#&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; $X[1] =~ s/&sig=.*//;
$x = $X[0] . " ";
$_ = $X[1];
$u = $X[1];

#speedtest
if (m/^http:\/\/(.*)\/speedtest\/(.*\.(jpg|txt))\?(.*)/) {
print $x . "http://www.speedtest.net.SQUIDINTERNAL/speedtest/" . $2 . "\n";

#mediafire
}elsif (m/^http:\/\/199\.91\.15\d\.\d*\/\w{12}\/(\w*)\/(.*)/) {
print $x . "http://www.mediafire.com.SQUIDINTERNAL/" . $1 ."/" . $2 . "\n";

#fileserve
}elsif (m/^http:\/\/fs\w*\.fileserve\.com\/file\/(\w*)\/[\w-]*\.\/(.*)/) {
print $x . "http://www.fileserve.com.SQUIDINTERNAL/" . $1 . "./" . $2 . "\n";

#filesonic
}elsif (m/^http:\/\/s[0-9]*\.filesonic\.com\/download\/([0-9]*)\/(.*)/) {
print $x . "http://www.filesonic.com.SQUIDINTERNAL/" . $1 . "\n";

#4shared
}elsif (m/^http:\/\/[a-zA-Z]{2}\d*\.4shared\.com(:8080|)\/download\/(.*)\/(.*\..*)\?.*/) {
print $x . "http://www.4shared.com.SQUIDINTERNAL/download/$2\/$3\n";

#4shared preview
}elsif (m/^http:\/\/[a-zA-Z]{2}\d*\.4shared\.com(:8080|)\/img\/(\d*)\/\w*\/dlink__2Fdownload_2F(\w*)_3Ftsid_3D[\w-]*\/preview\.mp3\?sId=\w*/) {
print $x . "http://www.4shared.com.SQUIDINTERNAL/$2\n";

#photos-X.ak.fbcdn.net where X a-z
}elsif (m/^http:\/\/photos-[a-z](\.ak\.fbcdn\.net)(\/.*\/)(.*\.jpg)/) {
print $x . "http://photos" . $1 . "/" . $2 . $3&nbsp; . "\n";

#YX.sphotos.ak.fbcdn.net where X 1-9, Y a-z
} elsif (m/^http:\/\/[a-z][0-9]\.sphotos\.ak\.fbcdn\.net\/(.*)\/(.*)/) {
print $x . "http://photos.ak.fbcdn.net/" . $1&nbsp; ."/". $2 . "\n";

#maps.google.com
} elsif (m/^http:\/\/(cbk|mt|khm|mlt|tbn)[0-9]?(.google\.co(m|\.uk|\.id).*)/) {
print $x . "http://" . $1&nbsp; . $2 . "\n";

# compatibility for old cached get_video?video_id
} elsif (m/^http:\/\/([0-9.]{4}|.*\.youtube\.com|.*\.googlevideo\.com|.*\.video\.google\.com).*?(videoplayback\?id=.*?|video_id=.*?)\&(.*?)/) {
$z = $2; $z =~ s/video_id=/get_video?video_id=/;
print $x . "http://video-srv.youtube.com.SQUIDINTERNAL/" . $z . "\n";

# youtube fix
} elsif (m/^http:\/\/([0-9.]{4}|.*\.youtube\.com|.*\.googlevideo\.com|.*\.video\.google\.com)\/videoplayback\?(.*)/) {
$p_str = $2;
$tag = "";
$alg = "";
$id = "";
$range = "";
if ($p_str =~ m/(itag=[0-9]*)/){$tag = "&".$1}
if ($p_str =~ m/(algorithm=[a-z]*\-[a-z]*)/){$alg = "&".$1}
if ($p_str =~ m/(id=[a-zA-Z0-9]*)/){$id = "&".$1}
if ($p_str =~ m/(range=[0-9\-]*)/){$range = "&".$1; $range =~ s/-//; $range =~ s/range=//; }
print $x . "http://video-srv.youtube.com.SQUIDINTERNAL/" . $tag . "&" . $alg . "&" . $id . "&" . $range . "\n";

} elsif (m/^http:\/\/www\.google-analytics\.com\/__utm\.gif\?.*/) {
print $x . "http://www.google-analytics.com/__utm.gif\n";

#Cache High Latency Ads
} elsif (m/^http:\/\/([a-z0-9.]*)(\.doubleclick\.net|\.quantserve\.com|\.googlesyndication\.com|yieldmanager|cpxinteractive)(.*)/) {
$y = $3;$z = $2;
for ($y) {
s/pixel;.*/pixel/;
s/activity;.*/activity/;
s/(imgad[^&]*).*/\1/;
s/;ord=[?0-9]*//;
s/;&timestamp=[0-9]*//;
s/[&?]correlator=[0-9]*//;
s/&cookie=[^&]*//;
s/&ga_hid=[^&]*//;
s/&ga_vid=[^&]*//;
s/&ga_sid=[^&]*//;
# s/&prev_slotnames=[^&]*//
# s/&u_his=[^&]*//;
s/&dt=[^&]*//;
s/&dtd=[^&]*//;
s/&lmt=[^&]*//;
s/(&alternate_ad_url=http%3A%2F%2F[^(%2F)]*)[^&]*/\1/;
s/(&url=http%3A%2F%2F[^(%2F)]*)[^&]*/\1/;
s/(&ref=http%3A%2F%2F[^(%2F)]*)[^&]*/\1/;
s/(&cookie=http%3A%2F%2F[^(%2F)]*)[^&]*/\1/;
s/[;&?]ord=[?0-9]*//;
s/[;&]mpvid=[^&;]*//;
s/&xpc=[^&]*//;
# yieldmanager
s/\?clickTag=[^&]*//;
s/&u=[^&]*//;
s/&slotname=[^&]*//;
s/&page_slots=[^&]*//;
}
print $x . "http://" . $1 . $2 . $y . "\n";

#cache high latency ads
} elsif (m/^http:\/\/(.*?)\/(ads)\?(.*?)/) {
print $x . "http://" . $1 . "/" . $2&nbsp; . "\n";

# spicific servers starts here....
} elsif (m/^http:\/\/(www\.ziddu\.com.*\.[^\/]{3,4})\/(.*?)/) {
print $x . "http://" . $1 . "\n";

#cdn, varialble 1st path
} elsif (($u =~ /filehippo/) && (m/^http:\/\/(.*?)\.(.*?)\/(.*?)\/(.*)\.([a-z0-9]{3,4})(\?.*)?/)) {
@y = ($1,$2,$4,$5);
$y[0] =~ s/[a-z0-9]{2,5}/cdn./;
print $x . "http://" . $y[0] . $y[1] . "/" . $y[2] . "." . $y[3] . "\n";

#rapidshare
} elsif (($u =~ /rapidshare/) && (m/^http:\/\/(([A-Za-z]+[0-9-.]+)*?)([a-z]*\.[^\/]{3}\/[a-z]*\/[0-9]*)\/(.*?)\/([^\/\?\&]{4,})$/)) {
print $x . "http://cdn." . $3 . "/SQUIDINTERNAL/" . $5 . "\n";

} elsif (($u =~ /maxporn/) && (m/^http:\/\/([^\/]*?)\/(.*?)\/([^\/]*?)(\?.*)?$/)) {
print $x . "http://" . $1 . "/SQUIDINTERNAL/" . $3 . "\n";

#like porn hub variables url and center part of the path, filename etention 3 or 4 with or without ? at the end
} elsif (($u =~ /tube8|pornhub|xvideos/) && (m/^http:\/\/(([A-Za-z]+[0-9-.]+)*?(\.[a-z]*)?)\.([a-z]*[0-9]?\.[^\/]{3}\/[a-z]*)(.*?)((\/[a-z]*)?(\/[^\/]*){4}\.[^\/\?]{3,4})(\?.*)?$/)) {
print $x . "http://cdn." . $4 . $6 . "\n";
#...spicific servers end here.

#photos-X.ak.fbcdn.net where X a-z
} elsif (m/^http:\/\/photos-[a-z].ak.fbcdn.net\/(.*)/) {
print $x . "http://photos.ak.fbcdn.net/" . $1&nbsp; . "\n";

#for yimg.com video
} elsif (m/^http:\/\/(.*yimg.com)\/\/(.*)\/([^\/\?\&]*\/[^\/\?\&]*\.[^\/\?\&]{3,4})(\?.*)?$/) {
print $x . "http://cdn.yimg.com//" . $3 . "\n";

#for yimg.com doubled
} elsif (m/^http:\/\/(.*?)\.yimg\.com\/(.*?)\.yimg\.com\/(.*?)\?(.*)/) {
print $x . "http://cdn.yimg.com/"&nbsp; . $3 . "\n";

#for yimg.com with &sig=
} elsif (m/^http:\/\/(.*?)\.yimg\.com\/(.*)/) {
@y = ($1,$2);
$y[0] =~ s/[a-z]+[0-9]+/cdn/;
$y[1] =~ s/&sig=.*//;
print $x . "http://" . $y[0] . ".yimg.com/"&nbsp; . $y[1] . "\n";

#youjizz. We use only domain and filename
} elsif (($u =~ /media[0-9]{2,5}\.youjizz/) && (m/^http:\/\/(.*)(\.[^\.\-]*?\..*?)\/(.*)\/([^\/\?\&]*)\.([^\/\?\&]{3,4})((\?|\%).*)?$/)) {
@y = ($1,$2,$4,$5);
$y[0] =~ s/(([a-zA-A]+[0-9]+(-[a-zA-Z])?$)|(.*cdn.*)|(.*cache.*))/cdn/;
print $x . "http://" . $y[0] . $y[1] . "/" . $y[2] . "." . $y[3] . "\n";

#general purpose for cdn servers. add above your specific servers.
} elsif (m/^http:\/\/([0-9.]*?)\/\/(.*?)\.(.*)\?(.*?)/) {
print $x . "http://squid-cdn-url//" . $2&nbsp; . "." . $3 . "\n";

#generic http://variable.domain.com/path/filename."ex" "ext" or "exte" with or withour "? or %"
} elsif (m/^http:\/\/(.*)(\.[^\.\-]*?\..*?)\/(.*)\.([^\/\?\&]{2,4})((\?|\%).*)?$/) {
@y = ($1,$2,$3,$4);
$y[0] =~ s/(([a-zA-A]+[0-9]+(-[a-zA-Z])?$)|(.*cdn.*)|(.*cache.*))/cdn/;
print $x . "http://" . $y[0] . $y[1] . "/" . $y[2] . "." . $y[3] . "\n";

# generic http://variable.domain.com/...
} elsif (m/^http:\/\/(([A-Za-z]+[0-9-]+)*?|.*cdn.*|.*cache.*)\.(.*?)\.(.*?)\/(.*)$/) {
print $x . "http://cdn." . $3 . "." . $4 . "/" . $5 .&nbsp; "\n";

# spicific extention that ends with ?
} elsif (m/^http:\/\/(.*?)\/(.*?)\.(jp(e?g|e|2)|gif|png|tiff?|bmp|ico|flv|on2)(.*)/) {
print $x . "http://" . $1 . "/" . $2&nbsp; . "." . $3 . "\n";

# all that ends with ;
} elsif (m/^http:\/\/(.*?)\/(.*?)\;(.*)/) {
print $x . "http://" . $1 . "/" . $2&nbsp; . "\n";

} else {
print $x . $_ . "sucks\n";
}
}

