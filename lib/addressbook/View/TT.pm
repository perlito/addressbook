package addressbook::View::TT;
use Moose;
use namespace::autoclean;

extends 'Catalyst::View::TT';

__PACKAGE__->config(
    TEMPLATE_EXTENSION => '.tt2',
    render_die => 1,
    INCLUDE_PATH => addressbook->path_to( 'root', 'src' ),	
    TIMER => 0,
    WRAPPER => 'wrapper.tt2', 
    
);

=head1 NAME

addressbook::View::TT - TT View for addressbook

=head1 DESCRIPTION

TT View for addressbook.

=head1 SEE ALSO

L<addressbook>

=head1 AUTHOR

tigran,,,

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
