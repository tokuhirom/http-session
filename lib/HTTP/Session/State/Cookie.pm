package HTTP::Session::State::Cookie;
use Moose;
with 'HTTP::Session::Role::State';
use CGI::Simple::Cookie;

# get session id from Cookie: header
sub get_session_id {
    my ($self, $req) = @_;

    my $name = $self->config->{name} or die "missing cookie name";

    my $header = $req->header('Cookie') or return;
    my %cookie = CGI::Simple::Cookie->parse($header);
    return $cookie{$name} ? $cookie{$name}->value : undef;
}

# output Set-Cookie: header
sub inject_session_id {
    my ($self, $res, $session_id) = @_;

    my $name = $self->config->{name} or die "missing cookie name";
    my $path = $self->config->{path} or die "missing cookie path";

    my $cookie = CGI::Simple::Cookie->new(
        -name  => $name,
        -value => $session_id,
        -path  => $path,
    );
    for my $key (qw/secure domain/) {
        $cookie->$key( $self->config->{$key} ) if $self->config->{$key};
    }

    $res->headers->push_header('Set-Cookie' => $cookie->as_string);
}

1;
