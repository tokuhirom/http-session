use strict;
use warnings;
use Test::More;
use Test::Exception;
use HTTP::Session;
plan skip_all => "this test requires HTTP::MobileAttribute" unless eval "use HTTP::MobileAttribute; 1;";
plan tests => 3;
require HTTP::Session::State::MobileAttributeID;

sub {
    local %ENV = (
        HTTP_USER_AGENT => 'DoCoMo/1.0/D504i/c10/TJ',
        HTTP_X_DCMGUID  => 'fooobaa'
    );
    my $state = HTTP::Session::State::MobileAttributeID->new(
        mobile_attribute => HTTP::MobileAttribute->new()
    );
    is $state->get_session_id(), 'fooobaa';
    $state->response_filter(); # nop.
}->();

sub {
    local %ENV = (
        HTTP_USER_AGENT => 'DoCoMo/1.0/D504i/c10/TJ',
    );
    my $state = HTTP::Session::State::MobileAttributeID->new(
        mobile_attribute => HTTP::MobileAttribute->new()
    );
    throws_ok { $state->get_session_id() } qr/cannot detect mobile id/;
}->();

sub {
    local %ENV = (
        HTTP_USER_AGENT => 'MOZILLA',
    );
    my $state = HTTP::Session::State::MobileAttributeID->new(
        mobile_attribute => HTTP::MobileAttribute->new()
    );
    throws_ok { $state->get_session_id() } qr/this carrier doesn't supports user_id/;
}->();
