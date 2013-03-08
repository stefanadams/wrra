package Mojolicious::Command::new_result_view;
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
    my ($self, $view, $source) = @_;

    die "No ResultView name specified\n" unless $view;
    die "No ResultView source name specified\n" unless $source;
    die "ResultView directory ResultView exists, are you in the right location?\n" if -d 'ResultView';
    die "ResultView directory Result doesn't exist, are you in the right location?\n" unless -d 'Result';
    die "ResultView directory ResultSet doesn't exist, are you in the right location?\n" unless -d 'ResultSet';
    die "ResultView $view Result already exists\n" if -e "Result/$view.pm";
    die "ResultView $view ResultSet already exists\n" if -e "ResultSet/$view.pm";

    open RESULT, ">Result/$view.pm";
    print RESULT <<EOF;
package WRRA::Schema::ResultView::Result::$view;

use base 'WRRA::Schema::Result::$source';

sub _columns { qw/id/ }

1;
EOF
    close RESULT;
    print "Please edit Result/$view.pm now (the default ResultSet/$view.pm is adequate)\n";

    open RESULTSET, ">ResultSet/$view.pm";
    print RESULTSET <<EOF;
package WRRA::Schema::ResultView::ResultSet::$view;

sub default { shift }

1;
EOF
    close RESULTSET;
}

1;
