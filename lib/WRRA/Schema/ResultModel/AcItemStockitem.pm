package WRRA::Schema::ResultModel::AcItemStockitem;

use base 'WRRA::Schema::Result::Item';

sub stockitem {
	my $self = shift;
	$self->name.':'.$self->stockitem_id;
}

sub TO_JSON { shift->hashref(qw(stockitem value)) }

1;
