#!/usr/bin/env perl

package Foo;
use Moose -traits => 'HasCache';

has 'foo' => (
    traits => ['Cacheable'],
    isa => 'Str',
    is  => 'rw',
    lazy_build => 1,
);

has 'bar' => (
    traits => ['Cacheable'],
    isa => 'Str',
    is  => 'rw',
    lazy_build => 1,
);

sub _build_foo {
    warn "building foo";
    sleep 10;
    return join '', map { chr(int(rand(93))+33) } 1..40;
    warn "finished building foo";
}

sub _build_bar {
    warn "building bar";
    sleep 10;
    return join '', map { chr(int(rand(93))+33) } 1..40;
    warn "finished building bar";
}


no Moose;


package main;
use strict;
use warnings;

use Cache::FastMmap;

Foo->meta->cache( Cache::FastMmap->new() );

print "\n[", scalar localtime, "] getting foo1 without cache key...\n";
my $foo1 = Foo->new;
print $foo1->foo, "\n";

print "\n[", scalar localtime, "] getting bar1 with cache key...\n";
$foo1->meta->find_attribute_by_name('bar')->cache_key( 'cached_bar' );
print $foo1->bar, "\n";

print "\n[", scalar localtime, "] getting foo2 with cache key...\n";
my $foo2 = Foo->new;
$foo2->meta->find_attribute_by_name('foo')->cache_key( 'cached_foo' );
print $foo2->foo, "\n";

print "\n[", scalar localtime, "] getting bar2 with cache key...\n";
$foo2->meta->find_attribute_by_name('bar')->cache_key( 'cached_bar' );
print $foo2->bar, "\n";
