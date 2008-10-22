package HTTP::Session::Role::State;
use Moose::Role;

requires qw/get_session_id response_filter/;

1;
