package Mojolicious::Plugin::Crud;
use Mojo::Base 'Mojolicious::Plugin';

# Currently a DBIC-only plugin

our $VERSION = '0.01';

use Mojo::Util qw(decamelize);
use Mojo::Exception;

use Data::Dumper;

#use Jqgrid;

has 'result';
has 'id';
has 'controller';
has 'resultset';
has 'request';
has 'failed_input';

my %op = (
	'eq' => { pre => '',  post => '',  op => '=', },              # equal
	'ne' => { pre => '',  post => '',  op => '!=', },             # not equal
	'lt' => { pre => '',  post => '',  op => '<', },              # less
	'le' => { pre => '',  post => '',  op => '<=', },             # less or equal
	'gt' => { pre => '',  post => '',  op => '>', },              # greater
	'ge' => { pre => '',  post => '',  op => '>=', },             # greater or equal
	'bw' => { pre => '',  post => '%', op => '-like', },          # begins with
	'bn' => { pre => '',  post => '%', op => '-not_like', },      # does not begin with
	'in' => { pre => '%', post => '%', op => '-like', },          # is in (reverse contains)
	'ni' => { pre => '%', post => '%', op => '-not_like', },      # is not in (reverse does not contain)
	'ew' => { pre => '%', post => '',  op => '-like', },          # ends with
	'en' => { pre => '%', post => '',  op => '-not_like', },      # does not end with
	'cn' => { pre => '%', post => '%', op => '-like', },          # contains
	'nc' => { pre => '%', post => '%', op => '-not_like', },      # does not contain
	'nu' => { pre => '',  post => '',  op => {'=' => undef}, },   # is null
	'nn' => { pre => '',  post => '',  op => {'!=' => undef}, },  # is not null
);

sub register {
	my ($self, $app) = @_;

	# This requires use of Mojo::Plugin::View
	$app->routes->add_shortcut(crud => sub {
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
		$r1->dbroute(['/create' => $result_class => $source], {crud => 'create'}, name => "create_$name");
		$r1->dbroute(['/' => $result_class => $source], {crud => 'read'}, name => "read_$name");
		$r1->dbroute(['/update' => $result_class => $source], {crud => 'update'}, name => "update_$name");
		$r1->dbroute(['/delete' => $result_class => $source], {crud => 'delete'}, \'delete', name => "delete_$name");
		$r1;
	});

	$app->helper(crud => sub {
		my ($c, $op, $rs) = @_;
		$self->controller($c);
		$self->resultset($rs);
		$self->request($c->req->params->to_hash);
		$self->id($self->request->{id});
		$self->result({});
		{
			no strict;
			$self->result->{relationships} = ${($rs->result_class).'::relationships'};
			$self->result->{read} = ${($rs->result_class).'::read'};
			$self->result->{edit} = ${($rs->result_class).'::edit'};
			$self->result->{validate} = ${($rs->result_class).'::validate'};
		}
		$self->$op;
	});
}

sub cell {
	my ($self, $celname, $value) = @_;
	return () unless $celname && $celname ne 'id';
	my ($edit, $validate) = ($self->result->{edit}, $self->result->{validate});

	my %cells;
	my $_celname = $edit->{$celname} if $edit && defined $edit->{$celname};
	$celname = ref $_celname eq 'CODE' ? $_celname : (ref $_celname eq 'SCALAR' || ! ref $_celname) ? ($_celname || $celname) : $celname;
	if ( ref $celname eq 'SCALAR' ) {
		%cells = ($$celname => $value);
	} elsif ( !ref $celname ) {
		%cells = ($self->_me($celname) => $value);
	} elsif ( ref $celname eq 'CODE' ) {
		%cells = $celname->($value);
	} else {
		return ();
	}
	warn Dumper({cell=>{%cells}}) if $ENV{CRUD_DEBUG};
	while ( my ($key, $value) = each %cells ) {
		next unless defined $validate->{$key};
		next unless $value !~ $validate->{$key}->[0];
		delete $cells{$key};
		$self->failed_input->{$key} = $validate->{$key}->[1];
	}
	return %cells;
}

sub row {
	my $self = shift;
	my $req = $self->request or return ();
	my %row = $req->{celname} ? $self->cell($req->{celname} => $req->{$req->{celname}}) : (map { $self->cell($_, $req->{$_}) } keys %$req);
	my $row;
	while ( my ($key, $value) = each %row ) {
		my ($table, $field) = split /\./, $self->_me($key);
		$row->{$table}->{$field} = $value;
	}
	warn Dumper({row=>$row}) if $ENV{CRUD_DEBUG};
	return $row;
};

sub filters {
	my ($self, $filters) = @_;
	$filters ? (%{_complex_search($filters)}) : ();
};

sub where {
	my $self = shift;
	return $self->filters if $self->request->{filters};
	my ($field, $op, $string) = ($self->request->{searchField}, $self->request->{searchOper}, $self->request->{searchString});
	return () unless $field && $op && defined $string;
	my ($read) = ($self->result->{read});
	$op{$op}{string} = $string;
	my $_field = $read->{$field} if $read && defined $read->{$field};
	$field = ref $_field eq 'ARRAY' && defined $_field->[0] ? $_field->[0] : (ref $_field eq 'SCALAR' || ! ref $_field) ? ($_field || $field) : $field;
	if ( ref $field eq 'SCALAR' ) {
		$field = $$field;
	} elsif ( !ref $field ) {
		$field = $self->_me($field);
	} elsif ( ref $field eq 'CODE' ) {
		return $field->($op{$op});
	} else {
		return ();
	}
	return $field => {$op{$op}{op} => ref $op{$op}{op} ? $op{$op}{op} : $op{$op}{pre}.$op{$op}{string}.$op{$op}{post}};
};

sub order_by {
	my $self = shift;
	my ($sidx, $sord) = ($self->request->{sidx}, $self->request->{sord});
	return () unless $sidx;
	my ($read) = ($self->result->{read});
	my @sidx = split /,/, $sidx;
	my @sord = split /,/, $sord;

	my @order_by = ();
	foreach ( 0..$#sidx ) {
		my ($sidx, $sord) = ($sidx[$_], $sord[$_]||'asc');
		my $_sidx = $read->{$sidx} if $read && defined $read->{$sidx};
		$sidx = ref $_sidx eq 'ARRAY' && defined $_sidx->[1] ? $_sidx->[1] : (ref $_sidx eq 'SCALAR' || ! ref $_sidx) ? ($_sidx || $sidx) : $sidx;
		if ( ref $sidx eq 'SCALAR' ) {
			$sidx = $$sidx;
		} elsif ( !ref $sidx ) {
			$sidx = $self->_me($sidx);
		} else {
			next;
		}
		push @order_by, {"-$sord" => $sidx->()} and next if ref $sidx eq 'CODE';
		push @order_by, {"-$sord" => $sidx};
	}
	return @order_by ? (order_by => [@order_by]) : ();
};

sub pager {
	my $self = shift;
	my ($page, $rows) = ($self->request->{page}, $self->request->{rows});
	return (page => ($page||1), (defined $rows ? (rows => $rows) : ()));
}

sub insert {
	my $self = shift;
	my $rs = $self->resultset;
	my $result_class = $self->resultset->result_class;
	my $id = $self->id;

	return Mojo::Exception->throw('Invalid insert request') unless delete $self->request->{oper} eq 'add';

	my $data = $self->row;
	return Mojo::Exception->throw($self->failed_input) if $self->failed_input;
	my $r = $rs->new_result({});
	$r = $result_class->_insert($r, $rs, $data) if $result_class->can('_insert');
	$r = $result_class->_create($r, $rs, $data) if $result_class->can('_create');
	return $r->insert_with_related($data);
}
*create = *insert;

sub search {
	my $self = shift;
	my $rs = $self->resultset;
	my $result_class = $self->resultset->result_class;

	$rs = $rs->search({}, {prefetch => $self->result->{relationships}}) if defined $self->result->{relationships};
	$rs = $rs->search({$self->where}, {$self->order_by, $self->pager});
	$rs = $result_class->_search($rs, $self->request) if $result_class->can('_search');
	$rs = $result_class->_read($rs, $self->request) if $result_class->can('_read');
	return $rs;
}
*read = *search;

sub update {
	my $self = shift;
	my $rs = $self->resultset;
	my $result_class = $self->resultset->result_class;
	my $id = $self->id;

	return Mojo::Exception->throw('Invalid update request') unless delete $self->request->{oper} eq 'edit';

	my $data = $self->row;
	return Mojo::Exception->throw($self->failed_input) if $self->failed_input;
	my $r = $rs->find($id);
	return Mojo::Exception->throw("Update error: Cannot find id $id") unless defined $r;
	$r = $result_class->_update($r, $rs, $data) if $result_class->can('_update');
	return $r->update_with_related($data);
}

sub delete {
	my $self = shift;
	my $result_class = $self->resultset->result_class;
	my $id = $self->id;

	return Mojo::Exception->throw('Invalid delete request') unless delete $self->request->{oper} eq 'del';

	my @err;
	foreach ( split /,/, $id ) {
		warn "Deleting $_\n" if $ENV{CRUD_DEBUG};
		my $r = $self->resultset->find($_);
		push @err, 0 and next unless defined $r;
		$r = $result_class->_delete($r, $self->resultset, $self->request) if $result_class->can('_delete');
		push @err, $r->delete;
	}
	return wantarray ? @err : scalar @err;
}

sub _me {
	my $self = shift;
	my $field = shift;
	ref $field || $field =~ /\./ ? $field : $self->resultset->current_source_alias.'.'.$field;
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
