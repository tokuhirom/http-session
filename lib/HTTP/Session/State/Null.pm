package HTTP::Session::State::Null;
use Moose;
with 'HTTP::Session::Role::State';

sub get_session_id { }
sub inject_session_id { }

1;
