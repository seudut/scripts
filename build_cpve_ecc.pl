#!/usr/bin/perl -w
#
use strict;


my $ecc_dir = $ENV{'HOME'} . "/JCC/ecc_mari_2/";
my $cpve_dir = $ENV{'HOME'} . "/CPVE/cpve_mari/";

## build cpve
chdir $cpve_dir;
! system '/usr/local/bin/scons arch=x86_64  platform=darwin debug=True -j16 osxversion=10.11' or  die $!;


chdir ($cpve_dir .  "target/dist/lib/darwin/");
## compress
! system "7z", "a", "darwin-x86_64.7z", "./x86_64" or die $!;
## replacd cpve libs;
! system "/bin/cp", "./darwin-x86_64.7z", $ecc_dir . "contrib/cpve/lib/darwin/" or die $!;


## build ecc
chdir $ecc_dir;
! system '/usr/bin/python runSconsBuild.py JabberMac64Bit -t no -j16 --nofetch Debug' or die $!;
