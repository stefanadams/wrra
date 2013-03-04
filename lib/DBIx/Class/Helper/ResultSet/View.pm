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
	my $rs = ref $self;
	$rs =~ s/::ResultSet::/::ResultView::ResultSet::/;
	$rs =~ s/[^:]+$/$view/;
	my $r = $self->result_class;
	$r =~ s/::Result::/::ResultView::Result::/;
	$r =~ s/[^:]+$/$view/;
	eval { (ref $self)->load_components("+$rs"); };
	warn "Couldn't load resultset component $rs\n" if $@;
	eval { ($self->result_class)->load_components("+$r"); };
	warn "Couldn't load result component $r\n" if $@;
        eval { ($self->result_class)->load_components(qw{Helper::Row::ToJSON::View}); };
	warn "Couldn't load result component Helper::Row::ToJSON::View\n" if $@;
	$self->can('default') ? $self->default($self->request) : $self;
}

1;
