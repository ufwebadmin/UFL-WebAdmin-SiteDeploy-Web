#!perl

use strict;
use warnings;
use Test::More tests => 10;
use UFL::WebAdmin::SiteDeploy::TestRepository;

use Test::WWW::Mechanize::Catalyst 'UFL::WebAdmin::SiteDeploy::Web';
my $mech = Test::WWW::Mechanize::Catalyst->new;

use_ok('UFL::WebAdmin::SiteDeploy::Web::Controller::Root');

my $TEST_REPO = UFL::WebAdmin::SiteDeploy::TestRepository->new;

$TEST_REPO->init;

my $uri = UFL::WebAdmin::SiteDeploy::Web->model('Repository')->uri;
UFL::WebAdmin::SiteDeploy::Web->model('Repository')->uri($TEST_REPO->repository_uri);

{
    local $ENV{REMOTE_USER} = 'dwc';

    $mech->get_ok('/', 'request for index page');
    $mech->content_like(qr/Name/i, 'appears to contain repository view');
    $mech->content_like(qr/Last updated/i, 'appears to last update information');
    $mech->content_like(qr/Last deployed/i, 'appears to last deployment information');
    $mech->content_like(qr/www.ufl.edu/i, 'repository view contains reference to www.ufl.edu');
    $mech->content_like(qr/www.webadmin.ufl.edu/i, 'repository view contains reference to www.webadmin.ufl.edu');
    $mech->content_unlike(qr/svnnotify.yml/i, 'repository view does not contains reference to the SVN::Notify configuration file');

    $mech->get('/this_does_not_exist');
    $mech->title_like(qr/Not Found/, 'looks like a 404 page');
    is($mech->status, 404, 'status code is correct');
}

# Restore the old URI
UFL::WebAdmin::SiteDeploy::Web->model('Repository')->uri($uri);
