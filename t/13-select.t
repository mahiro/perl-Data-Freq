#!perl -T

use strict;
use warnings;

use Test::More tests => 6;

use Data::Freq::Field;
use Data::Freq::Node;

subtest text => sub {
	plan tests => 4;
	
	my $root = Data::Freq::Node->new();
	++$root->{count} && $root->add_subnode('a') foreach 1..3;
	++$root->{count} && $root->add_subnode('b') foreach 1..5;
	++$root->{count} && $root->add_subnode('c') foreach 1..2;
	
	my $children = $root->children;
	my $nodes = [values %$children];
	
	my $field;
	
	$field = Data::Freq::Field->new({type => 'text', sort => 'value', order => 'asc'});
	is_deeply($field->select_nodes($nodes), [map {$children->{$_}} qw(a b c)]);
	
	$field = Data::Freq::Field->new({type => 'text', sort => 'value', order => 'desc'});
	is_deeply($field->select_nodes($nodes), [map {$children->{$_}} qw(c b a)]);
	
	$field = Data::Freq::Field->new({type => 'text', sort => 'count', order => 'asc'});
	is_deeply($field->select_nodes($nodes), [map {$children->{$_}} qw(c a b)]);
	
	$field = Data::Freq::Field->new({type => 'text', sort => 'count', order => 'desc'});
	is_deeply($field->select_nodes($nodes), [map {$children->{$_}} qw(b a c)]);
};

subtest number => sub {
	plan tests => 4;
	
	my $root = Data::Freq::Node->new();
	++$root->{count} && $root->add_subnode('10') foreach 1..3;
	++$root->{count} && $root->add_subnode('2') foreach 1..5;
	++$root->{count} && $root->add_subnode('3') foreach 1..2;
	
	my $children = $root->children;
	my $nodes = [values %$children];
	
	my $field;
	
	$field = Data::Freq::Field->new({type => 'number', sort => 'value', order => 'asc'});
	is_deeply($field->select_nodes($nodes), [map {$children->{$_}} qw(2 3 10)]);
	
	$field = Data::Freq::Field->new({type => 'number', sort => 'value', order => 'desc'});
	is_deeply($field->select_nodes($nodes), [map {$children->{$_}} qw(10 3 2)]);
	
	$field = Data::Freq::Field->new({type => 'text', sort => 'value', order => 'asc'});
	is_deeply($field->select_nodes($nodes), [map {$children->{$_}} qw(10 2 3)]);
	
	$field = Data::Freq::Field->new({type => 'text', sort => 'value', order => 'desc'});
	is_deeply($field->select_nodes($nodes), [map {$children->{$_}} qw(3 2 10)]);
};

subtest occurrence => sub {
	plan tests => 4;
	
	my $root = Data::Freq::Node->new();
	++$root->{count} && $root->add_subnode('a') foreach 1..3;
	++$root->{count} && $root->add_subnode('b') foreach 1..5;
	++$root->{count} && $root->add_subnode('c') foreach 1..2;
	++$root->{count} && $root->add_subnode('b') foreach 1..5;
	
	my $children = $root->children;
	my $nodes = [values %$children];
	
	my $field;
	
	$field = Data::Freq::Field->new({type => 'text', sort => 'first', order => 'asc'});
	is_deeply($field->select_nodes($nodes), [map {$children->{$_}} qw(a b c)]);
	
	$field = Data::Freq::Field->new({type => 'text', sort => 'first', order => 'desc'});
	is_deeply($field->select_nodes($nodes), [map {$children->{$_}} qw(c b a)]);
	
	$field = Data::Freq::Field->new({type => 'text', sort => 'last', order => 'asc'});
	is_deeply($field->select_nodes($nodes), [map {$children->{$_}} qw(a c b)]);
	
	$field = Data::Freq::Field->new({type => 'text', sort => 'last', order => 'desc'});
	is_deeply($field->select_nodes($nodes), [map {$children->{$_}} qw(b c a)]);
};

subtest offset => sub {
	plan tests => 9;
	
	my $root = Data::Freq::Node->new();
	++$root->{count} && $root->add_subnode('a') foreach 1..3;
	++$root->{count} && $root->add_subnode('b') foreach 1..5;
	++$root->{count} && $root->add_subnode('c') foreach 1..2;
	++$root->{count} && $root->add_subnode('d') foreach 1..5;
	
	my $children = $root->children;
	my $nodes = [values %$children];
	
	my $field;
	
	$field = Data::Freq::Field->new({type => 'text', sort => 'value', order => 'asc', offset => 0});
	is_deeply($field->select_nodes($nodes), [map {$children->{$_}} qw(a b c d)]);
	
	$field = Data::Freq::Field->new({type => 'text', sort => 'value', order => 'asc', offset => 1});
	is_deeply($field->select_nodes($nodes), [map {$children->{$_}} qw(b c d)]);
	
	$field = Data::Freq::Field->new({type => 'text', sort => 'value', order => 'asc', offset => 2});
	is_deeply($field->select_nodes($nodes), [map {$children->{$_}} qw(c d)]);
	
	$field = Data::Freq::Field->new({type => 'text', sort => 'value', order => 'asc', offset => 3});
	is_deeply($field->select_nodes($nodes), [map {$children->{$_}} qw(d)]);
	
	$field = Data::Freq::Field->new({type => 'text', sort => 'value', order => 'asc', offset => 4});
	is_deeply($field->select_nodes($nodes), [map {$children->{$_}} qw()]);
	
	$field = Data::Freq::Field->new({type => 'text', sort => 'value', order => 'asc', offset => -1});
	is_deeply($field->select_nodes($nodes), [map {$children->{$_}} qw(d)]);
	
	$field = Data::Freq::Field->new({type => 'text', sort => 'value', order => 'asc', offset => -2});
	is_deeply($field->select_nodes($nodes), [map {$children->{$_}} qw(c d)]);
	
	$field = Data::Freq::Field->new({type => 'text', sort => 'value', order => 'asc', offset => -3});
	is_deeply($field->select_nodes($nodes), [map {$children->{$_}} qw(b c d)]);
	
	$field = Data::Freq::Field->new({type => 'text', sort => 'value', order => 'asc', offset => -4});
	is_deeply($field->select_nodes($nodes), [map {$children->{$_}} qw(a b c d)]);
};

subtest limit => sub {
	plan tests => 9;
	
	my $root = Data::Freq::Node->new();
	++$root->{count} && $root->add_subnode('a') foreach 1..3;
	++$root->{count} && $root->add_subnode('b') foreach 1..5;
	++$root->{count} && $root->add_subnode('c') foreach 1..2;
	++$root->{count} && $root->add_subnode('d') foreach 1..5;
	
	my $children = $root->children;
	my $nodes = [values %$children];
	
	my $field;
	
	$field = Data::Freq::Field->new({type => 'text', sort => 'value', order => 'asc', limit => 0});
	is_deeply($field->select_nodes($nodes), [map {$children->{$_}} qw()]);
	
	$field = Data::Freq::Field->new({type => 'text', sort => 'value', order => 'asc', limit => 1});
	is_deeply($field->select_nodes($nodes), [map {$children->{$_}} qw(a)]);
	
	$field = Data::Freq::Field->new({type => 'text', sort => 'value', order => 'asc', limit => 2});
	is_deeply($field->select_nodes($nodes), [map {$children->{$_}} qw(a b)]);
	
	$field = Data::Freq::Field->new({type => 'text', sort => 'value', order => 'asc', limit => 3});
	is_deeply($field->select_nodes($nodes), [map {$children->{$_}} qw(a b c)]);
	
	$field = Data::Freq::Field->new({type => 'text', sort => 'value', order => 'asc', limit => 4});
	is_deeply($field->select_nodes($nodes), [map {$children->{$_}} qw(a b c d)]);
	
	$field = Data::Freq::Field->new({type => 'text', sort => 'value', order => 'asc', limit => -1});
	is_deeply($field->select_nodes($nodes), [map {$children->{$_}} qw(a b c)]);
	
	$field = Data::Freq::Field->new({type => 'text', sort => 'value', order => 'asc', limit => -2});
	is_deeply($field->select_nodes($nodes), [map {$children->{$_}} qw(a b)]);
	
	$field = Data::Freq::Field->new({type => 'text', sort => 'value', order => 'asc', limit => -3});
	is_deeply($field->select_nodes($nodes), [map {$children->{$_}} qw(a)]);
	
	$field = Data::Freq::Field->new({type => 'text', sort => 'value', order => 'asc', limit => -4});
	is_deeply($field->select_nodes($nodes), [map {$children->{$_}} qw()]);
};

subtest offset_limit => sub {
	plan tests => 4;
	
	my $root = Data::Freq::Node->new();
	++$root->{count} && $root->add_subnode('a') foreach 1..3;
	++$root->{count} && $root->add_subnode('b') foreach 1..5;
	++$root->{count} && $root->add_subnode('c') foreach 1..2;
	++$root->{count} && $root->add_subnode('d') foreach 1..5;
	
	my $children = $root->children;
	my $nodes = [values %$children];
	
	my $field;
	
	$field = Data::Freq::Field->new({type => 'text', sort => 'value', order => 'asc', offset => 1, limit => 2});
	is_deeply($field->select_nodes($nodes), [map {$children->{$_}} qw(b c)]);
	
	$field = Data::Freq::Field->new({type => 'text', sort => 'value', order => 'asc', offset => -3, limit => 2});
	is_deeply($field->select_nodes($nodes), [map {$children->{$_}} qw(b c)]);
	
	$field = Data::Freq::Field->new({type => 'text', sort => 'value', order => 'asc', offset => 1, limit => -1});
	is_deeply($field->select_nodes($nodes), [map {$children->{$_}} qw(b c)]);
	
	$field = Data::Freq::Field->new({type => 'text', sort => 'value', order => 'asc', offset => -3, limit => -1});
	is_deeply($field->select_nodes($nodes), [map {$children->{$_}} qw(b c)]);
};


