package DBIx::Class::Helper::ResultSet::Mojolicious::DateTime;
{
  $DBIx::Class::Helper::ResultSet::Mojolicious::DateTime::VERSION = '0.1.0';
}

use DateTime::Format::MySQL;

use overload '""' => sub { DateTime::Format::MySQL->format_datetime(shift) };

sub datetime { shift->controller->datetime(shift) }

1;
