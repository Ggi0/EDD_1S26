package grafo::NodoLista;

# NODO DE LA LISTA DE ADYACENCIA
# Este nodo representa UN ELEMENTO dentro de la lista de vecinos de un vertice del grafo
#
# Que guardamos aqui???
#   data -> referencia al NodoGrafo vecino (el amigo/vecino conectado)
#   siguiente -> referencia al proximo NodoLista (siguiente vecino en la lista)

use strict;
use warnings;


#  $data -> referencia a un objeto NodoGrafo (el vecino que este nodo representa)
sub new {
    my ($class, $data) = @_;

    my $self = {
        data      => $data,  # Referencia al NodoGrafo vecino
        siguiente => undef, # Proximo NodoLista en la lista, o undef si es el ultimo
    };

    bless $self, $class;
    return $self;
}

# Retorna la referencia al NodoGrafo que este nodo representa.
sub get_data {
    return $_[0]->{data};
}

# Reemplaza la referencia al NodoGrafo vecino.
sub set_data {
    my ($self, $nuevo_data) = @_;
    $self->{data} = $nuevo_data;
}

# Retorna el proximo NodoLista en la cadena, o undef si es el ultimo.
sub get_siguiente {
    return $_[0]->{siguiente};
}

# Enlaza este NodoLista con el siguiente en la cadena.
# $nodo_lista debe ser un objeto NodoLista, o undef para indicar fin de lista
sub set_siguiente {
    my ($self, $nodo_lista) = @_;
    $self->{siguiente} = $nodo_lista;
}

1;