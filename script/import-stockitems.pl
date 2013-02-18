use 5.010;
use FindBin;
use lib "$FindBin::Bin/../lib";
use Data::Dumper;
use WRRA::Schema;
my $schema = WRRA::Schema->connect("DBI:$ENV{WRRA_DBTYPE}:database=$ENV{WRRA_DBNAME};host=$ENV{WRRA_DBHOST}", $ENV{WRRA_DBUSER}, $ENV{WRRA_DBPASS});

my $rs = $schema->resultset("Stockitem");
while ( <> ) {
	warn join ', ', $., $_;
	chomp;
	@_ = split /\t/;
	#print Dumper({year=>2013, category=>$_[3], name=>$_[0], value=>$_[1], cost=>$_[2]});
	$rs->create({year=>2013, category=>$_[3], name=>$_[0], value=>$_[1], cost=>$_[2]});
}
