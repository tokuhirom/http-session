package HTTP::Session;
use Moose;
use 5.00800;
our $VERSION = '0.11';
use Digest::SHA1 ();
use Time::HiRes ();
use Moose::Util::TypeConstraints;
use Carp ();
use Scalar::Util ();

has store => (
    is       => 'ro',
    does     => 'HTTP::Session::Role::Store',
    required => 1,
);

has state => (
    is       => 'ro',
    does     => 'HTTP::Session::Role::State',
    required => 1,
);

has request => (
    is       => 'ro',
    isa      => 'Object',
    required => 1,
);

has session_id => (
    is       => 'rw',
    isa      => 'Str',
);

has _data => (
    is      => 'rw',
    isa     => 'HashRef',
    default => sub { +{} },
);

has is_changed => (
    is      => 'rw',
    isa     => 'Bool',
    default => 0,
);

has is_fresh => (
    is      => 'rw',
    isa     => 'Bool',
    default => 0,
);

has sid_length => (
    is => 'ro',
    isa => 'Int',
    default => 32,
);

sub BUILD {
    my $self = shift;
    $self->_load_session;
}

sub _load_session {
    my $self = shift;

    my $session_id = $self->state->get_session_id($self->request);
    if ( $session_id ) {
        my $data = $self->store->select($session_id);
        if ($data) {
            $self->session_id( $session_id );
            $self->_data($data);
        } else {
            if ($self->state->permissive) {
                $self->session_id( $session_id );
                $self->is_fresh(1);
            } else {
                # session was expired? or session fixation?
                # regen session id.
                $self->session_id( $self->_generate_session_id($self->request) );
                $self->is_fresh(1);
            }
        }
    } else {
        # no sid; generate it
        $self->session_id( $self->_generate_session_id($self->request) );
        $self->is_fresh(1);
    }
}

sub _generate_session_id {
    my $self = shift;
    my $unique = $ENV{UNIQUE_ID} || ( [] . rand() );
    return substr( Digest::SHA1::sha1_hex( Time::HiRes::gettimeofday . $unique ), 0, $self->sid_length );
}

sub response_filter {
    my ($self, $response) = @_;
    Carp::croak "missing response" unless Scalar::Util::blessed $response;

    $self->state->response_filter($self->session_id, $response);
}

sub DESTROY {
    my $self = shift;
    if ($self->is_fresh) {
        $self->store->insert( $self->session_id, $self->_data );
    } else {
        if ($self->is_changed) {
            $self->store->update( $self->session_id, $self->_data );
        }
    }
}

sub keys {
    my $self = shift;
    return keys %{ $self->_data };
}

sub get {
    my ($self, $key) = @_;
    $self->_data->{$key};
}

sub set {
    my ($self, $key, $val) = @_;
    $self->is_changed(1);
    $self->_data->{$key} = $val;
}

sub remove {
    my ( $self, $key ) = @_;
    $self->is_changed(1);
    delete $self->_data->{$key};
}

sub as_hashref {
    my $self = shift;
    return { %{ $self->_data } }; # shallow copy
}

sub expire {
    my $self = shift;
    $self->store->delete($self->session_id);

    # XXX tricky bit to unlock
    delete $self->{$_} for qw(is_fresh changed);
    $self->DESTROY;

    # rebless to null class
    bless $self, 'HTTP::Session::Expired';
}

sub regenerate_session_id {
    my ($self, $delete_old) = @_;
    $self->_data( { %{ $self->_data } } );

    if ($delete_old) {
        my $oldsid = $self->session_id;
        $self->store->delete($oldsid);
    }
    my $session_id = $self->_generate_session_id();
    $self->session_id( $session_id );
    $self->is_fresh(1);
}

{
    my $meta = __PACKAGE__->meta;
    for my $meth (qw/redirect_filter header_filter html_filter/) {
        $meta->add_method(
            $meth, sub {
                my ($self, $stuff) = @_;
                if ($self->state->can($meth)) {
                    $self->state->$meth($self->session_id, $stuff);
                } else {
                    $stuff;
                }
            },
        );
    }
    $meta->make_immutable;
}
no Moose;

package HTTP::Session::Expired;
sub is_fresh { 0 }
sub AUTOLOAD { }

1;
__END__

=encoding utf8

=head1 NAME

HTTP::Session - simple session

=head1 SYNOPSIS

    use HTTP::Session;

    my $session = HTTP::Session->new(
        store   => HTTP::Session::Store::Memcached->new(
            memd => Cache::Memcached->new({
                servers => ['127.0.0.1:11211'],
            }),
        ),
        state   => HTTP::Session::State::Cookie->new(
            cookie_key => 'foo_sid'
        ),
        request => $c->req,
    );

=head1 DESCRIPTION

Yet another session manager.

easy to integrate with L<HTTP::Engine> =)

=head1 METHODS

=over 4

=item $session->load_session()

load session

=item $session->html_filter($html)

filtering HTML

=item $session->redirect_filter($url)

filtering redirect URL

=item $session->header_filter($res)

filtering header

=item $session->response_filter($res)

filtering response. this method runs html_filter, redirect_filter and header_filter.

=item $session->keys()

keys of session.

=item $session->get(key)

get session item

=item $session->set(key, val)

set session item

=item $session->remove(key)

remove item.

=item $session->as_hashref()

session as hashref.

=item $session->expire()

expire the session

=item $session->regenerate_session_id([$delete_old])

regenerate session id.remove old one when $delete_old is true value.

=item BUILD

internal use only

=back

=head1 AUTHOR

Tokuhiro Matsuno E<lt>tokuhirom AAJKLFJEF GMAIL COME<gt>

=head1 SEE ALSO

L<Catalyst::Plugin::Session>, L<Sledge::Session>

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
