#!perl -T

use strict;
use warnings;

use Test::More tests => 4;

use Data::Freq;

subtest single => sub {
	plan tests => 4;
	
	my $data = Data::Freq->new();
	
	$data->add('foo');
	$data->add('bar');
	$data->add('foo');
	$data->add('baz');
	$data->add('foo');
	$data->add('bar');
	$data->add('foo');
	
	my @result;
	$data->output(sub {push @result, $_[0]});
	
	is_deeply([map {$result[0]->$_} qw(value count depth)], [undef, 7, 0]);
	is_deeply([map {$result[1]->$_} qw(value count depth)], ['foo', 4, 1]);
	is_deeply([map {$result[2]->$_} qw(value count depth)], ['bar', 2, 1]);
	is_deeply([map {$result[3]->$_} qw(value count depth)], ['baz', 1, 1]);
};

subtest number => sub {
	plan tests => 5;
	
	my $data = Data::Freq->new({type => 'number', sort => 'value'});
	
	$data->add(1);
	$data->add(10);
	$data->add(11);
	$data->add(2);
	
	my @result;
	$data->output(sub {push @result, $_[0]});
	my $i = 0;
	
	is_deeply([map {$result[$i]->$_} qw(value count depth)], [undef, 4, 0]); $i++;
	{
		is_deeply([map {$result[$i]->$_} qw(value count depth)], [1, 1, 1]); $i++;
		is_deeply([map {$result[$i]->$_} qw(value count depth)], [2, 1, 1]); $i++;
		is_deeply([map {$result[$i]->$_} qw(value count depth)], [10, 1, 1]); $i++;
		is_deeply([map {$result[$i]->$_} qw(value count depth)], [11, 1, 1]); $i++;
	}
};

subtest text => sub {
	plan tests => 5;
	
	my $data = Data::Freq->new({type => 'text', sort => 'value'});
	
	$data->add(1);
	$data->add(10);
	$data->add(11);
	$data->add(2);
	
	my @result;
	$data->output(sub {push @result, $_[0]});
	my $i = 0;
	
	is_deeply([map {$result[$i]->$_} qw(value count depth)], [undef, 4, 0]); $i++;
	{
		is_deeply([map {$result[$i]->$_} qw(value count depth)], [1, 1, 1]); $i++;
		is_deeply([map {$result[$i]->$_} qw(value count depth)], [10, 1, 1]); $i++;
		is_deeply([map {$result[$i]->$_} qw(value count depth)], [11, 1, 1]); $i++;
		is_deeply([map {$result[$i]->$_} qw(value count depth)], [2, 1, 1]); $i++;
	}
};

subtest date => sub {
	plan tests => 10;
	
	my $data = Data::Freq->new({type => 'month'}, {pos => 1});
	
	$data->add("a b [2012-01-01 00:00:00] c\n");
	$data->add("a b [2012-01-02 01:00:00] c\n");
	$data->add("a b [2012-02-03 02:00:00] d\n");
	$data->add("a b [2012-02-04 03:00:00] d\n");
	$data->add("a c [2012-02-05 04:00:00] d\n");
	$data->add("a c [2012-02-06 05:00:00] d\n");
	$data->add("a c [2012-02-07 06:00:00] d\n");
	$data->add("b d [2012-01-08 07:00:00] e\n");
	$data->add("b d [2012-02-09 08:00:00] e\n");
	$data->add("b e [2012-01-10 09:00:00] e\n");
	$data->add("b e [2012-01-11 10:00:00] f\n");
	$data->add("b f [2012-02-12 11:00:00] f\n");
	
	my @result;
	$data->output(sub {push @result, $_[0]});
	my $i = 0;
	
	is_deeply([map {$result[$i]->$_} qw(value count depth)], [undef, 12, 0]); $i++;
	{
		is_deeply([map {$result[$i]->$_} qw(value count depth)], ['2012-01', 5, 1]); $i++;
		{
			is_deeply([map {$result[$i]->$_} qw(value count depth)], ['b', 2, 2]); $i++;
			is_deeply([map {$result[$i]->$_} qw(value count depth)], ['e', 2, 2]); $i++;
			is_deeply([map {$result[$i]->$_} qw(value count depth)], ['d', 1, 2]); $i++;
		}
		is_deeply([map {$result[$i]->$_} qw(value count depth)], ['2012-02', 7, 1]); $i++;
		{
			is_deeply([map {$result[$i]->$_} qw(value count depth)], ['c', 3, 2]); $i++;
			is_deeply([map {$result[$i]->$_} qw(value count depth)], ['b', 2, 2]); $i++;
			is_deeply([map {$result[$i]->$_} qw(value count depth)], ['d', 1, 2]); $i++;
			is_deeply([map {$result[$i]->$_} qw(value count depth)], ['f', 1, 2]); $i++;
		}
	}
};
