package Siebel::Srvrmgr::Daemon::Action::LoadPreferences;

=pod
=head1 NAME

Siebel::Srvrmgr::Daemon::Action - base class for Siebel::Srvrmgr::Daemon action

=head1 SYNOPSES

=cut

use Moose;
use namespace::autoclean;

extends 'Siebel::Srvrmgr::Daemon::Action';

sub do {

    my $self   = shift;
    my $buffer = shift;

    $self->get_parser()->parse($buffer);

    my $tree = $self->get_parser()->get_parsed_tree();

    foreach my $obj ( @{$tree} ) {

        if ( $obj->isa('Siebel::Srvrmgr::ListParser::Output::LoadPreferences') ) {

            return 1;

        }

    }    # end of foreach block

    return 0;

}

__PACKAGE__->meta->make_immutable;
