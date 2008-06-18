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
        revision       => $site->project->head_revision,
        deploy_commits => $site->deploy_commits,
        template       => 'sites/view.tt',
    );
}

=head2 deploy

Deploy the stashed L<UFL::WebAdmin::SiteDeploy::Site> to production.

=cut

sub deploy : PathPart Chained('site') Args(0) {
    my ($self, $c) = @_;

    my $site = $c->stash->{site};
    my $return_uri = $c->uri_for($self->action_for('view'), [ $site->id ]);

    my $revision = $c->req->params->{revision};
    $c->detach('/default') unless $revision;

    if ($revision != $site->project->head_revision) {
        $return_uri->query_form(not_current => 1);
        return $c->res->redirect($return_uri);
    }

    my $message = 'Deploying ' . $site->id . ' on behalf of ' . $c->req->user->id . '.';
    if (my $additional_message = $c->req->param('message')) {
        $message .= " Their message:\n\n$additional_message";
    }

    $site->deploy($revision, $message);

    $return_uri->query_form(deployed => 1);
    $c->res->redirect($return_uri);
}

=head1 AUTHOR

Daniel Westermann-Clark E<lt>dwc@ufl.eduE<gt>

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
