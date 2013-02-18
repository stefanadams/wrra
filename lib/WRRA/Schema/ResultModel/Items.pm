package WRRA::Schema::ResultModel::Items;

use base 'WRRA::Schema::Result::Item';

use Data::Dumper;

sub resolver {
	search => {
		donor => 'donor.name',
		stockitem => 'stockitem.name',
		advertisement => 'donors.advertisement',
		#highbidder => 'bidder.name',
		#highbid => 'highbid.bid',
		#soldday => \'dayname(sold)',
	},
	order_by => {
		donor => ['donor.name'],
		stockitem => ['stockitem.name'],
		advertisement => ['donors.advertisement'],
		#soldday => [\'cast(sold as date)', 'number'],
	},
	update_or_create => {
		'donor.nameid' => sub {
			my (undef, $id) = (shift =~ /(.*?):([^:]+)$/);
			return donor_id=>$id;
		},
		'stockitem.nameid' => sub {
			my (undef, $id) = (shift =~ /(.*?):([^:]+)$/);
			return stockitem_id=>$id;
		},
		'donor.advertisement' => sub {
			my $value = shift;
			'donor' => sub {
				my $req = shift;
				return ({donor_id=>$req->{donor_id}}, {advertisement=>$value});
			}
		},
	},
	create_defaults => {
		year => sub { shift->year },
		number => sub {
			my ($rs, $req) = @_;
			if ( $rs = $rs->result_source->schema->resultset('Item')->search({stockitem_id=>$req->{stockitem_id}?{'!='=>undef}:{'='=>undef}}, {order_by=>'number desc'})->current_year->first ) {
				return $rs->number+1;
			} else {
				return $req->{stockitem_id}?1000:100;
			}
		},
	},
}

sub TO_XLS { shift->arrayref(qw(id number donor stockitem name description value category url)) }
sub TO_JSON {
	my $self = shift;
	return {
		(map { $_ => $self->$_ } qw(id number name description value category url)),
		donor => {
			nameid => $self->eval('$self->donor->nameid'),
			advertisement => $self->eval('$self->donor->advertisement'),
		},
		stockitem => {
			nameid => $self->eval('$self->stockitem->nameid'),
		},
	};
}

1;
