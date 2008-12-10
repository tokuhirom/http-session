package HTTP::Session::Store::File;
use strict;
use warnings;
use base qw/Class::Accessor::Fast/;
use Storable;

__PACKAGE__->mk_ro_accessors(qw/dir/);

sub new {
    my $class = shift;
    my %args = ref($_[0]) ? %{$_[0]} : @_;
    # check requried parameters
    for (qw/dir/) {
        Carp::croak "missing parameter $_" unless $args{$_};
    }
    # set default values
    bless {%args}, $class;
}

sub select {
    my ($self, $key) = @_;
    if (open my $fh, '<', $self->_to_path($key)) {
        my $value = Storable::fd_retrieve($fh);
        close $fh;
        return $value;
    }
    undef;
}

sub insert {
    my ($self, $key, $value) = @_;
    Storable::nstore $value, $self->_to_path($key);
}

sub update {
    shift->insert(@_);
}

sub delete {
    my ($self, $key) = @_;
    unlink $self->_to_path($key);
}

sub _to_path {
    my ($self, $key) = @_;
    $key =~ s/([^A-Za-pr-z0-9_])/sprintf("q%02x", ord $1)/eg;
    $self->dir . '/' . $key . '.dat';
}

1;
