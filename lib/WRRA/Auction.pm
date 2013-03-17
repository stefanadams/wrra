package WRRA::Auction;
use Mojo::Base 'Mojolicious::Controller';

use Mojo::JSON;

sub auction {
	my $self = shift;
	my $auction = $self->memd || $self->memd($self->_auction);
	$auction->{header}->{ad} = $self->_display_ad;
	$self->respond_to(
		json => {json => $auction},
	);
}

sub _auction {
	my $self = shift;
	my $items = {
		session => {
			user => {
				name => $self->is_user_authenticated ? $self->current_user->{name} : Mojo::JSON->false,
				role => $self->is_user_authenticated ? $self->role : Mojo::JSON->false,
				privs => $self->is_user_authenticated ? scalar $self->privileges : Mojo::JSON->false,
			}
		},
		header => {
			about => {
				name => $self->config->{auction_name},
				year => $self->datetime->year,
				night => defined $self->night ? $self->night : Mojo::JSON->false,
				closed => $self->closed ? Mojo::JSON->true : Mojo::JSON->false,
				live => $self->closed ? Mojo::JSON->false : Mojo::JSON->true,
				date_next => $self->date_next ? $self->date_next->format_cldr(q/EEE',' MMM d',' yyyy 'at' h':'mm':'ss/) : Mojo::JSON->false,
				datetime => $self->datetime,
			},
			play => $self->config('play'),
			alert => $self->_alert,
		},
		stats => {
		},
	};
	unless ( $self->closed ) {
		for ( qw/ready ondeck bidding verifying/ ) {
			my $i = $self->_items($_);
			$items->{items}->{$_} = $i if $i;
		}
	}
	return $items;
}

sub _items {
	my $self = shift;
	my $status = shift;
	my $photosdir = join '/', $self->app->home, 'public', ($self->config('photos') || 'photos');
	my $photosurl = join '/', ($self->config('photos') || 'photos');
	my $rs = $self->db->resultset(Item => 'Bidding')->search(undef, {prefetch=>'donor'});
	my $items;
	my $year = $self->datetime->year;
	given ( $status ) {
		when ( 'ready' ) {
			return undef unless $self->has_priv('admins');
			$rs = $rs->current_year->ready;
			$items = Mojo::JSON->new->decode(Mojo::JSON->new->encode([$rs->all]));
		}
		when ( 'ondeck' ) {
			return undef unless $self->has_priv('auctioneers');
			$rs = $rs->current_year->ondeck;
			$rs = $rs->auctioneer($self->username) if $self->role && $self->role eq 'auctioneers' && $self->username ne 'auctioneer';
			$items = Mojo::JSON->new->decode(Mojo::JSON->new->encode([$rs->all]));
		}
		when ( 'bidding' ) {
			$rs = $rs->current_year->bidding->search(undef, {prefetch=>['highbid', 'bids']});
			$rs = $rs->auctioneer($self->username) if $self->role && $self->role eq 'auctioneers' && $self->username ne 'auctioneer';
			$items = Mojo::JSON->new->decode(Mojo::JSON->new->encode([$rs->all]));
			foreach ( @$items ) {
				# if((find_in_set('newbid',`items`.`notify`) > 0),1,NULL) `newbid`
				# if((`items`.`status` = 'Sold'),1,NULL) `sold`
				($_->{img}) = glob("$photosdir/$year/$_->{number}.*") if $_->{number};
				$_->{img} && -e $_->{img} && -f _ && -r _ && do {
					$_->{img} =~ s/^$photosdir\/?// or $_->{img} = undef;
					$_->{img} = join '/', '', $photosurl, $_->{img} if $_->{img};
					last;
				};
				$_ = $self->_fakebidding($_);
#				foreach ( $self->db->resultset('Bid'
				$_->{bellringer} = $_->{bellringer} ? Mojo::JSON->true : Mojo::JSON->false;
				$_->{timer} = $_->{timer} ? Mojo::JSON->true : Mojo::JSON->false;
				$_->{cansell} = $_->{cansell} ? Mojo::JSON->true : Mojo::JSON->false;
				$_->{scheduled} = $_->{scheduled} ? Mojo::JSON->true : Mojo::JSON->false;
				$_->{started} = $_->{started} ? Mojo::JSON->true : Mojo::JSON->false;
				$_->{sold} = $_->{sold} ? Mojo::JSON->true : Mojo::JSON->false;
				$_->{cleared} = $_->{cleared} ? Mojo::JSON->true : Mojo::JSON->false;
			}
		}
		when ( 'verifying' ) {
			$rs = $rs->current_year->verifying;
			return undef unless $self->has_priv('callers');
			$items = Mojo::JSON->new->decode(Mojo::JSON->new->encode([$rs->all]));
		}
		default { return {} }
	}
	return $items;
}

sub _alert {
	my $self = shift;
	my $alert = $self->db->resultset('Alert')->search({alert=>$self->role||'public'})->first;
	return {$alert ? (msg=>$alert->msg) : ()};
}

sub _display_ad {
        my $self = shift;
	return {} if $self->has_priv('backend');
        my $adsdir = join '/', $self->app->home, 'public', ($self->config('ads') || 'ads');
        my $adsurl = join '/', ($self->config('ads') || 'ads');
	delete $self->session->{ad}->{refresh};
        return $self->session->{ad} if $self->session->{ad_ctime} && time-$self->session->{ad_ctime} <= ($self->config->{refresh}->{ad} || 30000) / 1000;
        $self->session->{ad_ctime} = time;

        my $ad;
        foreach my $_ad ( $self->db->resultset('Ads')->today->random->all ) {
                $ad = {map { $_ => $_ad->$_ } qw/url year advertiser_id ad_id/};
                if ( $_ad->advertiser ) {
                        $ad->{advertiser}->{name} = $_ad->advertiser->name;
                        $ad->{advertiser}->{advertisement} = $_ad->advertiser->advertisement;
                }
                next if $self->session->{ad}->{ad_id} && $ad->{ad_id} == $self->session->{ad}->{ad_id};
                my $r;
                if ( $r = $self->db->resultset('Adcount')->find($ad->{ad_id}, $self->datetime->ymd) ) {
                        $r->update({rotate=>($r->rotate||0)+1});
                } elsif ( $r = $self->db->resultset('Adcount')->new({ad_id=>$ad->{ad_id}, processed=>$self->datetime->ymd, rotate=>1}) ) {
                        $r->insert;
                }
                next unless $r;
                $ad->{img} = (glob("$adsdir/$ad->{year}/$ad->{advertiser_id}-$ad->{ad_id}.*"))[0] || (glob("$adsdir/$ad->{year}/$ad->{advertiser_id}.*"))[0] if $ad->{advertiser_id} && $ad->{ad_id};
                $ad->{img} && -e $ad->{img} && -f _ && -r _ && do {
                        $ad->{img} =~ s/^$adsdir\/?// or $ad->{img} = undef;
                        $ad->{img} = join '/', '', $adsurl, $ad->{img} if $ad->{img};
                        $r->update({display=>($r->display||0)+1}) and last;
                        delete $ad->{ad_id};
                }
        }
        unless ( $ad->{ad_id} && $ad->{img} && $ad->{url} ) {
                $ad->{ad_id} = $self->config->{default_ad}->{ad_id};
                $ad->{advertiser_id} = $self->config->{default_ad}->{advertiser_id};
                $ad->{img} = $adsdir.'/'.$self->config->{default_ad}->{img};
                $ad->{img} =~ s/^$adsdir\/?// or $ad->{img} = undef;
                $ad->{img} = join '/', '', $adsurl, $ad->{img} if $ad->{img};
                $ad->{url} = $self->config->{default_ad}->{url};
        }
        $self->session->{ad} = $ad;
        $ad->{refresh} = 1;
        return $ad;
}

sub _fakebidding {
	my $self = shift;
	my $row = shift;
	return $row unless $self->app->mode eq 'development' && $self->config->{fakebidding};
	if ( int(rand(99)) < 25 ) {
		$row->{nstatus} = 'Ready'; 
	} elsif ( int(rand(99)) < 25 ) {
		$row->{nstatus} = 'On Deck';
		#$row->{auctioneer} = int(rand(99)) < 50 ? 'a' : 'b';
	} elsif ( int(rand(99)) < 70 ) {
		$row->{nstatus} = 'Bidding';
		$row->{notifications}->{newbid} = 1 if int(rand(99)) < 20;
		if ( int(rand(99)) < 25 ) {
			$row->{notifications}->{starttimer} = 1;
		} elsif ( int(rand(99)) < 25 ) {
			$row->{notifications}->{sell} = 1;
		}
		#$row->{auctioneer} = int(rand(99)) < 50 ? 'a' : 'b';
		$row->{highbid}->{bid} = $row->{highbid}->{bid} =~ /\d/ ? $row->{highbid}->{bid} : $row->{value} - 10 + int(rand(15));
		$row->{highbid}->{id} = int(rand(100000));
		$row->{highbid}->{bidder}->{name} = substr($row->{donor}->{name}, 0, 18);
		$row->{highbid}->{bidder}->{id} = int(rand(100000));
		$row->{timer} = int(rand(99)) < 20 ? 1 : 0;
		$row->{runningtime} = int(rand(10));
		$row->{timertime} = int(rand(5));
	} elsif ( int(rand(99)) < 25 ) {
		$row->{nstatus} = 'Sold';
		$row->{sold} = 1;
		$row->{highbid}->{id} = int(rand(100000));
		$row->{highbid}->{bid} = $row->{highbid}->{bid} =~ /\d/ ? $row->{highbid}->{bid} : $row->{value} - 10 + int(rand(15));
		$row->{highbid}->{bidder}->{id} = int(rand(100000));
		$row->{highbid}->{bidder}->{name} = substr($row->{donor}->{name}, 0, 18);
		$row->{timer} = 1;
		$row->{runningtime} = int(rand(10));
		$row->{timertime} = int(rand(5));
	} elsif ( int(rand(99)) < 25 ) {
		$row->{nstatus} = 'Complete';
		$row->{sold} = 1;
		$row->{highbid}->{id} = int(rand(100000));
		$row->{highbid}->{bid} = $row->{highbid}->{bid} =~ /\d/ ? $row->{highbid}->{bid} : $row->{value} - 10 + int(rand(15));
		$row->{highbid}->{bidder}->{id} = int(rand(100000));
		$row->{highbid}->{bidder}->{name} = substr($row->{donor}->{name}, 0, 18);
		$row->{timer} = 1;
		$row->{runningtime} = int(rand(10));
		$row->{timertime} = int(rand(5));
	}
	$row->{bellringer} = $row->{highbid}->{bid} >= $row->{value};
	$row->{minbid} = $row->{highbid}->{bid}+5 if $row->{highbid}->{bid} < $row->{value};
	$row->{description} = int(rand(99)) < 40 ? 'Fuller description' : undef;
	$row->{url} ||= int(rand(99)) < 20 ? 'http://google.com' : undef;
	$row->{donor}->{url} ||= int(rand(99)) < 20 ? 'http://google.com' : undef;
	$row->{img} ||= int(rand(99)) < 20 ? '/img/yes.gif' : undef;
	return $row;
}

sub start {
	my $self = shift;
	my $id = $self->param('id') or return $self->render_not_found;
	my $r;
	given ( $self->role ) {
		when ( 'admins' ) {
			my $auctioneer = $self->param('auctioneer') or return $self->render_not_found;
			$r = $self->db->resultset('Item')->find($id)->update({auctioneer=>$auctioneer});
		}
		when ( 'auctioneers' ) {
			$r = $self->db->resultset('Item')->find($id)->update({started=>$self->datetime_mysql});
		}
		default { return $self->render_not_found }
	}
	$self->respond_to(
		json => {json => {res=>$r?'ok':'err'}},
	);
}

sub timer {
	my $self = shift;
	my $timer = $self->param('timer');
	my $id = $self->param('id') or return $self->render_not_found;
	my $r;
	given ( $self->role ) {
		when ( 'admins' ) {
			$r = $self->db->resultset('Item')->find($id)->notify("${timer}timer" => 1)->update;
		}
		when ( 'auctioneers' ) {
			$r = $self->db->resultset('Item')->find($id)->respond("${timer}timer")->update({timer=>$timer eq 'start' ? $self->datetime_mysql : undef});
		}
		default { return $self->render_not_found }
	}
	$self->respond_to(
		json => {json => {res=>$r?'ok':'err'}},
	);
}

sub sell {
	my $self = shift;
	my $id = $self->param('id') or return $self->render_not_found;
	my $r;
	given ( $self->role ) {
		when ( 'admins' ) {
			$r = $self->db->resultset('Item')->find($id)->notify(sell => 1)->update;
		}
		when ( 'auctioneers' ) {
			$r = $self->db->resultset('Item')->find($id);
			if ( $r->sold ) {
				$r->update({cleared=>$self->datetime_mysql});
			} else {
				$r->respond('sell')->update({sold=>$self->datetime_mysql});
			}
		}
		default { return $self->render_not_found }
	}
	$self->respond_to(
		json => {json => {res=>$r?'ok':'err'}},
	);
}

sub bidhistory {
	my $self = shift;
	my $item_id = $self->param('id') or return $self->render_json({res=>'err'});
	my $rs = $self->db->resultset(Bid => 'BidHistory')->search({item_id=>$item_id}, {order_by=>'bidtime desc'});
	$self->respond_to(
		json => {json => [$rs->all]},
	);
}

sub bid {
	my $self = shift;
	my $id = $self->param('id') or return $self->render_json({res=>'err'});
	my $r;
	given ( $self->role ) {
		when ( 'auctioneers' ) {
			$r = $self->db->resultset('Item')->find($id)->respond('newbid')->update;
		}
		when ( /^operators$|^admins$/ ) {
			my $phone = $self->param('phone') or return $self->render_json({res=>'err'});
			my $bidder_id = $self->param('bidder_id');
			my $name = $self->param('name') or return $self->render_json({res=>'err'});
			my $bid = $self->param('bid') or return $self->render_json({res=>'err'});
			unless ( $bidder_id ) {
				my $new_bidder = $self->db->resultset('Bidder')->create({year=>$self->datetime->year,name=>$name,phone=>$phone});
				return $self->render_json({res=>'err'}) unless $bidder_id = $new_bidder->id;
			}
			$bid = $self->db->resultset('Bid')->create({item_id=>$id,bidder_id=>$bidder_id,bid=>$bid,bidtime=>$self->datetime_mysql}) or return return $self->render_json({res=>'err'});
			$r = $self->db->resultset('Item')->find($id)->notify(newbid=>1)->update({highbid_id=>$bid->id});
		}
		default { return $self->render_not_found }
	}
	$self->respond_to(
		json => {json => {res=>$r?'ok':'err'}},
	);
}

sub bidder {
	my $self = shift;
	my $bidder_id = $self->param('id') or return $self->render_json({res=>'err'});
	my $bidder = {
		year => $self->datetime->year,
		address => $self->param('address') || '',
		city => $self->param('city') || '',
		state => $self->param('state') || '',
		zip => $self->param('zip') || '',
	};
	my $r;
	$r = $self->db->resultset('Item')->find($self->param('item_id'))->update({paid=>\'now()'}) && $self->db->resultset('Bidder')->find($bidder_id)->update($bidder);
	$self->respond_to(
		json => {json => {res=>$r?'ok':'err'}},
	);
}

1;
