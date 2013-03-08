package Mojolicious::Command::lastlog;
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

    my $log = $self->app->log->path;
    # use File::Basename; my $log = dirname($0)."/log/".$self->app->mode.".log";
    say $log ? `sed '/Mojolicious (Perl)/{h;d};H;\$!d;x' "$log";` : "Can't read file \"$log\"";
}

1;
