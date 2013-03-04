package Mojolicious::Plugin::DBIC;
use Mojo::Base 'Mojolicious::Plugin';

use Mojo::Loader;

has 'db';

sub register {
	my ($self, $app, $conf) = @_;
	my $schema = my $_schema = $conf->{schema} || ref($app).'::Schema';
	my $moniker = uc($app->moniker);

	eval "use $schema";
	die "Can't load schema $schema: $@" if $@;

	# Takes no arguments
	$app->helper(db => sub {
		my $c = shift;

		#if ( $self->db ) {
		#	$self->db->controller($c);
		#	return $self->db;
		#}

		my %connect = (
			type => 'mysql',
			name => $conf->{moniker} || $moniker || '',
			host => 'localhost',
			user => $conf->{moniker} || $moniker || '',
			pass => $conf->{moniker} || $moniker || '',
		);
		my $database = $c->config->{database} || {};
		$database = {%connect, %$database, (map { s/^${moniker}_DB//; lc($_) => delete $ENV{uc("${moniker}_DB$_")} } grep { /^${moniker}_DB/ } keys %ENV)};
		$self->db($schema->connect({dsn=>"DBI:$database->{type}:database=".$database->{name}.";host=".$database->{host},user=>$database->{user},password=>$database->{pass},controller=>$c}));
		return $self->db;
	});
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
