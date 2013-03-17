package Mojolicious::Plugin::DateTime;
use Mojo::Base 'Mojolicious::Plugin';

use DateTime;
use DateTime::Format::DateParse;
use DateTime::Format::MySQL;

sub register {
	my ($self, $app, $conf) = @_;
	my $basedt = $ENV{DATETIME} ? DateTime::Format::DateParse->parse_datetime($ENV{DATETIME}, 'local') : DateTime->now(time_zone=>'local');
	my $start = time;

	$app->helper(datetime => sub {
		my $c = shift;
		my $dt = shift;
		return $self->{datetime}->{$dt} ||= DateTime::Format::DateParse->parse_datetime($dt, 'local') if $dt;
		my $datetime;
		if ( $app->mode ne 'production' ) {
			$datetime = $basedt->clone->add(seconds=>time-$start);
			warn "FAKE: $datetime\n";
		} else {
			$datetime = DateTime->now(time_zone=>'local');
			warn "REAL: $datetime\n";
		}
		return $self->{datetime}->{now} = $datetime;
	});
	$app->helper(datetime_mysql => sub {
		my $c = shift;
		my $datetime = shift;
		DateTime::Format::MySQL->format_datetime($self->{datetime}->{$datetime||'now'});
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
