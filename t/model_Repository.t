#!perl

use strict;
use warnings;
use FindBin;
use Path::Class;
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

my $repo = UFL::WebAdmin::SiteDeploy::Web::Model::Repository->new(uri => $REPO_URI);
isa_ok($repo, 'Catalyst::Model');
isa_ok($repo, 'UFL::WebAdmin::SiteDeploy::Repository::SVN');
isa_ok($repo, 'UFL::WebAdmin::SiteDeploy::Repository');

isa_ok($repo->uri, 'URI::file');
is($repo->uri, $REPO_URI, "repository URI is $REPO_URI");
is($repo->uri->path, $REPO_DIR, "translated repository path is $REPO_DIR");

isa_ok($repo->client, 'SVN::Client');

my $entries = $repo->entries;
is(scalar keys %$entries, 2, 'repository contains two entries');

test_site(
    $repo->site('www.ufl.edu'),
    'http://www.ufl.edu/',
    1,
);

test_site(
    $repo->site('www.webadmin.ufl.edu'),
    'http://www.webadmin.ufl.edu/',
    1,
);

eval {
    $repo->site('this-does-not-exist.ufl.edu')
};
like($@, qr/Site this-does-not-exist.ufl.edu not found in repository $REPO_URI/, "got an error message for nonexistent site");

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