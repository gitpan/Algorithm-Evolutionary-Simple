# -*- cperl -*-
use Test::More;

use strict;
use warnings;

use lib qw( ../lib lib );

use Sort::Key::Top qw(rnkeytop) ;
use Algorithm::Evolutionary::Simple qw( random_chromosome max_ones 
					get_pool_roulette_wheel get_pool_binary_tournament
					produce_offspring single_generation);

my $length = 32;
my $number_of_strings = 32;

my @population;
my %fitness_of;
for (my $i = 0; $i < $number_of_strings; $i++) {
  $population[$i] = random_chromosome( $length);
  is( length($population[$i]), $length, "Ok length");
   if ( $i > 1 ){
    isnt( $population[$i], $population[$i-1], "Ok random");
  }
  $fitness_of{$population[$i]} = max_ones( $population[$i] );
  my $count_ones = grep( $_ eq 1, split(//, $population[$i]));
  is( $fitness_of{$population[$i]}, $count_ones, "Counting ones" );
}

my @pool = get_pool_roulette_wheel( \@population, \%fitness_of, $number_of_strings );

is ( scalar( @pool ), $number_of_strings, "Pool generation" );

my @new_pop = produce_offspring( \@pool, $number_of_strings );

is ( scalar( @new_pop), $number_of_strings, "New population generation");

map( $fitness_of{$_}?$fitness_of{$_}:($fitness_of{$_} = max_ones( $_)), @new_pop );

my @newest_pop = single_generation( \@new_pop, \%fitness_of );
my @old_best = rnkeytop { $fitness_of{$_} } 1 => @new_pop; # Extract elite
map( $fitness_of{$_}?$fitness_of{$_}:($fitness_of{$_} = max_ones( $_)), @newest_pop );
my @new_best = rnkeytop { $fitness_of{$_} } 1 => @newest_pop; # Extract elite
is ( $fitness_of{$new_best[0]} >= $fitness_of{$old_best[0]}, 1, 
     "Improving fitness $fitness_of{$new_best[0]} >= $fitness_of{$old_best[0]}" );

@pool = get_pool_binary_tournament( \@population, \%fitness_of, $number_of_strings );

is ( scalar( @pool ), $number_of_strings, "Pool generation" );

@new_pop = produce_offspring( \@pool, $number_of_strings );

is ( scalar( @new_pop), $number_of_strings, "New population generation");
done_testing();
