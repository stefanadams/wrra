package WRRA::Schema::ResultModel::AcItemCurrent;

use base 'WRRA::Schema::Result::Item';

sub label { shift->name }

sub TO_JSON { shift->hashref(qw(label description _value url category)) }
sub TO_JSON {
        my $self = shift;
        return {  
		(map { $_ => $self->$_ } qw(description _value category url)),
                label => $self->nameid,
		desc => $self->year,
        };
}

1;
