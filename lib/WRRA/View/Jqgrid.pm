package WRRA::View::Jqgrid;

use Data::Dumper;

sub read {
	my $class = shift;
	my $request = shift;
	my $resolver = shift;

	json => sub {
		my $self = shift;
		return {
			page => $self->pager->current_page||1,
			total => $self->pager->last_page||1,
			records => $self->pager->total_entries||0,
			rows => [$self->all], # TO_JSON
		} if ref $self;
	}
}

sub search {
	my $class = shift;
	my $request = shift;
	my $resolver = shift;

	my ($field, $oper, $string) = ($request->{searchField}, $request->{searchOper}, $request->{searchString});

	my $sopt = {
		eq => {'=' => $string},
		ne => {'!=' => $string},
		lt => {'<' => $string},
		le => {'<=' => $string},
		gt => {'>' => $string},
		ge => {'>=' => $string},
		bw => {'like' => $string.'%'},
		bn => {'not like' => $string.'%'},
		#in => {'<' => $string},  
		#ni => {'<' => $string},
		ew => {'like' => '%'.$string},
		en => {'not like' => '%'.$string},
		cn => {'like' => '%'.$string.'%'},
		nc => {'not like' => '%'.$string.'%'},
	} if defined $string;

	if ( defined $field && defined $resolver->{search}->{$field} ) {
		$field = $resolver->{search}->{$field};
	}

	if ( ref $field eq 'SCALAR' ) {
		$field = $$field;
	} elsif ( ref $field ) {
		warn "search resolver must be a scalar or scalarref";
		$field = undef;
	} elsif ( defined $field ) {
		$field = "me.$field" unless $field =~ /\./;
	}

	#warn Dumper({'View::Jqgrid' => [$field => $oper => $sopt->{$oper}]});
	return $field && $oper && $sopt->{$oper} ? ($field => $sopt->{$oper}) : ();
}

sub pager {
	my $class = shift;
	my $request = shift;
	my $resolver = shift;

	my ($page, $rows) = ($request->{page}, $request->{rows});
	return (page => ($page||1), (defined $rows ? (rows => $rows) : ()));
}

sub order_by {
	my $class = shift;
	my $request = shift;
	my $resolver = shift;

	my ($sidx, $sord) = ($request->{sidx}, $request->{sord});

	if ( defined $sidx && $resolver->{order_by}->{$sidx} ) {
		$sidx = $resolver->{order_by}->{$sidx};
	}

	if ( defined $sidx && not ref $sidx ) {
		$sidx = "me.$sidx" unless $sidx =~ /\./;
	}

	return $sidx ? (order_by => {'-'.($sord||'asc') => $sidx}) : ();
}

sub key {
	my $class = shift;
	my $request = shift;
	my $resolver = shift;

	return $request->{id};
}

sub create {
	my $class = shift;
	my $request = shift;
	my $resolver = shift;

	return () unless defined $request->{oper} && $request->{oper} eq 'add';

	return (
		(map {
			defined $_ && $resolver->{create_defaults}->{$_}
			? ("+$_" => $resolver->{create_defaults}->{$_})
			: ()
		} keys %{$resolver->{create_defaults}}),
		(map {
			defined $_ && $resolver->{update_or_create}->{$_} && ref $resolver->{update_or_create}->{$_} eq 'CODE'
			? ($resolver->{update_or_create}->{$_}->($request->{$_}, $request, $resolver))
			: ($_ => $request->{$_})
		} keys %$request)
	);
};

sub update {
	my $class = shift;
	my $request = shift;
	my $resolver = shift;

	return () unless defined $request->{oper} && $request->{oper} eq 'edit';

	return (map {
		defined $_ && $resolver->{update_or_create}->{$_} && ref $resolver->{update_or_create}->{$_} eq 'CODE'
		? ($resolver->{update_or_create}->{$_}->($request->{$_}, $request, $resolver))
		: ($_ => $request->{$_})
	} $request->{celname} ? ($request->{celname}) : (keys %$request));
}

sub delete {
	my $class = shift;
	my $request = shift;
	my $resolver = shift;

	return () unless defined $request->{oper} && $request->{oper} eq 'del';
};

1;
