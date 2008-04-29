package HTTP::Session::State::MobileUserID;
use Moose;
with 'HTTP::Session::Role::State';
use HTTP::MobileAttribute plugins => [
    qw/IS UserID/
];

sub get_session_id {
    my ($self, $req) = @_;

    my $attr = HTTP::MobileAttribute->new($req->headers);
    if ($attr->can('user_id')) {
        $attr->user_id;
    } else {
        return;
    }
}

sub inject_session_id { } # nop.

1;
