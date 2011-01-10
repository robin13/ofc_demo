package OutputResults;
use strict;
use warnings;
use Chart::OFC2;
use File::Spec::Functions;
use Data::Dumper;

sub new{
    my $class = shift;
    my $args = shift;
    my $self = {};

    foreach( qw/results out_dir/ ){
        if( ! $args->{$_} ){
            die( "Required argument $_ not defined" );
        }
        $self->{$_} = $args->{$_};
    }
    if( ! -d $self->{out_dir} ){
        die( "Output directory $self->{out_dir} does not exist" );
    }
    bless $self, $class;
    return $self;
}

sub text{
    my( $self ) = @_;

    my $results = $self->{results};

    my $outfile = catfile( $self->{out_dir}, 'output.txt' );
    print "Printing text output to $outfile\n";
    my $fh = IO::File->new( $outfile, 'w' );
    if( ! $fh ){
        die( "Could not open file $outfile: $!\n" );
    }

    # This is the traditional way: print out the numbers
    my $fmt = "%-12s => %4u\n";
    print { $fh } "Letter distribution in text\n";
    foreach( sort{ $results->{letter_distribution}->{$b} <=> $results->{letter_distribution}->{$a} }
               keys( %{ $results->{letter_distribution} } ) ){
        print { $fh } sprintf $fmt, $_, $results->{letter_distribution}->{$_};
    }
    print { $fh } "\n";

    print { $fh } "Words lengths found in text\n";
    foreach( sort{ $a <=> $b } keys( %{ $results->{word_lengths} } ) ){
        print { $fh } sprintf $fmt, $_, $results->{word_lengths}->{$_};
    }
    print { $fh } "\n";

    print { $fh } "Letter types\n";
    foreach( sort{ $results->{letter_types}->{$b} <=> $results->{letter_types}->{$a} }
               keys( %{ $results->{letter_types} } ) ){
        print { $fh } sprintf $fmt, $_, $results->{letter_types}->{$_};
    }
    print { $fh } "\n";

    print { $fh } "Whitspaces\n";
    foreach( sort{ $results->{whitespaces}->{$b} <=> $results->{whitespaces}->{$a} }
               keys( %{ $results->{whitespaces} } ) ){
        print { $fh } sprintf $fmt, $_, $results->{whitespaces}->{$_};
    }
    $fh->close();
}

sub ofc2{
    my( $self ) = @_;

    my $results = $self->{results};

    # Do the letter distribution
    my @labels = sort{ $results->{letter_distribution}->{$b} <=> $results->{letter_distribution}->{$a} }
      keys( %{ $results->{letter_distribution} } );
    $self->_write_chart( \@labels, $results->{letter_distribution}, 'Letter distribution' );

    @labels = sort{ $a <=> $b } 
      keys( %{ $results->{word_lengths} } );
    $self->_write_chart( \@labels, $results->{word_lengths}, 'Word lengths' );

    @labels = sort{ $results->{letter_types}->{$b} <=> $results->{letter_types}->{$a} }
      keys( %{ $results->{letter_types} } );
    $self->_write_chart( \@labels, $results->{letter_types}, 'Letter types' );

    @labels = sort{ $results->{whitespaces}->{$b} <=> $results->{whitespaces}->{$a} }
      keys( %{ $results->{whitespaces} } );
    $self->_write_chart( \@labels, $results->{whitespaces}, 'Whitespaces' );
}

sub _write_chart{
    my( $self, $labels, $data, $name ) = @_;

    printf "Generating graph for %s\n", $name;

    # Find out the best steps so the graph looks nice (no bunched labels)
    my $max = 0;
    my $steps = 1;
    foreach( keys( %{ $data } ) ){
        if( $data->{$_} > $max ){
            $max = $data->{$_};
        }
    }
    while( $max > 10 ){
        $steps *= 10;
        $max /= 10;
    }

    my $chart = Chart::OFC2->new(
        title  => $name,
        x_axis => {
            labels => {
                labels => $labels,
            },
           },
        y_axis => { min   => 0,
                    max   => 'a',
                    steps => $steps,
                },
       );

    my $bar = Chart::OFC2::Bar->new();
    $bar->values( [ map{ $data->{$_} } @{ $labels } ] );
    $chart->add_element( $bar );

    my $chart_name = lc( $name );
    $chart_name =~ s/ /-/g;
    my $outfile = catfile( $self->{out_dir}, $chart_name . '.json' );
    printf "Writing %s to %s\n", $name, $outfile;
    my $fh = IO::File->new( $outfile, 'w' );
    print $fh $chart->render_chart_data();
    $fh->close();

}
1;
