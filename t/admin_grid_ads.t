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
sub get_route_from_test { my ($route) = ($0 =~ /(\w+)\.t$/); $route =~ s/_/\//g; return "/$route"; }

use constant APP => 'WRRA';

my $t = Test::Mojo->new(APP);

my $route = get_route_from_test();

$t->get_ok($route)->status_is(200)->content_type_like(qr(text/html));

# An email should exist
$t->post_json_ok($route,							# Route
    {page=>1, rows=>5},								# POSTed JSON
    {'Accept' => 'application/json', 'X-Requested-With' => 'XMLHttpRequest'})	# Request Headers
  ->json_has('/0/email');

# An email should exist in the jqgrid
Test::Mojo->new(APP)->post_json_ok($route,
    {page=>1, rows=>5},
    {'Accept' => 'x-application/jqgrid', 'X-Requested-With' => 'XMLHttpRequest'})
  ->json_is('/rows/0/email' => $t->tx->res->json->[0]->{email});

# One Rotarian with name Adams
$t->post_json_ok($route, 
    {page=>1, rows=>5, sidx=>'name', searchField=>'name', searchOper=>'bw', searchString=>'Adams'},
    {'Accept' => 'x-application/jqgrid', 'X-Requested-With' => 'XMLHttpRequest'})
  ->json_is('/rows/0/name' => 'Adams, Stefan');

done_testing();
