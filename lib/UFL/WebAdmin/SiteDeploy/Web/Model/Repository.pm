package UFL::WebAdmin::SiteDeploy::Web::Model::Repository;

use Moose;
use Carp;
use UFL::WebAdmin::SiteDeploy::Site;
use UFL::WebAdmin::SiteDeploy::Types;
use VCI;

extends 'Moose::Object', 'Catalyst::Model';

has 'type' => (
    is => 'rw',
    isa => 'Str',
    required => 1,
    trigger => \&_build_repository,
);

has 'uri' => (
    is => 'rw',
    isa => 'URI',
    required => 1,
    coerce => 1,
    trigger => \&_build_repository,
);

has 'repository' => (
    is => 'rw',
    isa => 'VCI::Abstract::Repository',
    lazy_build => 1,
);

sub _build_repository {
    my ($self) = @_;

    my $repository = VCI->connect(
        type => $self->type,
        repo => $self->uri->as_string,
    );

    return $repository;
}

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

    my $self = $class->new($config);

    return $self;
}

=head2 sites

Return an arrayref of L<UFL::WebAdmin::SiteDeploy::Site>s that are
contained in the repository.

    my $sites = $repository->sites;
    print $sites->[0]->uri;

=cut

sub sites {
    my ($self) = @_;

    my @projects = sort {
        $a->name cmp $b->name
    } @{ $self->repository->projects };

    my @sites = map {
        UFL::WebAdmin::SiteDeploy::Site->new(project => $_)
    } @projects;

    return \@sites;
}

=head2 site

Return the L<UFL::WebAdmin::SiteDeploy::Site> corresponding to the
specified host. If the site does not exist, C<undef> is returned.

    $repository->site('www.ufl.edu');

=cut

sub site {
    my ($self, $host) = @_;

    my $project = $self->repository->get_project(name => $host);

    # XXX: Hack to check for site in repository
    eval { $project->head_revision };
    return if $@;

    my $site = UFL::WebAdmin::SiteDeploy::Site->new(project => $project);

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
