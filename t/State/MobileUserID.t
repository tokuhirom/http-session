use strict;
use warnings;
use Test::More;
use HTTP::Session::State::MobileUserID;
use HTTP::Request;

plan tests => 1;

my $req = HTTP::Request->new('GET', '/', [ 'User-Agent' => 'DoCoMo/1.0/D501i', 'X-DCMGUID' => 'IHOJGEGE' ]);

my $state = HTTP::Session::State::MobileUserID->new( config => {} );
is($state->get_session_id( $req ), 'IHOJGEGE');

