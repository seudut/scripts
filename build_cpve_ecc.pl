#!/usr/bin/perl -w
#
use strict;
## prog -c -e -a
# -c build cpve only
# -e build ecc only
# -a build all

my $arg = '-a';
$arg = shift (@ARGV) if (@ARGV > 0);

my $ecc_dir = $ENV{'HOME'} . "/JCC/ecc/";
my $cpve_dir = $ENV{'HOME'} . "/CPVE/cpve/";

## build cpve
if ($arg eq "-c" or $arg eq "-a")
{
    chdir $cpve_dir;
    ! system '/usr/local/bin/scons arch=x86_64  platform=darwin debug=False -j16 osxversion=10.11' or  die $!;
##    ! system '/bin/cp', "-r", "$cpve_dir/target/dist/lib/darwin/x86_64", "$ecc_dir/contrib/cpve/lib/darwin/" or die $!;
    ! system "/bin/cp -R $cpve_dir/target/dist/lib/darwin/x86_64 $ecc_dir/contrib/cpve/lib/darwin/" or die $!;
###    ## compress
###    chdir ($cpve_dir .  "target/dist/lib/darwin/");
###    ! system "7z", "a", "darwin-x86_64.7z", "./x86_64" or die $!;
###    ## replacd cpve libs;
###    ! system "/bin/cp", "./darwin-x86_64.7z", $ecc_dir . "contrib/cpve/lib/darwin/" or die $!;
}

###! system "/bin/cp", "-R", "$cpve_dir/target/dist/include/*", "$ecc_dir/contrib/cpve/include/*" or die $!;
! system "/bin/cp -R $cpve_dir/target/dist/include/* $ecc_dir/contrib/cpve/include/*" or die $!;

if ($arg eq "-e" or $arg eq "-a")
{
    ## build ecc
    chdir $ecc_dir;
    ! system '/usr/bin/python runSconsBuild.py JabberMac64Bit -t no -j16 --nofetch release' or die $!;
}


