package MVC::Bridge;

our $bridge;

# Reserved stash values
my %RESERVED = map { $_ => 1 } (
#  qw(view model controller session),
#  qw(action app cb controller data extends format handler json layout),
#  qw(namespace partial path status template text)
);

=head1 DESCRIPTION
                            +------------+
                            |   Model    |
                            +------------+
                           /\ .          /\
                           / .            \
                          / .              \
                         / .                \
                        / \/                 \
                  +------------+ <------ +------------+
 Graphical  <==== |    View    |         | Controller |  <==== User Input
  Output          +------------+ ......> +------------+

Controller knows the Model and View
View knows the Model
Model makes info available to View knowing nothing of the View
View makes info available to the Controller knowing nothing of the Controller
Model knows nothing about the existence of a Controller.

=head2 Controller
Controller defines Model and View and can set those

Controller
  MVC::Bridge->set(view => 'jqgrid');
  MVC::Bridge->set(model => 'ac_donor');
  MVC::Bridge->set(controller => 'crud');
Controller also sets hash objects
  MVC::Bridge->set(session => $self->session);
  MVC::Bridge->set(stash => $self->stash);
  MVC::Bridge->set(flash => $self->flash);
  MVC::Bridge->set(param => $self->param);
  MVC::Bridge->set(postdata => {json => Mojo::JSON->new->decode($self->req->body)});
  MVC::Bridge->set(config => $self->config);

=head2 Model 
Model accesses data but needs information from the Controller in order to model
the data (e.g. session or config) and also needs information from the view in
order to understand how to provide the data.
# MVC::Bridge->get('session');
# MVC::Bridge->get('config');
# MVC::Bridge->get('colmodel');

=head2 View
View determines

# MVC::Bridge->set(view => 'jqgrid');
# MVC::Bridge->set(model => 'ac_donor');
# MVC::Bridge->set(model => 'ac_donor');
# MVC::Bridge->set(controller => 'crud');
=cut

sub get {
  my $class = shift;

  # Hash
  $bridge ||= {};
  return $bridge unless @_;

  # Get
  return $bridge->{$_[0]} unless @_ > 1 || ref $_[0];

  return $bridge;
}

sub set {
  my $class = shift;

  # Hash
  $bridge ||= {};
  return $bridge unless @_;

  # Set
  my $values = ref $_[0] ? $_[0] : {@_};
  for my $key (keys %$values) {
    warn qq{Careful, "$key" is a reserved bridge value.}
      if $RESERVED{$key};
    $bridge->{$key} = $values->{$key};
  }

  return $bridge;
}

1;
