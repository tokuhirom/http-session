package HTTP::Session::Store::CHI;
use Moose;
with 'HTTP::Session::Role::Store';
use CHI;
use Moose::Util::TypeConstraints;

class_type 'CHI::Driver';
coerce 'CHI::Driver'
    => from 'HashRef'
    => via { CHI->new(%{$_}) };

has chi => (
    is       => 'ro',
    isa      => 'CHI::Driver',
    coerce   => 1,
    required => 1,
);

has expires => (
    is       => 'ro',
    isa      => 'Int',
    required => 1,
);

sub select {
    my ( $self, $session_id ) = @_;
    my $data = $self->chi->get($session_id);
}

sub insert {
    my ($self, $session_id, $data) = @_;
    $self->chi->set( $session_id, $data, $self->expires );
}

sub update {
    my ($self, $session_id, $data) = @_;
    $self->chi->set( $session_id, $data, $self->expires );
}

sub delete {
    my ($self, $session_id) = @_;
    $self->chi->remove( $session_id );
}

no Moose; __PACKAGE__->meta->make_immutable;
1;
__END__

=head1 NAME

HTTP::Session::Store::CHI - store session data with CHI

=head1 SYNOPSIS

    HTTP::Session->new(
        store => HTTP::Session::Store::CHI->new(
            chi => CHI->new(driver => 'memory'),
        ),
        state => ...,
        request => ...,
    );

    # or 

    HTTP::Session->new(
        store => HTTP::Session::Store::CHI->new(
            chi => {driver => 'memory'},
        ),
        state => ...,
        request => ...,
    );

=head1 DESCRIPTION

store session data with CHI

=head1 CONFIGURATION

=over 4

=item memd

instance of CHI::Driver

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

L<HTTP::Session>, L<CHI>

