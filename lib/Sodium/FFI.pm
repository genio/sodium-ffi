package Sodium::FFI;
use strict;
use warnings;

our $VERSION = '0.001';

use Carp qw(croak);
use Data::Dumper::Concise qw(Dumper);
use Exporter qw(import);

use Alien::Sodium;
use FFI::Platypus;
use Path::Tiny qw(path);
use Sub::Util qw(set_subname);

our @EXPORT_OK = qw();

our $ffi;
BEGIN {
    $ffi = FFI::Platypus->new(api => 1, lib => Alien::Sodium->dynamic_libs);
    $ffi->bundle();
}
$ffi->attach('sodium_version_string' => [] => 'string');

# All of these functions don't need to be gated by version.
$ffi->attach('sodium_library_version_major' => [] => 'int');
$ffi->attach('sodium_library_version_minor' => [] => 'int');

our %function = (
    # char *
    # sodium_bin2hex(char *const hex, const size_t hex_maxlen,
    # const unsigned char *const bin, const size_t bin_len)
    'sodium_bin2hex' => [
        ['string', 'size_t', 'string', 'size_t'] => 'string',
        sub {
            my ($xsub, $bin_string) = @_;
            $bin_string //= '';
            my $bin_len = length($bin_string);
            my $hex_max = $bin_len * 2;

            my $buffer = "\0" x ($hex_max + 1);
            $xsub->($buffer, $hex_max, $bin_string, $bin_len);
            return substr($buffer, 0, $hex_max);
        }
    ],

    # int sodium_hex2bin(
    #    unsigned char *const bin, const size_t bin_maxlen,
    #    const char *const hex, const size_t hex_len,
    #    const char *const ignore, size_t *const bin_len, const char **const hex_end)
    'sodium_hex2bin' => [
        ['string', 'size_t', 'string', 'size_t', 'string', 'size_t *', 'string *'] => 'int',
        sub {
            my ($xsub, $hex_string, %params) = @_;
            $hex_string //= '';
            my $hex_len = length($hex_string);

            # these two are mostly always void/undef
            my $ignore = $params{ignore};
            my $hex_end = $params{hex_end};

            my $bin_max_len = $params{max_len} // 0;
            if ($bin_max_len <= 0) {
                $bin_max_len = $hex_len;
                $bin_max_len = int($hex_len / 2) unless $ignore;
            }
            my $buffer = "\0" x ($hex_len + 1);
            my $bin_len = 0;

            my $ret = $xsub->($buffer, $hex_len, $hex_string, $hex_len, $ignore, \$bin_len, \$hex_end);
            unless ($ret == 0) {
                croak("sodium_hex2bin failed with: $ret");
            }

            return substr($buffer, 0, $bin_max_len) if $bin_max_len < $bin_len;
            return substr($buffer, 0, $bin_len);
        }
    ],
);

our %maybe_function = (
    'sodium_library_minimal' => {
        added => [1,0,12],
        # uint64_t uv_get_constrained_memory(void)
        ffi => [[], 'int'],
        fallback => sub { croak("sodium_library_minimal not implemented until libsodium v1.0.12"); },
    },
);

foreach my $func (keys %function) {
    $ffi->attach($func, @{$function{$func}});
    push @EXPORT_OK, $func;
}

foreach my $func (keys %maybe_function) {
    my $href = $maybe_function{$func};
    if (_version_or_better(@{$href->{added}})) {
        $ffi->attach($func, @{$href->{ffi}});
    }
    else {
        # monkey patch in the subref
        no strict 'refs';
        no warnings 'redefine';
        my $pkg = __PACKAGE__;
        *{"${pkg}::$func"} = set_subname("${pkg}::$func", $href->{fallback});
    }
    push @EXPORT_OK, $func;
}

sub _version_or_better {
    my ($maj, $min, $pat) = @_;
    $maj //= 0;
    $min //= 0;
    $pat //= 0;
    foreach my $partial ($maj, $min, $pat) {
        if ($partial =~ /[^0-9]/) {
            croak("_version_or_better requires 1 - 3 integers representing major, minor and patch numbers");
        }
    }
    # if no number was passed in, then the current version is higher
    return 1 unless ($maj || $min || $pat);

    my $version_string = Sodium::FFI::sodium_version_string();
    croak("No version string") unless $version_string;
    my ($smaj, $smin, $spatch) = split(/\./, $version_string);
    return 0 if $smaj < $maj; # full version behind of requested
    return 1 if $smaj > $maj; # full version ahead of requested
    # now we should be matching major versions
    return 1 unless $min; # if we were only given major, move on
    return 0 if $smin < $min; # same major, lower minor
    return 1 if $smaj > $min; # same major, higher minor
    # now we should be matching major and minor, check patch
    return 1 unless $pat; # move on if we were given maj, min only
    return 0 if $spatch < $pat;
    return 1;
}

1;

__END__


=head1 NAME

Sodium::FFI - FFI implementation of libsodium

=head1 SYNOPSIS

  use strict;

=head1 COPYRIGHT

 Copyright 2020 Chase Whitener. All rights reserved.

This library is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=cut
