#!/usr/bin/perl
package Rss;
require Exporter;

use strict;
use warnings;
use Encode;
use XML::Writer;
use IO::File;
use Time::Piece;

our @ISA        = qw(Exporter);
our @EXPORT     = qw(generate_rss_feed);
our $VERSION    = 0.00;

sub generate_rss_feed {
	my ($rss_file, $order_ref, $title_ref) = @_;
    # Create XML RSS feed
    my $output = IO::File->new(">$rss_file") or die "Could not open file $rss_file: $!";
    my $xml_writer = XML::Writer->new(OUTPUT => $output, DATA_MODE => 1, DATA_INDENT => 2);

    $xml_writer->xmlDecl('UTF-8');
    $xml_writer->startTag('rss', version => '2.0');
    $xml_writer->startTag('channel');
    $xml_writer->dataElement('title', 'Security News Feed');
    $xml_writer->dataElement('link', 'http://security.1h.cx/feed.xml');
    $xml_writer->dataElement('description', 'Feed with aggregated security news');
    $xml_writer->dataElement('language', 'en-us');

    foreach my $t (@{$order_ref}) {
        my $date = Time::Piece->new($title_ref->{$t}{'date'});
        $xml_writer->startTag('item');
        $xml_writer->dataElement('title', encode('UTF-8', $t));
        $xml_writer->dataElement('link', $title_ref->{$t}{'links'}[0]);
        $xml_writer->dataElement('description', encode('UTF-8', $title_ref->{$t}{'description'}));
        $xml_writer->dataElement('pubDate', $date->strftime("%a, %d %b %Y %H:%M:%S"));
        $xml_writer->endTag('item');
    }

    $xml_writer->endTag('channel');
    $xml_writer->endTag('rss');
    $xml_writer->end();
}

1;
