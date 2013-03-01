package DBIx::Class::Helper::ResultSet::Jqgrid;
{
  $DBIx::Class::Helper::ResultSet::Jqgrid::VERSION = '0.1.0';
}

use strict;
use warnings;

use Data::Dumper;

my $object_key = '__Helper__ResultSet__Jqgrid__JQGRID';

sub jqgrid {
	my $self = shift;
	my $result_class = $self->result_class;
	$result_class->load_components(qw{Helper::Result::Jqgrid}); 
	$self->{$object_key} = ref $_[0] ? $_[0] : {@_};
	$self;
}

sub insert {
	my $self = shift;
	my $request = $self->{$object_key} or return $self->next::method(@_);
	warn "CREATE JQGRID STYLE\n\n" if $ENV{JQGRID_DEBUG};

	return undef unless $request->{oper} eq 'add';

	my $result_class = $self->result_class;
	warn "Using Result Class $result_class\n" if $ENV{JQGRID_DEBUG};

	my $data = $self->_process_fields($request->{id} => {%$request});

	warn "Inserting new record\n" if $ENV{JQGRID_DEBUG};
	warn Dumper({insert=>$data}) if $ENV{JQGRID_DEBUG};
	my $insert = $self->new_result({});
	$insert->$_($data->{$_}) for keys %$data;
	return $insert->insert->id;
}

sub search {
	my $self = shift;
	my $request = $self->{$object_key} or return $self->next::method(@_);
	warn "SEARCH JQGRID STYLE\n\n" if $ENV{JQGRID_DEBUG};

	my $result_class = $self->result_class;
	warn "Using Result Class $result_class\n" if $ENV{JQGRID_DEBUG};

	#my $prefetch = $result_class->_prefetch if $result_class->can('_prefetch');
	#my $join = [$self->result_source->relationships] if $self->result_source->relationships;

	my %op = (
		'eq' => { pre => '',  post => '',  op => '=', },            # equal
		'ne' => { pre => '',  post => '',  op => '!=', },           # not equal
		'lt' => { pre => '',  post => '',  op => '<', },            # less
		'le' => { pre => '',  post => '',  op => '<=', },           # less or equal
		'gt' => { pre => '',  post => '',  op => '>', },            # greater
		'ge' => { pre => '',  post => '',  op => '>=', },           # greater or equal
		'bw' => { pre => '',  post => '%', op => '-like', },        # begins with
		'bn' => { pre => '',  post => '%', op => '-not_like', },    # does not begin with
		'in' => { pre => '%', post => '%', op => '-like', },        # is in (reverse contains)
		'ni' => { pre => '%', post => '%', op => '-not_like', },    # is not in (reverse does not contain)
		'ew' => { pre => '%', post => '',  op => '-like', },        # ends with
		'en' => { pre => '%', post => '',  op => '-not_like', },    # does not end with
		'cn' => { pre => '%', post => '%', op => '-like', },        # contains
		'nc' => { pre => '%', post => '%', op => '-not_like', },    # does not contain
		'nu' => { pre => '',  post => '',  op => {'=' => undef}, },
		'nn' => { pre => '',  post => '',  op => {'!=' => undef}, },
	);

	my @prefetch = ();

	my $filters = sub {
		my ($filters) = @_;
		$filters ? (%{_complex_search($filters)}) : ();
	};

	my $search = sub {
		my ($field, $op, $string) = @_;
		return () unless $field && $op && defined $string;
		# Need a callback here to reference ResultView::Result::
		my $cb = '_search_'.$field;
		if ( $result_class->can($cb) ) {
			$field = $result_class->$cb($self, $request);
		} else {
			push @prefetch, ((split /\./, $field)[0]) if $field =~ /\./;
		}
		return $self->_me($field) => (ref $op{$op}{op} ? $op{$op}{op} : $op{$op}{pre}.$string.$op{$op}{post});
	};

	my $order_by = sub {
		my ($sidx, $sord) = @_;
		return () unless $sidx;
		my @sidx = split /,/, $sidx;
		my @sord = split /,/, ($sord||'asc');

		my @order_by = ();
		foreach ( 0..$#sidx ) {
			my ($sidx, $sord) = ($sidx[$_], $sord[$_]);
			# Need a callback here to reference ResultView::Result::
			my $cb = '_order_by_'.$sidx;
			$sidx = $result_class->$cb($self, $request) if $result_class->can($cb);
			push @prefetch, ((split /\./, $sidx)[0]) if $sidx =~ /\./;
			push @order_by, {"-$sord" => $self->_me($sidx)};
		}
		return @order_by ? (order_by => [@order_by]) : ();
	};

	$self = $self->next::method({}, {prefetch => [@prefetch]}) if @prefetch;
	$self = $self->next::method({$search->($request->{searchField}, $request->{searchOper}, $request->{searchString})});
	$self = $self->next::method({$filters->($request->{filters})});
	$self = $self->next::method({}, {page => ($request->{page}||1), (defined $request->{rows} ? (rows => $request->{rows}) : ())});
	$self = $self->next::method({}, {$order_by->($request->{sidx}, $request->{sord})});
	return $self->jqgrid($request);
}

sub update {
	my $self = shift;
	my $request = $self->{$object_key} or return $self->next::method(@_);
	warn "UPDATE JQGRID STYLE\n\n" if $ENV{JQGRID_DEBUG};

	return undef unless $request->{oper} eq 'edit';

	my $result_class = $self->result_class;
	warn "Using Result Class $result_class\n" if $ENV{JQGRID_DEBUG};

	my $data;
	if ( $request->{celname} ) {
		# Cell Edit
		warn "Cell edit\n" if $ENV{JQGRID_DEBUG};
		$data = $self->_process_fields($request->{id} => {$request->{celname} => $request->{$request->{celname}}});
	} else {
		# Form Edit
		warn "Form edit\n" if $ENV{JQGRID_DEBUG};
		$data = $self->_process_fields($request->{id} => {%$request});
	}
	warn Dumper({update=>$data}) if $ENV{JQGRID_DEBUG};
	my $record = $self->find($request->{id}) or return undef;
	$record->$_($data->{$_}) for keys %$data;
	$record->update;
	return $record->id;
}

sub delete {
	my $self = shift;
	my $request = $self->{$object_key} or return $self->next::method(@_);
	warn "DELETE JQGRID STYLE\n\n" if $ENV{JQGRID_DEBUG};

	my $result_class = $self->result_class;
	warn "Using Result Class $result_class\n" if $ENV{JQGRID_DEBUG};

	foreach ( split /,/, $request->{id} ) {
		warn "Deleting $_\n" if $ENV{JQGRID_DEBUG};
		my $delete = $self->find($_) or next;
		$delete->delete;
	}
}

sub all {
	my $self = shift;
	my $request = $self->{$object_key} or return $self->next::method(@_);
	warn "ALL/FIRST JQGRID STYLE\n\n" if $ENV{JQGRID_DEBUG};

	return {   
		page => $self->pager->current_page||1,
		total => $self->pager->last_page||1,
		records => $self->pager->total_entries||0,
		rows => [$self->next::method], # TO_JSON
	} if ref $self;
};
*first = *all;

#sub first {
#	my $self = shift;
#	my $request = $self->{$object_key} or return $self->next::method(@_);
#	warn "FIRST JQGRID STYLE\n\n" if $ENV{JQGRID_DEBUG};
#
#	return {   
#		page => $self->pager->current_page||1,
#		total => $self->pager->last_page||1,
#		records => $self->pager->total_entries||0,
#		rows => [$self->next::method], # TO_JSON
#	} if ref $self;
#};

#################

sub _me {
	my $self = shift;
	my $field = shift;
	ref $field || $field =~ /\./ ? $field : $self->current_source_alias.'.'.$field;
}

sub _process_fields {
	my $self = shift;
	my $id = shift;
	my %request = %{+shift};
	%_ = %request;
	my $pk = {map { $_ => 1 } $self->result_source->primary_columns};
	my %updates = ();
	while ( my ($key, $value) = each %_ ) {
		if ( $pk->{$key} ) {
			delete $_{$key};
		} elsif ( $key =~ /\./ ) {
			my ($table, $field) = split /\./, $key;
			delete $_{$key};
			next if $field eq 'id';
			warn "Update linked table $table\n" if !$ENV{JQGRID_DEBUG};
			if ( $id eq '_empty' ) {
				warn Dumper({$_{"$table.id"}=>{$table => {$field => $value}}}) if $ENV{JQGRID_DEBUG};
				$updates{$table} ||= $self->search_related($table)->find($_{"$table.id"});
			} else {
				warn Dumper({$id=>{$table => {$field => $value}}}) if $ENV{JQGRID_DEBUG};
				$updates{$table} ||= $self->find($id)->$table;
			}
			$updates{$table}->$field($value);
		} else {
			delete $_{$key} unless $self->result_source->has_column($key);
		}
	}
	$updates{$_}->update for keys %updates;
	return {%_};
}

# package Catalyst::TraitFor::Controller::jQuery::jqGrid::Search;
# Copyright 2012 Scott R. Keszler.
sub _complex_search {
  my ($cs_ref) = @_;
  if ( ref $cs_ref eq 'HASH' ) {

    # hash keys possible: groupOp, groups, rules
    # in complex search, only groupOp is certain to be present
    # (although a complex search with only a groupOp isn't really very complex...)

    if ( defined $cs_ref->{groupOp} ) {

      my $group_op = '-' . lc $cs_ref->{groupOp};

      my $group_aref;
      $group_aref = _complex_search($cs_ref->{groups}) if defined $cs_ref->{groups} && @{$cs_ref->{groups}};

      my $rule_aref;
      $rule_aref = _complex_search($cs_ref->{rules}) if defined $cs_ref->{rules} && @{$cs_ref->{rules}};

      if ( $group_aref && $rule_aref ) {
        push @{$group_aref}, $rule_aref;
      }
      elsif ( $rule_aref ) {
        $group_aref = $rule_aref;
      }
      return { $group_op => $group_aref } if $group_aref;
    }

    # empty search
    return {};

  }
  elsif ( ref $cs_ref eq 'ARRAY' ) {

    # array can be rules or groups, either is array of hashes
    my $rg_aref;
    for my $rg ( @{$cs_ref} ) {
      if ( defined $rg->{groupOp} ) {

        # this one's a group
        my $group_aref = _complex_search($rg);
        push @{$rg_aref}, $group_aref if $group_aref;
      }
      elsif ( defined $rg->{field} ) {

        # this one's a rule, handle like simple search
        my $rule_aref = jqGrid_search(
            undef,
            {   _search      => 'true',
            searchField  => $rg->{field},
            searchOper   => $rg->{op},
            searchString => $rg->{data},
            },
            );
        push @{$rg_aref}, $rule_aref if $rule_aref;
      }
      else {
        return 'not a jqGrid group/rule ARRAY';    # this shouldn't happen...
      }
    }
    return $rg_aref;
  }
} ## end sub _complex_search

1;
