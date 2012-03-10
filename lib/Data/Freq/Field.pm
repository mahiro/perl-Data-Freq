use 5.006;
use strict;
use warnings;

package Data::Freq::Field;

=head1 NAME

Data::Freq::Field

=cut

use Carp qw(croak);
use Date::Parse qw(str2time);
use Scalar::Util qw(looks_like_number);
use POSIX qw(strftime);

=head1 METHODS

=head2 new

=cut

sub new {
	my ($class, $input) = @_;
	my $self;
	
	if (!ref $input) {
		$self = bless {$class->_expand_any($input)}, $class;
	} elsif (ref $input eq 'HASH') {
		$self = bless {
			$class->_expand_type ($input->{type }),
			$class->_expand_sort ($input->{sort }),
			$class->_expand_order($input->{order}),
			$class->_expand_pos  ($input->{pos  }),
		}, $class;
		
		$self->{key} = $input->{key} if defined $input->{key};
	} elsif (ref $input eq 'ARRAY') {
		$self = bless {map {$class->_expand_any($_)} @$input}, $class;
	} else {
		croak "invalid field: $input";
	}
	
	$self->{type} = 'text' unless defined $self->{type};
	
	if ($self->{type} eq 'text') {
		$self->{sort} ||= 'count';
	} else {
		$self->{sort} ||= 'value';
	}
	
	if ($self->{sort} eq 'count') {
		$self->{order} ||= 'desc';
	} else {
		$self->{order} ||= 'asc';
	}
	
	return $self;
}

=head2 evaluate

=cut

sub evaluate {
	my ($self, $record) = @_;
	my $result;
	
	if (defined $self->{pos}) {
		$result = $record->array->[$self->{pos}];
	} elsif (defined $self->{key}) {
		$result = $record->hash->{$self->{key}};
	} elsif ($self->{type} eq 'date') {
		$result = $record->date;
	} else {
		$result = $record->text;
	}
	
	if ($self->{type} eq 'date') {
		$result = looks_like_number($result) ? $result : str2time($result);
		$result = strftime($self->{strftime}, localtime $result) if defined $result;
	}
	
	if ($self->{convert}) {
		$result = $self->{convert}->($result);
	}
	
	return $result;
}

=head2 sort_result
=cut

sub sort_result {
	my ($self, $children) = @_;
	my $type  = $self->{type};
	my $sort  = $self->{sort};
	my $order = $self->{order};
	
	if ($type ne 'number' && $sort eq 'value') {
		if ($order eq 'asc') {
			return [sort {$a->$sort eq $b->$sort || $a->first <=> $b->first} @$children];
		} else {
			return [sort {$b->$sort eq $a->$sort || $a->first <=> $b->first} @$children];
		}
	} else {
		if ($order eq 'asc') {
			return [sort {$a->$sort <=> $b->$sort || $a->first <=> $b->first} @$children];
		} else {
			return [sort {$b->$sort <=> $a->$sort || $a->first <=> $b->first} @$children];
		}
	}
}

sub _expand_any {
	my ($class, $input) = @_;
	my @ret;
	
	if (@ret = $class->_expand_pos($input)) {
		return @ret;
	} elsif (@ret = $class->_expand_sort($input)) {
		return @ret;
	} elsif (@ret = $class->_expand_order($input)) {
		return @ret;
	} elsif (@ret = $class->_expand_type($input)) {
		return @ret;
	}
	
	return ();
}

sub _expand_type {
	my ($class, $input) = @_;
	
	if (!defined $input || $input eq '' || $input =~ /^texts?$/i) {
		return (type => 'text');
	} elsif ($input =~ /^num(ber)?s?$/i) {
		return (type => 'number');
	} elsif ($input =~ /\%/) {
		return (type => 'date', strftime => $input);
	} elsif ($input =~ /^years?$/i) {
		return (type => 'date', strftime => '%Y');
	} elsif ($input =~ /^month?s?$/i) {
		return (type => 'date', strftime => '%Y-%m');
	} elsif ($input =~ /^(date|day)s?$/i) {
		return (type => 'date', strftime => '%F');
	} elsif ($input =~ /^hours?$/i) {
		return (type => 'date', strftime => '%F %H');
	} elsif ($input =~ /^minutes?$/i) {
		return (type => 'date', strftime => '%F %H:%M');
	} elsif ($input =~ /^(seconds?|time)?$/i) {
		return (type => 'date', strftime => '%F %T');
	}
	
	return ();
}

sub _expand_sort {
	my ($class, $input) = @_;
	return () if !defined $input || $input eq '';
	
	if ($input =~ /^values?$/i) {
		return (sort => 'value');
	} elsif ($input =~ /^counts?$/i) {
		return (sort => 'count');
	} elsif ($input =~ /^(first|occur(rence)?s?)$/i) {
		return (sort => 'first');
	} elsif ($input =~ /^last$/i) {
		return (sort => 'last');
	}
	
	return ();
}

sub _expand_order {
	my ($class, $input) = @_;
	return () if !defined $input || $input eq '';
	
	if ($input =~ /^asc/i) {
		return (order => 'asc');
	} elsif ($input =~ /^desc$/i) {
		return (order => 'desc');
	}
	
	return ();
}

sub _expand_pos {
	my ($class, $input) = @_;
	return () if !defined $input || $input eq '';
	
	if ($input =~ /^-?\d+$/) {
		return (pos => $input);
	}
	
	return ();
}

1;
