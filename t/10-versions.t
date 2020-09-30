use strict;
use warnings;
use Test::More;
use Sodium::FFI ();

my $ver_string = Sodium::FFI::sodium_version_string();
my $ver_major = Sodium::FFI::sodium_library_version_major();
my $ver_minor = Sodium::FFI::sodium_library_version_minor();
ok($ver_string, "version string: $ver_string");
ok($ver_major, "version major: $ver_major");
ok($ver_minor, "version minor: $ver_minor");
# ok(Sodium::FFI::sodium_library_minimal(), "version minimal");
# ok(defined Sodium::FFI::UV_VERSION_MAJOR, "VERSION MAJOR: ". Sodium::FFI::UV_VERSION_MAJOR);
# ok(defined Sodium::FFI::UV_VERSION_MINOR, "VERSION MINOR: ". Sodium::FFI::UV_VERSION_MINOR);
# ok(defined Sodium::FFI::UV_VERSION_PATCH, "VERSION PATCH: ". Sodium::FFI::UV_VERSION_PATCH);
# ok(defined Sodium::FFI::UV_VERSION_HEX, "VERSION HEX: ". Sodium::FFI::UV_VERSION_HEX);
# ok(defined Sodium::FFI::UV_VERSION_SUFFIX, "VERSION SUFFIX: ". Sodium::FFI::UV_VERSION_SUFFIX);
# ok(defined Sodium::FFI::UV_VERSION_IS_RELEASE, "VERSION IS RELEASE: ". Sodium::FFI::UV_VERSION_IS_RELEASE);

done_testing;
