use strict;
use warnings;
use Test::More tests => 9;
use Test::Exception;
use HTTP::Session;
use HTTP::Session::Store::Memory;
use HTTP::Session::State::URI;
use HTTP::Response;
use CGI;

my $state = HTTP::Session::State::URI->new();
ok $state->does('HTTP::Session::Role::State');

sub {
    my $session = HTTP::Session->new(
        store   => HTTP::Session::Store::Memory->new,
        state   => HTTP::Session::State::URI->new(),
        request => CGI->new({ sid => 'bar' }),
    );
    $session->load_session;
    is $session->session_id(), 'bar';

    sub {
        my $res = HTTP::Response->new(200, 'ok', HTTP::Headers->new(), '<a href="/">foo</a>');
        $session->response_filter($res);
        is $res->content, '<a href="/?sid=bar">foo</a>';
    }->();

    sub {
        my $res = HTTP::Response->new(200, 'ok', HTTP::Headers->new(), '<form action="/"></form>');
        $session->response_filter($res);
        is $res->content, qq{<form action="/">\n<input type="hidden" name="sid" value="bar"></form>};
    }->();

    sub {
        my $res = HTTP::Response->new(302, 'ok', HTTP::Headers->new(Location => 'http://example.com/'));
        $session->response_filter($res);
        is $res->header('Location'), q{http://example.com/?sid=bar};
    }->();

    sub {
        my $res = HTTP::Response->new(404, 'not found');
        $session->response_filter($res);
        ok "not found";
    }->();

    sub {
        my $res = HTTP::Response->new(302, 'no location');
        $session->response_filter($res);
        is $res->code, 302, 'no locaiton';
    }->();

    throws_ok { $session->state->get_session_id }  qr/missing req/;
    throws_ok { $session->state->response_filter } qr/missing session_id/;
}->();

