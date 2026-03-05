package bst::nodo;


#   1.data  -> El valor que almacena el nodo (clave de comparación)
#   2. left  -> Referencia al hijo IZQUIERDO (valores MENORES que data)
#   3.   right -> Referencia al hijo DERECHO (valores MAYORES que data)
use strict;
use warnings;

# CONSTRUCTOR: new($data)
# Al crearse, no tiene hijos (left y right son undef).
sub new {
    my ($class, $data) = @_;

    my $self = {
        data  => $data, # Valor del nodo (clave de comparación BST)
        left  => undef,  # valores menores
        right => undef,# malores mayores
    };

    bless $self, $class;
    return $self;
}

# Set y Gets
sub get_data {
    return $_[0]->{data};
}

sub set_data {
    my ($self, $new_data) = @_;
    $self->{data} = $new_data;
}

# METODOS GET/SET para LEFT (hijo izquierdo)
sub get_left {
    return $_[0]->{left};
}

sub set_left {
    my ($self, $nodo_izq) = @_;
    # $nodo_izq debe ser una referencia a otro objeto nodo, o undef
    $self->{left} = $nodo_izq;
}

# METODOS GET/SET para RIGHT (hijo derecho)
sub get_right {
    return $_[0]->{right};
}

sub set_right {
    my ($self, $nodo_der) = @_;
    # $nodo_der es --> otro objeto nodo, o undef
    $self->{right} = $nodo_der;
}

#  es_hoja()
# Retorna 1 si el nodo NO tiene hijos
# Retorna 0--> si tiene al menos un hijo
sub es_hoja {
    my ($self) = @_;
    return (!defined($self->{left}) && !defined($self->{right})) ? 1 : 0;
}

#  to_string()
# Representación textual del nodo para depuración
sub to_string {
    my ($self) = @_;
    my $data       = $self->{data};
    my $tiene_izq  = defined($self->{left})  ? "Si" : "No";
    my $tiene_der  = defined($self->{right}) ? "Si" : "No";
    return "Nodo[data=$data, hijo_izq=$tiene_izq, hijo_der=$tiene_der]\n";
}

#  imprimir_nodo()
# Imprime la información del nodo en consola
sub imprimir_nodo {
    my ($self) = @_;
    print "Dato: $self->{data}\n";
    print "Hijo izquierdo: " . (defined($self->{left})  ? "si :) " : "no :(") . "\n";
    print "Hijo derecho:   " . (defined($self->{right}) ? "Si :)" : "No :(") . "\n\n";
}

1;