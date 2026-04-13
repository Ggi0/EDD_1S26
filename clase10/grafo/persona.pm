package grafo::Persona;

# OBJETO PERSONA
#
# Representa a una persona
# Ejemplo:
#   NodoGrafo(id="alice", data=Persona("Alice", 22, "Ingenieria"))
#   NodoGrafo(id="bob",   data=Persona("Bob",   24, "Sistemas"))

use strict;
use warnings;

sub new {
    my ($class, $nombre, $edad, $carrera) = @_;

    my $self = {
        nombre  => $nombre,
        edad    => $edad,
        carrera => $carrera,
    };

    bless $self, $class;
    return $self;
}

# GETTERS

sub get_nombre {
return $_[0]->{nombre};
}

sub get_edad {
         return $_[0]->{edad};
}

sub get_carrera {return $_[0]->{carrera};
}

# SETTERS
sub set_nombre {
    my ($self, $nuevo_nombre) = @_;
    $self->{nombre} = $nuevo_nombre;
}

sub set_edad {
    my ($self, $nueva_edad) = @_;
    $self->{edad} = $nueva_edad;
}

sub set_carrera {
    my ($self, $nueva_carrera) = @_;
    $self->{carrera} = $nueva_carrera;
}

# imprimir_info()
# Imprime todos los datos de la persona en formato legible.
sub imprimir_info {
    my ($self) = @_;
    print "  Nombre:  $self->{nombre}\n";
    print "  Edad: $self->{edad} anios\n";
    print "  Carrera: $self->{carrera}\n";
}

# get_info_graphviz()
sub get_info_graphviz {
    my ($self) = @_;
    return "$self->{nombre}\nEdad: $self->{edad}\n$self->{carrera}";
}

1;