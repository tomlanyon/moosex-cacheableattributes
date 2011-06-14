package MooseX::Traits::Attribute::Cacheable;
use Moose::Role;

has 'cache_builder' => (
    is => 'ro',
    isa => 'CodeRef',
    predicate => 'has_cache_builder',
);

has 'cache_type' => (
    is => 'ro',
    isa => 'Str',
    predicate => 'has_cache_type',
);

has 'cache_key' => (
    is => 'ro',
    isa => 'Str',
    predicate => 'has_cache_key',
);

has 'cache_expiry' => (
    is => 'ro',
    isa => 'Int',
    predicate => 'has_cache_expiry',
    default => 300,
);

after install_accessors => sub {
    my $self = shift;

    # all irrelevant unless we're building attribute values
    return unless $self->has_builder && $self->can( $self->builder );

    # again, irrelevant unless we've been given a cache_builder coderef
    return unless $self->has_cache_builder;

    Moose->throw_error(
        "Attribute cache_key required if using cacheable attributes"
    ) unless $self->has_cache_key;

    Moose->throw_error(
        "Attribute cache_type required if using cacheable attributes"
    ) unless $self->has_cache_type;

    # mixin MooseX::WithCache to the attribute metaclass
    Moose::Util::apply_all_roles(
        $self,
        'MooseX::WithCache', {
            backend => $self->cache_type,
            name    => 'cache',
        },
    );

    $self->associated_metaclass->add_around_method_modifier(
        $self->builder => sub {
            my $orig = shift;
            my $self = shift;
            my $instance = shift;

            if ($self->has_cache and not $self->_cache){
                $self->_cache( $self->cache
        
            if ($self->has_cache){
                if (my $cache_val = $self->cache_get( $self->cache_key )){
                    # found value in the cache
                    return $cache_val;
                } else {
                    # build value and store it in the cache
                    my $built_val = $self->$orig(@_);
                    $self->cache_set(
                        $self->cache_key => $built_val,
                        ( $self->has_cache_expiry ? $self->cache_expiry : () )
                    );
                
                    return $built_val;
                }
            }

            # otherwise, just run the original builder
            return $self->$orig(@_);
        },
    );
}

1;
