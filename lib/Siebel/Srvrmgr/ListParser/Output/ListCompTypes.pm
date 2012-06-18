package Siebel::Srvrmgr::ListParser::Output::ListCompTypes;
use Moose;

=pod

=head1 NAME

Siebel::Srvrmgr::ListParser::Output::ListCompTypes - subclass to parse list comp types command

=cut

extends 'Siebel::Srvrmgr::ListParser::Output';

=pod

=head1 SYNOPSIS

See L<Siebel::Srvrmgr::ListParser::Output> for examples.

=head1 DESCRIPTION

This subclass of L<Siebel::Srvrmgr::ListParser::Output> parses the output of the command C<list comp types>.

This is the list configuration of the C<srvrmgr> expected by the module:

	srvrmgr> configure list comp type
		CT_NAME (76):  Component type name
		CT_RUNMODE (31):  Supported run mode
		CT_ALIAS (31):  Component type alias
		CT_DESC_TEXT (251):  Description of component type

If the configuration is not setup as this, the parsing will fail and the module may raise exceptions.

=head1 ATTRIBUTES

=head2 types_attribs

An array reference with all the component types attributes. Each index will be an hash reference with the fields CT_NAME, CT_RUNMODE, CT_ALIAS and CT_DESC_TEXT.

=cut

has 'types_attribs' => (
    is     => 'rw',
    isa    => 'ArrayRef',
    reader => 'get_attribs',
    writer => 'set_attribs'
);

=pod

=head1 METHODS

=head2 get_attribs

Returns the array reference stored in the C<types_attribs> attribute.

=head2 set_attribs

Sets the attribute C<types_attribs>. Expects an array reference as parameter.

=head2 parse

Parses the data stored in the C<raw_data> attribute, setting the C<parsed_lines> attribute.

The C<raw_data> will be set to a reference to an empty array at the end of the process.

=cut

sub parse {

    my $self = shift;

    my $data_ref = $self->get_raw_data();

    my %parsed_lines;

# removing the three last lines Siebel 7.5.3 (one blank line followed by a line amount of lines returned followed by a blank line)
    for ( 1 .. 3 ) {

        pop( @{$data_ref} );

    }

    foreach my $line ( @{$data_ref} ) {

        chomp($line);

      SWITCH: {

            if ( $line =~ /^\-+\s/ ) {    # this is the header line

                my @columns = split( /\s{2}/, $line );

                my $pattern;

                foreach my $column (@columns) {

                    $pattern .= 'A'
                      . ( length($column) + 2 )
                      ; # + 2 because of the spaces after the "---" that will be trimmed

                }

                $self->_set_fields_pattern($pattern);

                last SWITCH;

            }

            if ( $line eq '' ) {

                last SWITCH;

            }

            if ( $line =~ /^CT_NAME\s.*\sCT_DESC_TEXT(\s+)?$/ )
            {    # this is the header

                my @columns = split( /\s{2,}/, $line );

                $self->set_attribs( \@columns );

                last SWITCH;

            }
            else {

                my @fields_values;

                # :TODO:5/1/2012 16:33:37:: copy this check to the other parsers
                if ( defined( $self->get_fields_pattern() ) ) {

                    @fields_values =
                      unpack( $self->get_fields_pattern(), $line );

                }
                else {

                    confess
                      "Cannot continue without having fields pattern defined";

                }

                my $ct_name = $fields_values[0];

                my $list_len = scalar(@fields_values);

                my $columns_ref = $self->get_attribs();

                confess "Could not retrieve the name of the fields"
                  unless ( defined($columns_ref) );

                if (@fields_values) {

                    for ( my $i = 0 ; $i < $list_len ; $i++ ) {

                        $parsed_lines{$ct_name}->{ $columns_ref->[$i] } =
                          $fields_values[$i];

                    }

                }
                else {

                    warn "got nothing\n";

                }

            }

        }

    }

    $self->set_data_parsed( \%parsed_lines );
    $self->set_raw_data( [] );

}

=pod

=head1 SEE ALSO

=over 2

=item *

L<Siebel::Srvrmgr::ListParser::Output>

=item *

L<Moose>

=back

=head1 AUTHOR

Alceu Rodrigues de Freitas Junior, E<lt>arfreitas@cpan.org<E<gt>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2012 of Alceu Rodrigues de Freitas Junior, E<lt>arfreitas@cpan.org<E<gt>

This file is part of Siebel Monitoring Tools.

Siebel Monitoring Tools is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

Siebel Monitoring Tools is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with Siebel Monitoring Tools.  If not, see <http://www.gnu.org/licenses/>.

=cut

no Moose;
__PACKAGE__->meta->make_immutable;
