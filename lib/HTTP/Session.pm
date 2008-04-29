package HTTP::Session;
use Moose;
use Digest::SHA1 qw(sha1_hex);                                                                                                        
use Time::HiRes qw(gettimeofday);                                                                                                     
use UNIVERSAL::require;
use 5.00800;
our $VERSION = '0.01';

has store => (
    is   => 'rw',
    does => 'HTTP::Session::Role::Store',
);

has state => (
    is   => 'rw',
    does => 'HTTP::Session::Role::State',
);

has config => (
    is       => 'ro',
    isa      => 'HashRef',
    required => 1,
);

has params => (
    is      => 'rw',
    isa     => 'HashRef',
);

has session_id => (
    is      => 'rw',
    isa     => 'Str',
);

has is_saved => (
    is      => 'rw',
    isa     => 'Bool',
    default => 0,
);

around 'new' => sub {
    my ($next, $class, %args) = @_;
    my $req = delete $args{request} || delete $args{req};
    my $self = $next->($class => %args);
    $self->state( $self->_create_state() );
    $self->store( $self->_create_store( $self->state, $req ) );
    $self;
};

sub _create_state {
    my $self = shift;
    my $module = $self->config->{state}->{module} or die "missing config->{state}->{module}";
    my $state_class = $self->pkg_require( 'State', $module );
    return $state_class->new( config => $self->config->{state}->{conf} || {} );
}

sub _create_store {
    my ($self, $state, $req) = @_;

    if (my $session_id = $state->get_session_id( $req )) {
        # restore session data from storage
        $self->session_id($session_id);

        my $store = $self->_create_store_instance( $session_id );
        $self->params( $store->load_session );
        return $store;
    } else {
        # generate new session
        $self->params( { } ); # set empty hashref
        $self->session_id( $self->generate_session_id );
        return $self->_create_store_instance( $self->session_id );
    }
}

sub _create_store_instance {
    my ($self, $session_id) = @_;
    my $conf = $self->config->{store}->{conf} || {};
    $self->pkg_require( 'Store', $self->config->{store}->{module} )->new( session_id => $session_id, config => $conf );
}

# save session data.
sub inject_session_id {
    my ($self, $res) = @_;
    $self->state->inject_session_id( $res );
}

sub save_session {
    my ($self, ) = @_;
    croak "double save" if $self->is_saved;
    $self->store->save_session( $self->params );
    $self->is_saved(1);
}

sub DESTROY {
    my $self = shift;
    $self->save_session unless $self->is_saved;
}

sub sid_length { 32 }
sub generate_session_id {
    my $self = shift;
    my $unique = $ENV{UNIQUE_ID} || [] . rand();
    return substr( sha1_hex( gettimeofday . $unique ), 0, $self->sid_length );
}

sub pkg_require {
    my ($self, @args) = @_;
    my $pkg = join '::', 'HTTP::Session', @args;
    $pkg->use or die $@;
    $pkg;
}

1;
__END__

=encoding utf8

=head1 NAME

HTTP::Session -

=head1 SYNOPSIS

    use HTTP::Session;
    my $session = HTTP::Session->new( request => $req, config => $conf );
    # ...
    $session->inject_session_id( $res );

    # session data is saved at DESTROY method.

=head1 DESCRIPTION

HTTP::Session is

=head1 TODO

no plan :-)

=head1 AUTHOR

Tokuhiro Matsuno E<lt>tokuhirom@gmail.comE<gt>

=head1 SEE ALSO

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
