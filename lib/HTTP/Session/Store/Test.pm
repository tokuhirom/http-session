package HTTP::Session::Store::Test;
use Moose;
with 'HTTP::Session::Role::Store';

has data => (
    is       => 'ro',
    isa      => 'HashRef',
    default  => sub { +{ } },
);

sub select {
    my ( $self, $session_id ) = @_;
    Carp::croak "missing session_id" unless $session_id;
    $self->data->{$session_id};
}

sub insert {
    my ($self, $session_id, $data) = @_;
    Carp::croak "missing session_id" unless $session_id;
    $self->data->{$session_id} = $data;
}

sub update {
    my ($self, $session_id, $data) = @_;
    Carp::croak "missing session_id" unless $session_id;
    $self->data->{$session_id} = $data;
}

sub delete {
    my ($self, $session_id) = @_;
    Carp::croak "missing session_id" unless $session_id;
    delete $self->data->{$session_id};
}

no Moose; __PACKAGE__->meta->make_immutable;
1;
__END__

=head1 NAME

HTTP::Session::Store::Test - store session data on memory for testing

=head1 SYNOPSIS

    HTTP::Session->new(
        store => HTTP::Session::Store::Test->new(
            data => {
                foo => 'bar',
            }
        ),
        state => ...,
        request => ...,
    );

=head1 DESCRIPTION

store session data on memory for testing

=head1 CONFIGURATION

=over 4

=item data

session data.

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

