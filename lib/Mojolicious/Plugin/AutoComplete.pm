package Mojolicious::Plugin::AutoComplete;
use Mojo::Base 'Mojolicious::Plugin';

our $VERSION = '0.01';

sub register {
  my ($self, $app) = @_;
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
