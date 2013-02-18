package WRRA::Schema::ResultModel::Donors;

use base 'WRRA::Schema::Result::Donor';

sub resolver {
        search => {
                contact => \'concat_ws("", me.contact1, me.contact2)',
		rotarian => \'concat_ws("", rotarian.lastname, rotarian.firstname)',
                #highbidder => 'bidder.name',
                #highbid => 'highbid.bid',
                #soldday => \'dayname(sold)',
        },
        order_by => {
                contact => ['me.contact1', 'me.contact2'],
		rotarian => ['rotarian.lastname', 'rotarian.firstname'],
                #soldday => [\'cast(sold as date)', 'number'],
        },
	update_or_create => {
		id => sub { donor_id=>shift },
		contact => sub {
			my ($contact1, $contact2) = split /\|/, shift;
			return contact1=>$contact1,contact2=>$contact2;
		},
		rotarian => sub { rotarian_id=>shift },
	},
}

sub rotarian { shift->SUPER::rotarian->name }

sub TO_XLS { shift->arrayref(qw(id chamberid phone category name contact address city state zip email url advertisement solicit ly_items rotarian comments)) }
sub TO_JSON { shift->hashref(qw(id chamberid phone category name contact address city state zip email url advertisement solicit ly_items rotarian comments)) }

1;
