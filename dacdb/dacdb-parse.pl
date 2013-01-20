#!/usr/bin/perl

use strict;
use warnings;
use FindBin qw($Bin);
use lib "$Bin/../lib";
use Schema;
use File::Basename;
use Getopt::Long;

use HTML::TableParser;

my $host = 'localhost';
my $user = basename $0, '.pl';
my $pass = $user;
GetOptions(
        'host|h=s' => \$host,
        'user|u=s' => \$user,
        'pass|p=s' => \$pass,
);
my $html = pop @ARGV;
my $db = $ARGV[0] || $user;

die "Usage: $0 [-u user] [-p pass] [-h host] [db] html_file\n" unless $html;

$db = Schema->connect({dsn=>"DBI:mysql:database=$db;host=$host",user=>$user,password=>$pass});

my @reqs = (
	{
		id => 1,
		row => \&row,
	},
);

my ($update, $new) = (0, 0);
my %dacdb = ();
my %wrra = ();
my $p = new HTML::TableParser([
	{id => 1, row => sub {
		$dacdb{${$_[2]}[10]}=1;
		${$_[2]}[17] =~ /^.*?(\d{3}).*?(\d{3}).*?(\d{4}).*?$/;
		${$_[2]}[17] = $1 && $2 && $3 ? "($1) $2-$3" : '';
		if ( my $r = $db->resultset('Rotarian')->search({'-or' => {rotarian_id => ${$_[2]}[10], first) ) {
			return if join("\t", map { $r->$_||'' } qw/rotarian_id lastname firstname phone email/) eq join("\t", map { ${$_[2]}[$_]||'' } qw/10 1 2 17 19/);
			print "Updating ${$_[2]}[1], ${$_[2]}[2] (${$_[2]}[10])...\n";
			$r->update({
				lastname=>${$_[2]}[1],
				firstname=>${$_[2]}[2],
				phone=>${$_[2]}[17],
				email=>${$_[2]}[19]
			}) unless $ENV{DEBUG};
			$update++;
		} else {
			${$_[2]}[10] = int(rand(1000))+1 unless ${$_[2]}[10] =~ /^\d+$/;
			print "Inserting ${$_[2]}[1], ${$_[2]}[2] (${$_[2]}[10])...\n";
			$db->resultset('Rotarian')->create({
				rotarian_id=>${$_[2]}[10],
				lastname=>${$_[2]}[1],
				firstname=>${$_[2]}[2],
				phone=>${$_[2]}[17],
				email=>${$_[2]}[19]
			}) unless $ENV{DEBUG};
			$new++;
		}
	}}
], { Decode => 1, Trim => 1, Chomp => 1 });
$p->parse_file($html);

my $r = $db->resultset('Rotarian');
while ( $_ = $r->next ) {
	print "Delete: ", $_->lastname, ', ', $_->firstname, "(", $_->id, ")\n" unless $dacdb{$_->id};
}
print STDERR "Updated: $update\nNew: $new\n";
