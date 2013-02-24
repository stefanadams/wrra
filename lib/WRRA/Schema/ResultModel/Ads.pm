package WRRA::Schema::ResultModel::Ads;

use base 'WRRA::Schema::Result::Ad';

sub resolver {
	update_or_create => {
		'id' => sub { ad_id=>shift },
	},
}

sub TO_XLS { shift->arrayref(qw(id scheduled advertiser name url)) }
sub TO_JSON {
	my $self = shift;
	return {
		(map { $_ => $self->$_ } qw(id scheduled name url)),
		advertiser => {
			nameid => $self->eval('$self->donor->nameid'),
		},
	};
}

1;
