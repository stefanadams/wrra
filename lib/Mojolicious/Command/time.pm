package Mojolicious::Command::time;
use Mojo::Base 'Mojolicious::Command';

# Short description
has description => "My first Mojo command.\n";

# Short usage message
has usage => <<"EOF";
  usage: $0 mycommand [OPTIONS]

  These options are available:
    -s, --something   Does something.
EOF

sub run {
    my ($self, @args) = @_;

    print scalar localtime;
}

1;
