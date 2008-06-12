#!perl

use strict;
use warnings;
use FindBin;
use Path::Class;
use Test::More tests => 9;
use UFL::WebAdmin::SiteDeploy::TestRepository;

use Test::WWW::Mechanize::Catalyst 'UFL::WebAdmin::SiteDeploy::Web';
my $mech = Test::WWW::Mechanize::Catalyst->new;

use_ok('UFL::WebAdmin::SiteDeploy::Web::Controller::Root');

my $TEST_REPO = UFL::WebAdmin::SiteDeploy::TestRepository->new;

$TEST_REPO->init;

{
    # Set the URI to the test repository
    my $uri = UFL::WebAdmin::SiteDeploy::Web->model('Repository')->uri;
    UFL::WebAdmin::SiteDeploy::Web->model('Repository')->uri($TEST_REPO->repository_uri);

    $mech->get_ok('/', 'request for index page');
    $mech->content_like(qr/Name/i, 'appears to contain repository view');
    $mech->content_like(qr/Revision/i, 'appears to contain repository view');
    $mech->content_like(qr/Created/i, 'appears to contain repository view');
    $mech->content_like(qr/www.ufl.edu/i, 'repository view contains reference to www.ufl.edu');
    $mech->content_like(qr/www.webadmin.ufl.edu/i, 'repository view contains reference to www.webadmin.ufl.edu');

    # Restore the old URI
    UFL::WebAdmin::SiteDeploy::Web->model('Repository')->uri($uri);
}

{
    $mech->get('/this_does_not_exist');
    $mech->title_like(qr/Not Found/, 'looks like a 404 page');
    is($mech->status, 404, 'status code is correct');
}
