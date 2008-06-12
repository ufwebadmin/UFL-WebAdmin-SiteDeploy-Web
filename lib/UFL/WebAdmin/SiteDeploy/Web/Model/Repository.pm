package UFL::WebAdmin::SiteDeploy::Web::Model::Repository;

use Moose;
use Carp;
use UFL::WebAdmin::SiteDeploy::Site;

extends 'UFL::WebAdmin::SiteDeploy::Repository::SVN',
    'Catalyst::Model';

=head1 NAME

UFL::WebAdmin::SiteDeploy::Web::Model::Repository - A repository containing sites

=head1 SYNOPSIS

    my $repo = $c->model('Repository');

=head1 DESCRIPTION

This is an interface to a repository containing one or more Web sites,
using Subversion as the revision control system.

=head1 METHODS

=head2 COMPONENT

Return a new instance of the repository given the configuration passed
from L<Catalyst::Component>.

=cut

sub COMPONENT {
    my ($class, $c, $config) = @_;

    return $class->new($config);
}

=head2 site

Return the L<UFL::WebAdmin::SiteDeploy::Site> corresponding to the
specified host. An error is thrown if the site does not exist in the
repository.

    $repository->site('www.ufl.edu');

=cut

sub site {
    my ($self, $host) = @_;

    my $entries = $self->entries;
    croak "Site $host not found in repository " . $self->uri
        unless $entries->{$host};

    my $site = UFL::WebAdmin::SiteDeploy::Site->new(
        uri => "http://$host/",
        repository => $self,
    );

    return $site;
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
