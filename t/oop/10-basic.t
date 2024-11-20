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
---
foo: bar
EOM


my @exp = (
    foo => ['bar'], { key => 'val' }
);
my $data = $xs->load_string($yaml);
is_deeply $data, \@exp, 'load_string scalar context';


my @data = $xs->load_string($yaml);
is_deeply $data[0], \@exp, 'load_string list context, first document';
is_deeply $data[1], { foo => 'bar' }, 'load_string list context, second document';
note __PACKAGE__.':'.__LINE__.$".Data::Dumper->Dump([\@data], ['data']);


@data = $xs->load_string('foo: bar');
is_deeply $data[0], { foo => 'bar' }, 'repeated load_string';

$data = {
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
$exp = <<'EOM';
--- 23
EOM
is $yaml, $exp, 'repeated dump';

done_testing;
