#!/usr/bin/perl -T

use strict;
use warnings;
use Encode;
use JSON::XS;
use Data::Dumper;
use lib 'lib/Feeds';
use Rss;
use Atom;
use FeedBurner;

# URLs of the RSS feeds
my @rss = (
	[ 'atom', 'https://seclists.org/rss/oss-sec.rss', 'oss-sec' ],
	[ 'atom', 'https://www.welivesecurity.com/en/rss/feed/', 'welive' ],
	[ 'atom', 'https://feeds.feedburner.com/TheHackersNews', 'hn' ],
	[ 'atom', 'https://isc.sans.edu/rssfeed.xml', 'isc' ],
	[ 'atom', 'https://blog.sucuri.net/feed', 'sucuri' ],
	[ 'atom', 'https://cxsecurity.com/wlb/rss/exploit/', 'cx-exploit' ],
	[ 'atom', 'https://blog.sucuri.net/feed', 'sucuri' ],
	[ 'atom', 'https://blog.cpanel.com/category/security/feed/', 'cpanel' ],
	[ 'atom', 'https://vuldb.com/?rss.recent', 'vuldb' ],
	[ 'atom', 'https://www.bleepingcomputer.com/feed/', 'bleeping' ],
	[ 'atom', 'https://securityonline.info/feed/', 'seconline' ],
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
	[ 'feedburner', 'https://feeds.feedburner.com/GoogleOnlineSecurityBlog', 'google' ]
);

my $json = 0;
my $xml = 0;
# Track titles of previous entries
my %previous_titles;
my $rss_file = 'rss.xml';
my $json_file = 'data.json';

$json = 1 if (defined($ARGV[0]) && $ARGV[0] eq 'json');
$xml  = 1 if (defined($ARGV[0]) && $ARGV[0] eq 'xml');

foreach my $feed(@rss) {
	print "Reading feed $feed->[1]\n";
	if ($feed->[0] eq 'atom') {
		atom_reader(\%previous_titles, $feed->[1], $feed->[2]);
	} elsif ($feed->[0] eq 'feedburner') {
		feedburner(\%previous_titles, $feed->[1], $feed->[2]);
	}
}

my @ordered_titles = sort { $previous_titles{$b}{date} <=> $previous_titles{$a}{date} } keys %previous_titles;
if ($json) {
	my @json = ();
	foreach my $t (@ordered_titles) {
		my %line = (
			"links"  => $previous_titles{$t}{'links'},
			"title" => encode('UTF-8', $t),
			"group" => $previous_titles{$t}{'group'},
			"date"  => $previous_titles{$t}{'date'},
			"description" => $previous_titles{$t}{'description'}
		);
		push @json, \%line;
	}
	open my $out, '>', $json_file or die "Unable to write to $json_file: $!\n";
	print $out encode_json(\@json);
	close $out;
} elsif ($xml) {
	generate_rss_feed($rss_file, \@ordered_titles, \%previous_titles);
} else {
	foreach my $t (@ordered_titles) {
		printf "%s %s \n", $previous_titles{$t}{group}, encode('UTF-8', $t);
	}
}

