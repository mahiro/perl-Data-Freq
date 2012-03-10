#!perl -T

use strict;
use warnings;

use Test::More tests => 2;

use Data::Freq::Record qw(logsplit);
use POSIX qw(strftime);

subtest logsplit => sub {
	plan tests => 6;
	
	is_deeply [logsplit ''], [];
	is_deeply [logsplit 'test'], ['test'];
	is_deeply [logsplit 'test1 test2'], ['test1', 'test2'];
	
	is_deeply [logsplit qq(ab [cd ef] "gh ij" kl [mn] op\n)],
			['ab', '[cd ef]', '"gh ij"', 'kl', '[mn]', 'op'];
	
	my ($date, $time) = split ' ', strftime('%F %T', localtime);
	
	is_deeply [logsplit qq([$date $time] - 123 {ab "cd" (ef-4.56 gh)} - -)],
			["[$date $time]", '-', '123', '{ab "cd" (ef-4.56 gh)}', '-', '-'];
	
	is_deeply [logsplit qq([ \\] ] " \\" " { \\} } ' \\' ')],
			['[ \\] ]', '" \\" "', '{ \\} }', "' \\' '"];
};

subtest text => sub {
	plan tests => 3;
	
	my $record = Data::Freq::Record->new('test');
	
	is $record->text, 'test';
	is_deeply $record->array, ['test'];
	eval {$record->hash}; ok $@;
	
};

