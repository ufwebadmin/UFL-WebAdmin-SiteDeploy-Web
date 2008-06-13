#!perl

use strict;
use warnings;
use Test::More tests => 6;
use UFL::WebAdmin::SiteDeploy::TestRepository;

use Test::WWW::Mechanize::Catalyst 'UFL::WebAdmin::SiteDeploy::Web';
my $mech = Test::WWW::Mechanize::Catalyst->new;

use_ok('UFL::WebAdmin::SiteDeploy::Web::Controller::Root');

my $TEST_REPO = UFL::WebAdmin::SiteDeploy::TestRepository->new;

$TEST_REPO->init;

{
    local $ENV{REMOTE_USER} = 'dwc';
    local UFL::WebAdmin::SiteDeploy::Web->config->{revision_uri_pattern} = 'http://trac.example.org/changeset/%s';

    my $uri = UFL::WebAdmin::SiteDeploy::Web->model('Repository')->uri;
    UFL::WebAdmin::SiteDeploy::Web->model('Repository')->uri($TEST_REPO->repository_uri);

    $mech->get_ok('/sites', 'request for index page');

    $mech->get('/sites/this-does-not-exist.ufl.edu');
    $mech->title_like(qr/Not Found/, 'looks like a 404 page');
    is($mech->status, 404, 'status code is correct');

    $mech->get_ok('/sites/www.ufl.edu');
    $mech->title_like(qr/www.ufl.edu/, 'looks like we are viewing a site');

    # Restore the old URI
    UFL::WebAdmin::SiteDeploy::Web->model('Repository')->uri($uri);

}
