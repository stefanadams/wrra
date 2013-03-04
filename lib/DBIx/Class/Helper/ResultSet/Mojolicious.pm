package DBIx::Class::Helper::ResultSet::Mojolicious;
{
  $DBIx::Class::Helper::ResultSet::Mojolicious::VERSION = '0.1.0';
}

use strict;
use warnings;

sub config { shift->result_source->schema->config }
sub session { shift->result_source->schema->session }
#sub stash { shift->result_source->schema->stash }
#sub param { shift->result_source->schema->param }
#sub postdata { shift->result_source->schema->postdata }
#sub request { shift->result_source->schema->request }

1;
