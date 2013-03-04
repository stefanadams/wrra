package Mojolicious::Plugin::Jqgrid;
use Mojo::Base 'Mojolicious::Plugin';

our $VERSION = '0.01';

use Mojo::Util qw(decamelize);

sub register {
	my ($self, $app) = @_;

	# This requires use of Mojo::Plugin::View
	$app->routes->add_shortcut(jqgrid => sub {
		my $r = shift;
		my ($route, $view, $source);
		($route, $view, $source) = @$_ == 1 ? (undef, @$_, @$_) : @$_ == 2 ? (undef, @$_) : (@$_) foreach grep { ref eq 'ARRAY' } @_;
		%_ = grep { !ref } @_;
		$_{name} =~ s/\W+//g if $_{name};
		my $name = decamelize(delete $_{name} // $view);
		$route =~ s/^\/+// if $route;
		$route //= $name;   
		my $extra_path = delete $_{extra_path};
		my $r1 = $r->under("/$name");
		$r1->view(['/create' => $view => $source], {jqgrid => 'create'}, name => "create_$name");
		$r1->view(['/' => $view => $source], {jqgrid => 'read'}, name => "read_$name");
		$r1->view(['/update' => $view => $source], {jqgrid => 'update'}, name => "update_$name");
		$r1->view(['/delete' => $view => $source], {jqgrid => 'delete'}, name => "delete_$name");
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
	my $request = ref $c->myrequest ? $c->myrequest : {$c->myrequest};

	return {} unless $request->{oper} eq 'add';

	my $data = $self->_process_fields($rs, $request->{id} => {%$request});

	warn "Inserting new record\n" if $ENV{JQGRID_DEBUG};
	warn Dumper({insert=>$data}) if $ENV{JQGRID_DEBUG};
	my $insert = $rs->new_result({});
	$insert->$_($data->{$_}) for keys %$data;
	return $insert->insert;

	my $id = $insert->insert->id;
	return {res=>($id?'ok':'err'), msg=>($id?'ok':'err'), id=>$id};
}

sub search {
	my $self = shift;
	my ($c, $rs) = @_;
	my $request = ref $c->myrequest ? $c->myrequest : {$c->myrequest};

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
		#if ( $result_class->can($cb) ) {
		#	$field = $result_class->$cb($self, $request);
		#} else {
			push @prefetch, ((split /\./, $field)[0]) if $field =~ /\./;
		#}
		return $self->_me($rs, $field) => (ref $op{$op}{op} ? $op{$op}{op} : {$op{$op}{op} => $op{$op}{pre}.$string.$op{$op}{post}});
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
			#$sidx = $result_class->$cb($self, $request) if $result_class->can($cb);
			push @prefetch, ((split /\./, $sidx)[0]) if $sidx =~ /\./;
			push @order_by, {"-$sord" => $self->_me($rs, $sidx)};
		}
		return @order_by ? (order_by => [@order_by]) : ();
	};

	$rs = ($rs->result_class)->_search($rs, $request) if ($rs->result_class)->can('_search');
	$rs = $rs->search({}, {prefetch => [@prefetch]}) if @prefetch;
	$rs = $rs->search({$search->($request->{searchField}, $request->{searchOper}, $request->{searchString})});
	$rs = $rs->search({$filters->($request->{filters})});
	$rs = $rs->search({}, {page => ($request->{page}||1), (defined $request->{rows} ? (rows => $request->{rows}) : ())});
	$rs = $rs->search({}, {$order_by->($request->{sidx}, $request->{sord})});
	return $rs;
}

sub update {
	my $self = shift;
	my ($c, $rs) = @_;
	my $request = ref $c->myrequest ? $c->myrequest : {$c->myrequest};

	return {} unless $request->{oper} eq 'edit';

	my $data;
	if ( $request->{celname} ) {
		# Cell Edit
		warn "Cell edit\n" if $ENV{JQGRID_DEBUG};
		$data = $self->_process_fields($rs, $request->{id} => {$request->{celname} => $request->{$request->{celname}}});
	} else {
		# Form Edit
		warn "Form edit\n" if $ENV{JQGRID_DEBUG};
		$data = $self->_process_fields($rs, $request->{id} => {%$request});
	}
	warn Dumper({update=>$data}) if $ENV{JQGRID_DEBUG};
	my $record = $rs->find($request->{id}) or return undef;
	$record->$_($data->{$_}) for keys %$data;
	return $record->update;

	return {res=>($record->update?'ok':'err'),msg=>''};
}

sub delete {
	my $self = shift;
	my ($c, $rs) = @_;
	my $request = ref $c->myrequest ? $c->myrequest : {$c->myrequest};

	return {} unless $request->{oper} eq 'del';

	my @err;
	foreach ( split /,/, $request->{id} ) {
		warn "Deleting $_\n" if $ENV{JQGRID_DEBUG};
		my $delete = $rs->find($_) or next;
		push @err, $delete->delete;
	}
	return wantarray ? @err : scalar @err;

	return {res=>(!@err?'ok':'err'),msg=>''};
}

sub _me {
	my $self = shift;
	my $rs = shift;
	my $field = shift;
	ref $field || $field =~ /\./ ? $field : $rs->current_source_alias.'.'.$field;
}

sub _process_fields {
	my $self = shift;
	my $rs = shift;
	my $id = shift;
	my %request = %{+shift};
	%_ = %request;
	my $pk = {map { $_ => 1 } $rs->result_source->primary_columns};
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
				$updates{$table} ||= $rs->search_related($table)->find($_{"$table.id"});
			} else {
				warn Dumper({$id=>{$table => {$field => $value}}}) if $ENV{JQGRID_DEBUG};
				$updates{$table} ||= $rs->find($id)->$table;
			}
			$updates{$table}->$field($value);
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
