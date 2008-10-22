package HTTP::Session::State::Cookie;
use Moose;
with 'HTTP::Session::Role::State';
use CGI::Cookie;
use Carp ();

has name => (
    is      => 'ro',
    isa     => 'Str',
    default => 'http_session_sid',
);

has path => (
    is => 'ro',
    isa => 'Str',
    default => '/',
);

has domain => (
    is => 'ro',
    isa => 'Str|Undef',
);

has expires => (
    is => 'ro',
    isa => 'Str|Undef',
);

sub get_session_id {
    my ($self, $req) = @_;

    my %jar    = CGI::Cookie->fetch;
    my $cookie = $jar{$self->name};
    return $cookie ? $cookie->value : undef;
}

sub response_filter {
    my ($self, $res, $session_id) = @_;
    Carp::croak "missing session_id" unless $session_id;

    my $cookie = CGI::Cookie->new(
        sub {
            my %options = (
                -name   => $self->name,
                -value  => $session_id,
                -path   => $self->path,
            );
            $options{'-domain'} = $self->domain if $self->domain;
            $options{'-expires'} = $self->expires if $self->expires;
            %options;
        }->()
    );
    $res->header( 'Set-Cookie' => $cookie->as_string );
}

no Moose; __PACKAGE__->meta->make_immutable;
1;
__END__

=head1 NAME

HTTP::Session::State::Cookie - Maintain session IDs using cookies

=head1 SYNOPSIS

    HTTP::Session->new(
        state => HTTP::Session::State::Cookie->new(
            name   => 'foo_sid',
            path   => '/my/',
            domain => 'example.com,
        ),
        store => ...,
        request => ...,
    );

=head1 DESCRIPTION

Maintain session IDs using cookies

=head1 CONFIGURATION

=over 4

=item name

cookie name.

    default: http_session_sid

=item path

path.

    default: /

=item domain

    default: undef

=item expires

expire date.e.g. "+3M".
see also L<CGI::Simple::Cookie>.

    default: undef

=back

=head1 METHODS

=over 4

=item get_session_id

=item response_filter

for internal use only

=back

=head1 SEE ALSO

L<HTTP::Session>

