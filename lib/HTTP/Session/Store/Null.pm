package HTTP::Session::Store::Null;
use Moose;
with 'HTTP::Session::Role::Store';

sub load_session { +{ } } # return empty hashref
sub save_session { }

1;
