package Schema::ResultSet::Donor;

use base 'Schema::ResultSet';

sub solicit { $_[0]->search({$_[0]->current_source_alias.'.solicit' => 1}) }

sub postcards {
	my ($self) = @_;

	my @columns = qw/name contact1 contact2 address city state zip/;
	my @postcards = ();
	foreach my $postcard ( $self->search(
		{solicit=>1},
		{
			columns => [@columns],
			order_by => {-asc=>'name'}
		},
	) ) {
		push @postcards, [map { $postcard->$_ } @columns];
	}
	return [@postcards];
}

1;
