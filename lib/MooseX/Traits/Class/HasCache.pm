package MooseX::Traits::Class::HasCache;
use Moose::Role;

has 'cache' => (
    is => 'rw',
    isa => 'Object',
    predicate => 'has_cache',
);

has 'cache_type' => (
    is => 'rw',
    isa => 'Str',
    predicate => 'has_cache_type',
);

1;
