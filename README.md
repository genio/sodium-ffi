# NAME

Sodium::FFI - FFI implementation of libsodium

# SYNOPSIS

```perl
use strict;
use warnings;
use v5.34;

use Sodium::FFI ();

my $text = "1234";
my $padded = Sodium::FFI::pad($text, 16);
say Sodium::FFI::unpad($padded);
```

# DESCRIPTION

[Sodium::FFI](https://metacpan.org/pod/Sodium%3A%3AFFI) is a set of Perl bindings for the [LibSodium](https://doc.libsodium.org/)
C library. These bindings have been created using FFI via [FFI::Platypus](https://metacpan.org/pod/FFI%3A%3APlatypus) to make
building and maintaining the bindings easier than was done via [Crypt::NaCl::Sodium](https://metacpan.org/pod/Crypt%3A%3ANaCl%3A%3ASodium).
While we also intend to fixup [Crypt::NaCl::Sodium](https://metacpan.org/pod/Crypt%3A%3ANaCl%3A%3ASodium) so that it can use newer versions
of LibSodium, the FFI method is faster to build and release.

# Utility/Helper Functions

LibSodium provides a few [Utility/Helper Functions](https://doc.libsodium.org/helpers)
to assist you in getting your data ready for encryption, decryption, or hashing.

## sodium\_add

```perl
use Sodium::FFI qw(sodium_add);
my $left = "111";
$left = sodium_add($left, 111);
say $left; # bbb
```

The [sodium\_add](https://doc.libsodium.org/helpers#adding-large-numbers)
function adds 2 large numbers.

## sodium\_bin2hex

```perl
use Sodium::FFI qw(sodium_bin2hex);
my $binary = "ABC";
my $hex = sodium_bin2hex($binary);
say $hex; # 414243
```

The [sodium\_bin2hex](https://doc.libsodium.org/helpers#hexadecimal-encoding-decoding)
function takes a binary string and turns it into a hex string.

## sodium\_compare

```perl
use Sodium::FFI qw(sodium_compare);
say sodium_compare("\x01", "\x02"); # -1
say sodium_compare("\x02", "\x01"); # 1
say sodium_compare("\x01", "\x01"); # 0
```

The [sodium\_compare](https://doc.libsodium.org/helpers#comparing-large-numbers)
function compares two large numbers encoded in little endian format.
Results in `-1` when `$left < $right`
Results in `0` when `$left eq $right`
Results in `1` when `$left > $right`

## sodium\_hex2bin

```perl
use Sodium::FFI qw(sodium_hex2bin);
my $hex = "414243";
my $bin = sodium_hex2bin($hex);
say $bin; # ABC
```

The [sodium\_hex2bin](https://doc.libsodium.org/helpers#hexadecimal-encoding-decoding)
function takes a hex string and turns it into a binary string.

## sodium\_increment

```perl
use Sodium::FFI qw(sodium_increment);
my $x = "\x01";
$x = sodium_increment($x); # "\x02";
```

The [sodium\_increment](https://doc.libsodium.org/helpers#incrementing-large-numbers)
function takes an arbitrarily long unsigned number and increments it.

## sodium\_library\_minimal

```perl
use Sodium::FFI qw(sodium_library_minimal);
say sodium_library_minimal; # 0 or 1
```

The `sodium_library_minimal` function lets you know if this is a minimal version.

## sodium\_library\_version\_major

```perl
use Sodium::FFI qw(sodium_library_version_major);
say sodium_library_version_major; # 10
```

The `sodium_library_version_major` function returns the major version of the library.

## sodium\_library\_version\_minor

```perl
use Sodium::FFI qw(sodium_library_version_minor);
say sodium_library_version_minor; # 3
```

The `sodium_library_version_minor` function returns the minor version of the library.

## sodium\_pad

```perl
use Sodium::FFI qw(sodium_pad);
my $bin_string = "\x01";
my $block_size = 4;
say sodium_pad($bin_string, $block_size); # 01800000
```

The [sodium\_pad](https://doc.libsodium.org/padding) function adds
padding data to a buffer in order to extend its total length to a
multiple of blocksize.

## sodium\_unpad

```perl
use Sodium::FFI qw(sodium_unpad);
my $bin_string = "\x01\x80\x00\x00\x0";
my $block_size = 4;
say sodium_unpad($bin_string, $block_size); # 01
```

The [sodium\_unpad](https://doc.libsodium.org/padding) function
computes the original, unpadded length of a message previously
padded using `sodium_pad`.

## sodium\_version\_string

```perl
use Sodium::FFI qw(sodium_version_string);
say sodium_version_string; # 1.0.18
```

The `sodium_version_string` function returns the stringified version information
for the version of LibSodium that you have installed.

# COPYRIGHT

```
Copyright 2020 Chase Whitener. All rights reserved.
```

This library is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.
