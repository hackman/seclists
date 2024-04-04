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
	[ 'atom', 'https://seclists.org/rss/oss-sec.rss', 'oss-sec' ],
	[ 'atom', 'https://www.welivesecurity.com/en/rss/feed/', 'welive' ],
	[ 'atom', 'https://feeds.feedburner.com/TheHackersNews', 'hn' ],
	[ 'atom', 'https://isc.sans.edu/rssfeed.xml', 'isc' ],
	[ 'atom', 'https://blog.sucuri.net/feed', 'sucuri' ],
	[ 'atom', 'https://rss.packetstormsecurity.com/files/tags/exploit/', 'ps-exploit' ],
	[ 'atom', 'https://rss.packetstormsecurity.com/files/tags/php/', 'ps-php' ],
	[ 'atom', 'https://rss.packetstormsecurity.com/files/tags/perl/', 'ps-perl' ],
	[ 'atom', 'https://rss.packetstormsecurity.com/files/tags/python/', 'ps-python' ],
	[ 'atom', 'https://rss.packetstormsecurity.com/files/tags/vulnerability/', 'ps-vuln' ],
	[ 'atom', 'https://rss.packetstormsecurity.com/files/os/linux/', 'ps-linux' ],
	[ 'atom', 'https://rss.packetstormsecurity.com/files/os/centos/', 'ps-centos' ],
	[ 'atom', 'https://rss.packetstormsecurity.com/files/os/debian/', 'ps-debian' ],
	[ 'atom', 'https://rss.packetstormsecurity.com/files/os/ubuntu/', 'ps-ubuntu' ],
	[ 'atom', 'https://rss.packetstormsecurity.com/files/os/slackware/', 'ps-slackware' ],
	[ 'atom', 'https://rss.packetstormsecurity.com/files/os/osx/', 'ps-osx' ],
	[ 'atom', 'https://rss.packetstormsecurity.com/files/os/apple/', 'ps-apple' ],
	[ 'atom', 'https://rss.packetstormsecurity.com/files/os/redhat/', 'ps-redhat' ],
	[ 'atom', 'https://rss.packetstormsecurity.com/files/os/windows/', 'ps-win' ],
	[ 'atom', 'https://cxsecurity.com/wlb/rss/exploit/', 'cx-exploit' ],
	[ 'atom', 'https://cxsecurity.com/cverss/fullmap/', 'cx-cve' ],
	[ 'atom', 'https://blog.sucuri.net/feed', 'sucuri' ],
	[ 'atom', 'https://blog.cpanel.com/category/security/feed/', 'cpanel' ],
	[ 'feedburner', 'https://feeds.feedburner.com/GoogleOnlineSecurityBlog', 'google' ]
);

my $json = 0;
# Track titles of previous entries
my %previous_titles;

$json = 1 if (defined($ARGV[0]) && $ARGV[0] eq 'json');

foreach my $feed(@rss) {
	if ($feed->[0] eq 'atom') {
		atom_reader(\%previous_titles, $feed->[1], $feed->[2]);
	} elsif ($feed->[0] eq 'feedburner') {
		feedburner(\%previous_titles, $feed->[1], $feed->[2]);
	}
}

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
