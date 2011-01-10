#!/usr/bin/perl
use strict;
use warnings;
use lib '../chart_ofc2/lib';
use Getopt::Long;
use AnalyseText;
use OutputResults;
use IO::File;

my $out_dir = 'output';
my $args;
GetOptions( 'in=s'     => \$args->{in},
            'output=s' => \$args->{output} );

if( ! $args->{in} || ! -f $args->{in} ){
    die( "in not defined, or not a file\n" );
}
my $analyser = AnalyseText->new();

print "Analyising text...\n";
my $results = $analyser->analyse( $args->{in} );
my $output = OutputResults->new( { results => $results,
                                   out_dir => $out_dir });

$output->text();
$output->ofc2();

print "Finished\n";

