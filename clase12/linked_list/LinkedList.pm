
package linked_list::LinkedList;

# IMPLEMENTAMOS UNA LISTA ENLAZADA SIMPLE

# La lista enlazada es una estructura que mantiene una cadena de nodos enlazados. 
# Solo necesita mantener una referencia al primer nodo (head), 
# y desde ahí puede acceder a todos los demás siguiendo los punteros "next".

use strict;
use warnings;

# use FindBin;
# use lib "$FindBin::Bin";
use linked_list::Nodo;
use constant Nodo => 'linked_list::Nodo';

# CONSTRUCCTOR:
sub new {
    my ($class) = @_;

    # la lista solo necesita almacenar una cosa:
    #       el PUNTERO al primer nodo (head)
    my $self ={
        head => undef, #al principio la lista esta vacia
    };

    bless $self, $class;
    return $self;
}

# METODOS:
# esta_vacia -->  verofocar si la lista esta vacia
# agregar --> agrega un no al inicio de la lista
# agregar_final -> agrega un nuevo nodo al final de la lista
# borrar -> elimina el primer nodo que contiene el valor espeficado
# buscar -> busca por un valor especifico
# tamanio -> cuantos nodos hau n la lista?

sub is_empty{
    my ($self) = @_;

    # si head es undef, la lista esta vacia
    return !defined($self->{head})? 1 : 0; # --> distingue entre undef y valores válidos
}

# agergar()
sub agregar{
    # 1) crear un nuevo nodo
    my ($self, $data) = @_;
    my $nuevo_nodo = Nodo->new($data);

    # 2) el nuevo nodo debe de apuntar al actual head
    # si la lista esta vacia, head es undef, eso esta correcto
    $nuevo_nodo->set_next($self->{head});

    # 3) el nuevo nodo pasa a ser el nuevo head 
    $self->{head} = $nuevo_nodo;

    # print " ==> NUEVO VALOR en la lista: $data\n";
}


# metodo delete -> borrar(valor especifico)
#   1. Lista vacía: no hacer nada
#   2. El nodo a eliminar es el head: cambiar head
#   3. El nodo está en medio o al final: reconectar punteros
sub delete{
    my ($self, $data) = @_;
    
    # caso 1 -> esta vicia
    if ($self->is_empty()){
        print "La lista esta vacia, no se puede eliminar ._. ";
        return;
    }

    # caso 2 -> el nodo a eliminar es el head
    if ($self->{head}->get_data() == $data){ # eq o ==
        $self->{head} = $self->{head}->get_next();

        print "$data eliminado correctamente\n";
        return;
    }

    #caso 3 -> el nodo esta en medio o al final
    # necesitamos mantener referencia al nodo anterior.
    my $anterior = $self->{head};
    my $actual = $anterior->get_next();

    while (defined($actual)){
        if ($actual->get_data() eq $data){
            # si entramos, significa que lo encontramos
            # el anterior salta al siguietne del actual
            $anterior->set_next($actual->get_next());
            print "Dato eliminado: $data\n";
            return
        }

        $anterior = $actual;
        $actual = $actual->get_next();
    }

    print "Dato: $data, no esta en la lista.\n"
}


# imprimir la lista --> recorre toda la lista y muestra cada nodo
# imprimir la lista --> recorre toda la lista y muestra cada nodo
sub imprimir_info {
    my ($self) = @_;

    if ($self->is_empty()) {
        print "\n== LA LISTA ESTA VACIA :(\n";
        return;
    }

    print "Lista: \n";
    my $current = $self->{head};

    while (defined($current)) {
        print $current->get_data();

        if (defined($current->get_next())){
            print " ==> ";
        }
        $current = $current->get_next();
    }

    print " ==> NULL\n\n";
}


# get_info_graphviz()
# Retorna un label en formato record para Graphviz
sub get_info_graphviz {
    my ($self) = @_;

    # Si está vacía
    if ($self->is_empty()) {
        return " VACIA ";
    }

    my $current = $self->{head};

    my @labels;

    while (defined($current)) {
        my $data = $current->get_data();

        # escapar caracteres peligrosos
        $data =~ s/"/\\"/g;

        push @labels, $data;

        $current = $current->get_next();
    }

    push @labels, "NULL";

    # unir en formato record vertical
    my $label = "[ " . join(" | ", @labels) . " ]";

    return $label;
}


1;