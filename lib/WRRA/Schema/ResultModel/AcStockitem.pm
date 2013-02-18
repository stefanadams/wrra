package WRRA::Schema::ResultModel::AcStockitem;

use base 'WRRA::Schema::Result::Stockitem';

sub _value { shift->value }
sub label {
	my $self = shift;
	$self->name.':'.$self->stockitem_id;
}

sub TO_JSON { shift->hashref(qw(label name _value category)) }

1;
