#!/usr/bin/perl

use strict;
use warnings;
use Encode;
use JSON::XS;
use Data::Dumper;
use lib 'lib/Feeds';
use Atom;
use FeedBurner;

# URLs of the RSS feeds
my @rss = (
	[ 'https://seclists.org/rss/oss-sec.rss', 'osssec.rss' ],
	[ 'https://feeds.feedburner.com/GoogleOnlineSecurityBlog', 'google.rss' ]
);

my $json = 0;
# Track titles of previous entries
my %previous_titles;

$json = 1 if (defined($ARGV[0]) && $ARGV[0] eq 'json');

atom_reader(\%previous_titles, 'https://seclists.org/rss/oss-sec.rss', 			'oss-sec');
atom_reader(\%previous_titles, 'https://www.welivesecurity.com/en/rss/feed/',	'welive');
atom_reader(\%previous_titles, 'https://feeds.feedburner.com/TheHackersNews',	'hn');
atom_reader(\%previous_titles, 'https://isc.sans.edu/rssfeed.xml',				'isc');
atom_reader(\%previous_titles, 'https://blog.sucuri.net/feed',					'sucuri');
#atom_reader(\%previous_titles, 'https://cxsecurity.com/wlb/rss/exploit/',		'cx-exploit');
feedburner(\%previous_titles,	'https://feeds.feedburner.com/GoogleOnlineSecurityBlog', 'google');

my @ordered_titles = sort { $previous_titles{$b}{date} <=> $previous_titles{$a}{date} } keys %previous_titles;

if ($json) {
	print "[\n";
	my $prev_element = 0;
	foreach my $t (@ordered_titles) {
		print ",\n" if ($prev_element);
		my %line = (
			"link"  => $previous_titles{$t}{'links'}[0],
			"title" => encode('UTF-8', $t),
			"group" => $previous_titles{$t}{'group'},
			"date"  => $previous_titles{$t}{'date'},
			"description" => $previous_titles{$t}{'description'}
		);
		print encode_json(\%line);
		$prev_element = 1;
	}
	print "]\n";
} else {
	foreach my $t (@ordered_titles) {
		printf "%s %s \n", $previous_titles{$t}{group}, encode('UTF-8', $t);
	}
}
