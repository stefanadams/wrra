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

my $headers = {'Accept' => 'application/json', 'Content-Type' => 'application/json', 'X-Requested-With' => 'XMLHttpRequest'};

# ads (ac_ad [qw/label scheduled advertiser.nameid url/], ac_advertiser [qw/label name scheduled url/])
$t->get_ok('/api/ac/ad?term=borgia' => $headers)->status_is(200)->json_is('/0/label' => 'St. Francis Borgia Regional HS');
$t->get_ok('/api/ac/advertiser?term=borgia' => $headers)->status_is(200)->json_is('/0/label' => 'St. Francis Borgia Regional HS');

# bellitems (ac_bellitem [qw/label/])
$t->get_ok('/api/ac/bellitem?term=wefq' => $headers)->status_is(200)->json_is('/0/label' => 'wefqwef');

# bidders (ac_city [qw/label state zip/])
$t->get_ok('/api/ac/city?term=wash' => $headers)->status_is(200)->json_is('/1/label' => 'Washington');

# bids (ac_bidder, ac_item_current)
TODO: {
	$ENV{DBIC_TRACE}=1;
	$ENV{MOJO_TEST}=0;
	local $TODO = 'Dunno';
	$t->get_ok('/api/ac/bidder?term=adams' => $headers)->status_is(200)->json_is('/0/label' => 'Stefan Adams');
	$t->get_ok('/api/ac/item_current?term=cookie' => $headers)->status_is(200)->content_like('/0/label' => 'sdfwfdwfdf');
	$ENV{MOJO_TEST}=1;
	$ENV{DBIC_TRACE}=0;
};

# donors (ac_city [qw/label state zip/])
$t->get_ok('/api/ac/city?term=wash' => $headers)->status_is(200)->json_is('/1/label' => 'Washington');

# items (ac_donor [qw/donor.advertisement/], ac_stockitem [qw/name _value category/], ac_item [qw/description _value url category/], ac_advertisement)
$t->get_ok('/api/ac/donor?term=adams' => $headers)->status_is(200)->json_is('/0/label' => 'Stefan Adams:753');
$t->get_ok('/api/ac/stockitem?term=will' => $headers)->status_is(200)->json_is('/1/label' => '$50.00 Williams Brothers Gift Certificate:47');
$t->get_ok('/api/ac/item?term=cookie' => $headers)->status_is(200)->json_is('/1/label' => '10 boxes of Girl Scout Cookies');
$t->get_ok('/api/ac/advertisement?term=wash' => $headers)->status_is(200)->json_is('/0/label' => '31st Annual Art Fair & Winefest is scheduled for May 18, 19, 20, 2012 in historic downtown Washington.');

# stockitems (ac_stockitem [qw/_value cost category/])
$t->get_ok('/api/ac/stockitem?term=will' => $headers)->status_is(200)->json_is('/1/label' => '$50.00 Williams Brothers Gift Certificate:47');

# bidding
$t->get_ok('/api/ac/pay_number?term=963' => $headers)->status_is(200)->json_is('/0/label' => '963');
#$t->get_ok('/api/ac/bidder?term=adams' => $headers)->status_is(200)->json_is('/0/label' => 'Stefan Adams');




#$t->get_ok('/api/ac/item_stockitem?term=wash' => $headers)->status_is(200)->json_is('/1/label' => 'Washington');

done_testing();
