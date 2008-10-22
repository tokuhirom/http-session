package HTTP::Session::State::MobileAttributeID;
use Moose;
with 'HTTP::Session::Role::State';
use Moose::Util::TypeConstraints;
use HTTP::MobileAttribute  plugins => [
    'UserID',
];

has mobile_attribute => (
    is       => 'ro',
    isa      => 'Object',
    required => 1,
);

has '+permissive' => (
    'default' => 1
);

sub get_session_id {
    my $self = shift;

    my $ma = $self->mobile_attribute;
    if ($ma->can('user_id')) {
        if (my $user_id = $ma->user_id) {
            return $user_id;
        } else {
            die "cannot detect mobile id from $ma";
        }
    } else {
        die "this carrier doesn't supports user_id: $ma";
    }
}

sub response_filter { }

no Moose; __PACKAGE__->meta->make_immutable;
1;
__END__

=head1 NAME

HTTP::Session::State::MobileAttributeID - Maintain session IDs using mobile phone's unique id

=head1 SYNOPSIS

    HTTP::Session->new(
        state => HTTP::Session::State::MobileAttributeID->new(),
        store => ...,
        request => ...,
    );

=head1 DESCRIPTION

Maintain session IDs using mobile phone's unique id

=head1 CONFIGURATION

=over 4

=item mobile_attribute

instance of L<HTTP::MobileAttribute>

=back

=head1 METHODS

=over 4

=item get_session_id

=item response_filter

for internal use only

=back

=head1 SEE ALSO

L<HTTP::Session>
