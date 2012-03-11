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
	my $self = bless {}, $class;
	
	if (!ref $input) {
		$self->_extract_any($input);
	} elsif (ref $input eq 'HASH') {
		for my $target (qw(type sort order pos key)) {
			if (defined $input->{$target}) {
				my $method = "_extract_$target";
				$self->$method($input->{$target});
			}
		}
	} elsif (ref $input eq 'ARRAY') {
		for my $item (@$input) {
			$self->_extract_any($item);
		}
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
	my $result = undef;
	
	TRY: {
		if (defined $self->{pos}) {
			my $pos = $self->{pos};
			my $array = $record->array or last TRY;
			$result = "@$array[@$pos]";
		} elsif (defined $self->{key}) {
			my $key = $self->{key};
			my $hash = $record->hash or last TRY;
			$result = "@$hash{@$key}";
		} elsif ($self->{type} eq 'date') {
			$result = $record->date;
		} else {
			$result = $record->text;
		}
		
		last TRY unless defined $result;
		
		if ($self->{type} eq 'date') {
			$result = looks_like_number($result) ? $result : str2time($result);
			$result = strftime($self->{strftime}, localtime $result) if defined $result;
		}
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

sub _extract_any {
	my ($self, $input) = @_;
	
	for my $target (qw(pos type sort order)) {
		my $method = "_extract_$target";
		return $self if $self->$method($input);
	}
	
	return undef;
}

sub _extract_type {
	my ($self, $input) = @_;
	return undef if ref($input);
	
	if (!defined $input || $input eq '' || $input =~ /^texts?$/i) {
		$self->{type} = 'text';
		return $self;
	} elsif ($input =~ /^num(ber)?s?$/i) {
		$self->{type} = 'number';
		return $self;
	} elsif ($input =~ /\%/) {
		$self->{type} = 'date';
		$self->{strftime} = $input;
		return $self;
	} elsif ($input =~ /^years?$/i) {
		$self->{type} = 'date';
		$self->{strftime} = '%Y';
		return $self;
	} elsif ($input =~ /^month?s?$/i) {
		$self->{type} = 'date';
		$self->{strftime} = '%Y-%m';
		return $self;
	} elsif ($input =~ /^(date|day)s?$/i) {
		$self->{type} = 'date';
		$self->{strftime} = '%F';
		return $self;
	} elsif ($input =~ /^hours?$/i) {
		$self->{type} = 'date';
		$self->{strftime} = '%F %H';
		return $self;
	} elsif ($input =~ /^minutes?$/i) {
		$self->{type} = 'date';
		$self->{strftime} = '%F %H:%M';
		return $self;
	} elsif ($input =~ /^(seconds?|time)?$/i) {
		$self->{type} = 'date';
		$self->{strftime} = '%F %T';
		return $self;
	}
	
	return undef;
}

sub _extract_sort {
	my ($self, $input) = @_;
	return undef if !defined $input || ref($input) || $input eq '';
	
	if ($input =~ /^values?$/i) {
		$self->{sort} = 'value';
		return $self;
	} elsif ($input =~ /^counts?$/i) {
		$self->{sort} = 'count';
		return $self;
	} elsif ($input =~ /^(first|occur(rence)?s?)$/i) {
		$self->{sort} = 'first';
		return $self;
	} elsif ($input =~ /^last$/i) {
		$self->{sort} = 'last';
		return $self;
	}
	
	return undef;
}

sub _extract_order {
	my ($self, $input) = @_;
	return undef if !defined $input || ref($input) || $input eq '';
	
	if ($input =~ /^asc/i) {
		$self->{order} = 'asc';
		return $self;
	} elsif ($input =~ /^desc$/i) {
		$self->{order} = 'desc';
		return $self;
	}
	
	return undef;
}

sub _extract_pos {
	my ($self, $input) = @_;
	return undef if !defined $input;
	
	if (ref $input eq 'ARRAY') {
		$self->{pos} ||= [];
		push @{$self->{pos}}, @$input;
		return $self;
	} elsif ($input =~ /^-?\d+$/) {
		$self->{pos} ||= [];
		push @{$self->{pos}}, $input;
		return $self;
	}
	
	return undef;
}

sub _extract_key {
	my ($self, $input) = @_;
	return undef if !defined $input;
	
	$self->{key} ||= [];
	push @{$self->{key}}, (ref($input) eq 'ARRAY' ? @$input : ($input));
	return $self;
}

1;
