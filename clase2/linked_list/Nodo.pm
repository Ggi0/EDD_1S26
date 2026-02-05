package linked_list::Nodo;

# linkend_list/Nodo.pm

# Nodo indiviual de la lista enlazada

# cada nodo tiene 2 partes
#   data (dato) -> valor que almacena
#   next (siguiente) -> referencia al siguiente nodo

use strict;
use warnings;

# CONSTRUCTOR: crear e inicializar objetos
#               asigna valores iniciales 
#               configuraciones automaticas 
#               encapsulacion de logica de creacion
# new()
# recibe el dato que queremos guardar
# regresa el objeto Node
sub new {

    # @_ es el array de argumentos que recibe la función
    #       1) es el elemento que recibe el nombre de la clase Nodo
    #       2) es el dato que le pasamos
    my ($class, $data) = @_;

    # crear el hash con la estructura del nodo:
    #   data : el valor
    #   next : que es la referencia al siguiente nodo 
    my $self = {
        #back => undef,
        data => $data,
        next => undef,
    };

    # bless 
    # convierte el hash $self en un objeto de la clase `$class` (nodo)
    # $self deja de ser un hash común y se convierte en un objeto de Nodo 
    # que puede usar los metodos de este package 
    bless $self, $class;

    # retornamos el objeto creado
    return $self;

};

# METODOS:
    # get_data
    # set_data
    # get_next
    # set_next
    # to_string

# get_data() retorna el dato almacenado en este nodo:
sub get_data {
    # el primer argumento, que siempre es $self (el objeto), 
    # Accedemos al campo 'data' del hash interno
    # print($_[0]->{data});
    return $_[0]->{data};
}

# set_data() cambia el dato almacenado en este nodo
sub set_data{
    my ($self, $new_data) = @_;
    $self->{data} = $new_data;
}

# get_next --> retorna la referencia al siguiente nodo
sub get_next{
    return $_[0]->{next};
}

# set_next --> establece cual es el siguiente nodo 
# realmente aquí estamos enlazando un nodo con otro
sub set_next{
    my ($self, $next_nodo) = @_;
    # $next_nodo debe ser una referencia a otro objeto Nodo
    # si es undef va ser el ultimo nodo
    $self->{next} = $next_nodo;
}

sub to_string{
    my ($self) = @_;
    my $data = $self->{data};
    my $tiene_sig = defined($self->{next}) ? "Si" : "No";

    return "Nodo[data=$data, tiene nodo siguiente = $tiene_sig]\n";
}


sub imprimir_nodo {
    my ($self) = @_;
    print("Dato: $self->{data}\n\n");
};


# TODO MODULO .pm debe terminar con 1;
# esto indica que el modulo se cargo correctamente
1;