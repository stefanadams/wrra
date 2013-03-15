package Mojolicious::Plugin::DateTime;
use Mojo::Base 'Mojolicious::Plugin';

use DateTime;
use DateTime::Format::DateParse;
use DateTime::Format::MySQL;

sub register {
	my ($self, $app, $conf) = @_;
	my $moniker = uc($app->moniker);

	$app->hook(before_dispatch => sub {
		my $c = shift;
		return $self->{datetime}->{now} = DateTime->now(time_zone=>'local') if $c->app->mode eq 'production';
		my $datetime = $c->session->{datetime} || $c->config->{datetime} || $ENV{"${moniker}_DATETIME"};
		$self->{datetime}->{now} = DateTime::Format::DateParse->parse_datetime($datetime) if $datetime;
		$self->{datetime}->{now} ||= DateTime->now(time_zone=>'local');
		$self->{datetime}->{now}->add(seconds=>time-$c->session->{start_time}) if $c->session->{start_time};
		warn $self->{datetime}->{now} if $ENV{"${moniker}_DATETIME"} && !$ENV{MOJO_TEST};
		$c->session->{start_time} = time if $datetime && !$c->session->{start_time};
		return $self->{datetime}->{now};
	});
	$app->helper(datetime => sub {
		my $c = shift;
		my $datetime = shift;
		return $self->{datetime}->{$datetime} ||= DateTime::Format::DateParse->parse_datetime($datetime) if $datetime;
		return $self->{datetime}->{now};
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
