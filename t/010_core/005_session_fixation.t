use strict;
use warnings;
use Test::More tests => 3;
use Test::Exception;
use HTTP::Session;
use HTTP::Session::Store::Test;
use HTTP::Session::State::URI;
use HTTP::Response;
use CGI;

my $store = HTTP::Session::Store::Test->new(
    data => {
        bar =>  { }
    },
);

sub {
    my $session = HTTP::Session->new(
        store   => $store,
        state   => HTTP::Session::State::URI->new(),
        request => CGI->new({ sid => 'bar' }),
    );
    is $session->session_id(), 'bar';
}->();

sub {
    my $session = HTTP::Session->new(
        store   => $store,
        state   => HTTP::Session::State::URI->new(),
        request => CGI->new({ sid => 'baz' }),
    );
    ok $session->session_id() ne 'baz', 'no session fixation';
    like $session->session_id(), qr/^[a-z0-9]{32}$/, 'regen session id';
}->();

