package tableHash::Persona;

# OBJETO PERSONA
#


use strict;
use warnings;

my $TIPOS_VALIDOS = {
    TIPO_A => 1,
    TIPO_B => 1,
    TIPO_C => 1,
    TIPO_D => 1,
};


sub new {
    my ($class, $nombre, $edad, $carrera, $tipo) = @_;

    # Validar el tipo recibido
    unless (defined $tipo && exists $TIPOS_VALIDOS->{$tipo}) {
        print "ALTO AHI MANITO: Tipo '$tipo' no reconocido. Tipos validos: TIPO_A, TIPO_B, TIPO_C, TIPO_D\n";
        $tipo = undef;
    }

    my $self = {
        nombre  => $nombre,
        edad    => $edad,
        carrera => $carrera,
        tipo    => $tipo,
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

sub get_tipo{return $_[0]->{tipo};}


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

sub set_tipo {
    my ($self, $nuevo_tipo) = @_;
    unless (defined $nuevo_tipo && exists $TIPOS_VALIDOS->{$nuevo_tipo}) {
        print "Tipo '$nuevo_tipo' no es valido.\n";
        return 0;
    }
    $self->{tipo} = $nuevo_tipo;
    return 1;
}

# imprimir_info()
# Imprime todos los datos de la persona en formato legible.
sub imprimir_info {
    my ($self) = @_;
    print "  Nombre:  $self->{nombre}\n";
    print "  Edad: $self->{edad} anios\n";
    print "  Carrera: $self->{carrera}\n";
    print " Tipo:" . (defined $self->{tipo} ? $self->{tipo} : "(sin tipo)") . "\n";

}

# get_info_graphviz()

sub get_info_graphviz {
    my ($self) = @_;
    my $tipo_str = defined $self->{tipo} ? $self->{tipo} : "SIN_TIPO";
    return "$self->{nombre}\nEdad: $self->{edad}\n$self->{carrera}\n[$tipo_str]";
}

sub get_etiqueta_corta {
    my ($self) = @_;
    my $tipo_str = defined $self->{tipo} ? $self->{tipo} : "?";
    return "$self->{nombre} [$tipo_str]";
}

1;