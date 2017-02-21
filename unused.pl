#!/usr/bin/perl

use strict;
use v5.14;

use PPI::Document;
use PPI::Dumper;
use PPI::Find;
use Data::Dumper;
use Module::Util qw(find_installed);

my %import;
my $doc = PPI::Document->new($ARGV[0]);

my $use = $doc->find( sub { $_[1]->isa('PPI::Statement::Include') } );
foreach my $u (@$use) {
    $import{$u->module} //= [];
    my $node = $u->find_first('PPI::Token::QuoteLike::Words');
    if ($node) {
      push @{ $import{$u->module} }, $node->literal;
    }
    elsif (my @export = get_exports( $u->module )) {
      push @{ $import{$u->module} }, @export;
    }
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

sub get_exports {
  my ($module) = @_;

  my $doc = PPI::Document->new(find_installed($module));
  my $export = $doc->find_first( sub { $_[1]->isa('PPI::Token::Symbol') && $_[1]->symbol eq '@EXPORT' } );
  return unless $export;

  my $subs = $export->parent->find_first('PPI::Token::QuoteLike::Words');

  return $subs->literal;
}

