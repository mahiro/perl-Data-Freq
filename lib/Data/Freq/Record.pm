use 5.006;
use strict;
use warnings;

package Data::Freq::Record;

=head1 NAME

Data::Freq::Record

=cut

use base 'Exporter';
use Carp qw(croak);
use Date::Parse qw(str2time);

our @EXPORT_OK = qw(logsplit);

=head1 EXPORT

=head2 logsplit

=cut

sub logsplit {
	my $log = shift;
	my @ret = ();
	
	push @ret, $1 while $log =~ m/ (
		" (?: \\" | "" | [^"]  )* " |
		' (?: \\' | '' | [^']  )* ' |
		\[ (?: \\[\[\]] | \[\[ | \]\] | [^\]] )* \] |
		\( (?: \\[\(\)] | \(\( | \)\) | [^\)] )* \) |
		\{ (?: \\[\{\}] | \{\{ | \}\} | [^\}] )* \} |
		\S+
	) /gx;
	
	return @ret;
}

=head1 METHODS

=head2 new

=cut

sub new {
	my ($class, $input) = @_;
	
	my $self = bless {
		init       => undef,
		text       => undef,
		array      => undef,
		hash       => undef,
		date       => undef,
		date_tried => 0,
	}, $class;
	
	if (!ref $input) {
		$self->{text}  = $input;
		$self->{init}  = 'text';
	} elsif (ref $input eq 'ARRAY') {
		$self->{array} = $input;
		$self->{init}  = 'array';
	} elsif (ref $input eq 'HASH') {
		$self->{hash}  = $input;
		$self->{init}  = 'hash';
	} else {
		croak "invalid argument type: ".ref($input);
	}
	
	return $self;
}

=head2 text

=cut

sub text {
	my $self = shift;
	return $self->{text} if defined $self->{text};
	
	if (defined $self->{array}) {
		$self->{text} = $self->{array}[0];
		return $self->{text};
	}
	
	croak "cannot retrieve a text value";
}

=head2 array

=cut

sub array {
	my $self = shift;
	return $self->{array} if defined $self->{array};
	
	if (defined $self->{text}) {
		$self->{array} = [logsplit $self->{text}];
		return $self->{array};
	}
	
	croak "cannot retrieve an array value";
}

=head2 hash

=cut

sub hash {
	my $self = shift;
	return $self->{hash} if defined $self->{hash};
	croak "cannot retrieve a hash value";
}

=head2 date

=cut

sub date {
	my $self = shift;
	return $self->{date} if $self->{date_tried};
	
	$self->{date_tried} = 1;
	
	my $array = eval {$self->array};
	croak $@ if $@;
	
	my $first = 1;
	
	for my $item (@$array) {
		my $str;
		
		if ($item =~ /^ \[ (.*) \] $/x) {
			$str = $1;
		} elsif ($first) {
			if ($item =~ /^ ["'\{\(] (.*) [\)\}'"] $/x) {
				$str = $1;
			} else {
				$str = $item;
			}
		}
		
		if (defined $str) {
			my $t = str2time($str);
			return $self->{date} = $t if defined $t;
		}
		
		$first = 0;
	}
	
	return $self->{date};
}

1;
