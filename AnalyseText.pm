package AnalyseText;
use strict;
use warnings;
use IO::File;
use Data::Dumper;

# This will do some basic analysis on a text file

sub new{
    my $class = shift;
    my $self = {};
    bless $self, $class;
}

# Analyse a text file
sub analyse{
    my $self = shift;
    my $file = shift;

    my $fh = IO::File->new( $file, 'r' );
    if( ! $fh ){
        die( "Could not open in file: $!\n" );
    }

    # Count the lengths of the words, and the number of letters
    my $word_lengths        = {};
    my $letter_distribution = {};
    my $letter_types        = {};
    my $whitespaces         = {};

    my $line;
    while( $line = readline( $fh ) ){
        # Count (and remove) the line end whitespaces
        $whitespaces->{cr} = ( $line =~ s/\r//g ) || 0;
        $whitespaces->{nl} = ( $line =~ s/\n//g ) || 0;

        # Count (and remove) punctuations
        $letter_types->{punctuation} = ( $line =~ s/[.,;:!?]//g );

        # Now we should have a fairly clean line - split out the words
        my @words = split( / /, $line );

        # Count (and remove) the spaces
        $whitespaces->{sp} = ( $line =~ s/ //g ) || 0;

        # Get the letter distribution
        map{ $letter_distribution->{lc($_)}++ } ( $line =~ m/([a-zA-Z])/g );

        $letter_types->{lower}  = ( $line =~ s/[a-z]//g ) || 0;
        $letter_types->{upper}  = ( $line =~ s/[A-Z]//g ) || 0;
        $letter_types->{number} = ( $line =~ s/[0-9]//g ) || 0;
        $letter_types->{other}  = ( $line =~ s/.//g )     || 0;

        # Count the word lengths
        foreach my $word( @words ){
            $word_lengths->{length( $word )}++;
        }
    }
    return { word_lengths        => $word_lengths,
             letter_types        => $letter_types,
             letter_distribution => $letter_distribution,
             whitespaces         => $whitespaces,
         };
}


1;
