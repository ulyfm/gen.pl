#!/usr/bin/perl
#SiteGen

use warnings;
use strict;
use File::Basename;
use Time::HiRes qw/gettimeofday/;

print "site generator\n";
my $millis = gettimeofday;
open my $fh, '<', "templates/index.html" or die "index template file doesn't exist.";
my $indextemp = do {local $/; <$fh>};
open $fh, '<', "templates/blog.html" or die "blog template file doesn't exist.";
my $blogtemp = do {local $/; <$fh>};
open $fh, '<', "templates/proj.html" or die "project template file doesn't exist.";
my $projtemp = do {local $/; <$fh>};

my $numprojs = 0;
my $numblogs = 0;

#load blogs
my @blogs = <./blogs/*>;
my $fi = "";
my $bloglinks = "";
foreach $fi (@blogs){
	my $title = "";
	my $date = "";
	my $text = "";
	open my $ff, '<', $fi or die "error finding blog file.";
	my $i = 0;
	while(my $row = <$ff>){
		chomp $row;
		if($i eq 0){
			$title = $row;
			$i = 1;	
		}elsif($i eq 1){
			$date = $row;
			$i = 2;
		}else{
			$text = $text . $row . "\n";
		}
	}
	my $finaltext = $blogtemp;
	$finaltext =~ s/<% title %>/$title/g;
	$finaltext =~ s/<% date %>/$date/g;
	$finaltext =~ s/<% text %>/$text/g;
	my $bpl = "/blogs/" . basename($fi) . ".html";
	$bloglinks = $bloglinks . "<li><a href='" . $bpl . "'>" . $title . "</a></li>";
	open FILE, ">", "./docs" . $bpl or die $!;
	print FILE $finaltext;
	close FILE;
	$numblogs = $numblogs + 1;
}

#load projs
my @projs = <./projects/*>;
my $fp = "";
my $projlinks = "";
foreach $fp (@projs){
	my $title = "";
	my $date = "";
	my $text = "";
	my $link = "";
	open my $ff, '<', $fp or die "error finding proj file.";
	my $i = 0;
	while(my $row = <$ff>){
		chomp $row;
		if($i eq 0){
			$title = $row;
			$i = 1;	
		}elsif($i eq 1){
			$date = $row;
			$i = 2;
		}elsif($i eq 2){
			$link = $row;
			$i = 3;
		}else{
			$text = $text . $row . "\n";
		}
	}
	my $finaltext = $projtemp;
	$finaltext =~ s/<% title %>/$title/g;
	$finaltext =~ s/<% date %>/$date/g;
	$finaltext =~ s/<% text %>/$text/g;
	my $bpl = "/projects/" . basename($fp) . ".html";
	$projlinks = $projlinks . "<li><a href='" . $bpl . "'>" . $title . "</a></li>";
	open FILE, ">", "./docs" . $bpl or die $!;
	print FILE $finaltext;
	close FILE;
	$numprojs = $numprojs + 1;
}

$indextemp =~ s/<% essaylinks %>/$bloglinks/g;
$indextemp =~ s/<% projectlinks %>/$projlinks/g;

open FILE, ">", "./docs/index.html" or die $!;
print FILE $indextemp;
close FILE;

$millis = gettimeofday - $millis;
print "generated $numblogs blogs and $numprojs projects in $millis seconds\n";
