use 5.006;
use strict;
use warnings;

package Data::Freq;

=head1 NAME

Data::Freq - collect data, count frequency, and make up
a multi-level counting report

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';

use Data::Freq::Field;
use Data::Freq::Node;
use Data::Freq::Record;
use Scalar::Util qw(blessed openhandle);

=head1 SYNOPSIS

    use Data::Freq;
    
    my $data = Data::Freq->new();
    
    while (my $line = <STDIN>) {
        $data->add($line);
    }
    
    $data->output();

=head1 EXAMPLES

=head2 Analyzing an Apache access log

    my $data = Data::Freq->new('date');
    
    while (my $line = <STDIN>) {
        $data->add($line);
    }
    
    $data->output();

The above example will generate a report:

    - 123: 2012-01-01
    - 456: 2012-01-02
    - 789: 2012-01-03
    ...

The date/time value is automatically extracted from the log line,
where the first date/time parsable field enclosed by a pair of brackets C<[...]>
is considered as a date/time field. (L<Date::Parse::str2time()|Date::Parse>)

If the initialization parameters for C<new()> are customized, e.g.

    Data::Freq->new(
        {type => 'date'},           # field spec for level 1
        {type => 'text', pos => 2}, # field spec for level 2
    );
    # assuming the position 2 (third portion, 0-based) is the remote username

then the output will look like this:

    - 123: 2012-01-01
      - 100: user1
      -  20: user2
      -   3: user3
    - 456: 2012-01-02
      - 400: user1
      -  50: user2
      -   6: user3
    ...

Below is another example along this line:

    Data::Freq->new('month', 'day');
    # Level 1: 'month'
    # Level 2: 'day'

with the output:

    - 12300: 2012-01
      - 123: 2012-01-01
      - 456: 2012-01-02
      - 789: 2012-01-03
      ...
    - 45600: 2012-02
      - 456: 2012-02-01
      - 789: 2012-02-02
      ...

=head1 METHODS

=head2 new

Usage:

    Data::Freq->new($field1, $field2, ...);

C<$field1>, C<$field2>, etc. are instances of L<Data::Freq::Field>,
or any valid parameters that can be passed to L<Data::Freq::Field->new()|Data::Freq::Field/new>.

The actual data to be analyzed need to be added by the L<add()|/add> method one by one.

The C<Data::Freq> object maintains the counting results, based on the specified fields.
The first field (C<$field1>) is used to group the added data into the major category.
The next subsequent field (C<$field2>) is for the sub-category under each major group.
Any more subsequent fields are interpreted recursively as sub-sub-category, etc.

If no fields are given to the C<new()> method, one field of the C<text> type will be assumed.

=cut

sub new {
	my $class = shift;
	
	my $fields = [map {
		blessed($_) && $_->isa('Data::Freq::Field') ?
				$_ : Data::Freq::Field->new($_)
	} (@_ ? (@_) : ('text'))];
	
	return bless {
		root   => Data::Freq::Node->new(),
		fields => $fields,
	}, $class;
}

=head2 add

Usage:

    $data->add("A record");
    $data->add("A log line text\n");
    $data->add(['Already', 'split', 'data']);
    $data->add({key1 => 'data1', key2 => 'data2', ...});

Add a record that increments the counting by 1.

The interpretation of the input depends on the type of fields specified in the C<new()> method.
See L<Data::Freq::Field::evaluate()|Data::Freq::Field/evaluate>.

=cut

sub add {
	my $self = shift;
	
	for my $input (@_) {
		my $record = Data::Freq::Record->new($input);
		
		my $node = $self->root;
		$node->{count}++;
		
		for my $field (@{$self->fields}) {
			my $value = $field->evaluate($record);
			last unless defined $value;
			$node = $node->add_subnode($field, $value);
		}
	}
	
	return $self;
}

=head2 output

Usage:

    $data->output();      # print results (default format)
    $data->output(\*OUT); # open handle or IO::* instance (default format)
    $data->output('callback_name');
    $data->output(sub {
        my $node = shift;
        # $node is a Data::Freq::Node instance
    });

=cut

sub output {
	my $self = shift;
	my $out = shift;
	
	if (!defined $out || openhandle($out)) {
		my $fh = $out || \*STDOUT;
		
		$out = sub {
			my $node = shift;
			
			if ($node->depth > 0) {
				$fh->print($node->indent, '- ', $node->format_count, ': ', $node->value, "\n");
			}
		};
	}
	
	$self->traverse(sub {
		my ($node, $children, $recurse, $field) = @_;
		$out->($node, $children, $field);
		$recurse->($_) foreach @$children;
	});
}

=head2 traverse

Usage:

    $data->traverse(sub {
        my ($node, $children, $recurse, $field) = @_;
        
        # Do something with $node before its child nodes
        
        # $children is a sorted list of child nodes, based on $field
        for my $child (@$children) {
        	$recurse->($child); # invoke recursion
        }
        
        # Do something with $node after its child nodes
    });

Example:

   var $field1 = Data::Freq::Field->new({type => 'month'});
   var $field2 = Data::Freq::Field->new({type => 'text', pos => 2});
   var $data = Data::Freq->new($field1, $field2);
   ...

Diagram:

    <Depth: 0>       <Depth: 1>          <Depth: 2>
                      $field1             $field2

    {root (400)}--+--{2012-01 (101)}--+--{user1 (10)}
                  |                   +--{user2 (8)}
                  |                   +--{user3 (7)}
                  |                   ...
                  +--{2012-02 (102)}--+--{user3 (11)}
                  |                   +--{user2 (9)}
                  |                   ...
                  ...

=cut

sub traverse {
	my $self = shift;
	my $callback = shift;
	
	my $fields = $self->fields;
	my $recurse; # separate declaration for closure access
	
	$recurse = sub {
		my $node = shift;
		my $children = [];
		my $field = undef;
		
		if ($field = $fields->[$node->depth]) {
			$children = [values %{$node->children}];
			$children = $field->sort_result($children);
		}
		
		$callback->($node, $children, $recurse, $field);
	};
	
	$recurse->($self->root);
}

=head2 root

=head2 fields

=cut

sub root   {shift->{root  }}
sub fields {shift->{fields}}

=head1 AUTHOR

Mahiro Ando, C<< <mahiro at cpan.org> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-data-freq at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Data-Freq>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Data::Freq

You can also look for information at:

=over 4

=item * RT: CPAN's request tracker (report bugs here)

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Data-Freq>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Data-Freq>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Data-Freq>

=item * Search CPAN

L<http://search.cpan.org/dist/Data-Freq/>

=back

=head1 ACKNOWLEDGEMENTS

=head1 LICENSE AND COPYRIGHT

Copyright 2012 Mahiro Ando.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.

=cut

1; # End of Data::Freq
