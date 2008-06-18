#!perl

use strict;
use warnings;
use Test::More tests => 15;
use UFL::WebAdmin::SiteDeploy::TestRepository;

use Test::WWW::Mechanize::Catalyst 'UFL::WebAdmin::SiteDeploy::Web';
my $mech = Test::WWW::Mechanize::Catalyst->new;

use_ok('UFL::WebAdmin::SiteDeploy::Web::Controller::Sites');

my $TEST_REPO = UFL::WebAdmin::SiteDeploy::TestRepository->new;

$TEST_REPO->init;

{
    local $ENV{REMOTE_USER} = 'dwc';

    my $uri = UFL::WebAdmin::SiteDeploy::Web->model('Repository')->uri;
    UFL::WebAdmin::SiteDeploy::Web->model('Repository')->uri($TEST_REPO->repository_uri);

    $mech->get_ok('/sites', 'request for index page');

    $mech->get('/sites/this-does-not-exist.ufl.edu');
    $mech->title_like(qr/Not Found/, 'looks like a 404 page');
    is($mech->status, 404, 'status code is correct');

    $mech->get_ok('/sites/www.ufl.edu');
    $mech->title_like(qr/www.ufl.edu/, 'looks like we are viewing a site');
    $mech->content_like(qr/Deploy site/, 'page has a deploy site section');
    $mech->content_like(qr/Recent changes to test/, 'page has a recent updates section');
    $mech->content_like(qr/Add some files/, 'page has a commit message');
    $mech->content_like(qr/Recent releases to production/, 'page has a recent deployments section');
    $mech->content_like(qr/Create a tag/, 'page has a commit message');

    my $message = $0 . ' ' . scalar(localtime);
    my $form = $mech->form_with_fields('message');
    ok($form, 'found a form');
    $mech->set_fields(message => $message);
    $mech->submit;
    $mech->title_like(qr/www.ufl.edu/, 'looks like we are viewing a site');
    $mech->content_like(qr/>6</, 'page appears to have the right revision number');
    $mech->content_like(qr|$message|, 'page contains the commit message');

    # Restore the old URI
    UFL::WebAdmin::SiteDeploy::Web->model('Repository')->uri($uri);

}
