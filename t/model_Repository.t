#!perl

use strict;
use warnings;
use SVN::Client;
use Test::More tests => 10 + 2*4 + 1;
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

my $model = UFL::WebAdmin::SiteDeploy::Web::Model::Repository->new(uri => $REPO_URI);
isa_ok($model, 'Catalyst::Model');
isa_ok($model, 'UFL::WebAdmin::SiteDeploy::Repository::SVN');
isa_ok($model, 'UFL::WebAdmin::SiteDeploy::Repository');

isa_ok($model->uri, 'URI::file');
is($model->uri, $REPO_URI, "repository URI is $REPO_URI");
is($model->uri->path, $REPO_DIR, "translated repository path is $REPO_DIR");

isa_ok($model->client, 'SVN::Client');

my $entries = $model->entries;
is(scalar keys %$entries, 3, 'repository contains three entries');

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

    my $client = SVN::Client->new;

    my $host = $site->uri->host;
    my $current_tags = $client->ls("$REPO_URI/$host/tags", 'HEAD', 0);
    is(scalar keys %$current_tags, $num_tags, "found $num_tags tag" . ($num_tags == 1 ? '' : 's'));

    $site->deploy('HEAD', "Deploying site");

    my $new_tags = $client->ls("$REPO_URI/$host/tags", 'HEAD', 0);
    is(scalar keys %$new_tags, $num_tags + 1, "found an additional tag after deploying");
}
