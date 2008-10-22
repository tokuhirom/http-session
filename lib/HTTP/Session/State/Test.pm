package HTTP::Session::State::Test;
use Moose;
with 'HTTP::Session::Role::State';

has session_id => (
    is       => 'ro',
    isa      => 'Str',
    required => 1,
);

sub get_session_id {
    my $self = shift;
    return $self->session_id;
}
sub response_filter { }

no Moose; __PACKAGE__->meta->make_immutable;
1;
__END__

=head1 NAME

HTTP::Session::State::Test - state module for testing

=head1 SYNOPSIS

    HTTP::Session->new(
        state => HTTP::Session::State::Test->new(
            session_id => 'foobar',
        ),
        store => ...,
        request => ...,
    );

=head1 DESCRIPTION

This is an mock object for testing session.

=head1 CONFIGURATION

=over 4

=item session_id

dummy session id

=back

=head1 METHODS

=over 4

=item get_session_id

=item response_filter

for internal use only

=back

=head1 SEE ALSO

L<HTTP::Session>

