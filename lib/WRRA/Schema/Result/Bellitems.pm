package WRRA::Schema::Result::Bellitems;

use base 'WRRA::Schema::Result::Bellitem';

sub _colmodel { qw/id name/ }

sub _create {
	my ($class, $r, $rs, $req) = @_;
	$r->year($rs->session->{year});
	return $r;
};

sub _search {
	my ($self, $rs, $req) = @_;
	$rs->current_year;
}

1;
