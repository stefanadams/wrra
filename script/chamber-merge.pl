#!/usr/bin/perl

use strict;
use warnings;
use FindBin qw($Bin);
use lib "$Bin/../lib";
use Schema;
use File::Basename;
use Getopt::Long;

my $host = 'localhost';
my $user = basename $0, '.pl';
my $pass = $user;
GetOptions(
	'host|h=s' => \$host,
	'user|u=s' => \$user,
	'pass|p=s' => \$pass,
);
my $year = pop @ARGV;
my $db = $ARGV[0] || $user;

die "Usage: $0 [-u user] [-p pass] [-h host] [db] year_file\n" unless $year;

$db = Schema->connect({dsn=>"DBI:mysql:database=$db;host=$host",user=>$user,password=>$pass});

my ($update, $new) = (0, 0);
open CSV, "$year.csv" or die "$!\n";
while ( <CSV> ) {
	chomp;
	($_{chamberid}, $_{name}, $_{contact1}, $_{phone}, $_{address}, $_{city}, $_{state}, $_{zip}) = split /\t/, $_;
	$_{phone} =~ s/\D//g;
	$_{phone} = "($1) $2-$3" if $_{phone} =~ /^(\d{3})(\d{3})(\d{4})/;
	($_{zip}) = ($_{zip} =~ /^(\d{5})/);

	if ( my $chamber = $db->resultset('Donor')->find({chamberid => $_{chamberid}}) ) {
		next if join("\t", map { $chamber->$_||'' } qw/chamberid name contact1 phone address city state zip/) eq join("\t", map { $_{$_}||'' } qw/chamberid name contact1 phone address city state zip/);
		print "Updating existing ", $chamber->chamberid, " ($_{chamberid})...\n";
		print join("\t", 'Old: ', map { $chamber->$_||'' } qw/chamberid name contact1 phone address city state zip/), "\n";
		print join("\t", 'New: ', map { $_{$_}||'' } qw/chamberid name contact1 phone address city state zip/), "\n";
		unless ( $ENV{DEBUG} ) {
			$chamber->update({
				name => $_{name},
				contact1 => $_{contact1},
				phone => $_{phone},
				address => $_{address},
				city => $_{city},
				state => $_{state},
				zip => $_{zip},
			}) or do { warn "Error updating.\n"; next; };
		}
		$update++;
	} else {
		print "Adding new undef ($_{chamberid})...\n";
		print join("\t", 'New: ', map { $_{$_}||'' } qw/chamberid name contact1 phone address city state zip/), "\n";
		unless ( $ENV{DEBUG} ) {
			$db->resultset('Donor')->create({
				chamberid => $_{chamberid},
				name => $_{name},
				category => undef,
				contact1 => $_{contact1},
				phone => $_{phone},
				address => $_{address},
				city => $_{city},
				state => $_{state},
				zip => $_{zip},
				solicit => 1,
				comments => "New in $year",
			}) or do { warn "Error inserting.\n"; next; };
		}
		$new++;
	}
}
close CSV;

print "Updated: $update\nNew: $new\n";
