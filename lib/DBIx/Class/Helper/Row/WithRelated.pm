package DBIx::Class::Helper::Row::WithRelated;
{
  $DBIx::Class::Helper::Row::WithRelated::VERSION = '0.1.0';
}

sub insert_with_related {
	my $self = my $insert = shift;
	my $row = shift;
	$self = $self->new_result({});
	$self->$_($row->{me}->{$_}) for keys %{$row->{me}};
	my $_insert = $self->insert;
	for my $table ( grep { $_ ne 'me' } keys %$row ) {
		my $table_rs = $create->search_related($table);
		$table_rs->$_($row->{$_}) for keys %{$row->{$table}};
		$table_rs->update;
	}
	return $_insert;
}
*create_with_related = *insert_with_related;
sub update_with_related {
	my $self = my $update = shift;
	my $row = shift;
	$self->$_($row->{me}->{$_}) for keys %{$row->{me}};
	my $_update = $self->update;
	for my $table ( grep { $_ ne 'me' } keys %$row ) {
		my $table_rs = $update->search_related($table);
		$table_rs->$_($row->{$_}) for keys %{$row->{$table}};
		$table_rs->update;
	}
	return $_update;
}

1;
