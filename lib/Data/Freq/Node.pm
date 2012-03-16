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

Usage:

    my $root_node = Data::Freq::Node->new();

Constructs a node object in the L<Data::Freq/frequency tree>.

=cut

sub new {
	my ($class, $value, $parent) = @_;
	
	if (ref $class) {
		$parent ||= $class;
		$class = ref $class;
	}
	
	my $depth = $parent ? ($parent->depth + 1) : 0;
	
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

Usage:

    my $child_node = $parent_node->add_subnode('normalized text');

Adds a normalized value and returns the corresponding subnode.

If the normalized text appears for the first time under the parent node,
a new node is created. Otherwise, the existing node is returned with its count
incremented by 1.

=cut

sub add_subnode {
	my ($self, $value) = @_;
	
	my $child = ($self->children->{$value} ||= $self->new($value, $self));
	
	$child->{first} = $self->count if $child->count == 0;
	$child->{last} = $self->count;
	
	$child->{count}++;
	
	if (!defined $self->max || $self->max < $child->count) {
		$self->{max} = $child->count;
	}
	
	return $child;
}

=head2 count

Retrieves the count for the normalized text.

=head2 value

Retrieves the normalized value.

=head2 parent

Retrieves the parent node in the L<Data::Freq/frequency tree>.

For the root node, C<undef> is returned.

=head2 children

Retrieves a hash ref of the raw counting results under this node,
where the key is the normalized text and the value is the corresponding subnode.

=head2 max

Retrieves the maximum count value of the child nodes.

=head2 first

Retrieves the first occurrence index of this node under its parent node.

The index is the count of the parent node at the time this child node is created.

=head2 last

Retrieves the last occurrence index of this node under its parent node.

The index is the count of the parent node at the last time this child node is added or created.

=head2 depth

Retrieves the depth in the L<Data::Freq/frequency tree>.

The depth of the root node is 0.

=cut

sub count    {shift->{count   }}
sub value    {shift->{value   }}
sub parent   {shift->{parent  }}
sub children {shift->{children}}
sub max      {shift->{max     }}
sub first    {shift->{first   }}
sub last     {shift->{last    }}
sub depth    {shift->{depth   }}

=head1 AUTHOR

Mahiro Ando, C<< <mahiro at cpan.org> >>

=head1 LICENSE AND COPYRIGHT

Copyright 2012 Mahiro Ando.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.

=cut

1;
