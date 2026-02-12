package lista_circular::Pelicula;

use strict;
use warnings;

# CONSTRUCTOR
# Crea un nuevo objeto Pelicula con todos sus atributos
sub new {
    my ($class, $nombre, $director, $duracion, $anio) = @_;
    
    my $self = {
        nombre   => $nombre,
        director => $director,
        duracion => $duracion,    # en minutos
        anio     => $anio,
    };
    
    # Convertir el hash en un objeto de la clase Pelicula
    bless $self, $class;
    
    return $self;
}


# METODOS GETTERS Y SETTERS

# get_nombre()
sub get_nombre {
    return $_[0]->{nombre};
}

# get_director()
sub get_director {
    return $_[0]->{director};
}

# get_duracion()
sub get_duracion {
    return $_[0]->{duracion};
}

# get_anio()
sub get_anio {
    return $_[0]->{anio};
}


# set_nombre($nuevo_nombre)
sub set_nombre {
    my ($self, $nuevo_nombre) = @_;
    $self->{nombre} = $nuevo_nombre;
}

# set_director($nuevo_director)
sub set_director {
    my ($self, $nuevo_director) = @_;
    $self->{director} = $nuevo_director;
}

# set_duracion($nueva_duracion)
sub set_duracion {
    my ($self, $nueva_duracion) = @_;
    $self->{duracion} = $nueva_duracion;
}

# set_anio($nuevo_anio)
sub set_anio {
    my ($self, $nuevo_anio) = @_;
    $self->{anio} = $nuevo_anio;
}


# imprimir_info()
# Imprime toda la informacion detallada de la pelicula
# Formato completo con todos los atributos
sub imprimir_info {
    my ($self) = @_;
    
    print "  ...................\n";
    print "  Nombre:    $self->{nombre}\n";
    print "  Director:  $self->{director}\n";
    print "  Duracion:  $self->{duracion} minutos\n";
    print "  Año:       $self->{anio}\n";
    print "  ...................\n\n";
}

sub get_info_graphviz {
    my ($self) = @_;
    
    return "Nombre: $self->{nombre}\n" .
           "Director: $self->{director}\n" .
           "Duracion: $self->{duracion} minutos\n" .
           "Año: $self->{anio}";
}

1;