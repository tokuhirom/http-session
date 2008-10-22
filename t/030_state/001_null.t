use strict;
use warnings;
use Test::More tests => 2;
use HTTP::Session::State::Null;

my $state = HTTP::Session::State::Null->new();
ok $state->does('HTTP::Session::Role::State');
is $state->get_session_id(), undef;
$state->response_filter(); # nop.

