use strict;
use warnings;
use FindBin;
use Test::More tests => 2;
use Test::YAML::Valid;

yaml_files_ok("$FindBin::Bin/../*.yml");
yaml_files_ok("$FindBin::Bin/../root/*/*.yml");
