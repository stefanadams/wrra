package Mojolicious::Command::backup;
use Mojo::Base 'Mojolicious::Command';

use DateTime;

# Short description
has description => "Create sql backup and tarballs.\n";

# Short usage message
has usage => <<"EOF";
  usage: $0 backup

EOF

sub run {
    my ($self, @args) = @_;

    my $moniker = $self->app->moniker;
    my $home = $self->app->home;
    my $db = $self->app->config->{database}->{name};
    # use File::Basename; my $log = dirname($0)."/log/".$self->app->mode.".log";
    my $timestamp = DateTime->now(time_zone=>'local')->datetime;
    say `mkdir -p $home/sql; mysqldump $db > $home/sql/$moniker.$timestamp.sql`;
    chdir $home;
    say `mkdir -p $home/tarballs; tar czf tarballs/$moniker.$timestamp.tar.gz --ignore-command-error public/ads public/photos wrra.conf sql/$moniker.$timestamp.sql`
    say $timestamp;
}

1;
