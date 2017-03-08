#!/usr/bin/perl -w
#
use strict;
use 5.010;


my $ecc_dir = $ENV{'HOME'} . "/JCC/ecc/";
my $cpve_dir = $ENV{'HOME'} . "/CPVE/cpve/";

chdir $cpve_dir or die $!;
! system '/usr/local/bin/scons arch=x86_64  platform=darwin debug=False -j16 osxversion=10.11' or  die $!;
! system "/bin/cp -r $cpve_dir/target/dist/lib/darwin/x86_64/dynamic/* $ecc_dir/out/bin/" or die $!;
say "DONE";
