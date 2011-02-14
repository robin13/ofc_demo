package OutputResults;
use strict;
use warnings;
use lib '../chart_ofc2/lib';
use Chart::OFC2;
use Chart::OFC2::Pie;
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
    $self->_write_chart( labels => \@labels,
                         data   => $results->{letter_distribution},
                         name   => 'Letter distribution' );

    @labels = sort{ $a <=> $b } 
      keys( %{ $results->{word_lengths} } );
    $self->_write_chart( labels   => \@labels,
                         data     => $results->{word_lengths},
                         name     => 'Word lengths' );

    @labels = sort{ $results->{letter_types}->{$b} <=> $results->{letter_types}->{$a} }
      keys( %{ $results->{letter_types} } );
    $self->_write_chart( labels      => \@labels,
                         data        => $results->{letter_types},
                         name        => 'Letter types',
                         type        => 'pie', );

    @labels = sort{ $results->{whitespaces}->{$b} <=> $results->{whitespaces}->{$a} }
      keys( %{ $results->{whitespaces} } );
    $self->_write_chart( labels     => \@labels,
                         data       => $results->{whitespaces},
                         name       => 'Whitespaces',
                         type       => 'pie' );
}

sub _write_chart{
    my( $self, %chart_info ) = @_;
    printf "Generating graph for %s\n", $chart_info{name};

    # Find out the best steps so the graph looks nice (no bunched labels)
    my $max = 0;
    my $steps = 1;
    foreach( keys( %{ $chart_info{data} } ) ){
        if( $chart_info{data}->{$_} > $max ){
            $max = $chart_info{data}->{$_};
        }
    }
    while( $max > 10 ){
        $steps *= 10;
        $max /= 10;
    }

    my $chart = undef;
    if( $chart_info{type} && $chart_info{type} eq 'pie' ){
        my @colours = qw{d01f3c 356aa0 C79810 73880A D15600 D15600};
        my @colours_selected;
        while( scalar( @colours_selected ) > scalar( @{ $chart_info{labels} } ) ){
            foreach( 0 .. $#colours ){
                push( @colours_selected, '#' . $colours[$_] );
            }
        }

        $chart = Chart::OFC2->new( title  => $chart_info{name} );
        my $pie = Chart::OFC2::Pie->new(  tip => '#val# of #total#<br>#percent# of 100%' );
        $pie->values( [ map{ $chart_info{data}->{$_} } @{ $chart_info{labels} } ] );
        $pie->values->labels( $chart_info{labels} );
        $pie->values->colours([ '#d01f3c', '#356aa0', '#C79810', '#73880A' ]);
        $chart->add_element( $pie );
    }else{
        $chart = Chart::OFC2->new( 'title'  => $chart_info{name},
                                   'x_axis' => { labels => { labels => $chart_info{labels}, } },
                                   'y_axis' => { min   => 0,
                                                 max   => 'a',
                                                 steps => $steps,
                                            },
                                 );
        my $bar = Chart::OFC2::Bar->new();
        $bar->values( [ map{ $chart_info{data}->{$_} } @{ $chart_info{labels} } ] );
        $chart->add_element( $bar );
    }


    my $chart_name = lc( $chart_info{name} );
    $chart_name =~ s/ /-/g;
    my $outfile = catfile( $self->{out_dir}, $chart_name . '.json' );
printf "Writing %s to %s\n", $chart_info{name}, $outfile;
    my $fh = IO::File->new( $outfile, 'w' );
    print $fh $chart->render_chart_data();
    $fh->close();

}
1;
