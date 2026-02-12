package D_linked_list::D_linkedList;


# LISTA DOBLEMENTE ENLAZADA

#   CAMBIOS PRINCIPALES respecto a lista simple:
#       1. Ahora mantenemos puntero a HEAD y TAIL
#       2. Cada operación debe actualizar AMBOS punteros: next Y prev
#       3. Podemos recorrer la lista en AMBAS direcciones


use strict;
use warnings;

use D_linked_list::Nodo;
use constant Nodo => 'D_linked_list::Nodo';


# CONSTRUCTOR

sub new {
    my ($class) = @_;

    #           cambio --> ojito
    # Ahora mantenemos DOS punteros:
    #   - head: primer nodo
    #   - tail: último nodo
    my $self = {
        head => undef,    # Primer nodo
        tail => undef,    # Último nodo
    };

    bless $self, $class;
    return $self;
}


# is_empty --> esta vacia?
sub is_empty {
    my ($self) = @_;
    return !defined($self->{head}) ? 1 : 0;
}


#               agregar()
#   1. Crear el nuevo nodo
#   2. Configurar next del nuevo nodo
#   3. Configurar prev del antiguo head
#   4. Actualizar head
#   5. Si la lista estaba vacía, actualizar tail también
sub agregar {
    my ($self, $data) = @_;

    # 1: Crear nuevo nodo
    my $nuevo_nodo = Nodo->new($data);

    # 2: El nuevo nodo apunta adelante al actual head
    $nuevo_nodo->set_next($self->{head});

    # 3: Si hay un head, su prev debe apuntar al nuevo nodo
    if (defined($self->{head})) {
        $self->{head}->set_prev($nuevo_nodo);
    }

    # 4: El nuevo nodo se convierte en head
    $self->{head} = $nuevo_nodo;

    # 5: Si la lista estaba vacía, tail también apunta al nuevo nodo
    if (!defined($self->{tail})) {
        $self->{tail} = $nuevo_nodo;
    }
}


# agregar_final()
sub agregar_final {
    my ($self, $data) = @_;

    # Crear nuevo nodo
    my $nuevo_nodo = Nodo->new($data);

    # Caso especial: lista vacía
    if ($self->is_empty()) {
        $self->{head} = $nuevo_nodo;
        $self->{tail} = $nuevo_nodo;
        return;
    }

    # 1. El nuevo nodo apunta atrás al actual tail
    $nuevo_nodo->set_prev($self->{tail});

    # 2. El actual tail apunta adelante al nuevo nodo
    $self->{tail}->set_next($nuevo_nodo);

    # 3. El nuevo nodo se convierte en tail
    $self->{tail} = $nuevo_nodo;
}


#               delete()
# Ahora debemos actualizar AMBOS punteros (next y prev)
# y también actualizar head/tail si es necesario
sub delete {
    my ($self, $data) = @_;

    # Caso 1: Lista vacía
    if ($self->is_empty()) {
        print "La lista está vacía, no se puede eliminar :c\n";
        return;
    }

    
    # Caso 2: Eliminar el HEAD
    
    if ($self->{head}->get_data() eq $data) {
        # Si head tiene siguiente, ese siguiente pierde su prev
        if (defined($self->{head}->get_next())) {
            $self->{head}->get_next()->set_prev(undef);
        }

        # Mover head al siguiente
        $self->{head} = $self->{head}->get_next();

        #  Si head es undef ahora, tail también debe ser undef
        if (!defined($self->{head})) {
            $self->{tail} = undef;
        }

        print "$data eliminado correctamente (era el head)\n";
        return;
    }

    
    # Caso 3: Eliminar en MEDIO o FINAL
    my $actual = $self->{head}->get_next();

    while (defined($actual)) {
        if ($actual->get_data() eq $data) {
            # Encontramos el nodo a eliminar

            # Actualizar el prev del siguiente (si existe)
            if (defined($actual->get_next())) {
                $actual->get_next()->set_prev($actual->get_prev());
            } else {
                #  Si no hay siguiente, estamos eliminando el tail
                $self->{tail} = $actual->get_prev();
            }

            # Actualizar el next del anterior (si existe)
            if (defined($actual->get_prev())) {
                $actual->get_prev()->set_next($actual->get_next());
            }

            print "Dato eliminado: $data\n";
            return;
        }

        $actual = $actual->get_next();
    }

    print "Dato: $data, no está en la lista\n";
}


# imprimir_lista (head -> tail)
# Este método es igual que en lista simple
sub imprimir_lista {
    my ($self) = @_;

    if ($self->is_empty()) {
        print "\n== LA LISTA ESTÁ VACÍA :(\n";
        return;
    }

    print "Lista (Head -> Tail): \nNULL <-> ";
    my $current = $self->{head};

    while (defined($current)) {
        print $current->get_data();

        if (defined($current->get_next())) {
            print " <-> ";  # Cambié la flecha para mostrar doble dirección
        }
        $current = $current->get_next();
    }

    print " <-> NULL\n\n";
}



# MÉTODO: buscar

sub buscar {
    my ($self, $data) = @_;

    my $current = $self->{head};
    while (defined($current)) {
        if ($current->get_data() eq $data) {
            return 1;  # Encontrado
        }
        $current = $current->get_next();
    }

    return 0;  # No encontrado
}


# tamanio()

sub tamanio {
    my ($self) = @_;

    my $count = 0;
    my $current = $self->{head};

    while (defined($current)) {
        $count++;
        $current = $current->get_next();
    }

    return $count;
}

1;
