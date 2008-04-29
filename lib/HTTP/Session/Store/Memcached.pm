package HTTP::Session::Store::Memcached;
use Moose;
with 'HTTP::Session::Role::Store';
use Cache::Memcached 1.21;

our $EXPTIME = 24*60*60; # default 1 day

has memcached => (
    is  => 'ro',
    isa => 'Cache::Memcached',
);

around 'new' => sub {
    my ($next, @args) = @_;
    my $self = $next->( @args );
    $self->{memcached} = Cache::Memcached->new( $self->config->{args} );
    $self;
};

sub load_session {
    my ($self, $session_id) = @_;
    $self->memcached->get( $session_id ) || {};
}

sub save_session {
    my ($self, $session_id, $params) = @_;
    my $exptime = $self->config->{exptime} || $EXPTIME;
    $self->memcached->set( $session_id => $params => $exptime );
}

1;
