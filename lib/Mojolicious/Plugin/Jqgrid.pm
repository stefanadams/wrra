package Mojolicious::Plugin::Jqgrid;
use Mojo::Base 'Mojolicious::Plugin';

our $VERSION = '0.01';

use Mojo::Util qw(decamelize);

sub register {
  my ($self, $app) = @_;

  # This requires use of Mojo::Plugin::View
  $app->routes->add_shortcut(jqgrid => sub {
    my $r = shift;
    my ($route, $view, $source);
    ($route, $view, $source) = @$_ == 1 ? (undef, @$_, @$_) : @$_ == 2 ? (undef, @$_) : (@$_) foreach grep { ref eq 'ARRAY' } @_;
    %_ = grep { !ref } @_;
    $_{name} =~ s/\W+//g if $_{name};
    my $name = decamelize(delete $_{name} // $view);
    $route =~ s/^\/+// if $route;
    $route //= $name;   
    my $extra_path = delete $_{extra_path};
    my $r1 = $r->under("/$name");
    $r1->view(['/create' => $view => $source], {jqgrid => 'create'}, name => "create_$name");
    $r1->view(['/' => $view => $source], {jqgrid => 'read'}, name => "read_$name");
    $r1->view(['/update' => $view => $source], {jqgrid => 'update'}, name => "update_$name");
    $r1->view(['/delete' => $view => $source], {jqgrid => 'delete'}, name => "delete_$name");
    $r1;
  });
}

1;
