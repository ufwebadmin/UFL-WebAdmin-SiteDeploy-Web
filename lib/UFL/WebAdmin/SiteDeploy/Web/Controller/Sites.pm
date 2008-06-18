package UFL::WebAdmin::SiteDeploy::Web::Controller::Sites;

use strict;
use warnings;
use parent qw/Catalyst::Controller/;

=head1 NAME

UFL::WebAdmin::SiteDeploy::Web::Controller::Sites - Controller for managing Web sites

=head1 DESCRIPTION

L<Catalyst> controller for managing sites in
L<UFL::WebAdmin::SiteDeploy::Web>.

=head1 METHODS

=cut

=head2 index 

Redirect to the home page, the list of current sites.

=cut

sub index : Path('') Args(0) {
    my ($self, $c) = @_;

    $c->res->redirect($c->uri_for($c->controller('Root')->action_for('index')));
}

=head2 site

Fetch the specified site from the
L<UFL::WebAdmin::SiteDeploy::Web::Model::Repository>.

=cut

sub site : PathPart('sites') Chained('/') CaptureArgs(1) {
    my ($self, $c, $host) = @_;

    my $site = $c->model('Repository')->site($host);
    $c->detach('/default') unless $site;

    $c->stash(site => $site);
}

=head2 view

Display basic information on the stashed
L<UFL::WebAdmin::SiteDeploy::Site>.

=cut

sub view : PathPart('') Chained('site') Args(0) {
    my ($self, $c) = @_;

    my $site = $c->stash->{site};

    $c->stash(
        update_commits => $site->update_commits,
        deploy_commits => $site->deploy_commits,
        template       => 'sites/view.tt',
    );
}

=head1 AUTHOR

Daniel Westermann-Clark E<lt>dwc@ufl.eduE<gt>

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
