#!/usr/bin/perl
package Cache;
use strict;
use warnings;
use Exporter;
use LWP::UserAgent;
use XML::Simple;
use File::stat;

our @ISA        = qw(Exporter);
our @EXPORT     = qw(update_cache check_cache fetch_xml);
our $VERSION    = 0.00;

sub web_request {
	my $url = shift;
	my $ua = new LWP::UserAgent;
	$ua->agent('HackMan feed puller');
	my $req = new HTTP::Request 'GET' => $url;
	my $res = $ua->request($req);

	if ($res->is_success) {
		return $res->content;
	} else {
		return;
	}
}

sub update_cache {
	my ($file, $content) = @_;
	open my $f, '>:encoding(UTF-8)', $file or die "Cannot open $file: $!";
	print $f $content;
	close $f;
}

sub check_cache {
	my ($cache_file, $rss_url) = @_;
	my $content;
	my $current_time = time();
	my $cache_time = 0;
	my $elapsed_time = 0;
	
	$cache_time = stat($cache_file)->mtime if (-e $cache_file);
	$elapsed_time = $current_time - $cache_time;
	if ($elapsed_time < 3600) {  # 3600 seconds = 1 hour
		# Use the cached content
		open my $f, '<:encoding(UTF-8)', $cache_file or die "Cannot open $cache_file: $!";
		local $/;
		$content = <$f>;
		close $f;
	} else {
		# Fetch new content and update cache
		$content = web_request($rss_url);
		update_cache($cache_file, $content) if defined $content;
	}
	return $content;
}

sub fetch_xml {
	my ($url, $cache_file) = @_;
	my $rss_content;
	# Fetch RSS feed (from cache if available and not older than 1 hour)
	$rss_content = check_cache($cache_file, $url);
	return unless defined $rss_content;

    # Parse XML
	my $xml_parser = XML::Simple->new();
	my $rss_data = $xml_parser->XMLin($rss_content);

	return $rss_data;
}

1;
