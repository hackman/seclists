#!/usr/bin/perl
package FeedBurner;
require Exporter;

use strict;
use warnings;
use Time::Piece;
use lib qw( lib );
use Cache;
use Similarity;
use Data::Dumper;

our @ISA        = qw(Exporter);
our @EXPORT     = qw(feedburner);
our $VERSION    = 0.00;

__PACKAGE__->main($ARGV[0]) unless caller; # executes at run-time, unless used as module

sub main {
    print "Calling: " . __PACKAGE__ . "\n";
    my %h = ();
    feedburner('https://feeds.feedburner.com/GoogleOnlineSecurityBlog', \%h, 'cache/google.rss');
}


sub feedburner {
	my ($titles_ref, $url, $group) = @_;
	my $rss_data = fetch_xml($url, 'cache/' . $group . '.rss');

	# Extract relevant information and check similarity
	foreach my $item (keys(%{$rss_data->{entry}})) {
		my $title       = $rss_data->{entry}->{$item}->{title}->{content};
		my $description = $rss_data->{entry}->{$item}->{content}->{content};
		my $date = $rss_data->{entry}->{$item}->{published};
		$date =~ s/\..*//;
		$date  		= Time::Piece->strptime($date, "%Y-%m-%dT%H:%M:%S");
		my $link  = '';
		foreach my $link_item(@{$rss_data->{entry}->{$item}->{link}}) {
			if ($link_item->{'rel'} eq 'alternate') {
				$link = $link_item->{'href'};
				last;
			}
		}
		if ($link eq '') {
			print Dumper($rss_data->{entry});
		}

		# Parse words in the title
		$title =~ s/^.*(Re:|Fwd:)+ ?//;
		my @words = split /\s+/, $title;

		# Check similarity with previous entries
		my $matched_title = check_similarity($titles_ref, \@words);

		if ($matched_title) {
			push(@{$titles_ref->{$matched_title}{links}}, $link);
		} else {
			$titles_ref->{$title}{group} = $group;
			$titles_ref->{$title}{date} = $date->epoch;
			$titles_ref->{$title}{description} = $description;
			push(@{$titles_ref->{$title}{links}}, $link);
			foreach my $word(@words) {
				$titles_ref->{$title}{words}{$word} = 1;
			}
		}
	}
}

1;
