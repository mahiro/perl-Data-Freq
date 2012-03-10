#!perl -T

use strict;
use warnings;

use Test::More tests => 7;

use Data::Freq::Field;

subtest default => sub {
	plan tests => 2;
	
	my $field = Data::Freq::Field->new();
	
	is(ref($field), 'Data::Freq::Field');
	is_deeply($field, {type => 'text', sort => 'count', order => 'desc'});
};

subtest simple_type => sub {
	plan tests => 21;
	
	is_deeply(Data::Freq::Field->new('text'   ), {type => 'text', sort => 'count', order => 'desc'});
	is_deeply(Data::Freq::Field->new('texts'  ), {type => 'text', sort => 'count', order => 'desc'});
	is_deeply(Data::Freq::Field->new('num'    ), {type => 'number', sort => 'value', order => 'asc'});
	is_deeply(Data::Freq::Field->new('nums'   ), {type => 'number', sort => 'value', order => 'asc'});
	is_deeply(Data::Freq::Field->new('number' ), {type => 'number', sort => 'value', order => 'asc'});
	is_deeply(Data::Freq::Field->new('numbers'), {type => 'number', sort => 'value', order => 'asc'});
	is_deeply(Data::Freq::Field->new('date'   ), {type => 'date', sort => 'value', order => 'asc', strftime => '%F'});
	is_deeply(Data::Freq::Field->new('dates'  ), {type => 'date', sort => 'value', order => 'asc', strftime => '%F'});
	
	is_deeply(Data::Freq::Field->new('year'   ), {type => 'date', sort => 'value', order => 'asc', strftime => '%Y'});
	is_deeply(Data::Freq::Field->new('years'  ), {type => 'date', sort => 'value', order => 'asc', strftime => '%Y'});
	is_deeply(Data::Freq::Field->new('month'  ), {type => 'date', sort => 'value', order => 'asc', strftime => '%Y-%m'});
	is_deeply(Data::Freq::Field->new('months' ), {type => 'date', sort => 'value', order => 'asc', strftime => '%Y-%m'});
	is_deeply(Data::Freq::Field->new('day'    ), {type => 'date', sort => 'value', order => 'asc', strftime => '%F'});
	is_deeply(Data::Freq::Field->new('days'   ), {type => 'date', sort => 'value', order => 'asc', strftime => '%F'});
	is_deeply(Data::Freq::Field->new('hour'   ), {type => 'date', sort => 'value', order => 'asc', strftime => '%F %H'});
	is_deeply(Data::Freq::Field->new('hours'  ), {type => 'date', sort => 'value', order => 'asc', strftime => '%F %H'});
	is_deeply(Data::Freq::Field->new('minute' ), {type => 'date', sort => 'value', order => 'asc', strftime => '%F %H:%M'});
	is_deeply(Data::Freq::Field->new('minutes'), {type => 'date', sort => 'value', order => 'asc', strftime => '%F %H:%M'});
	is_deeply(Data::Freq::Field->new('second' ), {type => 'date', sort => 'value', order => 'asc', strftime => '%F %T'});
	is_deeply(Data::Freq::Field->new('seconds'), {type => 'date', sort => 'value', order => 'asc', strftime => '%F %T'});
	is_deeply(Data::Freq::Field->new('time'   ), {type => 'date', sort => 'value', order => 'asc', strftime => '%F %T'});
};

subtest simple_pos => sub {
	plan tests => 7;
	
	is_deeply(Data::Freq::Field->new(  0), {type => 'text', sort => 'count', order => 'desc', pos => 0});
	is_deeply(Data::Freq::Field->new(  1), {type => 'text', sort => 'count', order => 'desc', pos => 1});
	is_deeply(Data::Freq::Field->new(  2), {type => 'text', sort => 'count', order => 'desc', pos => 2});
	is_deeply(Data::Freq::Field->new( 10), {type => 'text', sort => 'count', order => 'desc', pos => 10});
	
	is_deeply(Data::Freq::Field->new( -1), {type => 'text', sort => 'count', order => 'desc', pos => -1});
	is_deeply(Data::Freq::Field->new( -2), {type => 'text', sort => 'count', order => 'desc', pos => -2});
	is_deeply(Data::Freq::Field->new(-10), {type => 'text', sort => 'count', order => 'desc', pos => -10});
};

subtest simple_sort => sub {
	plan tests => 6;
	
	is_deeply(Data::Freq::Field->new('count'), {type => 'text', sort => 'count', order => 'desc'});
	is_deeply(Data::Freq::Field->new('value'), {type => 'text', sort => 'value', order => 'asc'});
	is_deeply(Data::Freq::Field->new('first'), {type => 'text', sort => 'first', order => 'asc'});
	is_deeply(Data::Freq::Field->new('last' ), {type => 'text', sort => 'last', order => 'asc'});
	
	is_deeply(Data::Freq::Field->new('occur'), {type => 'text', sort => 'first', order => 'asc'});
	is_deeply(Data::Freq::Field->new('occurrence'), {type => 'text', sort => 'first', order => 'asc'});
};

subtest simple_order => sub {
	plan tests => 4;
	
	is_deeply(Data::Freq::Field->new('asc'       ), {type => 'text', sort => 'count', order => 'asc'});
	is_deeply(Data::Freq::Field->new('ascending' ), {type => 'text', sort => 'count', order => 'asc'});
	is_deeply(Data::Freq::Field->new('desc'      ), {type => 'text', sort => 'count', order => 'desc'});
	is_deeply(Data::Freq::Field->new('descending'), {type => 'text', sort => 'count', order => 'desc'});
};

subtest hash_1 => sub {
	plan tests => 11;
	
	is_deeply(Data::Freq::Field->new({type => 'text'  }), {type => 'text', sort => 'count', order => 'desc'});
	is_deeply(Data::Freq::Field->new({type => 'number'}), {type => 'number', sort => 'value', order => 'asc'});
	is_deeply(Data::Freq::Field->new({type => 'date'  }), {type => 'date', sort => 'value', order => 'asc', strftime => '%F'});
	is_deeply(Data::Freq::Field->new({type => 'month' }), {type => 'date', sort => 'value', order => 'asc', strftime => '%Y-%m'});
	
	is_deeply(Data::Freq::Field->new({pos => 0}), {type => 'text', sort => 'count', order => 'desc', pos => 0});
	is_deeply(Data::Freq::Field->new({pos => 1}), {type => 'text', sort => 'count', order => 'desc', pos => 1});
	is_deeply(Data::Freq::Field->new({key => 'foo'}), {type => 'text', sort => 'count', order => 'desc', key => 'foo'});
	
	is_deeply(Data::Freq::Field->new({sort => 'count' }), {type => 'text', sort => 'count', order => 'desc'});
	is_deeply(Data::Freq::Field->new({sort => 'value' }), {type => 'text', sort => 'value', order => 'asc'});
	is_deeply(Data::Freq::Field->new({sort => 'first' }), {type => 'text', sort => 'first', order => 'asc'});
	is_deeply(Data::Freq::Field->new({sort => 'last'  }), {type => 'text', sort => 'last', order => 'asc'});
};

subtest hash_2 => sub {
	plan tests => 29;
	
	is_deeply(Data::Freq::Field->new({type => 'text'  , sort => 'count'}), {type => 'text', sort => 'count', order => 'desc'});
	is_deeply(Data::Freq::Field->new({type => 'text'  , sort => 'value'}), {type => 'text', sort => 'value', order => 'asc'});
	is_deeply(Data::Freq::Field->new({type => 'text'  , sort => 'first'}), {type => 'text', sort => 'first', order => 'asc'});
	is_deeply(Data::Freq::Field->new({type => 'text'  , sort => 'last' }), {type => 'text', sort => 'last', order => 'asc'});
	is_deeply(Data::Freq::Field->new({type => 'number', sort => 'count'}), {type => 'number', sort => 'count', order => 'desc'});
	is_deeply(Data::Freq::Field->new({type => 'number', sort => 'value'}), {type => 'number', sort => 'value', order => 'asc'});
	is_deeply(Data::Freq::Field->new({type => 'number', sort => 'first'}), {type => 'number', sort => 'first', order => 'asc'});
	is_deeply(Data::Freq::Field->new({type => 'number', sort => 'last' }), {type => 'number', sort => 'last', order => 'asc'});
	is_deeply(Data::Freq::Field->new({type => 'date'  , sort => 'count'}), {type => 'date', sort => 'count', order => 'desc', strftime => '%F'});
	is_deeply(Data::Freq::Field->new({type => 'date'  , sort => 'value'}), {type => 'date', sort => 'value', order => 'asc', strftime => '%F'});
	is_deeply(Data::Freq::Field->new({type => 'date'  , sort => 'first'}), {type => 'date', sort => 'first', order => 'asc', strftime => '%F'});
	is_deeply(Data::Freq::Field->new({type => 'date'  , sort => 'last' }), {type => 'date', sort => 'last', order => 'asc', strftime => '%F'});
	
	is_deeply(Data::Freq::Field->new({sort => 'count', order => 'asc' }), {type => 'text', sort => 'count', order => 'asc'});
	is_deeply(Data::Freq::Field->new({sort => 'count', order => 'desc'}), {type => 'text', sort => 'count', order => 'desc'});
	is_deeply(Data::Freq::Field->new({sort => 'value', order => 'asc' }), {type => 'text', sort => 'value', order => 'asc'});
	is_deeply(Data::Freq::Field->new({sort => 'value', order => 'desc'}), {type => 'text', sort => 'value', order => 'desc'});
	is_deeply(Data::Freq::Field->new({sort => 'first', order => 'asc' }), {type => 'text', sort => 'first', order => 'asc'});
	is_deeply(Data::Freq::Field->new({sort => 'first', order => 'desc'}), {type => 'text', sort => 'first', order => 'desc'});
	is_deeply(Data::Freq::Field->new({sort => 'last' , order => 'asc' }), {type => 'text', sort => 'last', order => 'asc'});
	is_deeply(Data::Freq::Field->new({sort => 'last' , order => 'desc'}), {type => 'text', sort => 'last', order => 'desc'});
	
	is_deeply(Data::Freq::Field->new({type => 'text'  , order => 'asc' }), {type => 'text', sort => 'count', order => 'asc'});
	is_deeply(Data::Freq::Field->new({type => 'text'  , order => 'desc'}), {type => 'text', sort => 'count', order => 'desc'});
	is_deeply(Data::Freq::Field->new({type => 'number', order => 'asc' }), {type => 'number', sort => 'value', order => 'asc'});
	is_deeply(Data::Freq::Field->new({type => 'number', order => 'desc'}), {type => 'number', sort => 'value', order => 'desc'});
	is_deeply(Data::Freq::Field->new({type => 'date'  , order => 'asc' }), {type => 'date', sort => 'value', order => 'asc', strftime => '%F'});
	is_deeply(Data::Freq::Field->new({type => 'date'  , order => 'desc'}), {type => 'date', sort => 'value', order => 'desc', strftime => '%F'});
	
	is_deeply(Data::Freq::Field->new({type => 'year' , pos =>   2  }), {type => 'date', sort => 'value', order => 'asc', pos => 2, strftime => '%Y'});
	is_deeply(Data::Freq::Field->new({sort => 'first', key => 'bar'}), {type => 'text', sort => 'first', order => 'asc', key => 'bar'});
	is_deeply(Data::Freq::Field->new({pos  =>    3   , key => 'baz'}), {type => 'text', sort => 'count', order => 'desc', pos => 3, key => 'baz'});
}
