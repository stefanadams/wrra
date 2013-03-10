package Mojolicious::Plugin::DateTime;
use Mojo::Base 'Mojolicious::Plugin';

use DateTime;
use DateTime::Format::DateParse;

sub register {
	my ($self, $app, $conf) = @_;
	my $moniker = uc($app->moniker);

	$app->helper(datetime => sub {
		my $c = shift;
		my $datetime = shift;
		$datetime and return DateTime::Format::DateParse->parse_datetime($datetime);
		$datetime = $c->session->{datetime} || $c->config->{datetime} || $ENV{"${moniker}_DATETIME"};
		$datetime = $datetime ? DateTime::Format::DateParse->parse_datetime($datetime) : DateTime->now;
		warn $datetime if $ENV{"${moniker}_DATETIME"};
		return $datetime;
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
