package Mojolicious::Command::sqldump;
use Mojo::Base 'Mojolicious::Command';

# Short description
has description => "Output last log.\n";

# Short usage message
has usage => <<"EOF";
  usage: $0 lastlog [OPTIONS]

  These options are available:
    -s, --something   Does something.
EOF

sub run {
    my ($self, @args) = @_;

    my $moniker = $self->app->moniker;
    my $home = $self->app->home;
    my $db = $self->app->config->{database}->{name};
    # use File::Basename; my $log = dirname($0)."/log/".$self->app->mode.".log";
    say `mysqldump $db > $home/sql/$moniker.\$(date +'%Y-%m-%dT%H:%M:%S').sql`
}

1;
