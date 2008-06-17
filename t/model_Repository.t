#!perl

use strict;
use warnings;
use Test::More tests => 15 + 2*4 + 1;
use UFL::WebAdmin::SiteDeploy::TestRepository;

BEGIN {
    use_ok('UFL::WebAdmin::SiteDeploy::Web::Model::Repository');
}

my $TEST_REPO = UFL::WebAdmin::SiteDeploy::TestRepository->new;

my $REPO_DIR = $TEST_REPO->repository_dir;
my $REPO_URI = $TEST_REPO->repository_uri;
diag("repo_dir = [$REPO_DIR], repo_uri = [$REPO_URI]");

$TEST_REPO->init;
ok(-d $REPO_DIR, 'repository directory created');

my $model = UFL::WebAdmin::SiteDeploy::Web::Model::Repository->new(
    type => 'Svn',
    uri => $REPO_URI,
);
isa_ok($model, 'Moose::Object');
isa_ok($model, 'Catalyst::Model');

is($model->type, 'Svn', 'repository type is correct');

isa_ok($model->uri, 'URI::file');
is($model->uri, $REPO_URI, "repository URI is $REPO_URI");
is($model->uri->path, $REPO_DIR, "translated repository path is $REPO_DIR");

isa_ok($model->repository, 'VCI::VCS::Svn::Repository');
isa_ok($model->repository, 'VCI::Abstract::Repository');

my $sites = $model->sites;
is(scalar @$sites, 2, 'repository contains two sites');
isa_ok($sites->[0], 'UFL::WebAdmin::SiteDeploy::Site');
isa_ok($sites->[1], 'UFL::WebAdmin::SiteDeploy::Site');
is($sites->[0]->uri, 'http://www.ufl.edu/', 'first site URI is http://www.ufl.edu/');
is($sites->[1]->uri, 'http://www.webadmin.ufl.edu/', 'second site URI is http://www.webadmin.ufl.edu/');

test_site(
    $model->site('www.ufl.edu'),
    'http://www.ufl.edu/',
    1,
);

test_site(
    $model->site('www.webadmin.ufl.edu'),
    'http://www.webadmin.ufl.edu/',
    1,
);

is($model->site('this-does-not-exist.ufl.edu'), undef, 'nonexistent site is not inflated');

sub test_site {
    my ($site, $uri, $num_tags) = @_;

    isa_ok($site, 'UFL::WebAdmin::SiteDeploy::Site');
    is($site->uri, $uri, "site URL is $uri");

    my $current_tags = $site->deployments;
    is(scalar @$current_tags, $num_tags, "found $num_tags tag" . ($num_tags == 1 ? '' : 's'));

    $site->deploy('HEAD', "Deploying site");

    my $new_tags = $site->deployments;
    is(scalar @$new_tags, $num_tags + 1, "found an additional tag after deploying");
}
