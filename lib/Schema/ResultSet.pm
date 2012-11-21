package Schema::ResultSet;

use base qw/DBIx::Class::ResultSet::WithMetaData DBIx::Class::ResultSet::HashRef DBIx::Class::ResultSet/;
#use base qw/DBIx::Class::ResultSet/;
__PACKAGE__->load_components(qw{Helper::ResultSet::Shortcut});

use Data::Dumper;

sub year { shift->result_source->storage->_connect_info->[0]->{year} || ((localtime())[5])+1900 }
# !!! Does NOT work as expected!!!!!!!!!!!!
sub warn_json { my $self = shift; warn Dumper($self->${\('hashref_'.(shift || 'first'))}); $self }

sub next_year { $_[0]->search({($_[1]?"$_[1].year":'year') => $_[0]->year+1}) }
sub current_year { $_[0]->search({($_[1]?"$_[1].year":'year') => $_[0]->year}) }
sub last_year { $_[0]->search({($_[1]?"$_[1].year":'year') => $_[0]->year-1}) }
sub recent_years { $_[0]->search({($_[1]?"$_[1].year":'year') => {-between => [$_[0]->year-2, $_[0]->year]}}) }
sub donor { $_[0]->search({'donor.name' => {-like => '%'.$_[0].'%'}}, {join=>'donor'}) }

# Grid can use ->all TO_JSON recursion; ->hashref_array for big trees of data
sub grid {
	my $self = shift;
	return {
                page=>$self->pager->current_page||1,
                total=>$self->pager->last_page||1,
                records=>$self->pager->total_entries||1,
                rows => [$self->all],
	};
}

sub grid_xls {
	my $self = shift;

	my @xls = ();
	foreach my $xls ( $self->all ) {
		push @xls, [map { $xls->can($_) && $xls->$_ } grep { $_ } $xls->columns];
	}
	return [@xls];
}

1;
