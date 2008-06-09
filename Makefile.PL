use inc::Module::Install;

name 'UFL-WebAdmin-SiteDeploy-Web';
all_from 'lib/UFL/WebAdmin/SiteDeploy/Web.pm';

requires 'Catalyst::Runtime' => '5.7012';
requires 'Catalyst::Plugin::ConfigLoader';
requires 'Catalyst::Plugin::Static::Simple';
requires 'Catalyst::Action::RenderView';
requires 'parent';
requires 'YAML'; # This should reflect the config file format you've chosen
                 # See Catalyst::Plugin::ConfigLoader for supported formats
catalyst;

install_script glob('script/*.pl');
auto_install;
WriteAll;
