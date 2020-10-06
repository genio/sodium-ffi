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

my $ffi = FFI::Platypus->new(api => 1);
$ffi->lib(Alien::Sodium->dynamic_libs);
$ffi->attach('sodium_version_string' => [] => 'string');
$ffi->bundle();

# All of these functions don't need to be gated by version.
$ffi->attach('sodium_library_version_major' => [] => 'int');
$ffi->attach('sodium_library_version_minor' => [] => 'int');
$ffi->attach('sodium_library_minimal' => [] => 'int');

our %function = (
);

our %maybe_function = (
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
