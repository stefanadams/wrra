package DBIx::Class::Helper::ResultSet::Jqgrid;
{
  $DBIx::Class::Helper::ResultSet::Jqgrid::VERSION = '0.1.0';
}

sub paged {
	my $self = shift;
	return $self->is_paged ? {
		page => $self->pager->current_page||1,
		total => $self->pager->last_page||1,
		records => $self->pager->total_entries||0,
		rows => [$self->all], # TO_JSON
	} : [$self->all];
}

sub xls {
        my $self = shift;
        delete $self->{attrs}->{page};
        delete $self->{attrs}->{rows};
        return [map { $_->TO_XLS } $self->all];
}

1;
