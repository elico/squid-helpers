#!/usr/bin/perl
use strict;
use warnings;

my %url;

# read config file
open CONF, $ARGV[0] or die "Error opening $ARGV[0]: $!";
while (<CONF>) {
	chomp;
	next if /^\s*#?$/;
	my @l = split("\t");
	$url{qr/$l[0]/} = $l[$#l];
}
close CONF;

# read urls from squid and do the replacement
URL: while (<STDIN>) {
	chomp;
	last if /^(exit|quit|x|q)$/;
	
	foreach my $re (keys %url) {
		if (/$re/) {
			print "OK store-id=",eval($url{$re})->(),"\n";
			next URL;
		}
	}
	print "ERR\n";
}
