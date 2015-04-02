#!/usr/bin/perl

use strict;
use v5.14;

use PPI::Document;
use PPI::Dumper;
use PPI::Find;
use Data::Dumper;

my %import;
my $doc = PPI::Document->new($ARGV[0]);

my $use = $doc->find( sub { $_[1]->isa('PPI::Statement::Include') } );
foreach my $u (@$use) {
    my $node = $u->find_first('PPI::Token::QuoteLike::Words');
    next unless $node;
    $import{$u->module} //= [];
    push @{ $import{$u->module} }, $node->literal;
}

my $words = $doc->find( sub { $_[1]->isa('PPI::Token::Word') } );


my @words = map { $_->content } @$words;

my %words;
@words{ @words } = 1;

foreach my $u (keys %import) {
    say $u;
    foreach my $w (@{$import{$u}}) {
        if (exists $words{$w}) {
            say "\t- Found $w";
        }
        else {
            say "\t- Can't find $w";
        }
    }
}
