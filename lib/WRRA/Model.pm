package WRRA::Model;

# Setup the Model

use strict;
use warnings;
use Carp qw/ croak /;

use Mojo::Base -base;
use Mojo::Loader;
use Mojo::Util qw/camelize decamelize/;
use WRRA::Schema;

has modules => sub { {} };
has 'schema'; # Attribute set by Mojolicious app (WRRA)

sub new {
    my $class = shift;
    my %args = @_;
    my $self = $class->SUPER::new(@_);

    foreach my $pm (grep { $_ ne 'WRRA::Model::Base' } @{Mojo::Loader->search('WRRA::Model')}) {
        my $e = Mojo::Loader->load($pm);
        croak "Loading `$pm' failed: $e" if ref $e;
        my ($basename) = $pm =~ /.*::(.*)/;
        $self->modules->{decamelize $basename} = $pm->new(%args);
	#use Data::Dumper;
	#warn Dumper([lc($basename), $pm]); # Verify the model names and the respective package
    }
    return $self;
}

# Get a model object by name
sub model {
    my ($self, $model) = @_;
    $self->{modules}{$model} or croak "Unknown model `$model'";
    $self->{modules}{$model}->schema($self->schema);
    return $self->{modules}{$model};
}

# Return a list of avaialable model names
# Probably only for test code
sub models { return grep { $_ ne '' } keys %{$_[0]->{modules}} }

1;
