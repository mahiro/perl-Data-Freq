use 5.006;
use strict;
use warnings;

package Data::Freq::Node;

=head1 NAME

Data::Freq::Node - Represents a node of the result tree constructed by Data::Freq

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';

=head1 METHODS

=head2 new

=cut

sub new {
	my ($class, $value, $depth) = @_;
	my $parent = undef;
	
	if (ref $class) {
		$parent = $class;
		$class = ref $class;
	}
	
	$depth = 0 unless defined $depth;
	
	return bless {
		# For this node's own
		count    => 0,
		value    => $value,
		
		# Parent & children
		parent   => $parent,
		children => {},
		first    => undef,
		last     => undef,
		max      => undef,
		min      => undef,
		
		# Depth from root
		depth    => $depth,
	}, $class;
}

=head2 add_subnode

=cut

sub add_subnode {
	my ($self, $value) = @_;
	
	my $child = ($self->children->{$value} ||=
			$self->new($value, $self->depth + 1));
	
	$child->{first} = $self->count if $child->count == 0;
	$child->{last} = $self->count;
	
	$child->{count}++;
	
	if (!defined $self->max || $self->max < $child->count) {
		$self->{max} = $child->count;
	}
	
	return $child;
}

=head2 count

=head2 value

=head2 parent

=head2 children

=head2 max

=head2 first

=head2 last

=head2 depth

=cut

sub count    {shift->{count   }}
sub value    {shift->{value   }}
sub parent   {shift->{parent  }}
sub children {shift->{children}}
sub max      {shift->{max     }}
sub first    {shift->{first   }}
sub last     {shift->{last    }}
sub depth    {shift->{depth   }}

=head2 indent

=cut

sub indent {
	my ($self, $space) = @_;
	$space = '  ' unless defined $space;
	return $space x ($self->depth - 1);
}

=head2 format_count

=cut

sub format_count {
	my $self = shift;
	
	if (my $parent = $self->parent) {
		my $max = $parent->max;
		return sprintf('%'.length("$max").'d', $self->count);
	} else {
		return $self->count;
	}
}

1;
