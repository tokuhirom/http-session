package HTTP::Session::Store::Memcached;
use Moose;
with 'HTTP::Session::Role::Store';
use Moose::Util::TypeConstraints;

class_type 'Cache::Memcached::Fast';
class_type 'Cache::Memcached';

has memd => (
    is  => 'ro',
    isa => 'Cache::Memcached::Fast|Cache::Memcached',
);

has expires => (
    is       => 'ro',
    isa      => 'Int',
    requires => 1,
);

sub select {
    my ( $self, $session_id ) = @_;
    my $data = $self->memd->get($session_id);
}

sub insert {
    my ($self, $session_id, $data) = @_;
    $self->memd->set( $session_id, $data, $self->expires );
}

sub update {
    my ($self, $session_id, $data) = @_;
    $self->memd->replace( $session_id, $data, $self->expires );
}

sub delete {
    my ($self, $session_id) = @_;
    $self->memd->delete( $session_id );
}

no Moose; __PACKAGE__->meta->make_immutable;
1;
__END__

=head1 NAME

HTTP::Session::Store::Memcached - store session data in memcached

=head1 SYNOPSIS

    HTTP::Session->new(
        store => HTTP::Session::Store::Memcached->new(
            memd => Cache::Memcached->new(servers => ['127.0.0.1:11211']),
        ),
        state => ...,
        request => ...,
    );

=head1 DESCRIPTION

store session data in memcached

=head1 CONFIGURATION

=over 4

=item memd

instance of Cache::Memcached or Cache::Memcached::Fast.

=item expires

session expire time(in seconds)

=back

=head1 METHODS

=over 4

=item select

=item update

=item delete

=item insert

for internal use only

=back

=head1 SEE ALSO

L<HTTP::Session>

