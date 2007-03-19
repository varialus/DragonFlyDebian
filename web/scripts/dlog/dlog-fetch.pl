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
# Dependencies on Debian packages: (non-exhaustive)
#  - libterm-readline-perl-perl [or similar?]
#  - libwww-perl
#  - libhtml-tree-perl
#  - libapt-pkg-perl
#  - [to be continued]
#
# (maybe) in future versions:
#  - replace HTML entities
#  - support several buildd servers query at the same time
#  - support several versions query at the same time (e.g. using a
#    coma-separated list)
#  - support command-line parameters to ease calls from dlog-analyze


use strict;
use Term::ReadLine;
use Data::Dumper;
use WWW::Mechanize;
use HTML::TreeBuilder;

use AptPkg::Config  '$_config';
use AptPkg::System  '$_system';
use AptPkg::Version;


# Initialization, cf. libapt-pkg-perl's apt-version example
$_config->init;                # init. the global config object w/ default values
$_system = $_config->system;   # determine the appropriate system type
my $vs = $_system->versioning; # fetch a versioning system


# Default configuration
my $VERSION     = '0.1';
my $USER_AGENT  = 'dlog-fetch/'.$VERSION;
my $GLOBAL_CONF = '/etc/dlogrc';
my $LOCAL_CONF  = "$ENV{HOME}/.dlogrc";


# Default global configuration, should be in $GLOBAL_CONF
my $LOCAL_LOGS = "$ENV{HOME}/.dlog";
my @BUILDD_SERVERS = (
    'buildd.debian.org',
    'experimental.ftbfs.de',
);
my %BUILDD_SERVERS_FETCH = (
    'buildd.debian.org'     => 'fetch.cgi',
    'experimental.ftbfs.de' => 'fetch.php', # aba ping'd about that... Let's see.
);


# Load configuration
if (-r $GLOBAL_CONF) {
    do $GLOBAL_CONF
        or die "Your global configuration file ($GLOBAL_CONF) contains errors.";
}
if (-r $LOCAL_CONF) {
    do $LOCAL_CONF
        or die "Your local configuration file ($LOCAL_CONF) contains errors.";
}


# Basic checks on the local log repository: $LOCAL_LOGS
check_storage();


# Prepare the terminal
my $term = new Term::ReadLine 'dlog-fetch';
my $OUT = $term->OUT || \*STDOUT;


# Prompt for the source package
my $source_prompt = 'Source package: ';
my $source;
while ( not defined ($source = $term->readline($source_prompt)) ) {}


# Readibility
print "\n";


# Construct the buildd log server prompt & list
my $server_id     = 0;
my $server_prompt = 'Build server: ';
my $server_list   = 'Available buildd log servers:' . "\n"
                  . sprintf( " %3d. %s\n", 0, 'All the below [not yet supported]');

foreach my $server_item (@BUILDD_SERVERS) {
    $server_list .= sprintf( " %3d. %s\n", ++$server_id, $server_item)
}


# Prompt for the buildd log server
print $server_list;
my $server;
while (
    not defined ($server = $term->readline($server_prompt))
 or ($server !~ /^\s*\d+\s*$/)
 or ($server<1) # change back to ($server<0) once version merging implemented
 or ($server>$server_id)
) {}

my $server_string = $BUILDD_SERVERS[$server-1];


# Readibility
print "\n";


# Fetch the versions from the buildd log servers
my @versions=();
if ($server) {
    # Single server
    @versions = fetch_versions($source, $server_string);
}
else {
    # TODO: [task="multi buildd support"]
    # foreach my $server_item (@BUILDD_SERVERS) {
    #     my @local_versions = fetch_versions($source, $server_item);
    #     push @versions, @local_versions;
    # }
}


# Print available versions
# TODO: [task="multi buildd support"]
# my @merged_versions = merge_versions(@versions); # needed in case of $server==0
#
# Note: a 3-digit number should be sufficient for a while...
my @merged_versions = @versions;
my $version_id      = 0;
my $version_prompt  = 'Package version: ';
my $version_list    = 'Available version logs:' . "\n"
                    . sprintf( " %3d. %s\n", 0, 'The latest');

foreach my $version_item (@merged_versions) {
    $version_list  .= sprintf( " %3d. %s\n", ++$version_id, $version_item);
}


# Prompt for the version
print $version_list;
my $version;
while (
    not defined ($version = $term->readline($version_prompt))
 or ($version !~ /^\s*\d+\s*$/)
 or ($version<0)
 or ($version>$version_id)
) {}


# Readibility
print "\n";


# 0 means the latest
$version = $version_id
    if not $version;
my $version_string = $merged_versions[$version-1];


# (Re...)parse the architecture list
my @archs=();
if ($version_string =~ /^(.*?)\s+\| (.*)$/) {
    $version_string = $1;
    @archs = split(',', $2);
}
else {
    die "Uh oh, not able to (re)parse $version_string";
}


# Prepare the list of the architectures for this version
my $arch_id      = 0;
my $arch_prompt  = 'Architecture to fetch the log from: ';
my $arch_list    = 'Available arch logs:' . "\n"
                 . sprintf( " %3d. %s\n", 0, 'Any idea of pertinent default?');

foreach my $arch_item (@archs) {
    $arch_list  .= sprintf( " %3d. %s\n", ++$arch_id, $arch_item);
}

# Prompt for the arch
print $arch_list;
my $arch;
while (
    not defined ($arch = $term->readline($arch_prompt))
 or ($arch !~ /^\s*\d+\s*$/)
 or ($arch<1) # No pertinent default
 or ($arch>$arch_id)
) {}

my $arch_string = $archs[$arch-1];


# Readibility
print "\n";


# Prepare the storage area
# print "$source, $version_string, $arch_string\n";
print "Preparing the storage for: \n    $source, $version_string, $arch_string\n";
prepare_storage($source, $version_string, $arch_string);

print "To be done: fetch the log.\n";
fetch_logs($source, $version_string, $arch_string, $server_string);


#
### Functions
#

# Prepare the storage area for a particular source/version/arch
#
sub prepare_storage {
    my ($source, $version, $arch) = @_;
    my $current = $LOCAL_LOGS;

    # We expect the $LOCAL_LOG directory to be still there, otherwise we'll die
    # while mkdir'ing
    foreach my $newdir ($source, $version, $arch) {
        $current .= '/' . $newdir;
        if (not -e $current) {
            mkdir $current
                or die "Unable to create $current during the storage preparation";
        }
    }
}


# Actually fetch the logs (might be more than one)
#
sub fetch_logs {
    my ($source, $version, $arch, $server) = @_;

    # Get the list of all logs for this triplet (could be several)
    # http://experimental.ftbfs.de/build.php?&pkg=apache&ver=1.3.34-4.1&arch=kfreebsd-i386&file=log

    # Create the UserAgent and fetch the page
    my $ua = WWW::Mechanize->new( agent => $USER_AGENT );
    $ua->get( sprintf("http://%s/build.php?&pkg=%s&ver=%s&arch=%s&file=log", 
                      $server, $source, $version, $arch)
    );
    # TODO: check return code

    # Parse the HTML code to prepare the link extraction
    my $tb = HTML::TreeBuilder->new();
    $tb->parse( $ua->content() );

    # Extracting the links, getting the timestamps
    for (@{ $tb->extract_links() || [] }) { # From: http://www.perl.com/lpt/a/972
        my($link, $element, $attr, $tag) = @$_;

        # Discard 'index' and raw log links for the moment
        if ($link =~ /&stamp=(.*?)&/) {
            my ($stamp) = ($1);

            # Get the log
            fetch_single_log($source, $version, $arch, $stamp, $server);
        }
    }
}


# Fetch a single log (given the timestamp)
#
sub fetch_single_log {
    my ($source, $version, $arch, $stamp, $server) = @_;

    # Working dir
    my $log_dir = join('/', $LOCAL_LOGS, $source, $version, $arch);

    # Create the UserAgent and fetch the page
    my $server_fetch = $BUILDD_SERVERS_FETCH{$server};
    my $ua = WWW::Mechanize->new( agent => $USER_AGENT );
    $ua->get( sprintf("http://%s/%s?&pkg=%s&ver=%s&arch=%s&stamp=%s&file=log&as=raw",
                      $server, $server_fetch, $source, $version, $arch, $stamp)
    );

    # At the moment, only download the file and store its (raw/html) content

    # Discard header/footer
    if ($ua->content() =~ /(^Build started at \d{8}-\d{4}.*Finished at \d{8}-\d{4}$)/ms) {
        my $content = $1;
        my $suffix  = '';

        if ($content !~ /^Built successfully$/ms) {
            $suffix = '_ftbfs';
        }

        open my $log, '>', $log_dir.'/'.$stamp.$suffix
            or die "Unable to create $stamp in $log_dir";

        print $log $content
            or die "Unable to write into $stamp in $log_dir";

        close $log
            or die "Unable to close $stamp in $log_dir"
    }
    else {
        die "Unable to detect header/footer for $stamp, please report";
    }

}


# Perform a basic check before interrogating the buildd log servers
#
sub check_storage {
    if (not -e $LOCAL_LOGS) {
        mkdir $LOCAL_LOGS
            or die "Unable to create the local log repository [$LOCAL_LOGS]";
    }
    elsif (not -d $LOCAL_LOGS) {
        die "The local log repository [$LOCAL_LOGS] should be a directory (if it exists)";
    }
    elsif (not -w $LOCAL_LOGS) {
        die "You don't have the permission to write in the local log repository [$LOCAL_LOGS]";
    }
}


# Fetch the versions of a $source package from a $server
#
sub fetch_versions {
    my ($source, $server) = @_;
    my @versions_and_archs = (); # Return lines
    my %versions = ();           # Intermediate results

    # Create the UserAgent and fetch the page
    my $ua = WWW::Mechanize->new( agent => $USER_AGENT );
    $ua->get( sprintf("http://%s/build.php?arch=&pkg=%s",
                      $server, $source)
    ); # TODO: check return code

    # Parse the HTML code to prepare the link extraction
    my $tb = HTML::TreeBuilder->new();
    $tb->parse( $ua->content() );

    # Extracting the links, getting version and arch
    my $version_max_width = 0;
    for (@{ $tb->extract_links() || [] }) { # From: http://www.perl.com/lpt/a/972
        my($link, $element, $attr, $tag) = @$_;

        # Discard 'index' and raw log links for the moment
        if ($link =~ /build.*ver=(.*?)&arch=(.*?)&file=log/) {
            my ($version, $arch) = ($1, $2);

            # Adapt the version name from entity-like substrings
            $version =~ s/%2B/+/g;
            $version =~ s/%3A/:/g;
            $version =~ s/%7E/~/g;

            # Update the max version length
            $version_max_width = length($version)
                if (length($version)>$version_max_width);

            # Add this arch to this version
            push @{ $versions{$version} }, $arch;
        }
    }

    # Put everything in order
    foreach my $version (sort {$vs->compare ($a, $b)} keys %versions) {
        push @versions_and_archs,
              $version
            . ' ' x ($version_max_width - length($version))
            . ' | '
            . join(',', sort @{ $versions{$version} })
        ;
    }

    #print join("\n", @versions_and_archs);
    #print "\n";
    #print Dumper(\$ua);
    #print $answer->links();
    return @versions_and_archs;
}
