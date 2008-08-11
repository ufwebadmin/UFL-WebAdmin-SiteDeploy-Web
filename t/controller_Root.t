#!perl

use strict;
use warnings;
use Test::More tests => 19;
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
    $mech->content_like(qr/Status/i, 'appears to contain repository view');
    $mech->content_like(qr/Last updated/i, 'appears to last update information');
    $mech->content_like(qr/Last deployed/i, 'appears to last deployment information');
    $mech->content_like(qr|www.ufl.edu(</a>)?</td>\s*<td class="deployed"><a href="http://localhost/sites/www.ufl.edu">Deployed|i, 'repository view contains reference to www.ufl.edu');
    $mech->content_like(qr|Mon, Jun  9, 2008  5:39 PM\s*\((<a\s+[^>]+>)?r2(</a>)?\)|s, 'repository view contains correct update information for www.ufl.edu');
    $mech->content_like(qr|Mon, Jun  9, 2008  5:40 PM\s*\((<a\s+[^>]+>)?r3(</a>)?\)|, 'repository view contains correct deployment information for www.ufl.edu');
    $mech->content_like(qr|www.webadmin.ufl.edu(</a>)?</td>\s*<td class="pending"><a href="http://localhost/sites/www.webadmin.ufl.edu">Pending|i, 'repository view contains reference to www.webadmin.ufl.edu');
    $mech->content_like(qr|Wed, Jun 18, 2008  5:54 PM\s*\((<a\s+[^>]+>)?r6(</a>)?\)|, 'repository view contains correct update information for www.webadmin.ufl.edu');
    $mech->content_like(qr|Mon, Jun  9, 2008  5:40 PM\s*\((<a\s+[^>]+>)?r4(</a>)?\)|, 'repository view contains correct deployment information for www.webadmin.ufl.edu');
    $mech->content_unlike(qr/svnnotify.yml/i, 'repository view does not contains reference to the SVN::Notify configuration file');

    my $message = 'Checking that we reload to the right place ' . scalar(localtime);
    $mech->get_ok('/sites/www.ufl.edu');
    my $form = $mech->form_with_fields('message');
    ok($form, 'found a form');
    $mech->set_fields(message => $message);
    $mech->submit;

    $mech->get_ok('/', 'reloading index page');
    $mech->content_like(qr/$message/, 'found the new commit');

    $mech->get('/this_does_not_exist');
    $mech->title_like(qr/Not Found/, 'looks like a 404 page');
    is($mech->status, 404, 'status code is correct');
}

# Restore the old URI
UFL::WebAdmin::SiteDeploy::Web->model('Repository')->uri($uri);
