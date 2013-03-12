use Mojo::Base -strict;

# Disable IPv6 and libev
BEGIN {
  $ENV{MOJO_MODE}    = 'development';
  $ENV{MOJO_TEST}    = 1;
  $ENV{MOJO_NO_IPV6} = 1;
  $ENV{MOJO_REACTOR} = 'Mojo::Reactor::Poll';
  $ENV{DBIC_TRACE}   = 0;
}

use Test::More;
use Test::Mojo;

my $t = Test::Mojo->new('WRRA');

# NI: User Index page
$t->get_ok('/')->status_is(200)->content_like(qr/ok/i);

# Year
$t->get_ok('/api/dbconfig/year' => {'Accept' => 'application/json'})->status_is(200)->json_is('/year' => '2013');
$t->get_ok('/api/dbconfig/year/2012' => {'Accept' => 'application/json'})->status_is(200)->json_is('/year' => '2012');
$t->get_ok('/api/dbconfig/year' => {'Accept' => 'application/json'})->status_is(200)->json_is('/year' => '2012');
