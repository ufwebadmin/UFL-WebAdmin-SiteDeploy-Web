#!perl

use strict;
use warnings;
use Test::More tests => 4;

BEGIN {
    use_ok('UFL::WebAdmin::SiteDeploy::Web::Model::Repository');
}

my $repo = UFL::WebAdmin::SiteDeploy::Web::Model::Repository->new;
isa_ok($repo, 'Catalyst::Model');
isa_ok($repo, 'UFL::WebAdmin::SiteDeploy::Repository::SVN');
isa_ok($repo, 'UFL::WebAdmin::SiteDeploy::Repository');
