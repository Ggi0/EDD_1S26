package lista_circular::ListaCircular;

    # lista_circular/ListaCircula.pm

use strict;
use warnings;

use lista_circular::Nodo;
use constant Nodo => 'lista_circular::Nodo';

# CONSTRUCTOR
sub new{
    my ($class) = @_;

    # diferencia: en una lista simple aqui head es especial
    # porque el ultimo nodo siempre apunta de vuelta a el
    my $self = {
        head => undef, # lista vacia
    };

    bless $self, $class;
    return $self;
}


# METODOS / INTERFACE
#   esta_vacia ?
#   agregar
#   agregar al final
#   borrar(dato)
#   buscar
#   tamanio
#   imprimir_lista

# is_empty() --> esta vacia?
sub is_empty {
    my ($self) = @_;

    # si head es undef, no hay nodos en la lista
    return !defined($self->{head})? 1 : 0;
}


# agregar($data)
sub agregar {
    # agregar nuevo nodo al principio de la lista
    my ($self, $data) = @_;

    # 1 crear un nuevo nodo
    my $nuevo_nodo = Nodo->new($data);

    # 2 la lista esta vacia?
    if ($self->is_empty()){
        # si esta vacia, el nuevo nodo es el unico
        # debe de apuntar a si mismo para formar el bucle
        $nuevo_nodo->set_next($nuevo_nodo);
        $self->{head} = $nuevo_nodo;

        print " ==> [NUEVO VALOR] Agregado exitosamente como 1er nodo\n";
        return;
    }

    # 3 lista con elementos
    # debemos buscar el ultimo nodo, cual es el ultimo? el que NEXT este apuntando al actual head
    my $ultimo = $self->{head};

    # recorremos hasta encontrar el nodo cuyo next es head
    while ($ultimo->get_next() != $self->{head}){
        $ultimo  = $ultimo->get_next();
    }

    # reconectar los punteros
    #   1. el nuevo nodo apunta al actual head
    $nuevo_nodo->set_next($self->{head});

    #   2. el ultimo nodo apunta al nuevo nodo (en vez del viejo head)
    $ultimo->set_next($nuevo_nodo);

    #   3. el nuevo nodo se convierte en el neuvo head
    $self->{head} = $nuevo_nodo;

    print " ==> [NUEVO VALOR] en la lista circular: $data\n"
}


# delete($data)
# elimina el primer nodo que contiene el valor especificado
sub delete{
    my ($self, $data) = @_;

    # caso 1 --> la lista esta vacia?
    if ($self->is_empty()){
        print "la lista esta vacia manito, no se puede borrar nada :( \n";
        return;
    }

    # buscar el ultimo nodo
    my $ultimo = $self->{head};
    while ($ultimo->get_next() != $self->{head}){
        $ultimo = $ultimo->get_next();
    }

    # caso 2 --> solo un nodo hay en la lista
    # si head->next apunta a si mismo, que solo hay un nodo.
    if ($self->{head}->get_next() == $self->{head}){
        # vefificamos si ese unico nodo tiene el dato
        if ($self->{head}->get_data() eq $data){
            $self->{head} = undef; # lista vacia
            return;
        } else {
            print "Dato: $data, no esta en la lista. \n";
            return;
        }
    }

    # caso 3 head contiene el dato que queremos borrar
    if ($self->{head}->get_data() eq $data){
        # el ultimo nodo debe de apuntar al segundo nodo
        $ultimo->set_next($self->{head}->get_next());

        # el segundo nodo se convierte en el head
        $self->{head} = $self->{head}->get_next();
        return;
    }

    #caso 4 el dato a eliminar esta en medio o al final
    my $anterior = $self->{head};
    my $actual = $anterior->get_next();

    # buscamos el dato que queremos borrar
    while ($actual != $self->{head}) {
        if ($actual->get_data() eq $data){
            
            # conectar punteros
            $anterior->set_next($actual->get_next());
            print "Dato eliminado $data\n";
            return;
        }

        $anterior = $actual;
        $actual = $actual->get_next();
    }

    # si el programa llega hasta aquí, significa que no encontro el dato
    print "El dtao $data, no esta en la lista. \n";

}


# tamanio()
# Retorna cuantos nodos hay en la lista
sub tamanio {
    my ($self) = @_;
    
    if ($self->is_empty()) {
        return 0;
    }
    
    my $contador = 0;
    my $actual = $self->{head};
    
    # Recorremos contando nodos hasta dar la vuelta completa
    do {
        $contador++;
        $actual = $actual->get_next();
    } while ($actual != $self->{head});
    
    return $contador;
}

# imprimir lista
sub imprimir_lista {
    # imprimir solo una vuelta, para no generar un bucle infinito
    my ($self) = @_;

    if ($self->is_empty()){
        print "\n la lista esta vacia :( pipipi \n";
        return;
    }

    print "Lista Circular completa: \n";
    my $actual = $self->{head};

    # do-while para imprimir almenos una vez el head
    do{
        my $dato = $actual->get_data();

        if (ref($dato) && $dato->can('imprimir_info')) {
             $dato->imprimir_info();
        } else {
            print $dato;
        }

        if ($actual->get_next() != $self->{head}) {
            print " -> ";
        }

        $actual = $actual->get_next();
    } while ($actual != $self->{head});

    print " -> (vuelve a HEAD)\n\n";
}



sub imprimir_pelicula {
    my ($self) = @_;

    if ($self->is_empty()){
        print "\nLa lista esta vacia :( pipipi\n";
        return;
    }

    print "Lista Circular completa:\n";

    my $actual = $self->{head};

    do {
        my $pelicula = $actual->get_data();

        # LLAMAR EL METODO DEL OBJETO
        $pelicula->imprimir_info();

        if ($actual->get_next() != $self->{head}) {
            print " -> \n";
        }

        $actual = $actual->get_next();

    } while ($actual != $self->{head});

    print "-> (vuelve a HEAD)\n\n";
}




1;
