package DBIx::Class::Helper::ResultSet::Mojolicious;
{
  $DBIx::Class::Helper::ResultSet::Mojolicious::VERSION = '0.1.0';
}

sub controller { shift->result_source->schema->controller }
sub config { shift->result_source->schema->config }
sub session { shift->result_source->schema->session }

1;
