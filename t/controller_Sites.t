#!perl

use strict;
use warnings;
use Test::More tests => 1 + 3 + 2*16;
use UFL::WebAdmin::SiteDeploy::TestRepository;

use Test::WWW::Mechanize::Catalyst 'UFL::WebAdmin::SiteDeploy::Web';
my $mech = Test::WWW::Mechanize::Catalyst->new;

use_ok('UFL::WebAdmin::SiteDeploy::Web::Controller::Sites');

my $TEST_REPO = UFL::WebAdmin::SiteDeploy::TestRepository->new;

$TEST_REPO->init;

my $uri = UFL::WebAdmin::SiteDeploy::Web->model('Repository')->uri;
UFL::WebAdmin::SiteDeploy::Web->model('Repository')->uri($TEST_REPO->repository_uri);

# Nonexistent site
{
    local $ENV{REMOTE_USER} = 'dwc';

    $mech->get_ok('/sites', 'request for index page');

    $mech->get('/sites/this-does-not-exist.ufl.edu');
    $mech->title_like(qr/Not Found/, 'looks like a 404 page');
    is($mech->status, 404, 'status code is correct');
}

# Site with no outstanding changes
{
    local $ENV{REMOTE_USER} = 'dwc';

    load_site($mech, 'www.ufl.edu', 0, 'Mon, June  9, 2008  9:40 PM', 'dwc', 'Create a tag');
    deploy_site($mech, 'www.ufl.edu', 7);
}

# Site with outstanding changes
{
    local $ENV{REMOTE_USER} = 'dwc';

    load_site($mech, 'www.webadmin.ufl.edu', 1, 'Mon, June  9, 2008  9:40 PM', 'dwc', 'Create a tag');
    deploy_site($mech, 'www.webadmin.ufl.edu', 8);
}

# Restore the old URI
UFL::WebAdmin::SiteDeploy::Web->model('Repository')->uri($uri);


sub load_site {
    my ($mech, $site, $outstanding_changes, $deploy_date, $author, $message) = @_;

    $mech->get_ok("/sites/$site");
    $mech->title_like(qr/$site/, 'looks like we are viewing a site');
    $mech->content_like(qr/Site information/, 'page has an information section');
    $mech->content_like(qr/Last updated in test/, 'page has a last updated in test section');
    $mech->content_like(qr/Last deployed to production/, 'page has a last deployed to production section');
    $mech->content_like(qr/Status/, 'page has a status section');
    $mech->content_like($outstanding_changes ? qr/Outstanding changes in test/ : qr/No outstanding changes/, ($outstanding_changes ? '' : 'no ') . 'outstanding changes');
    $mech->content_like(qr/Deploy site/, 'page has a deploy site section');
    $mech->content_like(qr|<a href="http://$site/">$site</a>|, 'page has a main site link');
    $mech->content_like(qr/Recent releases to production/, 'page has a recent deployments section');
    $mech->content_like(qr|$deploy_date</td>\s*<td>$author</td>\s*<td>$message|s, 'page has a commit message');
}

sub deploy_site {
    my ($mech, $site, $revision) = @_;

    my $message = $0 . ' ' . scalar(localtime);
    my $form = $mech->form_with_fields('message');
    ok($form, 'found a form');
    $mech->set_fields(message => $message);
    $mech->submit;

    $mech->title_like(qr/$site/, 'looks like we are viewing a site');
    $mech->content_like(qr/Site deployed/, 'site appears to have been deployed');
    $mech->content_like(qr/>$revision</, 'page appears to have the right revision number');
    $mech->content_like(qr|$message|, 'page contains the commit message');
}
