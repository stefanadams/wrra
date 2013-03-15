use Mojo::Base -strict;

# Disable IPv6 and libev
BEGIN {
  $ENV{MOJO_MODE}    = 'development';
  $ENV{MOJO_TEST}    = 1;
  $ENV{MOJO_NO_IPV6} = 1;
  $ENV{MOJO_REACTOR} = 'Mojo::Reactor::Poll';
  $ENV{DBIC_TRACE}   = 0;
}

#use Mojo::JSON;
use Test::More;
use Test::Mojo;

my $t = Test::Mojo->new('WRRA');

my $id;
my $headers = {'Accept' => 'application/json', 'Content-Type' => 'application/json', 'X-Requested-With' => 'XMLHttpRequest'};

# login
$t->post_ok('/login' => $headers => form => {username=>"admin",phone=>4138})->status_is(200)->json_is('/user/role' => 'admins');

# rotarians
$t->post_ok('/admin/rotarians/create' => $headers => q'{"id":5465464,"name":"Testing Man","email":"","phone":"","oper":"add"}')->status_is(200)->json_is('/res' => 'ok');
$t->post_ok('/admin/rotarians/update' => $headers => q'{"celname":"name","name":"Foo Bar","id":"5465464","oper":"edit"}')->status_is(200)->json_is('/res' => 'ok');
$t->post_ok('/admin/rotarians' => $headers => q'{"_search":true,"nd":1363061516241,"rows":20,"page":1,"sidx":"name","sord":"asc","filters":"","searchField":"name","searchString":"foo","searchOper":"cn"}')->status_is(200)->json_is('/rows/0/name' => 'Bar, Foo');
$t->delete_ok('/admin/rotarians/delete' => $headers => q'{"oper":"del","id":"5465464"}')->status_is(200)->json_is('/res' => 'ok');

# donors
$t->post_ok('/admin/donors/create' => $headers => q'{"id":"_empty","name":"Testing Man","phone":"(111) 111-1111","rotarian.name":"6124146","oper":"add"}')->status_is(200)->json_is('/res' => 'ok');
$t->post_ok('/admin/donors' => $headers => q'{"_search":true,"nd":1363061516241,"rows":20,"page":1,"sidx":"name","sord":"asc","filters":"","searchField":"phone","searchString":"(111) 111-1111","searchOper":"eq"}')->status_is(200)->json_is('/rows/0/name' => 'Testing Man');
$id = $t->tx->res->json->{rows}->[0]->{id};
$t->post_ok('/admin/donors/update' => $headers => qq'{"celname":"name","name":"Foo Bar $id","id":"$id","oper":"edit"}')->status_is(200)->json_is('/res' => 'ok');
$t->post_ok('/admin/donors' => $headers => q'{"_search":true,"nd":1363061516241,"rows":20,"page":1,"sidx":"name","sord":"asc","filters":"","searchField":"name","searchString":"foo bar","searchOper":"cn"}')->status_is(200)->json_is('/rows/0/name' => "Foo Bar $id");
$t->delete_ok('/admin/donors/delete' => $headers => qq'{"oper":"del","id":"$id"}')->status_is(200)->json_is('/res' => 'ok');

# postcards
$t->post_ok('/admin/reports/postcards' => $headers => q'{"_search":true,"nd":1363061516241,"rows":20,"page":1,"sidx":"contact1","sord":"asc","filters":"","searchField":"name","searchString":"AAA","searchOper":"bw"}')->status_is(200)->json_is('/rows/0/name' => "AAA World Wide Travel");

# stockitems
$t->post_ok('/admin/stockitems/create' => $headers => q'{"id":"_empty","name":"Testing Man","value":"100","cost":"75","oper":"add"}')->status_is(200)->json_is('/res' => 'ok');
$t->post_ok('/admin/stockitems' => $headers => q'{"_search":true,"nd":1363061516241,"rows":20,"page":1,"sidx":"name","sord":"asc","filters":"","searchField":"name","searchString":"Testing Man","searchOper":"eq"}')->status_is(200)->json_is('/rows/0/name' => 'Testing Man');
$id = $t->tx->res->json->{rows}->[0]->{id};
$t->post_ok('/admin/stockitems/update' => $headers => qq'{"celname":"name","name":"Foo Bar $id","id":"$id","oper":"edit"}')->status_is(200)->json_is('/res' => 'ok');
$t->post_ok('/admin/stockitems' => $headers => q'{"_search":true,"nd":1363061516241,"rows":20,"page":1,"sidx":"name","sord":"asc","filters":"","searchField":"name","searchString":"foo bar","searchOper":"cn"}')->status_is(200)->json_is('/rows/0/name' => "Foo Bar $id");
$t->delete_ok('/admin/stockitems/delete' => $headers => qq'{"oper":"del","id":"$id"}')->status_is(200)->json_is('/res' => 'ok');

# items
$t->post_ok('/admin/items/create' => $headers => q'{"id":"_empty","donor.nameid":"foo bar:753","name":"Testing Man","value":"100","cost":"75","oper":"add"}')->status_is(200)->json_is('/res' => 'ok');
$t->post_ok('/admin/items' => $headers => q'{"_search":true,"nd":1363061516241,"rows":20,"page":1,"sidx":"name","sord":"asc","filters":"","searchField":"name","searchString":"Testing Man","searchOper":"eq"}')->status_is(200)->json_is('/rows/0/donor/nameid' => 'Stefan Adams:753');
$id = $t->tx->res->json->{rows}->[0]->{id};
$t->post_ok('/admin/items/update' => $headers => qq'{"celname":"donor.nameid","donor.nameid":"foo bar:1","id":"$id","oper":"edit"}')->status_is(200)->json_is('/res' => 'ok');
$t->post_ok('/admin/items' => $headers => q'{"_search":true,"nd":1363061516241,"rows":20,"page":1,"sidx":"name","sord":"asc","filters":"","searchField":"name","searchString":"Testing Man","searchOper":"eq"}')->status_is(200)->json_is('/rows/0/donor/nameid' => "Valent:1");
$t->delete_ok('/admin/items/delete' => $headers => qq'{"oper":"del","id":"$id"}')->status_is(200)->json_is('/res' => 'ok');

# bellitems
$t->post_ok('/admin/bellitems/create' => $headers => q'{"id":"_empty","name":"Testing Man","oper":"add"}')->status_is(200)->json_is('/res' => 'ok');
$t->post_ok('/admin/bellitems' => $headers => q'{"_search":true,"nd":1363061516241,"rows":20,"page":1,"sidx":"name","sord":"asc","filters":"","searchField":"name","searchString":"Testing Man","searchOper":"eq"}')->status_is(200)->json_is('/rows/0/name' => 'Testing Man');
$id = $t->tx->res->json->{rows}->[0]->{id};
$t->post_ok('/admin/bellitems/update' => $headers => qq'{"celname":"name","name":"Foo Bar $id","id":"$id","oper":"edit"}')->status_is(200)->json_is('/res' => 'ok');
$t->post_ok('/admin/bellitems' => $headers => q'{"_search":true,"nd":1363061516241,"rows":20,"page":1,"sidx":"name","sord":"asc","filters":"","searchField":"name","searchString":"foo bar","searchOper":"cn"}')->status_is(200)->json_is('/rows/0/name' => "Foo Bar $id");
$t->delete_ok('/admin/bellitems/delete' => $headers => qq'{"oper":"del","id":"$id"}')->status_is(200)->json_is('/res' => 'ok');

# seq items

# flyer
$t->post_ok('/admin/reports/flyer' => $headers => q'{"_search":true,"nd":1363061516241,"rows":20,"page":1,"sidx":"name","sord":"asc"}')->status_is(200)->json_is('/rows/0/number' => "961");

# bidding

# logout
$t->get_ok('/logout' => $headers)->status_is(200)->json_is('/user/role' => Mojo::JSON->false);



done_testing();
