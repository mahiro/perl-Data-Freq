#!perl -T

use 5.006;
use strict;
use warnings;
use Test::More tests => 3;

use Data::Freq;

for my $module (keys %INC) {
    $module =~ s/\.pm$//;
    $module =~ s{/}{::}g;
    
    if ($module =~ /^Data::Freq::/) {
        is(eval('$'.$module.'::VERSION'), $Data::Freq::VERSION, $module);
    }
}
