package WRRA::Schema::Result::Winners;

use base 'WRRA::Schema::Result::Item';

sub _colmodel { qw/id scheduled.day_name number highbid.bid highbid.bidder.name highbid.bidder.phone contacted paid bellringer bellitem.id bellitem.name name value donor.name/ }

sub _search {
        my ($self, $rs, $req) = @_;
        $rs->search({}, {order_by=>{'-asc'=>['scheduled','number']}})->current_year->sold
} 

# The relationships associated with this result (table)
our $relationships = ['bellitem', {highbid=>'bidder'}];

our $read = {
        'bellitem.nameid' => 'bellitem.name',
};
# When editing (i.e. creating or updating), use this hashref to lookup coderefs and pass the value to provide and expect back a full hash of key/value pairs.
our $edit = {
	'bellitem.name' => 'bellitem_id',
	'contacted' => sub { contacted => (shift) ? \'now()' : undef },
	'paid' => sub { paid => (shift) ? \'now()' : undef },
};

1;
