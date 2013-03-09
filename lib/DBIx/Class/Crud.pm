package DBIx::Class::Crud;

use strict;
use warnings;

our $VERSION = '0.01';

use Data::Dumper;

sub new {
	my $class = shift;
	my $self = {@_};
	bless $self, $class;
}

sub resultset {
	my $self = shift;
	$self->{resultset} = $_[0] if ref $_[0];
	$self->{resultset};
}
sub result_class { shift->resultset->result_class }
sub result {
	my $self = shift;
	my $result_class = $self->result_class;
	no strict;
	$self->{relationships} = ${$result_class.'::relationships'};
	$self->{read} = ${$result_class.'::read'};
	$self->{edit} = ${$result_class.'::edit'};
	$self->{validate} = ${$result_class.'::validate'};
	return $self;
}

sub request {
	my $self = shift;
	$self->{request} = $_[0] if ref $_[0] eq 'HASH';
	$self->{request};
}
sub id {
	my $self = shift;
	$self->request->{$self->{id}||'id'};
}

sub _what {
	my $self = shift;
	my $what = shift;
	return $self->{$what} = [@_] if ref $_[0] eq 'CODE';
	return () unless $self->{$what};
	my @what = @{$self->{$what}};
	my $code = shift @what;
	$code ? $code->($self, @what) : ();
}

sub where {
	my $self = shift;
	return $self->_what(where => @_);
}

sub filters {
	my $self = shift;
	return $self->_what(filters => @_);
}

sub order_by {
	my $self = shift;
	return $self->_what(order_by => @_);
}

sub pager {
	my $self = shift;
	return $self->_what(pager => @_);
}

sub insert {
        my $self = shift;
        my $rs = $self->resultset;
        my $result_class = $self->result_class;
        my $id = $self->id;
        my $request = $self->_row;

        return $rs->throw_exception($self->_exception) if $self->_exception;
        my $r = $rs->new_result({});
        $r = $result_class->_insert($r, $rs, $request) if $result_class->can('_insert');
        $r = $result_class->_create($r, $rs, $request) if $result_class->can('_create');   
        $r = $r->insert_with_related($request); # DBIx::Class::Helper::Row::WithRelated
	{res=>($r?'ok':'err'),$result_class->can('_return')?$result_class->_return($r => 'insert'):()}
}
*create = *insert;

sub search {
        my $self = shift;
        my $rs = $self->resultset;
        my $result_class = $self->result_class;
	my $request = $self->request;

        $rs = $rs->search({}, {prefetch => $self->result->{relationships}}) if defined $self->result->{relationships};
        $rs = $rs->search({$self->where}, {$self->order_by, $self->pager});
        $rs = $result_class->_search($rs, $request) if $result_class->can('_search');
        $rs = $result_class->_read($rs, $request) if $result_class->can('_read');
        return $rs;
}
*read = *search;

sub update {
        my $self = shift;
        my $rs = $self->resultset;
        my $result_class = $self->result_class;
        my $id = $self->id;
        my $request = $self->_row;

	return $rs->throw_exception($self->_exception) if $self->_exception;
        my $r = $rs->find($id);
	return $rs->throw_exception("Update error: Cannot find id $id") unless defined $r;
        $r = $result_class->_update($r, $rs, $request) if $result_class->can('_update');
        $r = $r->update_with_related($request);
	{res=>($r?'ok':'err'),$result_class->can('_return')?$result_class->_return($r => 'update'):()}
}
 
sub delete {
        my $self = shift;
        my $rs = $self->resultset;
        my $result_class = $self->result_class;
        my $id = $self->id;
	my $request = $self->request;

        my @err;
        foreach ( split /,/, $id ) {
                warn "Deleting $_\n" if $ENV{CRUD_DEBUG};
                my $r = $self->resultset->find($_);
                push @err, 0 and next unless defined $r;
                $r = $result_class->_delete($r, $request) if $result_class->can('_delete');
                push @err, $_ unless $r->delete;
        }
	{res=>(@err?'err':'ok')}
}
 
sub _me {
        my $self = shift;
        my $field = shift;
        ref $field || $field =~ /\./ ? $field : $self->resultset->current_source_alias.'.'.$field;
}

sub _exception {
	my $self = shift;
	push @{$self->{exception}->{$_[0]}}, $_[1] if @_;
	wantarray ? keys %{$self->{exception}} : scalar keys %{$self->{exception}};
}

sub _cell {
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
                $self->_exception($key => $validate->{$key}->[1]);
        }
        return %cells;
}
 
sub _row {
        my $self = shift;
        my $req = $self->request or return ();
        my %row = $req->{celname} ? $self->_cell($req->{celname} => $req->{$req->{celname}}) : (map { $self->_cell($_, $req->{$_}) } keys %$req);
        my $row;
        while ( my ($key, $value) = each %row ) {
                my ($table, $field) = split /\./, $self->_me($key);
                $row->{$table}->{$field} = $value;
        }
        warn Dumper({row=>$row}) if $ENV{CRUD_DEBUG};
        return $row;
};

1;
