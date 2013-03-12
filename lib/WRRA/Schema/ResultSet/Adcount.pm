package WRRA::Schema::ResultSet::Adcount;
use base 'WRRA::Schema::ResultSet';

sub random { shift->search({}, {order_by=>[{'-asc'=>'rotate'}, \'RAND()']}) }

sub today { my $self = shift; $self->current_year->search({scheduled=>[''.$self->datetime,{'='=>undef}]}) }
sub yesterday { my $self = shift; $self->current_year->search({scheduled=>[''.$self->datetime,{'='=>undef}]}) }
sub tomorrow { my $self = shift; $self->current_year->search({scheduled=>[''.$self->datetime,{'='=>undef}]}) }
sub first_day { my $self = shift; $self->current_year->search({scheduled=>[''.$self->datetime,{'='=>undef}]}) }
sub last_day { my $self = shift; $self->current_year->search({scheduled=>[''.$self->datetime,{'='=>undef}]}) }
sub all_days { my $self = shift; $self->current_year->search({scheduled=>[''.$self->datetime,{'='=>undef}]}) }

1;
