package DBIx::Class::Helper::ResultSet::View;
{
  $DBIx::Class::Helper::ResultSet::View::VERSION = '0.1.0';
}

use strict;
use warnings;

# This resultset method changes the result class and loads helper result methods into that class
# It also loads additional resultset methods into the resultset class
# Finally, it kicks off the loaded resultset methods by calling default (if defined)
sub view {
	my $self = shift;
	my $view = shift or return $self;
	my $resultset_class = $self->result_source->resultset_class;
	my $rs_component = $resultset_class;
	$rs_component =~ s/::ResultSet::/::ResultView::ResultSet::/;
	$rs_component =~ s/[^:]+$/$view/;
	my $result_class = $self->result_class;
	$result_class =~ s/::Result::/::ResultView::Result::/;
	$result_class =~ s/[^:]+$/$view/;
	eval { $resultset_class->load_components("+$rs_component"); };
	warn "Couldn't load component $rs_component\n" if $@;
	eval { $self = $self->search({}, {result_class=>$result_class}); };
	warn "Couldn't load result class $result_class\n" if $@;
        $result_class->load_components(qw{Helper::Row::ToJSON::View});
	$self->can('default') ? $self->default : $self;
}

1;
