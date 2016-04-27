#!/usr/bin/perl -w
#
use strict;


my $arg = "all";
$arg = shift (@ARGV) if (@ARGV > 0);

##my $base_url = 'http://sea-cpve.cisco.com:8080/job/BUILD_WINDOWS_VS2013_MARI/lastSuccessfulBuild/artifact/Source/target/publish/dist/csf2g-cpve-win32-x86-vs2013-2.399.4.zip'
my $base_url = 'http://sea-cpve.cisco.com:8080/job/';
my $path = 'lastSuccessfulBuild/artifact/Source/target/publish/dist/';
my $path22 = 'lastSuccessfulBuild/artifact/';

my $ecc_dir = $ENV{'HOME'} . "/JCC/ecc_mari_2/contrib/cpve/";
##my $ecc_dir = $ENV{'HOME'} . "/JCC/ecc/contrib/cpve/";

my $version = "2.399.6";

## compress
my %plat_hash = (
            "win32" =>  {
                            "job" =>  "BUILD_WINDOWS_VS2013_MARI",
                            "cpve_gz" =>   "csf2g-cpve-win32-x86-vs2013-$version.zip",
                            "ecc_7z" =>   "lib/win32/win32-x86_vs2013.7z",
                            "ecc_path" => "lib/win32/12.0/x86",
                        },

            "mac"   =>  {
                           "job" =>  "BUILD_MAC64_MARI",
                           "cpve_gz" =>   "csf2g-cpve-darwin-x86_64-$version.tar.gz",
                           "ecc_7z" =>   "lib/darwin/darwin-x86_64.7z",
                           "ecc_path" => "lib/darwin/x86_64",
                        },

            "linux" =>  {
                           "job" =>  "BUILD_LINUX_MARI",
                           "cpve_gz" =>   "csf2g-cpve-linux2-x86-$version.tar.gz",
                           "ecc_7z" =>   "lib/linux2/linux2-x86.7z",
                           "ecc_path" => "lib/linux2/x86",
                        },

            "ios32"   =>  {
                           "job" =>  "BUILD_IOS_9_0_IPAD_MARI",
                           "cpve_gz" =>   "csf2g-cpve-darwin-arm-$version.tar.gz",
                           "ecc_7z" =>   "lib/darwin/darwin-arm.7z",
                           "ecc_path" => "lib/darwin/armv7",
                        },

            "ios64"   =>  {
                           "job" =>  "BUILD_IOS_9_0_64BIT_IPAD_MARI",
                           "cpve_gz" =>   "csf2g-cpve-darwin-arm64-$version.tar.gz",
                           "ecc_7z" =>   "lib/darwin/darwin-arm64.7z",
                           "ecc_path" => "lib/darwin/arm64",
                        },

            "android"   => {
                           "job" =>  "BUILD_ANDROID_LINUX_MARI",
                           "cpve_gz" =>   "csf2g-cpve-android-arm-$version.tar.gz",
                           "ecc_7z" =>   "lib/android/android-arm.7z",
                           "ecc_path" => "lib/android/arm",
                        },
        );


my $tmp = $ENV{"PWD"} . "/temp/";

! system "rm", "-rf", $tmp  or die $! if -e $tmp;

mkdir $tmp or die $! unless -e $tmp;


foreach my $plat (keys %plat_hash)
{
    chdir $tmp or die $!;
    next if ($plat ne $arg and $arg ne "all");
    my $vv = &get_version ($plat_hash{$plat}{"job"});

    # download
    my $full_url = $base_url . $plat_hash{$plat}{"job"} . "/" . $path . "/" .  $plat_hash{$plat}{"cpve_gz"};
    $full_url =~ s/$version/$vv/g;
    ! system "wget", $full_url or die $!;

    ## extract
    my $file = $plat_hash{$plat}{"cpve_gz"};
    $file =~ s/$version/$vv/g;
    (! system "tar", "zxvf", $file or die $! ) if($file =~ /.tar.gz$/);
    (! system "unzip", "-o", $file or die $! ) if($file =~ /.zip$/);


    ## delete some files
    &dele_files();

    ## 7z compress
    my $compress_dir = $plat_hash{$plat}{"ecc_path"};
    my $zz_name = $plat_hash{$plat}{"ecc_7z"};

    if ($plat eq "win32"){
        !system "mkdir lib/win32/12.0/" or die $!;
        !system "mv lib/win32/x86 lib/win32/12.0/" or die $!;
        $compress_dir = "lib/win32/12.0/";
    }

    if ($plat eq "ios32"){
        !system "mv lib/darwin/arm lib/darwin/armv7" or die $!;
    }


    chdir ( $compress_dir . "/..");

    $zz_name =~ s#.*?/.*?/##g;
    $compress_dir =~ s#.*?/.*?/##g;
    ! system "7z", "a", $zz_name, $compress_dir or die $!; 

    ## replace 7z
    chdir $tmp;
    ! system "/bin/cp", $plat_hash{$plat}{"ecc_7z"},  $ecc_dir . $plat_hash{$plat}{"ecc_7z"} or die $!;
}

## replace header
! system "/bin/cp", "include/csf/media/rtp/CPVEMedia.hpp", $ecc_dir .  "include/csf/media/rtp/CPVEMedia.hpp" or die $!;


sub get_version 
{
    my $full_url = $base_url . $_[0] . "/" . $path22 . "/source_settings.ini";
    unlink "source_settings.ini";
    system 'wget', $full_url;
    my $vv = "";
    open (FH, "<", "./source_settings.ini") or die $!;
    while(<FH>){
##        chomp ($line);
        next unless (/CPVEVERSION/);
        $vv = $_;
        $vv  =~ s/CPVEVERSION=//;
        last;
    }
    close FH;
    $vv =~ s/\r\n//g;
    return $vv;
}

sub dele_files
{
    my @files = (
  'lib/win32/x86/dynamic/libeay32.dll'
, 'lib/win32/x86/dynamic/ssleay32.dll'
, 'lib/win32/x86/dynamic/debug/libeay32.dll'
, 'lib/win32/x86/dynamic/debug/ssleay32.dll'
, 'lib/android/arm/static/libssl.a'
, 'lib/android/arm/static/libcrypto.a'
, 'lib/android/arm/static/debug/libssl.a'
, 'lib/android/arm/static/debug/libcrypto.a'
, 'lib/linux2/x86/dynamic/debug/libcrypto.so.1.0.0'
, 'lib/linux2/x86/dynamic/debug/libssl.so.1.0.0'
, 'lib/linux2/x86/dynamic/libcrypto.so.1.0.0'
, 'lib/linux2/x86/dynamic/libssl.so.1.0.0'
);
unlink $_ foreach @files;
}

