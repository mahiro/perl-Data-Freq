package Data::Freq;

use 5.006;
use strict;
use warnings;

=head1 NAME

Data::Freq - collect data, count frequency, and generate
multi-level statistical reports

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';

=head1 SYNOPSIS

Example:

    use Data::Freq;

    my $data = Data::Freq->new('ymd');
    my $log = IO::File->new('access.log'); # Apache access log, e.g.

    while (my $line = <$log>) {
        $data->add($line);
    }

    $log->close();

    $data->print();

The above example will generate a report:

    2012-01-01: 123
    2012-01-02: 456
    2012-01-03: 789
    ...

If the initialization parameters are customized:

    Data::Freq->new({type => 'ymd'}, {type => 'text', pos => 3});

then the output will look like:

    2012-01-01: 123
      user1: 100
      user2:  20
      user3:   3
    2012-01-02: 456
      user1: 400
      user2:  50
      user3:   6
    ...

=head1 SUBROUTINES/METHODS

=head2 new

=cut

sub new {
}

=head2 add

=cut

sub add {
}

=head2 print

=cut

sub print {
}

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
