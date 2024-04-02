#!/usr/bin/perl
package Atom;
require Exporter;

use strict;
use warnings;
use Time::Piece;
use lib qw( lib );
use Cache;
use Similarity;

our @ISA        = qw(Exporter);
our @EXPORT     = qw(atom_reader);
our $VERSION    = 0.00;

__PACKAGE__->main($ARGV[0]) unless caller; # executes at run-time, unless used as module

sub main {
	print "Calling: " . __PACKAGE__ . "\n";
	my %h = ();
	atom_reader('https://seclists.org/rss/oss-sec.rss', \%h, 'cache/osssec.rss');
}

sub atom_reader {
	my ($titles_ref, $url, $group) = @_;
	my $rss_data = fetch_xml($url, 'cache/' . $group . '.rss');

	# Extract relevant information and check similarity
	foreach my $item (@{$rss_data->{channel}->{item}}) {
		my $title		= $item->{title};
		my $link 		= $item->{link};
		my $description = $item->{description};
		my $date = '';
		if ($item->{pubDate} =~ /[A-Z]$/) {
			$date 		= Time::Piece->strptime($item->{pubDate}, "%a, %d %b %Y %H:%M:%S %Z");
		} else {
			$date 		= Time::Piece->strptime($item->{pubDate}, "%a, %d %b %Y %H:%M:%S %z");
		}

		# Parse words in the title and cleanup reply/forwarder subject
		$title =~ s/^.*(Re:|Fwd:)+ ?//;
		my @words = split /\s+/, $title;

		# Check similarity with previous entries
		my $matched_title = check_similarity($titles_ref, \@words);

		if ($matched_title) {
			# Add more links related to the title
			push(@{$titles_ref->{$matched_title}{links}}, $link);
		} else {
			# Populate the new entry in the hash
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
