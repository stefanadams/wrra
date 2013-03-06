package DBIx::Class::Helper::ResultSet::Mojolicious;
{
  $DBIx::Class::Helper::ResultSet::Mojolicious::VERSION = '0.1.0';
}

sub config { shift->result_source->schema->config }
sub session { shift->result_source->schema->session }

1;
