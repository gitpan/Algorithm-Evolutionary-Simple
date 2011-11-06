use Test::More;

use lib qw( ../lib lib );

use Algorithm::Evolutionary::Simple qw( random_chromosome max_ones 
					get_pool_roulette_wheel produce_offspring );

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
done_testing();
