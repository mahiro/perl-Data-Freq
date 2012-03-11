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

Split a text that represents a line in a log file.

A log line is typically whitespace-separated, while anything inside
brackets C<[...]>, braces C<{...}>, parentheses C<(...)>, double quotes C<"...">,
or single quotes C<'...'> is considered as one chunk as a whole
even if whitespaces may be included inside.

The C<logsplit> function takes care of such typical notations.

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
	
	if (!defined $input) {
		$self->{text} = '';
		$self->{init} = 'text';
	} elsif (!ref $input) {
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
	
	return undef;
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
	
	return undef;
}

=head2 hash

=cut

sub hash {
	my $self = shift;
	return $self->{hash} if defined $self->{hash};
	return undef;
}

=head2 date

=cut

sub date {
	my $self = shift;
	return $self->{date} if $self->{date_tried};
	
	$self->{date_tried} = 1;
	
	my $array = $self->array or return undef;
	
	if (my $pos = shift) {
		my $str = "@$array[@$pos]";
		$str =~ s/^ \[ (.*) \] $/$1/x;
		return $self->{date} = $str if $str !~ /\D/;
		return $self->{date} = _str2time($str);
	}
	
	for my $item (@$array) {
		if ($item =~ /^ \[ (.*) \] $/x) {
			my $t = _str2time($1);
			return $self->{date} = $t if defined $t;
		}
	}
	
	return undef;
}

sub _str2time {
	my $str = shift;
	
	my $msec = $1 if $str =~ s/[,\.](\d+)$//;
	my $t = str2time($str);
	return undef unless defined $t;
	
	$t += "0.$msec" if $msec;
	return $t;
}

1;
