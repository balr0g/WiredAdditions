#!/usr/bin/perl -w

use strict;

die "$0: Must be run from Xcode" unless $ENV{"BUILT_PRODUCTS_DIR"};

$ENV{"PATH"} = "/opt/local/bin:/usr/local/bin:/usr/bin";

my $latest_revision = 0;

#foreach ("", "libwired", "wired", "wired/libwired", "WiredAdditions", "WiredAdditions/libwired" ) {
#	my $revision = `svn info $_ 2>/dev/null | grep "^Last Changed Rev:"`;
#	my $revision = `git --git-dir=$_/.git rev-parse --verify --short HEAD`;
#	$revision =~ s/(.+): (\d+)\n/$2/;	
#	if($revision && $revision > $latest_revision) {
#		$latest_revision = $revision;
#	}
#}

my $latest_revision = `git --git-dir=$ARGV[1]/.git rev-parse --verify --short HEAD`;



die "$0: No Git revision found" unless $latest_revision;

my @files = @ARGV;

if(@files == 0) {
	push(@files, "$ENV{BUILT_PRODUCTS_DIR}/$ENV{INFOPLIST_PATH}");
}

foreach my $file (@files) {
	open(FH, "$file") or die "$0: $file: $!";
	my $content = join("", <FH>);
	close(FH);

	$content =~ s/([\t ]+<key>CFBundleVersion<\/key>\n[\t ]+<string>).*?(<\/string>)/$1$latest_revision$2/;
	$content =~ s/\$\(?SVN_REVISION\)?/$latest_revision/g;
	
	open(FH, ">$file") or die "$0: $file: $!";
	print FH $content;
	close(FH);
}
