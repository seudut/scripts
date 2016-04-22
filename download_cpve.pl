#!/usr/bin/perl -w
#
use strict;

##my $base_url = 'http://sea-cpve.cisco.com:8080/job/BUILD_WINDOWS_VS2013_MARI/lastSuccessfulBuild/artifact/Source/target/publish/dist/csf2g-cpve-win32-x86-vs2013-2.399.4.zip'
my $base_url = 'http://sea-cpve.cisco.com:8080/job/';
my $path = 'lastSuccessfulBuild/artifact/Source/target/publish/dist/';

my $ecc_dir = $ENV{'HOME'} . "/JCC/ecc_mari_2/contrib/cpve/";

## compress
my %plat_hash = (
            "win32" =>  {
                            "job" =>  "BUILD_WINDOWS_VS2013_MARI",
                            "cpve_gz" =>   "csf2g-cpve-win32-x86-vs2013-2.399.4.zip",
                            "ecc_7z" =>   "lib/win32/win32-x86_vs2013.7z",
                            "ecc_path" => "lib/win32/x86",
                        },

            "mac"   =>  {
                           "job" =>  "BUILD_MAC64_MARI",
                           "cpve_gz" =>   "csf2g-cpve-darwin-x86_64-2.399.4.tar.gz",
                           "ecc_7z" =>   "lib/darwin/darwin-x86_64.7z",
                            "ecc_path" => "lib/darwin/x86_64",
                        },

            "linux" =>  {
                           "job" =>  "BUILD_LINUX_MARI",
                           "cpve_gz" =>   "csf2g-cpve-linux2-x86-2.399.4.tar.gz",
                           "ecc_7z" =>   "lib/linux2/linux2-x86.7z",
                            "ecc_path" => "lib/linux2/x86",
                        },

            "ios"   =>  {
                           "job" =>  "BUILD_IOS_9_0_64BIT_IPAD_MARI",
                           "cpve_gz" =>   "csf2g-cpve-darwin-arm64-2.399.4.tar.gz",
                           "ecc_7z" =>   "lib/darwin/darwin-arm64.7z",
                            "ecc_path" => "lib/darwin/arm64",
                        },

            "android"   => {
                           "job" =>  "BUILD_ANDROID_LINUX_MARI",
                           "cpve_gz" =>   "csf2g-cpve-android-arm-2.399.4.tar.gz",
                           "ecc_7z" =>   "lib/android/android-arm.7z",
                            "ecc_path" => "lib/android/arm",
                        },
        );


chdir "./temp";

# download
foreach my $target (keys %plat_hash)
{
    next if ($target ne "mac");
    # download
    my $full_url = $base_url . $plat_hash{$target}{"job"} . "/" . $path . "/" .  $plat_hash{$target}{"cpve_gz"};
    ! system "wget", $full_url or die $!;

    ## uncompress
    my $file = $plat_hash{$target}{"cpve_gz"};
    (! system "tar", "zxvf", $file or die $! ) if($file =~ /.tar.gz$/);
    (! system "unzip", "-o", $file or die $! ) if($file =~ /.zip$/);

    ## 7z compress
    ! system "7z", "a", $plat_hash{$target}{"ecc_7z"}, $plat_hash{$target}{"ecc_path"} or die $!; 

    ## replace 7z
    ! system "/bin/cp", $plat_hash{$target}{"ecc_7z"},  $ecc_dir . $plat_hash{$target}{"ecc_7z"} or die $!;
}

## replace header
system "/bin/cp", "include/csf/media/rtp/CPVEMedia.hpp", $ecc_dir .  "include/csf/media/rtp/CPVEMedia.hpp";

