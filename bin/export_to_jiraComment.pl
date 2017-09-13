#!/usr/bin/perl
open FF,$ARGV[0];
my @data = <FF>;
close(FF);
open OO,">$ARGV[1]";
my $header = shift @data;
chomp($header);
$header =~ s/,/\|\|/g;
$header =~ s/\r//g;
print OO "||$header||\n";
foreach(@data)
{
        chomp;
        s/\r//g;
        s/,/\|/g;
        print OO "|$_|\n";
}
close(OO);
