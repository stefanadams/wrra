package Mojolicious::Plugin::View;
use Mojo::Base 'Mojolicious::Plugin';

our $VERSION = '0.01';

use Mojo::Util qw(decamelize);

sub register {
  my ($self, $app) = @_;

  #$r->view([$view => $source], {$controller => $action}, \$method, name=>'', extra_path=>'', %_);
  #$r->auto_complete([AcCity => 'Donor'], {api => 'auto_complete'}, name=>'City');
  $app->routes->add_shortcut(view => sub {
    my $r = shift;
    my ($route, $view, $source, $method, $controller, $action) = (undef, undef, undef, 'post', 'crud', 'read');
    foreach ( @_ ) {
      ($route, $view, $source) = @$_ == 1 ? (undef, @$_, @$_) : @$_ == 2 ? (undef, @$_) : (@$_) if ref $_ eq 'ARRAY';
      ($controller, $action) = %$_ if ref $_ eq 'HASH';
      ($method) = $$_ if ref $_ eq 'SCALAR';
    }
    %_ = grep { !ref } @_;
    $_{name} =~ s/\W+//g if $_{name};
    my $name = decamelize(delete $_{name} // $view);
    $route =~ s/^\/+// if $route;
    $route //= $name;
    my $extra_path = delete $_{extra_path};
warn Data::Dumper::Dumper([
	{method => $method},
	{route => join('/', '', grep { $_ } $route, $extra_path)},
	{require_xhr => 1},
	{to => ["$controller#$action", results=>[$view, $source], %_]},
	{name => join('_', map { s/\W//g; $_ } grep { $_ } $name, $extra_path)}
]) if $controller eq 'api';
#    $r->$method(join('/', '', grep { $_ } $route, $extra_path))->xhr->to("$controller#$action", view=>$view, source=>$source, %_)->name(join('_', map { s/\W//g; $_ } grep { $_ } $name, $extra_path));
    $r->$method(join('/', '', grep { $_ } $route, $extra_path))->xhr->to("$controller#$action");
    $r;
    #$r1->get("/$name.xls")->to('crud#read', format=>'xls')->name($name); # XLS must be GET and can't be XHR, so it needs to be a unique URI
  });
}

1;
