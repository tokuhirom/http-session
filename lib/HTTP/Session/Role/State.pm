package HTTP::Session::Role::State;
use Moose::Role;

requires qw/get_session_id response_filter/;

has permissive => (
    is      => 'ro',
    isa     => 'Bool',
    default => 0,
);

1;
