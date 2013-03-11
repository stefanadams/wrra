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

# DateTime
$ENV{WRRA_DATETIME} = "2000-03-10 10:00:00";
SKIP : {
	local $TODO = "Infinitely looping";
	skip $TODO, 3;
	$t->get_ok('/api/header' => {'Accept' => 'application/json'})->status_is(200)->json_is('/about/closed' => '1');
	$t->get_ok('/api/header' => {'Accept' => 'application/json'})->status_is(200)->json_is('/about/night' => 0); #
	$t->get_ok('/api/header' => {'Accept' => 'application/json'})->status_is(200)->json_is('/about/year' => 2000); #
};

$ENV{WRRA_DATETIME} = "2013-03-10 10:00:00";
$t->get_ok('/api/header' => {'Accept' => 'application/json'})->status_is(200)->json_is('/about/closed' => '1');
$t->get_ok('/api/header' => {'Accept' => 'application/json'})->status_is(200)->json_is('/about/night' => 0); #
$t->get_ok('/api/header' => {'Accept' => 'application/json'})->status_is(200)->json_is('/about/year' => 2013); #

$ENV{WRRA_DATETIME} = "2013-03-18 16:59:59";
$t->get_ok('/api/header' => {'Accept' => 'application/json'})->status_is(200)->json_is('/about/closed' => '1');
$t->get_ok('/api/header' => {'Accept' => 'application/json'})->status_is(200)->json_is('/about/night' => 1);
$t->get_ok('/api/header' => {'Accept' => 'application/json'})->status_is(200)->json_is('/about/year' => 2013);
$ENV{WRRA_DATETIME} = "2013-03-18 17:00:00";
$t->get_ok('/api/header' => {'Accept' => 'application/json'})->status_is(200)->json_is('/about/closed' => '0');
$t->get_ok('/api/header' => {'Accept' => 'application/json'})->status_is(200)->json_is('/about/night' => 1);
$t->get_ok('/api/header' => {'Accept' => 'application/json'})->status_is(200)->json_is('/about/year' => 2013);
$ENV{WRRA_DATETIME} = "2013-03-18 17:00:01";
$t->get_ok('/api/header' => {'Accept' => 'application/json'})->status_is(200)->json_is('/about/closed' => '0');
$t->get_ok('/api/header' => {'Accept' => 'application/json'})->status_is(200)->json_is('/about/night' => 1);
$t->get_ok('/api/header' => {'Accept' => 'application/json'})->status_is(200)->json_is('/about/year' => 2013);
$ENV{WRRA_DATETIME} = "2013-03-18 20:59:59";
$t->get_ok('/api/header' => {'Accept' => 'application/json'})->status_is(200)->json_is('/about/closed' => '0');
$t->get_ok('/api/header' => {'Accept' => 'application/json'})->status_is(200)->json_is('/about/night' => 1);
$t->get_ok('/api/header' => {'Accept' => 'application/json'})->status_is(200)->json_is('/about/year' => 2013);
$ENV{WRRA_DATETIME} = "2013-03-18 21:00:00";
$t->get_ok('/api/header' => {'Accept' => 'application/json'})->status_is(200)->json_is('/about/closed' => '1'); #
$t->get_ok('/api/header' => {'Accept' => 'application/json'})->status_is(200)->json_is('/about/night' => 1);
$t->get_ok('/api/header' => {'Accept' => 'application/json'})->status_is(200)->json_is('/about/year' => 2013);
$ENV{WRRA_DATETIME} = "2013-03-18 21:00:01";
$t->get_ok('/api/header' => {'Accept' => 'application/json'})->status_is(200)->json_is('/about/closed' => '1');
$t->get_ok('/api/header' => {'Accept' => 'application/json'})->status_is(200)->json_is('/about/night' => 1);
$t->get_ok('/api/header' => {'Accept' => 'application/json'})->status_is(200)->json_is('/about/year' => 2013);

$ENV{WRRA_DATETIME} = "2013-03-19 16:59:59";
$t->get_ok('/api/header' => {'Accept' => 'application/json'})->status_is(200)->json_is('/about/closed' => '1');
$t->get_ok('/api/header' => {'Accept' => 'application/json'})->status_is(200)->json_is('/about/night' => 2);
$t->get_ok('/api/header' => {'Accept' => 'application/json'})->status_is(200)->json_is('/about/year' => 2013);
$ENV{WRRA_DATETIME} = "2013-03-19 17:00:00";
$t->get_ok('/api/header' => {'Accept' => 'application/json'})->status_is(200)->json_is('/about/closed' => '0');
$t->get_ok('/api/header' => {'Accept' => 'application/json'})->status_is(200)->json_is('/about/night' => 2);
$t->get_ok('/api/header' => {'Accept' => 'application/json'})->status_is(200)->json_is('/about/year' => 2013);
$ENV{WRRA_DATETIME} = "2013-03-19 17:00:01";
$t->get_ok('/api/header' => {'Accept' => 'application/json'})->status_is(200)->json_is('/about/closed' => '0');
$t->get_ok('/api/header' => {'Accept' => 'application/json'})->status_is(200)->json_is('/about/night' => 2);
$t->get_ok('/api/header' => {'Accept' => 'application/json'})->status_is(200)->json_is('/about/year' => 2013);
$ENV{WRRA_DATETIME} = "2013-03-19 20:59:59";
$t->get_ok('/api/header' => {'Accept' => 'application/json'})->status_is(200)->json_is('/about/closed' => '0');
$t->get_ok('/api/header' => {'Accept' => 'application/json'})->status_is(200)->json_is('/about/night' => 2);
$t->get_ok('/api/header' => {'Accept' => 'application/json'})->status_is(200)->json_is('/about/year' => 2013);
$ENV{WRRA_DATETIME} = "2013-03-19 21:00:00";
$t->get_ok('/api/header' => {'Accept' => 'application/json'})->status_is(200)->json_is('/about/closed' => '1'); #
$t->get_ok('/api/header' => {'Accept' => 'application/json'})->status_is(200)->json_is('/about/night' => 2);
$t->get_ok('/api/header' => {'Accept' => 'application/json'})->status_is(200)->json_is('/about/year' => 2013);
$ENV{WRRA_DATETIME} = "2013-03-19 21:00:01";
$t->get_ok('/api/header' => {'Accept' => 'application/json'})->status_is(200)->json_is('/about/closed' => '1');
$t->get_ok('/api/header' => {'Accept' => 'application/json'})->status_is(200)->json_is('/about/night' => 2);
$t->get_ok('/api/header' => {'Accept' => 'application/json'})->status_is(200)->json_is('/about/year' => 2013);

$ENV{WRRA_DATETIME} = "2013-03-20 16:59:59";
$t->get_ok('/api/header' => {'Accept' => 'application/json'})->status_is(200)->json_is('/about/closed' => '1');
$t->get_ok('/api/header' => {'Accept' => 'application/json'})->status_is(200)->json_is('/about/night' => 3);
$t->get_ok('/api/header' => {'Accept' => 'application/json'})->status_is(200)->json_is('/about/year' => 2013);
$ENV{WRRA_DATETIME} = "2013-03-20 17:00:00";
$t->get_ok('/api/header' => {'Accept' => 'application/json'})->status_is(200)->json_is('/about/closed' => '0');
$t->get_ok('/api/header' => {'Accept' => 'application/json'})->status_is(200)->json_is('/about/night' => 3);
$t->get_ok('/api/header' => {'Accept' => 'application/json'})->status_is(200)->json_is('/about/year' => 2013);
$ENV{WRRA_DATETIME} = "2013-03-20 17:00:01";
$t->get_ok('/api/header' => {'Accept' => 'application/json'})->status_is(200)->json_is('/about/closed' => '0');
$t->get_ok('/api/header' => {'Accept' => 'application/json'})->status_is(200)->json_is('/about/night' => 3);
$t->get_ok('/api/header' => {'Accept' => 'application/json'})->status_is(200)->json_is('/about/year' => 2013);
$ENV{WRRA_DATETIME} = "2013-03-20 20:59:59";
$t->get_ok('/api/header' => {'Accept' => 'application/json'})->status_is(200)->json_is('/about/closed' => '0');
$t->get_ok('/api/header' => {'Accept' => 'application/json'})->status_is(200)->json_is('/about/night' => 3);
$t->get_ok('/api/header' => {'Accept' => 'application/json'})->status_is(200)->json_is('/about/year' => 2013);
$ENV{WRRA_DATETIME} = "2013-03-20 21:00:00";
$t->get_ok('/api/header' => {'Accept' => 'application/json'})->status_is(200)->json_is('/about/closed' => '1'); #
$t->get_ok('/api/header' => {'Accept' => 'application/json'})->status_is(200)->json_is('/about/night' => 3);
$t->get_ok('/api/header' => {'Accept' => 'application/json'})->status_is(200)->json_is('/about/year' => 2013);
$ENV{WRRA_DATETIME} = "2013-03-20 21:00:01";
$t->get_ok('/api/header' => {'Accept' => 'application/json'})->status_is(200)->json_is('/about/closed' => '1');
$t->get_ok('/api/header' => {'Accept' => 'application/json'})->status_is(200)->json_is('/about/night' => 3);
$t->get_ok('/api/header' => {'Accept' => 'application/json'})->status_is(200)->json_is('/about/year' => 2013);

$ENV{WRRA_DATETIME} = "2013-03-21 16:59:59";
$t->get_ok('/api/header' => {'Accept' => 'application/json'})->status_is(200)->json_is('/about/closed' => '1');
$t->get_ok('/api/header' => {'Accept' => 'application/json'})->status_is(200)->json_is('/about/night' => 4);
$t->get_ok('/api/header' => {'Accept' => 'application/json'})->status_is(200)->json_is('/about/year' => 2013);
$ENV{WRRA_DATETIME} = "2013-03-21 17:00:00";
$t->get_ok('/api/header' => {'Accept' => 'application/json'})->status_is(200)->json_is('/about/closed' => '0');
$t->get_ok('/api/header' => {'Accept' => 'application/json'})->status_is(200)->json_is('/about/night' => 4);
$t->get_ok('/api/header' => {'Accept' => 'application/json'})->status_is(200)->json_is('/about/year' => 2013);
$ENV{WRRA_DATETIME} = "2013-03-21 17:00:01";
$t->get_ok('/api/header' => {'Accept' => 'application/json'})->status_is(200)->json_is('/about/closed' => '0');
$t->get_ok('/api/header' => {'Accept' => 'application/json'})->status_is(200)->json_is('/about/night' => 4);
$t->get_ok('/api/header' => {'Accept' => 'application/json'})->status_is(200)->json_is('/about/year' => 2013);
$ENV{WRRA_DATETIME} = "2013-03-21 20:59:59";
$t->get_ok('/api/header' => {'Accept' => 'application/json'})->status_is(200)->json_is('/about/closed' => '0');
$t->get_ok('/api/header' => {'Accept' => 'application/json'})->status_is(200)->json_is('/about/night' => 4);
$t->get_ok('/api/header' => {'Accept' => 'application/json'})->status_is(200)->json_is('/about/year' => 2013);
$ENV{WRRA_DATETIME} = "2013-03-21 21:00:00";
$t->get_ok('/api/header' => {'Accept' => 'application/json'})->status_is(200)->json_is('/about/closed' => '0'); #
$t->get_ok('/api/header' => {'Accept' => 'application/json'})->status_is(200)->json_is('/about/night' => 4);
$t->get_ok('/api/header' => {'Accept' => 'application/json'})->status_is(200)->json_is('/about/year' => 2013);
$ENV{WRRA_DATETIME} = "2013-03-21 21:00:01";
$t->get_ok('/api/header' => {'Accept' => 'application/json'})->status_is(200)->json_is('/about/closed' => '1');
$t->get_ok('/api/header' => {'Accept' => 'application/json'})->status_is(200)->json_is('/about/night' => 4);
$t->get_ok('/api/header' => {'Accept' => 'application/json'})->status_is(200)->json_is('/about/year' => 2013);

$ENV{WRRA_DATETIME} = "2013-04-10 10:00:00";
$t->get_ok('/api/header' => {'Accept' => 'application/json'})->status_is(200)->json_is('/about/closed' => '1');
$t->get_ok('/api/header' => {'Accept' => 'application/json'})->status_is(200)->json_is('/about/night' => 0);
$t->get_ok('/api/header' => {'Accept' => 'application/json'})->status_is(200)->json_is('/about/year' => 2013);

$ENV{WRRA_DATETIME} = "2020-04-10 10:00:00";
SKIP : {
	local $TODO = "Infinitely looping";
	skip $TODO, 3;
	$t->get_ok('/api/header' => {'Accept' => 'application/json'})->status_is(200)->json_is('/about/closed' => '1');
	$t->get_ok('/api/header' => {'Accept' => 'application/json'})->status_is(200)->json_is('/about/night' => 0);
	$t->get_ok('/api/header' => {'Accept' => 'application/json'})->status_is(200)->json_is('/about/year' => 2020);
};

done_testing();
