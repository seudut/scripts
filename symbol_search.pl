#!/usr/bin/perl -w
#
# ./symbol_search.pl FUNCTION xxx.dylib
## do not use this search static function
use strict;
use 5.010;

die $! unless @ARGV;

my $symbol= shift @ARGV;

foreach (@ARGV){
    say if `nm -a $_` =~ /T.*$symbol/;
}
