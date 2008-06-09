#!perl

use strict;
use warnings;
use File::Spec;
use FindBin;
use Test::More tests => 12;

BEGIN {
    use_ok('UFL::WebAdmin::SiteDeploy::Web::Model::Repository');
}

my $REPO_DUMP   = File::Spec->join($FindBin::Bin, 'data', 'repo.dump');
my $SCRATCH_DIR = File::Spec->join($FindBin::Bin, 'var');
my $REPO_DIR    = File::Spec->join($SCRATCH_DIR, 'repo');
my $REPO_URI    = "file://$REPO_DIR";
diag("repo_dir = [$REPO_DIR]");

load_repository($SCRATCH_DIR, $REPO_DIR, $REPO_DUMP);
ok(-d $REPO_DIR, 'repository directory created');

my $repo = UFL::WebAdmin::SiteDeploy::Web::Model::Repository->new(uri => $REPO_URI);
isa_ok($repo, 'Catalyst::Model');
isa_ok($repo, 'UFL::WebAdmin::SiteDeploy::Repository::SVN');
isa_ok($repo, 'UFL::WebAdmin::SiteDeploy::Repository');

isa_ok($repo->uri, 'URI::file');
is($repo->uri, $REPO_URI, "repository URI is $REPO_URI");
is($repo->uri->path, $REPO_DIR, "translated repository path is $REPO_DIR");

isa_ok($repo->client, 'SVN::Client');

my @sites = $repo->sites;
is(scalar @sites, 2, 'got two sites back from the repository');
isa_ok($sites[0], 'UFL::WebAdmin::SiteDeploy::Site');
isa_ok($sites[1], 'UFL::WebAdmin::SiteDeploy::Site');


sub load_repository {
    my ($scratch_dir, $repo_dir, $repo_dump) = @_;

    File::Path::rmtree($scratch_dir) if -d $scratch_dir;

    File::Path::mkpath($scratch_dir);
    system('svnadmin', 'create', $repo_dir);
    qx{svnadmin load "$repo_dir" < "$repo_dump"};
}
