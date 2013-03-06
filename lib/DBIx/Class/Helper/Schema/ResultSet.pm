package DBIx::Class::Helper::Schema::ResultSet;
{
  $DBIx::Class::Helper::Schema::ResultSet::VERSION = '0.1.0';
}

sub resultset {
	my $self = shift;
	my ($source, $new_result_class) = @_;
	$self = $self->next::method($source);
	if ( $new_result_class ) {
		my $result_class = $self->result_class;
		$result_class =~ s/[^:]+$/$new_result_class/;
		eval { $self = $self->search({}, {result_class=>$result_class}); };
		warn "Couldn't load Result Class $result_class\n" if $@;     
	}
	return $self;
}

1;
