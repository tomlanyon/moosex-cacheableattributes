#!/usr/bin/env perl

package Foo;
use Moose -traits => 'HasCache';

has 'foo' => (
    traits => ['Cacheable'],
    cache_key => 'foo',
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


no Moose;


package main;
use strict;
use warnings;

use Cache::FastMmap;

Foo->meta->cache( Cache::FastMmap->new() );

print "\n[", scalar localtime, "] getting foo once...\n";
my $foo1 = Foo->new;
print $foo1->foo, "\n";

print "\n[", scalar localtime, "] getting foo twice...\n";
my $foo2 = Foo->new;
print $foo2->foo, "\n";

print "\n[", scalar localtime, "]\n";


