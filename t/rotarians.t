use Mojo::Base -strict;
use Mojo::Loader;

use Test::More;
use Data::Dumper;

require_ok 'WRRA::Schema';


SKIP : {
    skip "WRRA_DB* environment not set... skipping", 1 unless $ENV{WRRA_DBTYPE} && $ENV{WRRA_DBNAME} && $ENV{WRRA_DBHOST} && $ENV{WRRA_DBUSER} && $ENV{WRRA_DBPASS};

    my $schema;
    eval { $schema = WRRA::Schema->connect("DBI:$ENV{WRRA_DBTYPE}:database=$ENV{WRRA_DBNAME};host=$ENV{WRRA_DBHOST}", $ENV{WRRA_DBUSER}, $ENV{WRRA_DBPASS}) };
    skip "Schema not connected", 1 if not ok !$@, "Schema connected";

    ok ref($schema), 'WRRA::Schema';

    ok $schema->source('Rotarian')->has_relationship('leader');

#    diag join ',', $schema->class('Rotarian');
#    diag join ',', $schema->resultset('Rotarian')->result_class;

#    diag join ',', $schema->source('Rotarian')->name;
#    diag join ',', $schema->source('Rotarian')->relationships;
#    diag join ',', $schema->source('Rotarian')->result_class;
#    diag join ',', $schema->source('Rotarian')->resultset_class;
#    diag Dumper($schema->source('Rotarian')->resultset_attributes);

#    diag join ',', $schema->resultset('Rotarian')->result_source->name;
    diag Dumper($schema->resultset('Rotarian')->search({lastname=>'Adams'})->result_source->schema->resultset('Rotarian')->search({lastname=>'Forget'})->hashref_array);
#    diag join ',', $schema->resultset('Rotarian')->result_source->columns;
#    diag join ',', $schema->resultset('Rotarian')->result_source->relationships;
#    diag Dumper($schema->resultset('Rotarian')->result_source->reverse_relationship_info('donors'));
#    diag join ',', $schema->resultset('Rotarian')->result_source->schema->class('Rotarian');
#    diag join ',', $schema->resultset('Rotarian')->result_source->storage->connected;
#    diag Dumper($schema->resultset('Rotarian')->result_source->relationship_info('leader'));
#    diag join ',', $schema->resultset('Rotarian')->result_source->has_relationship('leader');
#    diag join ',', $schema->resultset('Rotarian')->result_source->related_class('leader');
}

done_testing();
