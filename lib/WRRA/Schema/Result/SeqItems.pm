package WRRA::Schema::Result::SeqItems;

use base 'WRRA::Schema::Result::Item';

sub FROM_JSON { qw/id number name value scheduled.day_name/ }

sub _search {
	my ($self, $rs, $req) = @_;
	$rs->search({}, {order_by=>{'-asc'=>['scheduled','seq']}})->current_year
} 

our $read = {
	scheduled => sub {
		my ($condition) = @_;
		my ($start, $n) = ($session->{start}, $req->{n});
		
		return ({'='=>undef}) if not(defined $n) || $n <= 0 || $n =~ /\D/ || $start !~ /^\d{4}-\d{2}-\d{2}$/;
		return (-or => [{'='=>undef},{'!='=>undef}]) if $n >= 9999;
		$n--;
		return ({'='=>\"date_add('$start', interval $n day)"});
	},
};
our $edit = {
	id => sub {
		my ($value, $req, $session) = @_;
		my @item_id = map { /_(\d+)$/; $1 } @$value;
		my $n = $req->{n};
		if ( $n == 0 ) {
			return (
				scheduled => undef,
				seq => \join('', 'FIND_IN_SET(item_id, "', join(',', @item_id), '")'),
			);
		} elsif ( $n > 0 and $n < 9999 ) {
			$n--;
			return (
				scheduled => \"date_add('$req->{start}', interval $n day)",
				seq => \join('', 'FIND_IN_SET(item_id, "', join(',', @item_id), '")'),
			);
		}
	},
};

1;
