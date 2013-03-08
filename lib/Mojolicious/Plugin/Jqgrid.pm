package Mojolicious::Plugin::Jqgrid;
use Mojo::Base 'Mojolicious::Plugin';

# Currently a DBIC-only plugin

our $VERSION = '0.01';

use Mojo::Util qw(decamelize);
use Mojo::Exception;

use Data::Dumper;

use DBIx::Class::Crud;

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
		$r1->dbroute(['/delete' => $result_class => $source], {jqgrid => 'delete'}, \'delete', name => "delete_$name");
		$r1;
	});

	$app->helper(jqgrid => sub {
		my ($c, $op, $rs) = @_;
		my $crud = new DBIx::Class::Crud;
		$crud->resultset($c->db->resultset($c->param('results')));
		$crud->request(ref $c->merged ? $c->merged : {$c->merged});
		delete $crud->request->{_};
		$crud->filters(\&filters);
		$crud->where(\&where);
		$crud->order_by(\&order_by);
		$crud->pager(\&pager);
		return $crud;
	});
}

sub where {
	my $self = shift;
	return $self->filters if $self->request->{filters};
	my ($field, $op, $string) = ($self->request->{searchField}, $self->request->{searchOper}, $self->request->{searchString});
	return () unless $field && $op && defined $string;
	my ($read) = ($self->result->{read});
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

sub filters {
	my ($self, $filters) = @_;
	$filters ? (%{_complex_search($filters)}) : ();
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
