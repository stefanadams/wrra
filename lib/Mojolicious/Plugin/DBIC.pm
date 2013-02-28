package Mojolicious::Plugin::DBIC;
use Mojo::Base 'Mojolicious::Plugin';

use Data::Dumper;
sub register {
  my ($self, $app, $conf) = @_;
  my $schema = $conf->{schema} || ref($app).'::Schema';

  my %conf = $app->config->{database} ? (%{$app->config->{database}}) : ();
  my %env = (map { my $env = uc($app->moniker.'_DB'.$_); $_ => $ENV{$env} } grep { my $env = uc($app->moniker.'_DB'.$_); defined $ENV{$env} ? 1 : 0 } qw/type name host user pass/);
  my $db = {
    type => 'mysql',
    name => $conf->{moniker} || $app->moniker || '',
    host => 'localhost',
    user => $conf->{moniker} || $app->moniker || '',
    pass => $conf->{moniker} || $app->moniker || '',
    %conf,
    %env,
  };

  $app->helper(
    db => sub {
      my $c = shift;
      eval "use $schema";
      if ( $@ ) {
        warn "Can't load schema $schema: $@";
        return undef;
      } else {
        return $schema->connect({dsn=>"DBI:$db->{type}:database=".$db->{name}.";host=".$db->{host},user=>$db->{user},password=>$db->{pass}});
      }
    },
  );
}

1;

=head1 NAME

Mojolicious::Plugin::MyStash - Access request as MyStash

=head1 SYNOPSIS

  # Mojolicious
  $self->plugin('MyStash');

  # Mojolicious::Lite
  plugin 'MyStash';

=head1 DESCRIPTION

L<Mojolicious::Plugin::MyStash> accesses request as MyStash for L<Mojolicious>.

=head1 HELPERS

L<Mojolicious::Plugin::MyStash> implements the following helpers.

=head2 json

  %= json 'foo'

=head1 METHODS

L<Mojolicious::Plugin::MyStash> inherits all methods from
L<Mojolicious::Plugin> and implements the following new ones.

=head2 register

  $plugin->register(Mojolicious->new);

Register helpers in L<Mojolicious> application.

=head1 SEE ALSO

L<Mojolicious>, L<Mojolicious::Guides>, L<http://mojolicio.us>.

=cut
