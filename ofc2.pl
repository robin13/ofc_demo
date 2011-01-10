#!/usr/bin/perl
use strict;
use warnings;
use lib '../chart-ofc2/lib';

use Chart::OFC2;
use Chart::OFC2::Bar;
use Chart::OFC2::Candle;
use IO::File;
use Class::Date qw/now/;

my $make_html = 0;
my $make_data = 1;
my $outfile = '/var/www/default/index.html';
my $data_file = '/var/www/default/chart-data.json';
my $num_days = 5;

my $date = now();

my @days = ();
local $Class::Date::DATE_FORMAT="%Y-%m-%d";

foreach( 1 .. $num_days ){
    push( @days, $date->string );
    $date += '1d';
}

my $chart = Chart::OFC2->new(
    title  => 'Bar chart test',
    x_axis => {
        labels => {
            labels => \@days,
        }
       },
   y_axis_right => {
       'min'         => 0,
       'max'         => 1,
   },
                             x_legend => { text => "Test X" },
    );

my $bar = Chart::OFC2::Candle->new();
$bar->values([ [8, 7, 5, 2 ], [7, 6.6, 4, 2.2 ], { high => 10, top => 7, bottom => 8, low => 3 } ] );
$bar->tip( "#x_label#<br>High: #high#<br>90%: #open#<br>10%: #close#<br>Low: #low#" );

$chart->add_element($bar);

if( $make_html ){
    my $fh = IO::File->new( $outfile, 'w' );
    print { $fh } "<html>\n";
    print { $fh } $chart->render_swf(600, 400, $data_file, 'test-chart') . "\n";
    print { $fh } "</html>\n";
    $fh->close();
}

if( $make_data ){
    my $fh = IO::File->new( $data_file, 'w' );
    print { $fh } $chart->render_chart_data();
    $fh->close();
}

