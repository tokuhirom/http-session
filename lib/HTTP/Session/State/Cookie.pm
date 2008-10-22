package HTTP::Session::State::Cookie;
use Moose;
with 'HTTP::Session::Role::State';
use CGI::Cookie;
use Carp ();

has cookie_name => (
    is      => 'ro',
    isa     => 'Str',
    default => 'http_session_sid',
);

has cookie_path => (
    is => 'ro',
    isa => 'Str',
    default => '/',
);

has cookie_domain => (
    is => 'ro',
    isa => 'Str|Undef',
);

sub get_session_id {
    my ($self, $req) = @_;

    my %jar    = CGI::Cookie->fetch;
    my $cookie = $jar{$self->cookie_name};
    return $cookie ? $cookie->value : undef;
}

sub response_filter {
    my ($self, $res, $session_id) = @_;
    Carp::croak "missing session_id" unless $session_id;

    my $cookie = CGI::Cookie->new(
        sub {
            my %options = (
                -name   => $self->cookie_name,
                -value  => $session_id,
                -path   => $self->cookie_path,
            );
            $options{'-domain'} = $self->cookie_domain if $self->cookie_domain;
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
            cookie_name   => 'foo_sid',
            cookie_path   => '/my/',
            cookie_domain => 'example.com,
        ),
        store => ...,
        request => ...,
    );

=head1 DESCRIPTION

Maintain session IDs using cookies

=head1 CONFIGURATION

=over 4

=item cookie_name

cookie name.

    default: http_session_sid

=item cookie_path

path.

    default: /

=item cookie_domain

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

