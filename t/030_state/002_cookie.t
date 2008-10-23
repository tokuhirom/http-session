use strict;
use warnings;
use Test::More tests => 9;
use Test::Exception;
use HTTP::Session;
use HTTP::Session::Store::Debug;
use HTTP::Session::State::Cookie;
use HTTP::Response;
use HTTP::Request;
use HTTP::Headers;
use CGI;

my $store = HTTP::Session::Store::Debug->new(
    data => {
        bar => {}
    }
);

sub {
    local %ENV = (
        HTTP_COOKIE => 'http_session_sid=bar; path=/;',
    );

    my $session = HTTP::Session->new(
        store   => $store,
        state   => HTTP::Session::State::Cookie->new(),
        request => CGI->new
    );
    is $session->session_id(), 'bar';
    my $res = HTTP::Response->new(200, 'foo');
    $session->response_filter($res);
    is $res->header('Set-Cookie'), 'http_session_sid=bar; path=/';
}->();

sub {
    my $session = HTTP::Session->new(
        store   => $store,
        state   => HTTP::Session::State::Cookie->new(),
        request => HTTP::Request->new(
            'GET',
            '/',
            HTTP::Headers->new(
                Cookie => 'http_session_sid=bar; path=/;',
            ),
        ),
    );
    is $session->session_id(), 'bar';
}->();

sub {
    local $ENV{HTTP_COOKIE} = '';

    my $session = HTTP::Session->new(
        store   => $store,
        state   => HTTP::Session::State::Cookie->new(),
        request => CGI->new
    );
    like $session->session_id(), qr/^[a-z0-9]{32}$/, 'cookie not found';
}->();

sub {
    local $ENV{HTTP_COOKIE} = 'foo_sid=bar; path=/admin/;';

    my $session = HTTP::Session->new(
        store => $store,
        state => HTTP::Session::State::Cookie->new(
            name    => 'foo_sid',
            path    => '/admin/',
            domain  => 'example.com',
        ),
        request => CGI->new
    );
    is $session->session_id, 'bar';
    my $res = HTTP::Response->new(200, 'foo');
    $session->response_filter($res);
    is $res->header('Set-Cookie'), 'foo_sid=bar; domain=example.com; path=/admin/';
}->();

sub {
    local $ENV{HTTP_COOKIE} = 'foo_sid=bar; path=/admin/;';

    my $session = HTTP::Session->new(
        store => $store,
        state => HTTP::Session::State::Cookie->new(
            expires => '+1M',
            name    => 'foo_sid',
        ),
        request => CGI->new
    );
    is $session->session_id, 'bar';
    my $res = HTTP::Response->new(200, 'foo');
    $session->response_filter($res);
    like $res->header('Set-Cookie'), qr!foo_sid=bar; path=/; expires=[A-Z][a-z]{2}, \d+-[A-Z][a-z]{2}-\d{4} \d\d:\d\d:\d\d GMT!;
}->();

sub {
    local $ENV{HTTP_COOKIE} = 'foo_sid=bar; path=/admin/;';

    my $session = HTTP::Session->new(
        store => $store,
        state => HTTP::Session::State::Cookie->new(),
        request => CGI->new
    );
    throws_ok {$session->state->response_filter() } qr/missing session_id/;
}->();

