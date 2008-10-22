use strict;
use warnings;
use HTTP::Session;
use HTTP::Engine;
use HTTP::Session::State::Cookie;
use HTTP::Session::State::URI;
use HTTP::Session::Store::Memory;
use HTTP::Session::State::MobileAttributeID;
use HTTP::MobileAttribute plugins => [
    qw/ IS /
];
use String::TT qw/tt strip/;

HTTP::Engine->new(
    interface => {
        module => 'ServerSimple',
        args => {
            port => 9999,
        },
        request_handler => sub {
            my $req = shift;
            my $state = sub {
                my $ma = HTTP::MobileAttribute->new($req->headers);
                my $gen_cookie_state = sub {
                    HTTP::Session::State::Cookie->new();
                };
                if ($ma->is_airh_phone || $ma->is_non_mobile) {
                    return $gen_cookie_state->();
                } elsif ($ma->user_agent =~ /Google|Yahoo/) {
                    return $gen_cookie_state->();
                } else {
                    if ($ma->user_id) {
                        return HTTP::Session::State::MobileAttributeID->new(
                            mobile_attribute => $ma,
                        );
                    } else {
                        return HTTP::Session::State::URI->new();
                    }
                }
            }->();
            my $session = HTTP::Session->new(
                state => $state,
                store => HTTP::Session::Store::Memory->new(),
                request => $req,
            );
            my $count = $session->get('count') || 0;
            my $html = tt strip q{
                <?xml version="1.0" encoding="utf-8"?>
                <!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
                <html xmlns="http://www.w3.org/1999/xhtml">
                    <head></head>
                    <body>
                        count is <a href="/">[% count |html %]</a><br />
                        state is [% state | html %]<br />
                        session id is [% session.session_id %].
                    </body>
                </html>
            };
            $session->set(count => $count + 1);
            my $res = HTTP::Engine::Response->new(
                status => 200,
                body   => $html,
            );
            $res->header('Content-Type' => 'text/html');
            $session->response_filter($res);
            return $res;
        },
    }
)->run;

