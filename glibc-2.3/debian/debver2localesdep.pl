#!/usr/bin/perl

$_ = shift;

/(.*)-(.*)/m;

$debver = $1;
$devrev = $2;

@revs = split('\.', $devrev);

$devrev = $revs[0];
$devrev = "$devrev.$revs[1]" if defined($revs[1]) and $revs[1] > 0;

print "glibc-$debver-$devrev\n";
