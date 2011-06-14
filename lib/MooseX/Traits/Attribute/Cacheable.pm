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
);

after install_accessors => sub {
    my $self = shift;

    # all irrelevant unless we're building attribute values
    return unless $self->has_builder;

    # again, irrelevant unless we've been given a cache_builder coderef
    return unless $self->has_cache_builder;

    Moose->throw_error(
        "Attribute cache_key required for Cacheable attribute ".$self->name
    ) unless $self->has_cache_key;

    Moose->throw_error(
        "Attribute cache_type required for Cacheable attribute ".$self->name
    ) unless $self->has_cache_type;

    # mixin MooseX::WithCache to the attribute metaclass
    Moose::Util::apply_all_roles(
        $self,
        'MooseX::WithCache', {
            backend => $self->cache_type,
            name    => 'cache',
        },
    );

    $self->associated_class->add_around_method_modifier(
        $self->builder => sub {
            my $orig = shift;
            my $instance = shift; # the class containing this attribute

            # just run the original builder if we're not doing caching
            return $instance->$orig(@_) unless $self->has_cache_builder;

            # build the cache object if we haven't yet done so
            unless ($self->meta->get_attribute('cache')->has_value($self)){
                # pull the cache object from the calling instance
                # and store as our attribute's cache
                my $cache = $self->cache_builder->( $instance );
                $self->cache( $cache );
            }

            # abort if we still don't have a cache set
            return unless $self->meta->get_attribute('cache')->has_value($self);

            # actually do the cache lookup
            if (my $cache_val = $self->cache_get( $self->cache_key )){
                # found value in the cache
                return $cache_val;
            } else {
                # build value and store it in the cache
                my $built_val = $instance->$orig(@_);
                $self->cache_set(
                    $self->cache_key => $built_val,
                    ( $self->has_cache_expiry ? $self->cache_expiry : () )
                );
            
                return $built_val;
            }
        },
    );
};

1;
