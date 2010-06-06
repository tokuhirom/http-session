use strict;
use warnings;
use Test::Requires { 'Net::CIDR::MobileJP' => 0.17};
use Test::Requires 'HTML::StickyQuery::DoCoMoGUID', 'HTTP::MobileAttribute', 'HTTP::Session::State::GUID';
use Test::More tests => 10;
use CGI;
use HTTP::Session;
use HTTP::Session::State::Cookie;
use HTTP::Session::State::URI;
use HTTP::Session::State::GUID;
use HTTP::Session::Store::Test;
use Net::CIDR::MobileJP;

# -------------------------------------------------------------------------
# state::cookie

do {
    my $session = HTTP::Session->new(
        state   => HTTP::Session::State::Cookie->new(),
        store   => HTTP::Session::Store::Test->new(),
        request => CGI->new(),
    );
    my $res = [200, ['Content-Type' => 'text/plain'], ['ok']];
    $session->response_filter($res);
    is scalar(@{$res->[1]}), 4;
    is $res->[1]->[2], 'Set-Cookie';
    like $res->[1]->[3], qr{http_session_sid=[^;]+; path=/};
};

# -------------------------------------------------------------------------
# state::uri

do {
    my $session = HTTP::Session->new(
        state   => HTTP::Session::State::URI->new(),
        store   => HTTP::Session::Store::Test->new(),
        request => CGI->new(),
    );
    my $res = [302, ['Location' => 'http://gp.ath.cx/'], ['']];
    $session->response_filter($res);
    is scalar(@{$res->[1]}), 2, 'redirect';
    like $res->[1]->[1], qr{^http://gp\.ath\.cx/\?sid=.+$};
    like $res->[1]->[1], qr{^http://gp\.ath\.cx/\?sid=.+$};
};

do {
    my $session = HTTP::Session->new(
        state   => HTTP::Session::State::URI->new(),
        store   => HTTP::Session::Store::Test->new(),
        request => CGI->new(),
    );
    my $res = [200, ['Content-Type' => 'text/html'], ['<a href="/foo">ooo</a>']];
    $session->response_filter($res);
    like $res->[2]->[0], qr{^<a href="/foo\?sid=.+">ooo</a>$};
};

# -------------------------------------------------------------------------
# state::guid

local %ENV = (
    HTTP_USER_AGENT => 'DoCoMo/1.0/D504i/c10/TJ',
    HTTP_X_DCMGUID  => 'fooobaa',
    REMOTE_ADDR     => '192.168.1.1',
);
my $ma = HTTP::MobileAttribute->new();
do {
    my $session = HTTP::Session->new(
        state   => HTTP::Session::State::GUID->new(
            mobile_attribute => $ma,
            check_ip => 0,
            cidr     => Net::CIDR::MobileJP->new('t/data/cidr.yaml'),
        ),
        store   => HTTP::Session::Store::Test->new(),
        request => CGI->new(),
    );
    my $res = [302, ['Location' => 'http://gp.ath.cx/'], ['']];
    $session->response_filter($res);
    is scalar(@{$res->[1]}), 2, 'redirect';
    is $res->[1]->[1], 'http://gp.ath.cx/?guid=ON';
};

do {
    my $session = HTTP::Session->new(
        state   => HTTP::Session::State::GUID->new(
            mobile_attribute => $ma,
            check_ip => 0,
            cidr     => Net::CIDR::MobileJP->new('t/data/cidr.yaml'),
        ),
        store   => HTTP::Session::Store::Test->new(),
        request => CGI->new(),
    );
    my $res = [200, ['Content-Type' => 'text/html'], ['<a href="/foo">ooo</a>']];
    $session->response_filter($res);
    like $res->[2]->[0], qr{^<a href="/foo\?guid=ON">ooo</a>$};
};
