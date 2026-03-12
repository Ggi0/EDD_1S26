package avl::nodo;

# NODO PARA ARBOL AVL
#   altura -> Altura del nodo en el arbol (0 si es hoja) <----- esto es la diferencia con el bst, con esto vamos a calcular el FE y equilibrarlo
#
#  pero 1ue es la ALTURA de un nodo?
#   Es la cantidad de aristas en el camino mas largo desde este nodo
#   hasta cualquier hoja descendiente suya.
use strict;
use warnings;

sub new {
    my ($class, $data) = @_;

    my $self = {
        data   => $data,
        left   => undef,
        right  => undef,
        altura => 0,     # Un nodo recien creado siempre es hoja, altura = 0
    };

    bless $self, $class;
    return $self;
}

# GETTERS Y SETTERS

sub get_data  {return $_[0]->{data};}
sub get_left  {return $_[0]->{left};}
sub get_right { return $_[0]->{right};}
sub get_altura{return $_[0]->{altura};}

sub set_data {
    my ($self, $val) = @_;
    $self->{data} = $val;
}

sub set_left {
    my ($self, $nodo) = @_;
    $self->{left} = $nodo;
}

sub set_right {
    my ($self, $nodo) = @_;
    $self->{right} = $nodo;
}

sub set_altura {
    my ($self, $h) = @_;
    $self->{altura} = $h;
}

# es_hoja()
# Retorna 1 si el nodo no tiene hijos, 0 si tiene al menos uno.
sub es_hoja {
    my ($self) = @_;
    return (!defined($self->{left}) && !defined($self->{right})) ? 1 : 0;
}

1;