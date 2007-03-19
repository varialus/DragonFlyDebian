#!/usr/bin/perl -w
#
# GPL 2+ by Cyril Brulebois <cyril.brulebois@enst-bretagne.fr>, 2007
#
# DISCLAIMER:
#
#   Yes, I know, this is written in Perl and this is *DIRTY*, but at the
#   moment, it is only a PoC (candidate).
#
#


use strict;
use Term::ReadLine;
use Data::Dumper;
use WWW::Mechanize;
use HTML::TreeBuilder;



# Default configuration
my $VERSION     = '0.1';
my $GLOBAL_CONF = '/etc/dlogrc';
my $LOCAL_CONF  = "$ENV{HOME}/.dlogrc";
my $DLOG_FETCH  = './dlog-fetch.pl';


# Default global configuration, should be in $GLOBAL_CONF
my $LOCAL_LOGS = "$ENV{HOME}/.dlog";


# Load configuration
if (-r $GLOBAL_CONF) {
    do $GLOBAL_CONF
        or die "Your global configuration file ($GLOBAL_CONF) contains errors.";
}
if (-r $LOCAL_CONF) {
    do $LOCAL_CONF
        or die "Your local configuration file ($LOCAL_CONF) contains errors.";
}


# Basic checks on the local log repository: $LOCAL_LOGS -- Needed for reading? -> Disabled.
# check_storage();


# Read the whole dpkg-buildpackage log given as parameter
my $dbp_log_filename = shift @ARGV
    or die "Usage: $0 build-package.log";

open my $dbp_log, '<', $dbp_log_filename
    or die "Unable to open dpkg-buildpackage log $dbp_log_filename";

my $dbp_log_content = join("\n", <$dbp_log>);

close $dbp_log
    or die "Unable to close $dbp_log";


# Determine some basic information
my ($source, $version);

if ($dbp_log_content =~ /^dpkg-buildpackage: source package is (.*?)$/ms) {
    $source = $1;
}
else {
    print 'Warning: source package not found' . "\n";
    die 'This is not supported (yet)';
}

if ($dbp_log_content =~ /^dpkg-buildpackage: source version is (.*?)$/ms) {
    $version = $1;
}
else {
    print 'Warning source version not found' . "\n";
    die 'This is not supported (yet)';
}


# Prepare the terminal
my $term = new Term::ReadLine 'dlog-analyze';
my $OUT = $term->OUT || \*STDOUT;


# Check whether some files matching these package configurations exist
my $ref_log_filename = '';

while (not $ref_log_filename) {

    # TODO: Swap these instructions and remove a goto...

    # Possible logs are there
    print 'Checking for [', "$LOCAL_LOGS/$source/$version", ']', "\n";
    if (-d "$LOCAL_LOGS/$source/$version") {
        print 'Prompting', "\n";
        $ref_log_filename = prompt_for_arch($source,$version);
        next if $ref_log_filename; # spare the dlog_fetch_status call
    }
    else {
        print 'There is no build log in the local repository, fetching some', "\n\n";
    }


    # Call dlog-fetch
    my $dlog_fetch_status = system($DLOG_FETCH, $source, $version);
    if ($dlog_fetch_status) {
        printf "WARNING: %s exited badly: %s\n\n",  $DLOG_FETCH, $?
    }
}


# Going to compare $dbp_log_filename with $ref_log_filename
print "We are going to compare $dbp_log_filename to $ref_log_filename\n";



# Readibility
print "\n";





#
### Functions
#

# Prompt for an architecture:
#  - returns '' if user selects to download another log
#  - or the filename to use
#
sub prompt_for_arch {
    my ($source, $version) = @_;
    my $log_location = "$LOCAL_LOGS/$source/$version";

    # Fetch the available logs
    my @archs     = sort (<$log_location/*/*>);
    my @filenames = @archs;
    map { s{(.*)/(.*)/(.*)}{$2 $3} } @archs;
    map { s{_ftbfs$}{ (FTBFS)}   } @archs;


    # Return if no log are available
    return ''
        if not @archs;


    # Prepare the prompt
    my $arch_id      = 0;
    my $arch_prompt  = 'Log to use: ';
    my $arch_list    = 'Available logs:' . "\n"
                     . sprintf( " %3d. %s\n", 0, 'Download another');

    foreach my $arch_item (@archs) {
        $arch_list  .= sprintf( " %3d. %s\n", ++$arch_id, $arch_item);
    }


    # Prompt for the arch
    print $arch_list;
    my $arch;
    while (
        not defined ($arch = $term->readline($arch_prompt))
     or ($arch !~ /^\s*\d+\s*$/)
     or ($arch<0) 
     or ($arch>$arch_id)
    ) {}


    # Readibility
    print("\n");


    return $arch
         ? $filenames[$arch-1] # Full path
         : '';
}
