use strict;
use warnings;
use Test::More;
use YAML::XS;
use YAML::XS::LibYAML;
use Data::Dumper;
use v5.10;

my $xs = YAML::XS::LibYAML->new();

my $yaml = <<'EOM';
- test
- true
- false
- null
- nums

- 5
- -5
- 0xa
- 0xb
- 0.0

- 3.141
- -5.40
- 0o7
- 0o10
- 56789012345678901234

- 5678901234
- 567890123
- .inf
- .nan
- .23
EOM

my $data = $xs->load_string($yaml);
note __PACKAGE__.':'.__LINE__.$".Data::Dumper->Dump([\$data], ['data']);
#is scalar @$data, 7, 'expected number of elements';
pass "test";

is $data->[0], "test", "test 0";
is $data->[1], "1", "test 1";
is $data->[2], "", "test 2";
is $data->[3], undef, "test 3";
is $data->[4], "nums", "test 4";

is $data->[5], 5, "test 5";
is $data->[6], -5, "test 6";
is $data->[7], 10, "test 7";
is $data->[8], 11, "test 8";
is $data->[9], 0.0, "test 9";

is $data->[10], 3.141, "test 10";
is $data->[11], -5.4, "test 11";
is $data->[12], 7, "test 12";
is $data->[13], 8, "test 13";
is $data->[14], -1, "test 14";

is $data->[15], 5678901234, "test 15";
is $data->[16], 567890123, "test 16";
is $data->[17], "Inf", "test 17";
is $data->[18], "NaN", "test 18";
is $data->[19], .23, "test 19";

use Devel::Peek;
#diag $data->[10];
#Dump $data->[10];
#diag $data->[11];
#Dump $data->[11];
#my $x = "3.141";
#Dump $x;

#diag $data->[-3];
#Dump $data->[-3];
diag $data->[-2];
Dump $data->[-2];
diag $data->[-1];
Dump $data->[-1];

done_testing;

