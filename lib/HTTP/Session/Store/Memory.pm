package HTTP::Session::Store::Memory;
use Moose;
with 'HTTP::Session::Role::Store';

my $storage = { };

sub select {
    my ( $self, $session_id ) = @_;
    Carp::croak "missing session_id" unless $session_id;
    $storage->{$session_id};
}

sub insert {
    my ($self, $session_id, $data) = @_;
    Carp::croak "missing session_id" unless $session_id;
    $storage->{$session_id} = $data;
}

sub update {
    my ($self, $session_id, $data) = @_;
    Carp::croak "missing session_id" unless $session_id;
    $storage->{$session_id} = $data;
}

sub delete {
    my ($self, $session_id) = @_;
    Carp::croak "missing session_id" unless $session_id;
    delete $storage->{$session_id};
}

no Moose; __PACKAGE__->meta->make_immutable;
1;
__END__

=head1 NAME

HTTP::Session::Store::Memory - store session data on memory

=head1 SYNOPSIS

    HTTP::Session->new(
        store => HTTP::Session::Store::Memory->new(),
        state => ...,
        request => ...,
    );

=head1 DESCRIPTION

store session data on memory

=head1 CONFIGURATION

nop

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

