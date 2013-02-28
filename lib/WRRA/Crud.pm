package WRRA::Crud;
use Mojo::Base 'Mojolicious::Controller';

# The controller receives a request from a user, passes incoming data to the
# model and retrieves data from it, which then gets turned into an actual
# response by the view. But note that this pattern is just a guideline that
# most of the time results in cleaner more maintainable code, not a rule that
# should be followed at all costs.

# The controller decides how to handler data 
# The model retrieves data (DB Schema)
#   Receives data from controller and uses this to decide what data
# The view is responsible for deciding how it looks (rendering)

# The view asks for the data from the model
# The controller decides which model to use
# The model retries the appropriate data based on the request from the cntrlr

#              +----------------+     +-------+
#  Request  -> |                | <-> | Model |
#              |                |     +-------+
#              |   Controller   |
#              |                |     +-------+
#  Response <- |                | <-> | View  |
#              +----------------+     +-------+

use Mojo::Util qw(camelize);

use Data::Dumper;

sub create {
	my $self = shift;
	$self->view($self->param('v')) or $self->render_exception;
	my $m = $self->model($self->param('m')) or $self->render_exception;
	$self->respond_to(
		json => sub {
			$self->render_json($m->create);
		},
	);
}

sub read {
	my $self = shift;
	my ($view, $source) = $self->param('results');
	my $data = $self->db->resultset($source)->view($view)->jqgrid($self->myrequest)->search->first;
	$self->respond_to(
		json => {json => [$data]},
		xls => sub { # With TO_XLS
			$self->cookie(fileDownload => 'true');
			$self->cookie(path => '/');
			$self->render_xls(result => [$data->first]);
		},
	);
}

sub update {
	my $self = shift;
	$self->view($self->param('v')) or $self->render_exception;
	my $m = $self->model($self->param('m')) or $self->render_exception;
	$self->respond_to(
		json => sub {
			$self->render_json($m->update);
		},
	);
}

sub delete {
	my $self = shift;
	$self->view($self->param('v')) or $self->render_exception;
	my $m = $self->model($self->param('m')) or $self->render_exception;
	$self->respond_to(
		json => sub {
			$self->render_json($m->delete);
		},
	);
}

1;
