package WRRA::Schema::Result::Bidding;

use 5.010;
use base 'WRRA::Schema::Result::Item';

# The columns to be rendered
sub _colmodel { qw/id number name runningtime timertime description value notifications notify cansell bellringer status nstatus auctioneer url timer startbid minbid highbid.bid highbid.id highbid.bidder.id highbid.bidder.name [bids] donor.name donor.url donor.advertisement scheduled started sold contacted cleared/ }

# The columns to be rendered as special accessor methods
#sub received { shift->SUPER::received->ymd }
#sub sold { shift->SUPER::sold ? 1 : 0 }

# This class method is passed $r and $op
sub _return {
	my ($class, $r, $op) = @_;
	given ( $op ) {
		when ( 'insert' ) { return number => $r->number }
	}
	return ();
}

# These class methods are passed $rs, $request
sub _create {
	my ($class, $r, $rs, $req) = @_;
	my $number;
	if ( my $_r = $r->result_source->schema->resultset('Item')->search({stockitem_id=>$req->{me}->{stockitem_id}?{'!='=>undef}:{'='=>undef}}, {order_by=>'number desc'})->current_year->first ) {
		$number = $_r->number+1;
	} else {
		$number = $req->{me}->{stockitem_id}?1000:100;
	}
	$r->year($rs->datetime->year);
	$r->number($number);
	return $r;
};
sub _search { $_[1]->current_year };
#sub _update { $_[1] };
#sub _delete { $_[1] };

# The relationships associated with this result (table)
our $relationships = [qw/highbid bid bidder donor/];

# When reading (i.e. searching or ordering), use this hashref to lookup references (scalar) or use mysql functions (scalarref)
# As a special case, if an arrayref is provided, index [0] is provided for search routines and index [1] is provided for ordering routines.
# If not an arrayref then the same handler is used for both search and ordering.
# if a coderef is provided, pass a hashref of the search condition to search or nothing to ordering.  Expects a fully formulated SQL::Abstract ref.
our $read = {
	'donor.nameid' => 'donor.name',
	'stockitem.nameid' => 'stockitem.name',
};
# When editing (i.e. creating or updating), use this hashref to lookup coderefs and pass the value to provide and expect back a full hash of key/value pairs.
our $edit = {
	'donor.nameid' => sub {
		my (undef, $id) = (shift =~ /(.*?):([^:]+)$/);
		return donor_id => $id||'';
	},
	'stockitem.nameid' => sub {
		my (undef, $id) = (shift =~ /(.*?):([^:]+)$/);
		return stockitem_id => $id||'';
	},
	#'donor.advertisement'
};
# For each field being edited (i.e. created or updated) validate the value with the qr regex in this hashref
our $validate = {
	'value' => [qr/^\d+$/, 'Value must be a whole number'],
};

1;
