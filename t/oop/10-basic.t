use strict;
use warnings;
use Test::More;
use YAML::XS::LibYAML;
use Data::Dumper;

my $xs = YAML::XS::LibYAML->new( indent => 8 );
note __PACKAGE__.':'.__LINE__.$".Data::Dumper->Dump([\$xs], ['xs']);

is ref $xs, 'YAML::XS::LibYAML', "got YAML::XS object";

my $yaml = <<'EOM';
- foo
- [bar]
- key: val
EOM

my @data = $xs->load_string($yaml);
my @exp = (
    foo => ['bar'], { key => 'val' }
);
is_deeply $data[0], \@exp, 'load_string';
note __PACKAGE__.':'.__LINE__.$".Data::Dumper->Dump([\@data], ['data']);

@data = $xs->load_string('foo: bar');
is_deeply $data[0], { foo => 'bar' }, 'repeated load_string';

my $data = {
    this => {
        is => [ object => ori => "ented" ],
    },
};
$yaml = $xs->dump_string($data);

note $yaml;

my $exp = <<'EOM';
---
this:
        is:
        - object
        - ori
        - ented
EOM

is $yaml, $exp, 'dump';

$yaml = $xs->dump_string(23);
note $yaml;
my $exp = <<'EOM';
--- 23
EOM
is $yaml, $exp, 'repeated dump';

done_testing;
