package WRRA::Schema::ResultSet::Ad;
use base 'WRRA::Schema::ResultSet';

sub random { shift->search({}, {order_by=>[\'RAND()']}) }

sub today { my $self = shift; $self->current_year->search({scheduled=>[''.$self->datetime->ymd,{'='=>undef}]}) }
sub yesterday { my $self = shift; $self->current_year->search({scheduled=>[''.$self->datetime->ymd,{'='=>undef}]}) }
sub tomorrow { my $self = shift; $self->current_year->search({scheduled=>[''.$self->datetime->ymd,{'='=>undef}]}) }
sub first_day { my $self = shift; $self->current_year->search({scheduled=>[''.$self->datetime->ymd,{'='=>undef}]}) }
sub last_day { my $self = shift; $self->current_year->search({scheduled=>[''.$self->datetime->ymd,{'='=>undef}]}) }
sub all_days { my $self = shift; $self->current_year->search({scheduled=>[''.$self->datetime->ymd,{'='=>undef}]}) }

1;
