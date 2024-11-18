use strict;
use warnings;
use Test::More;
use YAML::XS::LibYAML;
use Data::Dumper;

my $xs = YAML::XS::LibYAML->new;

my $yaml = <<'EOM';
- &SCALAR foo
- &SEQ [bar]
- &MAP
  key: val

- *SCALAR
- *SEQ
- *MAP
EOM

my @data = $xs->load_string($yaml);
my @exp = (
    (foo => ['bar'], { key => 'val' }) x 2
);
is_deeply $data[0], \@exp, 'load_string';
is $data[0]->[0], $data[0]->[3], 'scalar alias loaded correctly';
is $data[0]->[1], $data[0]->[4], 'sequence alias loaded correctly';
is $data[0]->[2], $data[0]->[5], 'mapping alias loaded correctly';

done_testing;
