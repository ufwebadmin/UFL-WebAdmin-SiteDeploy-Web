package UFL::WebAdmin::SiteDeploy::Web::Model::Repository;

use Moose;

extends 'Catalyst::Model',
    'UFL::WebAdmin::SiteDeploy::Repository::SVN';

=head1 NAME

UFL::WebAdmin::SiteDeploy::Web::Model::Repository - A repository containing sites

=head1 SYNOPSIS

    my $repo = $c->model('Repository');

=head1 DESCRIPTION

This is an interface to a repository containing one or more Web sites,
using Subversion as the revision control system.

=head1 SEE ALSO

=over 4

=item * L<Catalyst::Model>

=item * L<UFL::WebAdmin::SiteDeploy::Repository::SVN>

=back

=head1 AUTHOR

Daniel Westermann-Clark E<lt>dwc@ufl.eduE<gt>

=head1 LICENSE

This program is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
