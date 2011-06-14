package MooseX::CacheableAttributes;
BEGIN { $MooseX::CacheableAttributes::VERSION = '0.01' }
1;

=pod

=head1 NAME

MooseX::CacheableAttributes;

=head1 VERSION

version 0.01

=head1 SYNOPSIS

    package Record;
    use Moose;

    has 'cache' => (
        is              => 'ro',
        isa             => 'Cache::Memcached',
    );

    has 'data' => (
        traits          => [ 'Cacheable' ],
        is              => 'ro',
        isa             => 'Str',
        cache_builder   => sub { shift->cache },
        cache_key       => 'my-data-key',
        cache_type      => 'Cache::Memcached',
        lazy_build      => 1,
    );

    sub _build_data {
        return $db->intensive_db_query();
    }

    no Moose;
    package main;

    my $cache = Cache::Memcached->new( ... );
    my $record = Record->new( cache => $cache );

    # will query cache for 'my-data-key' before building via _build_data()
    print $record->data;

=head1 DESCRIPTION

MooseX::CacheableAttributes is a Moose attribute trait which adds
MooseX::WithCache caching to your attributes. This allows you to build
attribute values from a compatible cache (e.g. Memcached) rather than
from more intensive sources (e.g. database call, filesytem calls).

=head2 USAGE

The B<Cacheable> trait may be applied to any attribute.  However, only
attributes which have a builder method are susceptible to caching.

Attributes without builder methods will not throw any error or warning
messages but will effectively be a no-op.

Attributes must have a C<cache_builder> option given before they are
able to be read or written to the cache. Even with the B<Cacheable> trait,
attributes without C<cache_builder> will not use the cache.

=head2 ATTRIBUTE OPTIONS

Once the Cacheable trait is applied to your attribute, the following options are
available:

=over 4

=item cache_builder

A coderef executed at run-time; should return a cache object compatible with
L<MooseX::WithCache>.

=item cache_type

The type of cache object your C<cache_builder> should return. Must be a
L<MooseX::WithCache> compatible cache type. This option is required
when C<cache_builder> is specified.

=item cache_key

The key to use for the cache lookup. Required when C<cache_builder> is
specified.

=back

=head1 SEE ALSO

See also L<MooseX::WithCache>.

=head1 AUTHOR

Tom Lanyon <dec@cpan.org>

=head1 LICENSE

This is free software; you can redistribute it and/or modify it under
the same terms as Perl itself.

=cut
