use Mojo::Base -strict;

# Disable IPv6 and libev
BEGIN {
  $ENV{MOJO_MODE}    = 'development';
  $ENV{MOJO_NO_IPV6} = 1;
  $ENV{MOJO_REACTOR} = 'Mojo::Reactor::Poll';
#  $ENV{DBIC_TRACE}   = 0;
#  $ENV{WRRA_DBUSER} and $ENV{WRRA_DBPASS} and $ENV{WRRA_DBNAME} or die 'Set WRRA_DB* environment variable';
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

# AutoCompletes
#$t->get_ok('/api/ac/ad?term=wash' => {'Accept' => 'application/json'})->status_is(200)->json_is('/1/label' => 'Washington');
#$t->get_ok('/api/ac/advertisement?term=wash' => {'Accept' => 'application/json'})->status_is(200)->json_is('/1/label' => 'Washington');
#$t->get_ok('/api/ac/advertiser?term=wash' => {'Accept' => 'application/json'})->status_is(200)->json_is('/1/label' => 'Washington');
#$t->get_ok('/api/ac/bellitem?term=wash' => {'Accept' => 'application/json'})->status_is(200)->json_is('/1/label' => 'Washington');
#$t->get_ok('/api/ac/bidder?term=adams' => {'Accept' => 'application/json'})->status_is(200)->json_is('/1/label' => 'Washington');
$t->get_ok('/api/ac/city?term=wash' => {'Accept' => 'application/json'})->status_is(200)->json_is('/1/label' => 'Washington');
$t->get_ok('/api/ac/donor?term=adams' => {'Accept' => 'application/json'})->status_is(200)->json_is('/0/label' => 'Stefan Adams:753');
$t->get_ok('/api/ac/item_current?term=cookie' => {'Accept' => 'application/json'})->status_is(200)->json_is('/0/label' => 'One Dozen Boxes of Thin Mint Girl Scout Cookies');
#$t->get_ok('/api/ac/item?term=cookie' => {'Accept' => 'application/json'})->status_is(200)->json_is('/1/label' => 'Washington');
#$t->get_ok('/api/ac/item_stockitem?term=wash' => {'Accept' => 'application/json'})->status_is(200)->json_is('/1/label' => 'Washington');
#$t->get_ok('/api/ac/paynumber?term=wash' => {'Accept' => 'application/json'})->status_is(200)->json_is('/1/label' => 'Washington');
#$t->get_ok('/api/ac/stockitem?term=will' => {'Accept' => 'application/json'})->status_is(200)->json_is('/1/label' => 'Washington');

done_testing();
