package HTTP::Session::Store::DBM;
use Moose;
with 'HTTP::Session::Role::Store';
use Fcntl;

has file => (
    is       => 'ro',
    isa      => 'Str',
    required => 1,
);

has dbm => (
    is      => 'ro',
    isa     => 'HashRef',
    default => sub {
        my $self = shift;
        my %hash;
        Class::MOP::load_class( $self->dbm_class );
        tie %hash, $self->dbm_class, $self->file, O_CREAT | O_RDWR, oct("600");
        return \%hash;
    },
    lazy    => 1,
);

has dbm_class => (
    is      => 'ro',
    isa     => 'Str',
    default => 'SDBM_File',
);

sub select {
    my ( $self, $key ) = @_;
    $self->dbm->{$key};
}

sub insert {
    my ( $self, $key, $value ) = @_;
    $self->dbm->{$key} = $value;
}
sub update { shift->insert(@_) }

sub delete {
    my ( $self, $key ) = @_;
    delete $self->dbm->{$key};
}

1;
