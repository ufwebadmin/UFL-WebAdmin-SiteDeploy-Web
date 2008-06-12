use inc::Module::Install;

name 'UFL-WebAdmin-SiteDeploy-Web';
all_from 'lib/UFL/WebAdmin/SiteDeploy/Web.pm';

requires 'Carp';
requires 'Catalyst' => '5.7012';
requires 'Catalyst::Action::RenderView';
requires 'Catalyst::Plugin::Authentication';
requires 'Catalyst::Plugin::ConfigLoader';
requires 'Catalyst::Plugin::StackTrace';
requires 'Catalyst::Plugin::Static::Simple';
requires 'Catalyst::Plugin::Unicode::Encoding';
requires 'Catalyst::View::TT';
requires 'Moose';
requires 'parent';
requires 'UFL::Controller::Authentication' => '0.02';
requires 'UFL::WebAdmin::SiteDeploy' => '0.06';
requires 'UFL::WebAdmin::SiteDeploy::Repository::SVN';
requires 'UFL::WebAdmin::SiteDeploy::Site';
requires 'YAML';

build_requires 'Catalyst::Test';
build_requires 'FindBin';
build_requires 'Path::Class';
build_requires 'SVN::Client';
build_requires 'Test::More';
build_requires 'Test::YAML::Valid';
build_requires 'UFL::WebAdmin::SiteDeploy::TestRepository';

catalyst;

install_script glob('script/*.pl');

WriteAll;
