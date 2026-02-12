package D_linked_list::Nodo;

# 
# NODO PARA LISTA DOBLEMENTE ENLAZADA
# 
# CAMBIO PRINCIPAL: Ahora cada nodo tiene 3 partes en lugar de 2
#   1. data (dato) -> valor que almacena
#   2. next (siguiente) -> referencia al siguiente nodo
#   3. prev (anterior) -> referencia al nodo anterior  ***
# 

use strict;
use warnings;

# 
# CONSTRUCTOR: new()
# 
sub new {
    my ($class, $data) = @_;

    # cambio 
    # Ahora el hash tiene 3 campos en lugar de 2
    my $self = {
        data => $data,
        next => undef,    # Siguiente nodo (como en la lista enlazada simple)
        prev => undef,    # : Nodo anterior 
    };

    bless $self, $class;
    return $self;
}


# MÉTODOS GET/SET para DATA  
sub get_data {
    return $_[0]->{data};
}

sub set_data {
    my ($self, $new_data) = @_;
    $self->{data} = $new_data;
}

 
# MÉTODOS GET/SET para NEXT \
sub get_next {
    return $_[0]->{next};
}

sub set_next {
    my ($self, $next_nodo) = @_;
    $self->{next} = $next_nodo;
}


# MÉTODOS GET/SET para PREV
# Estos métodos NO existían en la lista simple
sub get_prev {
    return $_[0]->{prev};
}

sub set_prev {
    my ($self, $prev_nodo) = @_;
    # $prev_nodo debe ser una referencia a otro objeto Nodo
    # o undef si este es el primer nodo
    $self->{prev} = $prev_nodo;
}


# MÉTODO to_string (modificado para mostrar prev también)
sub to_string {
    my ($self) = @_;
    my $data = $self->{data};
    
    # Ahora mostramos tanto next como prev
    my $tiene_sig = defined($self->{next}) ? "Si" : "No";
    my $tiene_ant = defined($self->{prev}) ? "Si" : "No";  

    return "Nodo[data=$data, tiene_siguiente=$tiene_sig, tiene_anterior=$tiene_ant]\n";
}

sub imprimir_nodo {
    my ($self) = @_;
    print "Dato: $self->{data}\n";
    print "Tiene anterior: " . (defined($self->{prev}) ? "Si" : "No") . "\n";
    print "Tiene siguiente: " . (defined($self->{next}) ? "Si" : "No") . "\n\n";
}

1;
