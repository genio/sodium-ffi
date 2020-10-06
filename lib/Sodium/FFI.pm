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
