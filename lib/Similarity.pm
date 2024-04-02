#!/usr/bin/perl
package Similarity;
require Exporter;
our @ISA        = qw(Exporter);
our @EXPORT     = qw(check_similarity);
our $VERSION    = 0.00;

use strict;
use warnings;

sub check_similarity {
    my ($previous_titles_ref, $current_words_ref) = @_;

    foreach my $prev_title (keys %$previous_titles_ref) {
        my $matched_count = 0;
		my $similarity_percentage = 0;
        foreach my $word (@$current_words_ref) {
            $matched_count++ if ($previous_titles_ref->{$prev_title}{words}{$word});
        }
		if (exists($previous_titles_ref->{$prev_title}{words})) {
	        $similarity_percentage = $matched_count / scalar($previous_titles_ref->{$prev_title}{words}) * 100;
		} else {
			return;
		}
        return $prev_title if ($similarity_percentage > 50);
    }

    return;
}

1;
