use Mojo::Base -strict;

# Disable IPv6 and libev
BEGIN {
  $ENV{MOJO_MODE}    = 'development';
  $ENV{MOJO_NO_IPV6} = 1;
  $ENV{MOJO_REACTOR} = 'Mojo::Reactor::Poll';
  $ENV{DBIC_TRACE}   = 0;
  $ENV{WRRA_DBUSER} and $ENV{WRRA_DBPASS} and $ENV{WRRA_DBNAME} or die 'Set WRRA_DB* environment variable';
}

use Test::More;
use Test::Mojo;

my $t = Test::Mojo->new('WRRA');

# NI: User Index page
$t->get_ok('/')->status_is(200)->content_like(qr/User Index/i);

$t->get_ok('/admin')->status_is(404);
$t->get_ok('/admin/grid')->status_is(404);

done_testing();
