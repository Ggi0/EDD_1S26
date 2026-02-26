
package lista_circular::Nodo;

# ---> lista_circular/Nodo.pm

# Similar al nodo de una lista enlazada simple
# a diferencia que el ultimo apunta al primero (HEAD) en lugar de null

use strict;
use warnings;


# CONSTRUCTOR: crea e inicializa objetos
# recibe el objeto que queremos guardar.
# retorna el objeto Nodo
sub new {

#   $_[0] = nombre de la clase (Nodo)
#   $_[1] = el dato que queremos almacenar
    my ($class, $data) = @_;

    # hash que representa la estructura interana del nodo (atributos)
    my $self = {
        data => $data,
        next => undef,
    };

    # convertir le hash en un objeto de la clase Nodo
    bless $self, $class;

    return $self;

}


# METODOS DE ACCESO (get y set)

# get_data()
sub get_data{
    # $_[0] es siempre $self (el objeto actual)
    return $_[0]->{data};
}

# set_data()
sub set_data{
    my ($self, $new_data) = @_;
    $self->{data} = $new_data;
}

#get_next
sub get_next{
    return $_[0]->{next};
}

# set_next()
sub set_next{
    my ($self, $next_nodo) = @_;

    $self->{next} = $next_nodo;
}


sub to_string{
    my ($self) = @_;

    my $data = $self->{data};
    # defined es para saber si no es null
    my $tiene_sig = defined($self->{next}) ? "Simonchos" : "No";

    return " NODO[data = $data, tiene siguientes = $tiene_sig]\n";
}


sub imprimir_nodo {
    my ($self) = @_;
    print "Dato: $self->{data}\n\n";
}


1;
