package WRRA::Schema::ResultSet::Donor;
use base 'WRRA::Schema::ResultSet';

sub solicit { $_[0]->search({$_[0]->current_source_alias.'.solicit' => 1}) }
sub donor { $_[0]->search({'donor.name' => {-like => '%'.$_[1].'%'}}, {join=>'donor'}) }

1;
