package WRRA::Schema::ResultModel::SeqItems;

use base 'WRRA::Schema::Result::Item';

use Data::Dumper;

sub resolver {
	search => {
		scheduled => sub {
			my ($start, $n) = @_;
			return ({'='=>undef}) if not(defined $n) || $n <= 0 || $n =~ /\D/ || $start !~ /^\d{4}-\d{2}-\d{2}$/;
			return () if $n >= 9999;
			$n--;
			return ({'='=>\"date_add('$start', interval $n day)"});
		},
	},
	update_or_create => {
		id => sub {
			my ($value, $request) = @_;
			my @item_id = map { /_(\d+)$/; $1 } @$value;
			my $n = $request->{n};
			if ( $n == 0 ) {
				return (
					scheduled => undef,
					seq => \join('', 'FIND_IN_SET(item_id, "', join(',', @item_id), '")'),
				);
			} elsif ( $n > 0 and $n < 9999 ) {
				$n--;
				return (
					scheduled => \"date_add('$request->{start}', interval $n day)",
					seq => \join('', 'FIND_IN_SET(item_id, "', join(',', @item_id), '")'),
				);
			}
		},
	},
}

sub TO_JSON {
	my $self = shift;
	return {
		(map { $_ => $self->$_ } qw(id number name)),
		night => $self->eval('$self->scheduled->day_name'),
	};
}

1;
