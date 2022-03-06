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
While we also intend to fix up [Crypt::NaCl::Sodium](https://metacpan.org/pod/Crypt%3A%3ANaCl%3A%3ASodium) so that it can use newer versions
of LibSodium, the FFI method is faster to build and release.

# Crypto Auth Functions

LibSodium provides a few
[Crypto Auth Functions](https://doc.libsodium.org/secret-key_cryptography/secret-key_authentication)
to encrypt and verify messages with a key.

## crypto\_auth

```perl
use Sodium::FFI qw(randombytes_buf crypto_auth crypto_auth_keygen);
# First, let's create a key
my $key = crypto_auth_keygen();
# let's encrypt 12 bytes of random data... for fun
my $message = randombytes_buf(12);
my $encrypted_bytes = crypto_auth($message, $key);
say $encrypted_bytes;
```

The [crypto\_auth](https://doc.libsodium.org/secret-key_cryptography/secret-key_authentication#usage)
function encrypts a message using a secret key and returns that message as a string of bytes.

## crypto\_auth\_verify

```perl
use Sodium::FFI qw(randombytes_buf crypto_auth_verify crypto_auth_keygen);

my $message = randombytes_buf(12);
# you'd really need to already have the key, but here
my $key = crypto_auth_keygen();
# your encrypted data would come from a call to crypto_auth
my $encrypted; # assume this is full of bytes
# let's verify
my $boolean = crypto_auth_verify($encrypted, $message, $key);
say $boolean;
```

The [crypto\_auth\_verify](https://doc.libsodium.org/secret-key_cryptography/secret-key_authentication#usage)
function returns a boolean letting us know if the encrypted message and the original message are verified with the
secret key.

## crypto\_auth\_keygen

```perl
use Sodium::FFI qw(crypto_auth_keygen);
my $key = crypto_auth_keygen();
# this could also be written:
use Sodium::FFI qw(randombytes_buf crypto_auth_KEYBYTES);
my $key = randombytes_buf(crypto_auth_KEYBYTES);
```

The [crypto\_auth\_keygen](https://doc.libsodium.org/secret-key_cryptography/secret-key_authentication#usage)
function returns a byte string of `crypto_auth_KEYBYTES` bytes.

# AES256-GCM Crypto Functions

LibSodium provides a few
[AES256-GCM functions](https://doc.libsodium.org/secret-key_cryptography/aead/aes-256-gcm)
to encrypt or decrypt a message with a nonce and key. Note that these functions may not be
available on your hardware and will `croak` in such a case.

## crypto\_aead\_aes256gcm\_decrypt

```perl
use Sodium::FFI qw(
    randombytes_buf crypto_aead_aes256gcm_decrypt
    crypto_aead_aes256gcm_is_available
    crypto_aead_aes256gcm_keygen crypto_aead_aes256gcm_NPUBBYTES
);

if (crypto_aead_aes256gcm_is_available()) {
    # you'd really need to already have the nonce and key, but here
    my $key = crypto_aead_aes256gcm_keygen();
    my $nonce = randombytes_buf(crypto_aead_aes256gcm_NPUBBYTES);
    # your encrypted data would come from a call to crypto_aead_aes256gcm_encrypt
    my $encrypted; # assume this is full of bytes
    # any additional data bytes that were encrypted should also be included
    # they can be undef
    my $additional_data = undef; # we don't care to add anything extra
    # let's decrypt!
    my $decrypted_bytes = crypto_aead_aes256gcm_decrypt(
        $encrypted, $additional_data, $nonce, $key
    );
    say $decrypted_bytes;
}
```

The [crypto\_aead\_aes256gcm\_decrypt](https://doc.libsodium.org/secret-key_cryptography/aead/aes-256-gcm#combined-mode)
function returns a string of bytes after verifying that the ciphertext
includes a valid tag using a secret key, a public nonce, and additional data.

## crypto\_aead\_aes256gcm\_encrypt

```perl
use Sodium::FFI qw(
    randombytes_buf crypto_aead_aes256gcm_encrypt
    crypto_aead_aes256gcm_is_available
    crypto_aead_aes256gcm_keygen crypto_aead_aes256gcm_NPUBBYTES
);
if (crypto_aead_aes256gcm_is_available()) {
    # First, let's create a key and nonce
    my $key = crypto_aead_aes256gcm_keygen();
    my $nonce = randombytes_buf(crypto_aead_aes256gcm_NPUBBYTES);
    # let's encrypt 12 bytes of random data... for fun
    my $message = randombytes_buf(12);
    # any additional data bytes that were encrypted should also be included
    # they can be undef
    my $additional_data = undef; # we don't care to add anything extra
    $additional_data = randombytes_buf(12); # or some random byte string
    my $encrypted_bytes = crypto_aead_aes256gcm_encrypt(
        $message, $additional_data, $nonce, $key
    );
    say $encrypted_bytes;
}
```

The [crypto\_aead\_aes256gcm\_encrypt](https://doc.libsodium.org/secret-key_cryptography/aead/aes-256-gcm#combined-mode)
function encrypts a message using a secret key and a public nonce and returns that message
as a string of bytes.

## crypto\_aead\_aes256gcm\_is\_available

```perl
use Sodium::FFI qw(crypto_aead_aes256gcm_is_available);
if (crypto_aead_aes256gcm_is_available()) {
    # ... encrypt and decrypt some data here
}
```

The [crypto\_aead\_aes256gcm\_is\_available](https://doc.libsodium.org/secret-key_cryptography/aead/aes-256-gcm#limitations)
function returns `1` if the current CPU supports the AES256-GCM implementation, `0` otherwise.

## crypto\_aead\_aes256gcm\_keygen

```perl
use Sodium::FFI qw(
    crypto_aead_aes256gcm_keygen crypto_aead_aes256gcm_is_available
);
if (crypto_aead_aes256gcm_is_available()) {
    my $key = crypto_aead_aes256gcm_keygen();
    # this could also be written:
    use Sodium::FFI qw(randombytes_buf crypto_aead_aes256gcm_KEYBYTES);
    my $key = randombytes_buf(crypto_aead_aes256gcm_KEYBYTES);
}
```

The [crypto\_aead\_aes256gcm\_keygen](https://doc.libsodium.org/secret-key_cryptography/aead/aes-256-gcm#detached-mode)
function returns a byte string of `crypto_aead_aes256gcm_KEYBYTES` bytes.

# chacha20poly1305 Crypto Functions

LibSodium provides a few
[chacha20poly1305 functions](https://doc.libsodium.org/secret-key_cryptography/aead/chacha20-poly1305/original_chacha20-poly1305_construction)
to encrypt or decrypt a message with a nonce and key.

## crypto\_aead\_chacha20poly1305\_decrypt

```perl
use Sodium::FFI qw(
    randombytes_buf crypto_aead_chacha20poly1305_decrypt
    crypto_aead_chacha20poly1305_keygen crypto_aead_chacha20poly1305_NPUBBYTES
);

# you'd really need to already have the nonce and key, but here
my $key = crypto_aead_chacha20poly1305_keygen();
my $nonce = randombytes_buf(crypto_aead_chacha20poly1305_NPUBBYTES);
# your encrypted data would come from a call to crypto_aead_chacha20poly1305_encrypt
my $encrypted; # assume this is full of bytes
# any additional data bytes that were encrypted should also be included
# they can be undef
my $additional_data = undef; # we don't care to add anything extra
# let's decrypt!
my $decrypted_bytes = crypto_aead_chacha20poly1305_decrypt(
    $encrypted, $additional_data, $nonce, $key
);
say $decrypted_bytes;
```

The [crypto\_aead\_chacha20poly1305\_decrypt](https://doc.libsodium.org/secret-key_cryptography/aead/chacha20-poly1305/original_chacha20-poly1305_construction#combined-mode)
function returns a string of bytes after verifying that the ciphertext
includes a valid tag using a secret key, a public nonce, and additional data.

## crypto\_aead\_chacha20poly1305\_encrypt

```perl
use Sodium::FFI qw(
    randombytes_buf crypto_aead_chacha20poly1305_encrypt
    crypto_aead_chacha20poly1305_keygen crypto_aead_chacha20poly1305_NPUBBYTES
);
# First, let's create a key and nonce
my $key = crypto_aead_chacha20poly1305_keygen();
my $nonce = randombytes_buf(crypto_aead_chacha20poly1305_NPUBBYTES);
# let's encrypt 12 bytes of random data... for fun
my $message = randombytes_buf(12);
# any additional data bytes that were encrypted should also be included
# they can be undef
my $additional_data = undef; # we don't care to add anything extra
$additional_data = randombytes_buf(12); # or some random byte string
my $encrypted_bytes = crypto_aead_chacha20poly1305_encrypt(
    $message, $additional_data, $nonce, $key
);
say $encrypted_bytes;
```

The [crypto\_aead\_chacha20poly1305\_encrypt](https://doc.libsodium.org/secret-key_cryptography/aead/chacha20-poly1305/original_chacha20-poly1305_construction#combined-mode)
function encrypts a message using a secret key and a public nonce and returns that message
as a string of bytes.

## crypto\_aead\_chacha20poly1305\_keygen

```perl
use Sodium::FFI qw(
    crypto_aead_chacha20poly1305_keygen
);
my $key = crypto_aead_chacha20poly1305_keygen();
# this could also be written:
use Sodium::FFI qw(randombytes_buf crypto_aead_chacha20poly1305_KEYBYTES);
my $key = randombytes_buf(crypto_aead_chacha20poly1305_KEYBYTES);
```

The [crypto\_aead\_chacha20poly1305\_keygen](https://doc.libsodium.org/secret-key_cryptography/aead/chacha20-poly1305/original_chacha20-poly1305_construction#detached-mode)
function returns a byte string of `crypto_aead_chacha20poly1305_KEYBYTES` bytes.

# chacha20poly1305\_ietf Crypto Functions

LibSodium provides a few
[chacha20poly1305 IETF functions](https://doc.libsodium.org/secret-key_cryptography/aead/chacha20-poly1305/ietf_chacha20-poly1305_construction)
to encrypt or decrypt a message with a nonce and key.

The `IETF` variant of the `ChaCha20-Poly1305` construction can safely encrypt a practically unlimited number of messages,
but individual messages cannot exceed approximately `256 GiB`.

## crypto\_aead\_chacha20poly1305\_ietf\_decrypt

```perl
use Sodium::FFI qw(
    randombytes_buf crypto_aead_chacha20poly1305_ietf_decrypt
    crypto_aead_chacha20poly1305_ietf_keygen crypto_aead_chacha20poly1305_IETF_NPUBBYTES
);

# you'd really need to already have the nonce and key, but here
my $key = crypto_aead_chacha20poly1305_ietf_keygen();
my $nonce = randombytes_buf(crypto_aead_chacha20poly1305_IETF_NPUBBYTES);
# your encrypted data would come from a call to crypto_aead_chacha20poly1305_ietf_encrypt
my $encrypted; # assume this is full of bytes
# any additional data bytes that were encrypted should also be included
# they can be undef
my $additional_data = undef; # we don't care to add anything extra
# let's decrypt!
my $decrypted_bytes = crypto_aead_chacha20poly1305_ietf_decrypt(
    $encrypted, $additional_data, $nonce, $key
);
say $decrypted_bytes;
```

The [crypto\_aead\_chacha20poly1305\_ietf\_decrypt](https://doc.libsodium.org/secret-key_cryptography/aead/chacha20-poly1305/ietf_chacha20-poly1305_construction#combined-mode)
function returns a string of bytes after verifying that the ciphertext
includes a valid tag using a secret key, a public nonce, and additional data.

## crypto\_aead\_chacha20poly1305\_ietf\_encrypt

```perl
use Sodium::FFI qw(
    randombytes_buf crypto_aead_chacha20poly1305_ietf_encrypt
    crypto_aead_chacha20poly1305_ietf_keygen crypto_aead_chacha20poly1305_IETF_NPUBBYTES
);
# First, let's create a key and nonce
my $key = crypto_aead_chacha20poly1305_ietf_keygen();
my $nonce = randombytes_buf(crypto_aead_chacha20poly1305_IETF_NPUBBYTES);
# let's encrypt 12 bytes of random data... for fun
my $message = randombytes_buf(12);
# any additional data bytes that were encrypted should also be included
# they can be undef
my $additional_data = undef; # we don't care to add anything extra
$additional_data = randombytes_buf(12); # or some random byte string
my $encrypted_bytes = crypto_aead_chacha20poly1305_ietf_encrypt(
    $message, $additional_data, $nonce, $key
);
say $encrypted_bytes;
```

The [crypto\_aead\_chacha20poly1305\_ietf\_encrypt](https://doc.libsodium.org/secret-key_cryptography/aead/chacha20-poly1305/ietf_chacha20-poly1305_construction#combined-mode)
function encrypts a message using a secret key and a public nonce and returns that message
as a string of bytes.

## crypto\_aead\_chacha20poly1305\_ietf\_keygen

```perl
use Sodium::FFI qw(
    crypto_aead_chacha20poly1305_ietf_keygen
);
my $key = crypto_aead_chacha20poly1305_ietf_keygen();
# this could also be written:
use Sodium::FFI qw(randombytes_buf crypto_aead_chacha20poly1305_IETF_KEYBYTES);
my $key = randombytes_buf(crypto_aead_chacha20poly1305_IETF_KEYBYTES);
```

The [crypto\_aead\_chacha20poly1305\_ietf\_keygen](https://doc.libsodium.org/secret-key_cryptography/aead/chacha20-poly1305/ietf_chacha20-poly1305_construction#detached-mode)
function returns a byte string of `crypto_aead_chacha20poly1305_IETF_KEYBYTES` bytes.

# Public Key Cryptography - Public Key Signatures

LibSodium provides a few
[Public Key Signature Functions](https://doc.libsodium.org/public-key_cryptography/public-key_signatures)
where a signer generates a key pair (public key and secret key) and appends the secret
key to any number of messages. The one doing the verification will need to know and trust the public key
before messages signed using it can be verified. This is not authenticated encryption.

## crypto\_sign

```perl
use Sodium::FFI qw(crypto_sign_keypair crypto_sign);
my $msg = "Let's sign this and stuff!";
my ($public_key, $secret_key) = crypto_sign_keypair();
my $signed_msg = crypto_sign($msg, $secret_key);
```

The [crypto\_sign](https://doc.libsodium.org/public-key_cryptography/public-key_signatures#combined-mode)
function prepends a signature to an unaltered message.

## crypto\_sign\_keypair

```perl
use Sodium::FFI qw(crypto_sign_keypair);
my ($public_key, $secret_key) = crypto_sign_keypair();
```

The [crypto\_sign\_keypair](https://doc.libsodium.org/public-key_cryptography/public-key_signatures#key-pair-generation)
function randomly generates a secret key and a corresponding public key.

## crypto\_sign\_open

```perl
use Sodium::FFI qw(crypto_sign_open);
# we should have the public key and signed message to open
my $signed_msg = ...;
my $public_key = ...;
my $msg = crypto_sign_open($signed_msg, $public_key);
```

The [crypto\_sign\_open](https://doc.libsodium.org/public-key_cryptography/public-key_signatures#combined-mode)
function prepends a signature to an unaltered message.

## crypto\_sign\_seed\_keypair

```perl
use Sodium::FFI qw(crypto_sign_seed_keypair crypto_sign_SEEDBYTES randombytes_buf);
my $seed = randombytes_buf(crypto_sign_SEEDBYTES);
my ($public_key, $secret_key) = crypto_sign_seed_keypair($seed);
```

The [crypto\_sign\_seed\_keypair](https://doc.libsodium.org/public-key_cryptography/public-key_signatures#key-pair-generation)
function randomly generates a secret key deterministically derived from a single key seed and a corresponding public key.

# Random Number Functions

LibSodium provides a few
[Random Number Generator Functions](https://doc.libsodium.org/generating_random_data)
to assist you in getting your data ready for encryption, decryption, or hashing.

## randombytes\_buf

```perl
use Sodium::FFI qw(randombytes_buf);
my $bytes = randombytes_buf(2);
say $bytes; # contains two bytes of random data
```

The [randombytes\_buf](https://doc.libsodium.org/generating_random_data#usage)
function returns string of random bytes limited by a provided length.

## randombytes\_buf\_deterministic

```perl
use Sodium::FFI qw(randombytes_buf_deterministic);
# create some seed string of length Sodium::FFI::randombytes_SEEDBYTES
my $seed = 'x' x Sodium::FFI::randombytes_SEEDBYTES;
# use that seed to create a random string
my $length = 2;
my $bytes = randombytes_buf_deterministic($length, $seed);
say $bytes; # contains two bytes of random data
```

The [randombytes\_buf\_deterministic](https://doc.libsodium.org/generating_random_data#usage)
function returns string of random bytes limited by a provided length.

It returns a byte string indistinguishable from random bytes without knowing the `$seed`.
For a given seed, this function will always output the same sequence.
The seed string you create should be `randombytes_SEEDBYTES` bytes long.
Up to 256 GB can be produced with a single seed.

## randombytes\_random

```perl
use Sodium::FFI qw(randombytes_random);
my $random = randombytes_random();
say $random;
```

The [randombytes\_random](https://doc.libsodium.org/generating_random_data#usage)
function returns an unpredictable value between `0` and `0xffffffff` (included).

## randombytes\_uniform

```perl
use Sodium::FFI qw(randombytes_uniform);
my $upper_limit = 0xffffffff;
my $random = randombytes_uniform($upper_limit);
say $random;
```

The [randombytes\_uniform](https://doc.libsodium.org/generating_random_data#usage)
function returns an unpredictable value between `0` and `$upper_bound` (excluded).
Unlike `randombytes_random() % $upper_bound`, it guarantees a uniform
distribution of the possible output values even when `$upper_bound` is not a
power of `2`. Note that an `$upper_bound` less than `2` leaves only a single element
to be chosen, namely `0`.

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

## sodium\_base642bin

```perl
use Sodium::FFI qw(sodium_base642bin);
say sodium_base642bin('/wA='); # \377\000
my $variant = Sodium::FFI::sodium_base64_VARIANT_ORIGINAL;
say sodium_base642bin('/wA=', $variant); # \377\000
$variant = Sodium::FFI::sodium_base64_VARIANT_ORIGINAL_NO_PADDING;
say sodium_base642bin('/wA', $variant); # \377\000
$variant = Sodium::FFI::sodium_base64_VARIANT_URLSAFE;
say sodium_base642bin('_wA=', $variant); # \377\000
$variant = Sodium::FFI::sodium_base64_VARIANT_URLSAFE_NO_PADDING;
say sodium_base642bin('_wA', $variant); # \377\000
```

The [sodium\_base642bin](https://doc.libsodium.org/helpers#base64-encoding-decoding)
function takes a base64 encoded string and turns it back into a binary string.

## sodium\_bin2base64

```perl
use Sodium::FFI qw(sodium_bin2base64);
say sodium_bin2base64("\377\000"); # /wA=
my $variant = Sodium::FFI::sodium_base64_VARIANT_ORIGINAL;
say sodium_bin2base64("\377\000", $variant); # /wA=
$variant = Sodium::FFI::sodium_base64_VARIANT_ORIGINAL_NO_PADDING;
say sodium_bin2base64("\377\000", $variant); # /wA
$variant = Sodium::FFI::sodium_base64_VARIANT_URLSAFE;
say sodium_bin2base64("\377\000", $variant); # _wA=
$variant = Sodium::FFI::sodium_base64_VARIANT_URLSAFE_NO_PADDING;
say sodium_bin2base64("\377\000", $variant); # _wA
```

The [sodium\_bin2base64](https://doc.libsodium.org/helpers#base64-encoding-decoding)
function takes a binary string and turns it into a base64 encoded string.

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

## sodium\_is\_zero

```perl
use Sodium::FFI qw(sodium_is_zero);
my $string = "\x00\x00\x01"; # zero zero 1
# entire string not zeros
say sodium_is_zero($string); # 0
# first byte of string is zero
say sodium_is_zero($string, 1); # 1
# first two bytes of string is zero
say sodium_is_zero($string, 2); # 1
```

The [sodium\_is\_zero](https://doc.libsodium.org/helpers#testing-for-all-zeros)
function tests a string for all zeros.

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

## sodium\_memcmp

```perl
use Sodium::FFI qw(sodium_memcmp);
my $string1 = "abcdef";
my $string2 = "abc";
my $match_length = 3;
# string 1 and 2 are equal for the first 3
say sodium_memcmp($string1, $string2, $match_length); # 0
# they are not equal for 4 slots
say sodium_memcmp("abcdef", "abc", 4); # -1
```

The [sodium\_memcmp](https://doc.libsodium.org/helpers#constant-time-test-for-equality)
function compares two strings in constant time.
Results in `-1` when strings 1 and 2 aren't equal.
Results in `0` when strings 1 and 2 are equal.

## sodium\_pad

```perl
use Sodium::FFI qw(sodium_pad);
my $bin_string = "\x01";
my $block_size = 4;
say sodium_pad($bin_string, $block_size); # 01800000
```

The [sodium\_pad](https://doc.libsodium.org/padding) function adds
padding data to a buffer in order to extend its total length to a
multiple of the block size.

## sodium\_sub

```perl
use Sodium::FFI qw(sodium_sub);
my $x = "\x02";
my $y = "\x01";
my $z = sodium_sub($x, $y);
say $x; # \x01
```

The [sodium\_sub](https://doc.libsodium.org/helpers#subtracting-large-numbers)
function subtracts 2 large, unsigned numbers encoded in little-endian format.

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
