package HTTP::Session::State::URI;
use Moose;
use URI;
with 'HTTP::Session::Role::State';
use HTML::StickyQuery;

has session_id_name => (
    is      => 'ro',
    isa     => 'Str',
    default => 'sid',
);

sub get_session_id {
    my ($self, $req) = @_;
    Carp::croak "missing req" unless $req;
    $req->param($self->session_id_name);
}

sub response_filter {
    my ($self, $res, $session_id) = @_;
    Carp::croak "missing session_id" unless $session_id;

    if ($res->code == 302) {
        if (my $uri = $res->header('Location')) {
            $res->header('Location' => $self->_redirect_filter($uri, $session_id));
        }
        return $res;
    } elsif ($res->content) {
        $res->content( $self->_html_filter($res->content, $session_id) );
        return $res;
    } else {
        return $res; # nop
    }
}

sub _html_filter {
    my ($self, $html, $session_id) = @_;

    my $session_id_name = $self->session_id_name;

    $html =~ s/(<form\s*.*?>)/$1\n<input type="hidden" name="$session_id_name" value="$session_id">/isg;

    my $sticky = HTML::StickyQuery->new;
    return $sticky->sticky(
        scalarref => \$html,
        param     => { $session_id_name => $session_id },
    );
}

sub _redirect_filter {
    my ( $self, $path, $session_id ) = @_;

    my $uri = URI->new($path);
    $uri->query_form( $uri->query_form, $self->session_id_name => $session_id );
    return $uri->as_string;
}

no Moose; __PACKAGE__->meta->make_immutable;
1;
__END__

=head1 NAME

HTTP::Session::State::URI - embed session id to uri

=head1 SYNOPSIS

    HTTP::Session->new(
        state => HTTP::Session::State::URI->new(
            session_id_name => 'foo_sid',
        ),
        store => ...,
        request => ...,
    );

=head1 DESCRIPTION

This state module embeds session id to uri.

=head1 CONFIGURATION

=over 4

=item session_id_name

You can set the session id name.

    default: sid

=back

=head1 METHODS

=over 4

=item get_session_id

=item response_filter

for internal use only

=back

=head1 WARNINGS

URI sessions are very prone to session hijacking problems.

=head1 SEE ALSO

L<HTTP::Session>

