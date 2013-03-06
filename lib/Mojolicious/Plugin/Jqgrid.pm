package Mojolicious::Plugin::Jqgrid;
use Mojo::Base 'Mojolicious::Plugin';

# Currently a DBIC-only plugin

our $VERSION = '0.01';

use Mojo::Util qw(decamelize);
use Mojo::Exception;

use Data::Dumper;

sub register {
	my ($self, $app) = @_;

	# This requires use of Mojo::Plugin::View
	$app->routes->add_shortcut(jqgrid => sub {
		my $r = shift;
		my ($route, $result_class, $source);
		($route, $result_class, $source) = @$_ == 1 ? (undef, @$_, @$_) : @$_ == 2 ? (undef, @$_) : (@$_) foreach grep { ref eq 'ARRAY' } @_;
		%_ = grep { !ref } @_;
		$_{name} =~ s/\W+//g if $_{name};
		my $name = decamelize(delete $_{name} // $result_class);
		$route =~ s/^\/+// if $route;
		$route //= $name;   
		my $extra_path = delete $_{extra_path};
		my $r1 = $r->under("/$name");
		$r1->dbroute(['/create' => $result_class => $source], {jqgrid => 'create'}, name => "create_$name");
		$r1->dbroute(['/' => $result_class => $source], {jqgrid => 'read'}, name => "read_$name");
		$r1->dbroute(['/update' => $result_class => $source], {jqgrid => 'update'}, name => "update_$name");
		$r1->dbroute(['/delete' => $result_class => $source], {jqgrid => 'delete'}, name => "delete_$name");
		$r1;
	});

	$app->helper(jqgrid => sub {
		my $c = shift;
		my ($op, $rs) = @_;
		$self->$op($c, $rs);
	});
}

sub insert {
	my $self = shift;
	my ($c, $rs) = @_;
	my $request = ref $c->merged ? $c->merged : {$c->merged};
	my ($relationships, $edit, $validate);
	{
		no strict;
		$relationships = ${($rs->result_class).'::relationships'};
		$edit = ${($rs->result_class).'::edit'};
		$validate = ${($rs->result_class).'::validate'};
	}

	return {} unless $request->{oper} eq 'add';

	my $data = $self->_process_fields($rs, $request->{id} => {%$request});

	warn "Inserting new record\n" if $ENV{JQGRID_DEBUG};
	warn Dumper({insert=>$data}) if $ENV{JQGRID_DEBUG};
	my @failed_input = map { $_ => $validate->{$_}->[1] } grep { defined $validate->{$_} && $data->{$_} !~ $validate->{$_}->[0] } keys %$data;
	return Mojo::Exception->throw([@failed_input]) if @failed_input;
	$rs = $rs->new_result({});
	$rs->$_($data->{$_}) for keys %$data;
	$rs = ($rs->result_class)->_insert($rs, $request) if ($rs->result_class)->can('_insert');
	return ref $rs ? $rs->insert : $rs;
}

sub search {
	my $self = shift;
	my ($c, $rs) = @_;
	my $request = ref $c->merged ? $c->merged : {$c->merged};
	my ($relationships, $read);
	{
		no strict;
		$relationships = ${($rs->result_class).'::relationships'};
		$read = ${($rs->result_class).'::read'};
	}

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

	my $filters = sub {
		my ($filters) = @_;
		$filters ? (%{_complex_search($filters)}) : ();
	};

	my $search = sub {
		my ($field, $op, $string) = @_;
		return () unless $field && $op && defined $string;
		$op{$op}{string} = $string;
		my $_field = $read->{$field} if $read && defined $read->{$field};
		$field = ref $_field eq 'ARRAY' && defined $_field->[0] ? $_field->[0] : ref $_field eq 'SCALAR' || ! ref $_field ? $_field || $field : $field;
		if ( ref $field eq 'SCALAR' ) {
			$field = $$field;
		} elsif ( !ref $field ) {
			$field = $self->_me($rs, $field);
		} elsif ( ref $field eq 'CODE' ) {
			return $field->($op{$op});
		} else {
			return ();
		}
		return $field => {$op{$op}{op} => ref $op{$op}{op} ? $op{$op}{op} : $op{$op}{pre}.$op{$op}{string}.$op{$op}{post}};
	};

	my $order_by = sub {
		my ($sidx, $sord) = @_;
		return () unless $sidx;
		my @sidx = split /,/, $sidx;
		my @sord = split /,/, $sord;

		my @order_by = ();
		foreach ( 0..$#sidx ) {
			my ($sidx, $sord) = ($sidx[$_], $sord[$_]||'asc');
			my $_sidx = $read->{$sidx} if $read && defined $read->{$sidx};
			$sidx = ref $_sidx eq 'ARRAY' && defined $_sidx->[1] ? $_sidx->[1] : ref $_sidx eq 'SCALAR' || ! ref $_sidx ? $_sidx || $sidx : $sidx;
			if ( ref $sidx eq 'SCALAR' ) {
				$sidx = $$sidx;
			} elsif ( !ref $sidx ) {
				$sidx = $self->_me($rs, $sidx);
			} else {
				next;
			}
			push @order_by, {"-$sord" => $sidx->()} and next if ref $sidx eq 'CODE';
			push @order_by, {"-$sord" => $sidx};
		}
		return @order_by ? (order_by => [@order_by]) : ();
	};

	$rs = $rs->search({}, {prefetch => $relationships}) if defined $relationships;
	$rs = $rs->search({$search->($request->{searchField}, $request->{searchOper}, $request->{searchString})});
	$rs = $rs->search({$filters->($request->{filters})});
	$rs = $rs->search({}, {$order_by->($request->{sidx}, $request->{sord})});
	$rs = $rs->search({}, {page => ($request->{page}||1), (defined $request->{rows} ? (rows => $request->{rows}) : ())});
	$rs = ($rs->result_class)->_search($rs, $request) if ($rs->result_class)->can('_search');
	return $rs;
}

sub update {
	my $self = shift;
	my ($c, $rs) = @_;
	my $request = ref $c->merged ? $c->merged : {$c->merged};
	my ($relationships, $edit, $validate);
	{
		no strict;
		$relationships = ${($rs->result_class).'::relationships'};
		$edit = ${($rs->result_class).'::edit'};
		$validate = ${($rs->result_class).'::validate'};
	}

	return {} unless $request->{oper} eq 'edit';

	my $data;
	if ( $request->{celname} ) {
		# Cell Edit
		warn "Cell edit\n" if $ENV{JQGRID_DEBUG};
		$data = $self->_edit($rs, $request->{id} => {$request->{celname} => $request->{$request->{celname}}});
	} else {
		# Form Edit
		warn "Form edit\n" if $ENV{JQGRID_DEBUG};
		$data = $self->_edit($rs, $request->{id} => {%$request});
	}
	warn Dumper([update=>$request->{id}=>$data]) if $ENV{JQGRID_DEBUG};
	my @failed_input = map { $_ => $validate->{$_}->[1] } grep { defined $validate->{$_} && $data->{$_} !~ $validate->{$_}->[0] } keys %$data;
	return Mojo::Exception->throw([@failed_input]) if @failed_input;
	$rs = $rs->find($request->{id}) or return undef;
	$rs->$_($data->{$_}) for keys %$data;
	$rs = ($rs->result_class)->_update($rs, $request) if ($rs->result_class)->can('_update');
	return ref $rs ? $rs->update : $rs;
}

sub delete {
	my $self = shift;
	my ($c, $rs) = @_;
	my $request = ref $c->merged ? $c->merged : {$c->merged};
	my ($relationships);
	{
		no strict;
		$relationships = ${($rs->result_class).'::relationships'};
	}

	return {} unless $request->{oper} eq 'del';

	my @err;
	foreach ( split /,/, $request->{id} ) {
		warn "Deleting $_\n" if $ENV{JQGRID_DEBUG};
		my $_rs = $rs->find($_) or next;
		$_rs = ($rs->result_class)->_update($_rs, $request) if ($rs->result_class)->can('_delete');
		push @err, ref $_rs ? $_rs->delete : $_rs;
	}
	return wantarray ? @err : scalar @err;
}

sub _me {
	my $self = shift;
	my $rs = shift;
	my $field = shift;
	ref $field || $field =~ /\./ ? $field : $rs->current_source_alias.'.'.$field;
}

sub _edit {
	my $self = shift;
	my $rs = shift;
	my $id = shift;
	my %request = %{+shift};
	%_ = %request;
	my $pk = {map { $_ => 1 } $rs->result_source->primary_columns};
	my ($edit, $validate);
	{
		no strict;  
		$edit = ${($rs->result_class).'::edit'};
		$validate = ${($rs->result_class).'::validate'};
	}
	my %updates = ();
	while ( my ($key, $value) = each %_ ) {
		if ( $pk->{$key} ) {
			delete $_{$key};
		} elsif ( $edit->{$key} && (ref $edit->{$key} eq 'CODE' || !ref $edit->{$key}) ) {
			my %pair = ref $edit->{$key} eq 'CODE' ? $edit->{$key}->($value) : ($edit->{$key}, $value);
			delete $_{$key};
			while ( my ($key, $value) = each %pair ) {
				if ( $key =~ /\./ ) {
					my ($table, $field) = split /\./, $key;
					next if $field eq 'id';
					warn "Update linked table $table\n" if $ENV{JQGRID_DEBUG};
					if ( $id eq '_empty' ) {
						warn Dumper({$_{"$table.id"}=>{$table => {$field => $value}}}) if $ENV{JQGRID_DEBUG};
						$updates{$table} ||= $rs->search_related($table)->find($_{"$table.id"});
					} else {
						warn Dumper({$id=>{$table => {$field => $value}}}) if $ENV{JQGRID_DEBUG};
						$updates{$table} ||= $rs->find($id)->$table;
					}
					$updates{$table}->$field($value) if not defined $validate->{$key} || (defined $validate->{$key} && $value =~ $validate->{$key}->[0]);
				} else {
					$_{$key}=$value if $rs->result_source->has_column($key);
				}
			}
		} else {
			delete $_{$key} unless $rs->result_source->has_column($key);
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
