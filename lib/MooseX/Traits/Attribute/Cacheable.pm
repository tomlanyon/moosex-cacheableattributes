package MooseX::Traits::Attribute::Cacheable;
use Moose::Role;

has 'cache_key' => (
    is => 'rw',
    isa => 'Str',
    predicate => 'has_cache_key',
);

has 'cache_expiry' => (
    is => 'rw',
    isa => 'Int',
    predicate => 'has_cache_expiry',
);

after install_accessors => sub {
    my $attribute = shift;

    # all irrelevant unless we're building attribute values
    return unless $attribute->has_builder;

    $attribute->associated_class->add_around_method_modifier(
        $attribute->builder => sub {
            my $orig = shift;
            my $instance = shift; # the class containing this attribute

            my $instance_class = Class::MOP::class_of($instance);

            # just run the original builder if we're not doing caching
            # - must have cache defined on the calling class and a cache
            #   key defined on our attribute instance
            return $instance->$orig(@_)
                unless ($instance_class->has_cache and $attribute->has_cache_key);

            # ensure MooseX::WithCache is applied to the attribute
            my $cache_type = $instance_class->cache_type ?
                $instance_class->cache_type : ref( $instance_class->cache );
            Moose::Util::ensure_all_roles(
                $attribute,
                'MooseX::WithCache', {
                    backend => $cache_type,
                    name    => 'cache',
                }
            );

            # get this after we mixin MX::WithCache, because that changes the class
            my $attribute_class = Class::MOP::class_of($attribute);

            # copy the cache object if we haven't yet done so
            unless ($attribute_class->find_attribute_by_name('cache')->has_value($attribute)){
                # pull the cache object from the calling instance
                # and store as our attribute's cache
                $attribute->cache( $instance_class->cache );
            }

            # abort if we still don't have a cache set
            return unless $attribute_class->find_attribute_by_name('cache')->has_value($attribute);

            # actually do the cache lookup
            if (my $cache_val = $attribute->cache_get( $attribute->cache_key )){
                # found value in the cache
                return $cache_val;
            } else {
                # build value and store it in the cache
                my $built_val = $instance->$orig(@_);
                $attribute->cache_set(
                    $attribute->cache_key => $built_val,
                    ( $attribute->has_cache_expiry ? $attribute->cache_expiry : () )
                );
            
                return $built_val;
            }
        },
    );
};

1;
