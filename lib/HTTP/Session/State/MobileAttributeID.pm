package HTTP::Session::State::MobileAttributeID;
use Moose;
with 'HTTP::Session::Role::State';
use Moose::Util::TypeConstraints;
use HTTP::MobileAttribute  plugins => [
    'UserID',
    'CIDR',
];

has mobile_attribute => (
    is       => 'ro',
    isa      => 'Object',
    required => 1,
);

has check_ip => (
    is      => 'ro',
    isa     => 'Bool',
    default => 1,
);

has '+permissive' => (
    'default' => 1
);

sub get_session_id {
    my ($self, $req) = @_;

    my $ma = $self->mobile_attribute;
    if ($ma->can('user_id')) {
        if (my $user_id = $ma->user_id) {
            if ($self->check_ip) {
                my $ip = $ENV{REMOTE_ADDR} || $req->address || die "cannot get address";
                if (!$ma->isa_cidr($ip)) {
                    die "SECURITY: invalid ip($ip, $ma, $user_id)";
                }
            }
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
        state => HTTP::Session::State::MobileAttributeID->new(
            mobile_attribute => HTTP::MobileAttribute->new($r),
        ),
        store => ...,
        request => ...,
    );

=head1 DESCRIPTION

Maintain session IDs using mobile phone's unique id

=head1 CONFIGURATION

=over 4

=item mobile_attribute

instance of L<HTTP::MobileAttribute>

=item check_ip

check the IP address in the carrier's cidr/ or not?
see also L<Net::CIDR::MobileJP>

=back

=head1 METHODS

=over 4

=item get_session_id

=item response_filter

for internal use only

=back

=head1 SEE ALSO

L<HTTP::Session>
