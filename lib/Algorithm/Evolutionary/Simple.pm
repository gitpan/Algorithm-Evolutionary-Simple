package Algorithm::Evolutionary::Simple;

use warnings;
use strict;
use Carp;

use version; our $VERSION = qv('0.0.3');
use Carp qw(croak);

use base 'Exporter';
use Sort::Key::Top qw(rnkeytop) ;

our @EXPORT_OK= qw( random_chromosome max_ones spin get_pool_roulette_wheel 
		    produce_offspring mutate crossover );


# Module implementation here
sub random_chromosome {
  my $length = shift;
  my $string = '';
  for (1..$length) {
    $string .= (rand >0.5)?1:0;
  }
  $string;
}

sub max_ones {
  my $str=shift;
  my $count = 0;
  while ($str) {
    $count += chop($str);
  }
  $count;
}

sub get_pool_roulette_wheel {
  my $population = shift || croak "No population here";
  my $fitness_of = shift || croak "need stuff evaluated";
  my $need = shift || croak "I need to know the new population size";

  my $total_fitness = 0;
  map(  $total_fitness += $fitness_of->{$_} , @$population );
  my @best = rnkeytop { $fitness_of->{$_} } 2 => @$population;
  my @wheel = map( $fitness_of->{$_}/$total_fitness, @$population);
  my @slots = spin( \@wheel, scalar(@$population) );
  my @pool;
  my $index = 0;
  do {
    my $p = $index++ % @slots;
    my $copies = $slots[$p];
    for (1..$copies) {
      push @pool, $population->[$p];
    }
  } while ( @pool < $need );
  
  @pool;
}

sub spin {
   my ( $wheel, $slots ) = @_;
   my @slots = map( $_*$slots, @$wheel );
   return @slots;
}

sub produce_offspring {
  my $pool = shift || croak "Pool missing";
  my $offspring_size = shift || croak "Population size needed";
  my @population = ();
  my $population_size = scalar( @$pool );
  for ( my $i = 0; $i < $offspring_size/2; $i++ )  {
    my $first = $pool->[rand($population_size)];
    my $second = $pool->[rand($population_size)];
    
    push @population, crossover( $first, $second );
  }
  map( $_ = mutate($_), @population );
  return @population;
}

sub mutate {
  my $chromosome = shift;
  my $mutation_point = rand( length( $chromosome ));
  substr($chromosome, $mutation_point, 1,
	 ( substr($chromosome, $mutation_point, 1) eq 1 )?0:1 );
  return $chromosome;
}

sub crossover {
  my ($chromosome_1, $chromosome_2) = @_;
  my $length = length( $chromosome_1 );
  my $xover_point_1 = int rand( $length - 2 );
  my $range = 1 + int rand ( $length - $xover_point_1 );
  my $swap_chrom = $chromosome_1;
  substr($chromosome_1, $xover_point_1, $range,
	 substr($chromosome_2, $xover_point_1, $range) );
  substr($chromosome_2, $xover_point_1, $range,
	 substr($swap_chrom, $xover_point_1, $range) );
  return ( $chromosome_1, $chromosome_2 );
}

"010101"; # Magic true value required at end of module
__END__

=head1 NAME

Algorithm::Evolutionary::Simple - A few auxiliary functions to run a simple EA in Perl


=head1 VERSION

This document describes Algorithm::Evolutionary::Simple version 0.0.3


=head1 SYNOPSIS

    use Algorithm::Evolutionary::Simple qw(max_ones random_chromosome);

=head1 DESCRIPTION

Assorted functions needed by an evolutionary algorithm app; just to get started


=head1 INTERFACE 

=head2 random_chromosome( $length )

Creates a binary chromosome, with uniform distribution of 0s and 1s,
and returns it as a string.

=head2 max_ones( $string )

Classical function that returns the number of ones in a binary string.

=head2 spin($wheel, $slots )

Mainly for internal use, $wheel has the normalized probability, and
    $slots  the number of individuals to return.
 
=head2 get_pool_roulette_wheel( $population_arrayref, $fitness_of_hashref, $how_many_I_need )

Obtains a pool of new chromosomes using fitness_proportional selection

=head2 produce_offspring( $population_hashref, $how_many_I_need )

Uses mutation first and then crossover to obtain a new population

=head2 mutate( $string )

Bitflips a  a single point in the binary string

=head2 crossover( $one_string, $another_string )

Applies two-point crossover to both strings, returning them changed

=head1 DIAGNOSTICS

None known

=over

=item C<< Error message here, perhaps with %s placeholders >>

[Description of error here]

=item C<< Another error message here >>

[Description of error here]

[Et cetera, et cetera]

=back


=head1 CONFIGURATION AND ENVIRONMENT

=for author to fill in:
    A full explanation of any configuration system(s) used by the
    module, including the names and locations of any configuration
    files, and the meaning of any environment variables or properties
    that can be set. These descriptions must also include details of any
    configuration language used.
  
Algorithm::Evolutionary::Simple requires no configuration files or environment variables.


=head1 DEPENDENCIES

L<Sort::Key::Top> for efficient sorting. 


=head1 BUGS AND LIMITATIONS

It's intended for simplicity, not flexibility. If you want a
    full-featured evolutionary algorithm library, check L<Algorithm::Evolutionary>

Please report any bugs or feature requests to
C<bug-algorithm-evolutionary-simple@rt.cpan.org>, or through the web interface at
L<http://rt.cpan.org>.


=head1 AUTHOR

JJ Merelo  C<< <jj@merelo.net> >>


=head1 LICENCE AND COPYRIGHT

Copyright (c) 2011, JJ Merelo C<< <jj@merelo.net> >>. All rights reserved.

This module is free software; you can redistribute it and/or
modify it under the same terms as Perl itself. See L<perlartistic>.


=head1 DISCLAIMER OF WARRANTY

BECAUSE THIS SOFTWARE IS LICENSED FREE OF CHARGE, THERE IS NO WARRANTY
FOR THE SOFTWARE, TO THE EXTENT PERMITTED BY APPLICABLE LAW. EXCEPT WHEN
OTHERWISE STATED IN WRITING THE COPYRIGHT HOLDERS AND/OR OTHER PARTIES
PROVIDE THE SOFTWARE "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER
EXPRESSED OR IMPLIED, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE. THE
ENTIRE RISK AS TO THE QUALITY AND PERFORMANCE OF THE SOFTWARE IS WITH
YOU. SHOULD THE SOFTWARE PROVE DEFECTIVE, YOU ASSUME THE COST OF ALL
NECESSARY SERVICING, REPAIR, OR CORRECTION.

IN NO EVENT UNLESS REQUIRED BY APPLICABLE LAW OR AGREED TO IN WRITING
WILL ANY COPYRIGHT HOLDER, OR ANY OTHER PARTY WHO MAY MODIFY AND/OR
REDISTRIBUTE THE SOFTWARE AS PERMITTED BY THE ABOVE LICENCE, BE
LIABLE TO YOU FOR DAMAGES, INCLUDING ANY GENERAL, SPECIAL, INCIDENTAL,
OR CONSEQUENTIAL DAMAGES ARISING OUT OF THE USE OR INABILITY TO USE
THE SOFTWARE (INCLUDING BUT NOT LIMITED TO LOSS OF DATA OR DATA BEING
RENDERED INACCURATE OR LOSSES SUSTAINED BY YOU OR THIRD PARTIES OR A
FAILURE OF THE SOFTWARE TO OPERATE WITH ANY OTHER SOFTWARE), EVEN IF
SUCH HOLDER OR OTHER PARTY HAS BEEN ADVISED OF THE POSSIBILITY OF
SUCH DAMAGES.
