use strict;
use warnings;
use Test::More;
use Sodium::FFI qw(sodium_bin2hex sodium_hex2bin);

# hex2bin
is(sodium_hex2bin("414243", ignore => ': '), "ABC", "hex2bin: ignore ': ': 414243 = ABC");
is(sodium_hex2bin("41 42 43", ignore => ': '), "ABC", "hex2bin: ignore ': ': 41 42 43 = ABC");
is(sodium_hex2bin("41:4243", ignore => ': '), "ABC", "hex2bin: ignore ': ': 41:4243 = ABC");

is(sodium_hex2bin("414243", max_len => 2), "AB", "hex2bin: maxlen 2: 414243 = AB");
is(sodium_hex2bin("41:42:43", max_len => 2, ignore => ':'), "AB", "hex2bin: maxlen 2, ignore ':': 414243 = AB");
is(sodium_hex2bin("41 42 43", max_len => 1), "A", "hex2bin: maxlen 2: 41 42 43 = A");

my $hex = "Cafe : 6942";
my $bin = sodium_hex2bin($hex, max_len => 4, ignore => ': ');
my $readable = '';
$readable .= sprintf('%02x', ord($_)) for split //, $bin;
is($readable, 'cafe6942', "hex2bin: maxlen 4, ignore ': ': readable; Cafe : 6942 = cafe6942");

# hex2bin - bin2hex round trip
{
    my $hex = '414243';
    my $bin = sodium_hex2bin($hex);
    is($bin, 'ABC', 'round-trip: first leg ok');
    my $new_hex;
    my $error;
    {
        local $@;
        $error = $@ || 'Error' unless eval {
            $new_hex = sodium_bin2hex($bin);
            1;
        };
    }
    is($new_hex, $hex, 'round-trip: second leg ok. YAY');
    ok(!$error, 'no errors on the round trip');
}

done_testing;
