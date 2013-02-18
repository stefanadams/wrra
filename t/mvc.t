use Mojo::Base -strict;
use Mojo::Loader;

use Test::More;
use Data::Dumper;

use List::Compare;

require_ok 'WRRA::Schema';

### Config
my @sources = qw/Adcount Ad Ads Alert Bellcount Bellitem Bidder Bid Donor Item Leader Rotarian Stockitem/;

foreach my $pm (grep { $_ ne 'WRRA::Model::Base' } @{Mojo::Loader->search('WRRA::Model')}) {
    eval "use $pm;";
    ok !$@, "Model $pm loaded";
    my $name = $pm;
    $name =~ s/.*:://;
    ok grep(/::$name$/, @{Mojo::Loader->search('WRRA::Schema::ResultModel')}), "Found matching ResultModel $name for Model";
}
foreach my $pm (@{Mojo::Loader->search('WRRA::Schema::ResultModel')}) {
    eval "use $pm;";
    ok !$@, "ResultModel $pm loaded";
    eval "$pm->source_name;";
    ok !$@, "ResultSource for $pm loaded";
    my $name = $pm;
    $name =~ s/.*:://;
    ok grep(/::$name$/, @{Mojo::Loader->search('WRRA::Model')}), "Found matching Model $name for ResultModel";
}
foreach my $pm (@{Mojo::Loader->search('WRRA::Schema::Result')}) {
    eval "use $pm;";
    ok !$@, "ResultSource $pm loaded";
    my $name = $pm;
    $name =~ s/.*:://;
    #ok grep(/::$name$/, @{Mojo::Loader->search('WRRA::Schema::ResultSet')}), "Found matching ResultSet $name for ResultSource";
    diag "No matching ResultSet $name for ResultSource" unless grep(/::$name$/, @{Mojo::Loader->search('WRRA::Schema::ResultSet')});
}
foreach my $pm (@{Mojo::Loader->search('WRRA::Schema::ResultSet')}) {
    eval "use $pm;";
    ok !$@, "ResultSet $pm loaded";
    my $name = $pm;
    $name =~ s/.*:://;
    ok grep(/::$name$/, @{Mojo::Loader->search('WRRA::Schema::Result')}), "Found matching ResultSource $name for ResultSet";
}

SKIP : {
    skip "WRRA_DB* environment not set... skipping", 1 unless $ENV{WRRA_DBTYPE} && $ENV{WRRA_DBNAME} && $ENV{WRRA_DBHOST} && $ENV{WRRA_DBUSER} && $ENV{WRRA_DBPASS};

    my $schema;
    eval { $schema = WRRA::Schema->connect("DBI:$ENV{WRRA_DBTYPE}:database=$ENV{WRRA_DBNAME};host=$ENV{WRRA_DBHOST}", $ENV{WRRA_DBUSER}, $ENV{WRRA_DBPASS}) };
    skip "Schema not connected", 1 if not ok !$@, "Schema connected";

    ok ref($schema), 'WRRA::Schema';

    ok $schema->sources == scalar(@sources), 'Expected '.scalar(@sources).' ResultSources and got '.$schema->sources;
    #diag "$_: ". $schema->class($_) for $schema->sources;

    ok (List::Compare->new([$schema->source('Rotarian')->relationships], [qw/leader donors/])->is_LequivalentR, 'Rotarian relationships (leader donors)');
    ok (List::Compare->new([$schema->source('Donor')->relationships], [qw/rotarian items/])->is_LequivalentR, 'Donor relationships (rotarian items)');
    ok (List::Compare->new([$schema->source('Bidder')->relationships], [qw/bids/])->is_LequivalentR, 'Bidder relationships (bids items*)');
    ok (List::Compare->new([$schema->source('Bid')->relationships], [qw/bidder item/])->is_LequivalentR, 'Bid relationships (bidder item)');
    ok (List::Compare->new([$schema->source('Item')->relationships], [qw/donor stockitem highbid bids/])->is_LequivalentR, 'Item relationships (donor stockitem highbid bids bidders*)');
    ok (List::Compare->new([$schema->source('Leader')->relationships], [qw/rotarians/])->is_LequivalentR, 'Leader relationships (rotarians)');
}

done_testing();
