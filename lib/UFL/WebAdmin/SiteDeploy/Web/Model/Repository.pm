package UFL::WebAdmin::SiteDeploy::Web::Model::Repository;

use Moose;
use UFL::WebAdmin::SiteDeploy::Site;

extends 'UFL::WebAdmin::SiteDeploy::Repository::SVN',
    'Catalyst::Model';

=head1 NAME

UFL::WebAdmin::SiteDeploy::Web::Model::Repository - A repository containing sites

=head1 SYNOPSIS

    my $repo = $c->model('Repository');
    my @sites = $repo->sites;

=head1 DESCRIPTION

This is an interface to a repository containing one or more Web sites,
using Subversion as the revision control system.

=head1 METHODS

=head2 sites

Return a list of L<UFL::WebAdmin::SiteDeploy::Site>s stored in this
repository.

=cut

sub sites {
    my ($self) = @_;

    my $contents = $self->client->ls($self->uri, 'HEAD', 0);

    my @sites = map {
        UFL::WebAdmin::SiteDeploy::Site->new(uri => $_)
    } keys %$contents;

    return @sites;
}

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
