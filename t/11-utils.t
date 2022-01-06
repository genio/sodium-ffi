use strict;
use warnings;
use Test::More;
use Sodium::FFI qw(
    sodium_add sodium_bin2hex sodium_compare sodium_hex2bin sodium_increment
    sodium_library_minimal sodium_pad sodium_unpad
);

# diag("SIZE_MAX is: " . Sodium::FFI::SIZE_MAX);

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
    is($bin, 'ABC', 'hex2bin: first leg ok');
    my $new_hex = sodium_bin2hex($bin);
    is($new_hex, $hex, 'bin2hex: second leg ok. YAY');
}

# sodium_add, sodium_increment
{
    my $left = "\xFF\xFF\x80\x01\x02\x03\x04\x05\x06\x07\x08";
    sodium_increment($left);
    is(sodium_bin2hex($left), '0000810102030405060708', 'increment, bin2hex: Got the right answer');
    my $right = "\x01\x02\x03\x04\x05\x06\x07\x08\xFA\xFB\xFC";
    sodium_add($left, $right);
    is(sodium_bin2hex($left), '0102840507090b0d000305', 'add, bin2hex: Got the right answer');
}

# sodium_compare
SKIP: {
    skip('sodium_compare implemented in libsodium >= v1.0.4', 3) unless Sodium::FFI::_version_or_better(1, 0, 4);
    my $v1 = "\x01\x02\x03\x04\x05\x06\x07\x08\x09\x0A\x0B\x0C\x0D\x0E\x0F\x10\x11\x12\x13\x14\x15\x16\x17\x18\x19\x1A\x1B\x1C\x1D\x1E\x1F";
    my $v2 = "\x02\x02\x03\x04\x05\x06\x07\x08\x09\x0A\x0B\x0C\x0D\x0E\x0F\x10\x11\x12\x13\x14\x15\x16\x17\x18\x19\x1A\x1B\x1C\x1D\x1E\x1F";
    is(sodium_compare($v1, $v2), -1, 'sodium_compare: v1 < v2');
    sodium_increment($v1);
    is(sodium_compare($v1, $v2), 0, 'sodium_compare: increment sets v1 == v2');
    sodium_increment($v1);
    is(sodium_compare($v1, $v2), 1, 'sodium_compare: increment sets v1 > v2');
};

# sodium_pad
SKIP: {
    skip('sodium_pad implemented in libsodium >= v1.0.14', 2) unless Sodium::FFI::_version_or_better(1, 0, 14);
    my $str = 'xyz';
    my $str_padded = sodium_pad($str, 16);
    is(sodium_bin2hex($str_padded), '78797a80000000000000000000000000', 'sodium_pad: looks right');
    is(sodium_unpad($str_padded, 16), $str, 'sodium_unpad: round trip is good');
};

# sodium_library_minimal
SKIP: {
    skip('sodium_library_minimal implemented in libsodium >= v1.0.12', 1) unless Sodium::FFI::_version_or_better(1, 0, 12);
    is(sodium_library_minimal, Sodium::FFI::SODIUM_LIBRARY_MINIMAL, 'sodium_library_minimal: Got the right answer');
};

done_testing;
