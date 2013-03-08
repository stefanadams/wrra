package Mojolicious::Plugin::BuildSelect;
use Mojo::Base 'Mojolicious::Plugin';

our $VERSION = '0.01';

use Mojo::Util qw(decamelize);

has 'controller';
has 'resultset';
has 'request';

sub register {
  my ($self, $app) = @_;

  # This requires use of Mojo::Plugin::View
  $app->routes->add_shortcut(build_select => sub {
    my $r = shift;
    my ($route, $result_class, $source);
    ($route, $result_class, $source) = @$_ == 1 ? (undef, @$_, @$_) : @$_ == 2 ? (undef, @$_) : (@$_) foreach grep { ref eq 'ARRAY' } @_;
    %_ = grep { !ref } @_;
    $_{name} =~ s/\W+//g if $_{name};
    my $name = decamelize(delete $_{name} // $result_class);
    $route =~ s/^\/+// if $route;
    $route //= $name;   
    $r->dbroute(["/$route" => "Bs$result_class" => $source], {api => 'build_select'}, \'get', %_);
  });

  $app->helper(bs => sub {
    my ($c, $rs) = @_;
    $self->controller($c);
    $self->resultset($rs);
    $self->request(ref $c->merged ? $c->merged : {$c->merged});
    $rs = ($rs->result_class)->_search($rs, $self->request) if ($rs->result_class)->can('_search');
    $rs = ($rs->result_class)->_read($rs, $self->request) if ($rs->result_class)->can('_read');
    return $rs;
  });
}

1;
