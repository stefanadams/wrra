package WRRA::Schema::Result::Donors;

use base 'WRRA::Schema::Result::Donor';

sub _search {
	my ($self, $rs, $req) = @_;
	$rs;
} 

sub TO_VIEW { qw/id chamberid phone category name contact address city state zip email url advertisement solicit ly_items rotarian.id rotarian.name comments/ }

1;
