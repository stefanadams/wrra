package Mojolicious::Plugin::AutoComplete;
use Mojo::Base 'Mojolicious::Plugin';

our $VERSION = '0.01';

use Mojo::Util qw(decamelize);

sub register {
  my ($self, $app) = @_;

  # This requires use of Mojo::Plugin::View
  #$r->auto_complete([AcCity => 'Donor'], {api => 'auto_complete'}, name=>'City');
  $app->routes->add_shortcut(auto_complete => sub {
    my $r = shift;
    my ($route, $result_class, $source);
    ($route, $result_class, $source) = @$_ == 1 ? (undef, @$_, @$_) : @$_ == 2 ? (undef, @$_) : (@$_) foreach grep { ref eq 'ARRAY' } @_;
    %_ = grep { !ref } @_;
    $_{name} =~ s/\W+//g if $_{name};
    my $name = decamelize(delete $_{name} // $result_class);
    $route =~ s/^\/+// if $route;
    $route //= $name;   
    $r->dbroute(["/$route" => "Ac$result_class" => $source], {api => 'auto_complete'}, \'get', %_);
  });

  $app->helper(ac => sub {
    my ($c, $rs) = @_;
    $rs = ($rs->result_class)->_search($rs, (ref $c->myrequest ? $c->myrequest : {$c->myrequest})) if ($rs->result_class)->can('_search');
    return $rs;
  });

  $app->helper(autocomplete => sub {
    my ($self, $name, $values) = @_;
    $values ||= [];
    #var autocomplete = {
    #    minLength: 2
    #};
    #%== auto_complete 'ac_city', [qw/state zip/], 
    my $select = join '', map { my $id = my $key = $_; $id =~ s/^_//; $id =~ s/\./\\\\./g; $key =~ s/^.*?\.//; "\$('#$id').val(ui.item.$key);" } @$values;
    my $url = $self->url_for($name);
    return <<EOF;
function $name(elem){
    \$(elem).autocomplete(\$.extend({}, {
            source: "$url",
            minLength: 2,
            select: function(event, ui){ if (ui.item) { $select true; } }
    }, autocomplete)).data( "ui-autocomplete" )._renderItem = function( ul, item ) {
        if ( item.desc ) {
            return \$("<li>").append("<a>"+item.label+"<br>"+item.desc+"</a>").appendTo(ul);
        } else {
            return \$("<li>").append("<a>"+item.label+"</a>").appendTo(ul);
        }
    };
    return true;
}
EOF
  });
}

1;
