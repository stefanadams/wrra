package WRRA::Model::Base;

use Mojo::Base -base;

use WRRA::View;

use Data::Dumper;

# app is for using the application's logging and config facilities, NOT the controller
has [qw/ app schema /];

# The Model::* subclasses should have the optional:
# resultset_class
# result_class
# resultset -> for extra chained resultset methods

# The Schema::Result::* subclasses should have the optional:
# resolver
# column methods
# TO_JSON and TO_XLS

sub _s { $_[0]=~s/$_[1]/$_[2]/; $_[0] };

# The resultset_class to use (basically the table name)
sub _resultset_class { $_[0]->can('resultset_class') ? $_[0]->resultset_class : ((split /::/, ref $_[0])[-1]) }
# The result_class to process data (which set of functions and TO_JSONs to use)
sub _result_class {
	my $self = shift;
	my $result_class = $self->can('result_class') ? $self->result_class : _s(ref($self), 'Model', 'Schema::ResultModel');
	eval "use $result_class;";
	if ( $@ ) { warn "Error loading $result_class\n" }
	$result_class->can('resolver') ? WRRA::View->resolver($result_class->resolver) : warn "No resolver for $result_class found";
	return (result_class => $result_class);
}
# Make the resultset chain available to the model subclass for customizing the resulset
sub _resultset { $_[0]->can('resultset') ? $_[0]->resultset($_[1]) : $_[1] }

sub create {
	my $self = shift;
	#warn Dumper({'WRRA::Model::Base' => [$self->_resultset_class, {$self->_result_class}]});
	$self->schema->resultset($self->_resultset_class)->search({}, {$self->_result_class})->rs_create(@_);
}

sub read { # Called by the controller
	my $self = shift;
	#warn Dumper({'WRRA::Model::Base' => [$self->_resultset_class, {$self->_result_class}]});
	$self->_resultset($self->schema->resultset($self->_resultset_class)->search_rs({}, {$self->_result_class}))->rs_read(@_);
}

sub update {
	my $self = shift;
	#warn Dumper({'WRRA::Model::Base' => [$self->_resultset_class, {$self->_result_class}]});
	$self->schema->resultset($self->_resultset_class)->search({}, {$self->_result_class})->rs_update(@_);
}

sub delete {
	my $self = shift;
	#warn Dumper({'WRRA::Model::Base' => [$self->_resultset_class, {$self->_result_class}]});
	$self->schema->resultset($self->_resultset_class)->search({}, {$self->_result_class})->rs_delete(@_);
}

1;
