package WRRA::Schema::ResultSet;

use base qw/DBIx::Class::ResultSet::HashRef DBIx::Class::ResultSet/;
__PACKAGE__->load_components(qw{Helper::ResultSet::Shortcut});

use strict;
use warnings;
use WRRA::View;

use Data::Dumper;

sub year { shift->result_source->schema->config->{year} || ((localtime())[5])+1900 }

sub json {
	my $self = shift;
	if ( my $output = $self->{attrs}->{json} ) {
		return $output->($self); # Run the output provided by the view Handler
	} else {
		return [$self->all] # TO_JSON
	}
}

sub build_select {
	my $self = shift;
	if ( my $output = $self->{attrs}->{build_select} ) {
		return $output->($self); # Run the output provided by the view Handler
	} else {
		return [Dumper $self->hashref_array] # TO_JSON
	}
}

sub xls {
	my $self = shift;
	delete $self->{attrs}->{page};
	delete $self->{attrs}->{rows};
	return [map { $_->TO_XLS } $self->all];
}

sub rs_create {
	my $self = shift;
	my %req = WRRA::View->create;
	warn Dumper({req=>{%req}});
	#warn Dumper({update => {map { $_=>[$req{$_}->(\%req)] } grep { ref $req{$_} eq 'CODE' } keys %req}});
	foreach ( grep { ref $req{$_} eq 'CODE' } grep { !/^\+/ } keys %req ) {
		my ($search, $update) = $req{$_}->(\%req);
		warn Dumper({update_related => {$_ => [$search, $update]}});
		# This isn't the best way to get it.
		# How to translate a relationship to a resultset?
		$self->result_source->schema->resultset("\u$_")->find($search)->update($update);
	}
	my $create = {
		(map { my $key = $_; $key =~ s/^\+//; $key => ref $req{$_} eq 'CODE' ? $req{$_}->($self, \%req) : !ref($req{$_}) ? $req{$_} : () } grep { /^\+/ } keys %req),
		(map { $_=>$req{$_} } grep { $self->result_source->has_column($_) } keys %req)
	};
	warn Dumper({create=>$create});
	my $id = $self->create($create)->id;
	return {res=>($id?'ok':'err'), msg=>($id?'ok':'err'), id=>$id};
	return {id=>50000};
}

sub rs_read {
	my $self = shift;
	#warn Dumper({read => [{WRRA::View->search}, {WRRA::View->order_by, WRRA::View->pager, WRRA::View->read}]});
	return $self->search({WRRA::View->search}, {WRRA::View->order_by, WRRA::View->pager, WRRA::View->read});
}

sub rs_update {
	my $self = shift;
	my %req = WRRA::View->update;
	#warn Dumper({update => {map { $_=>[$req{$_}->(\%req)] } grep { ref $req{$_} eq 'CODE' } keys %req}});
	foreach ( grep { ref $req{$_} eq 'CODE' } keys %req ) {
		my ($search, $update) = $req{$_}->(\%req);
		warn Dumper({update_related => {$_ => [$search, $update]}});
		$self->find($search)->$_->update($update);
	}
	my $update = {
		map { $_=>$req{$_} } grep { $self->result_source->has_column($_) } keys %req
	};
	warn Dumper({update=>{WRRA::View->key=>$update}});
	return {res=>($self->find(WRRA::View->key)->update($update)?'ok':'err'),msg=>''};
}

sub rs_delete {
	my $self = shift;
	warn Dumper({delete => WRRA::View->key});
	return {res=>($self->find(WRRA::View->key)->delete?'ok':'err'),msg=>''};
}

1;
