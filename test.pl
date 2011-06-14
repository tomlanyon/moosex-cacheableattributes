#!/usr/bin/env perl

package Foo;
use Moose;

has 'cache' => (
    is => 'rw',
    isa => 'Object',
);

has 'foo' => (
    traits => ['Cacheable'],
    cache_key => 'foo',
    cache => sub { shift->cache },
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

sub get_foo {
    my $self = shift;

    warn "foo is ".$self->foo;
}

no Moose;

package main;

use strict;
use warnings;

use Cache::FastMmap;
my $cache = Cache::FastMmap->new();

print "\n[", scalar localtime, "] getting foo once...\n";
my $foo1 = new Foo( cache => $cache );
$foo1->get_foo;

print "\n[", scalar localtime, "] getting foo twice...\n";
my $foo2 = new Foo( cache => $cache );
$foo2->get_foo;

print "\n[", scalar localtime, "]\n";


