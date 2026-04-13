package grafo::ListaAdyacencia;

# LISTA DE ADYACENCIA
#
# Esta estructura representa la lista de VECINOS de un vertice.
# Es una lista enlazada simple construida con objetos NodoLista.
#
# se mira como una lista simprelmente enlazada
#   cabeza -> [NodoLista: Bob] -> [NodoLista: Carlos] -> [NodoLista: Ale] -> undef
#
#   cabeza: referencia al primer NodoLista, o undef si la lista esta vacia
#   tamanio: cuantos vecinos tiene este vertice

use strict;
use warnings;

use grafo::NodoLista;

use constant NodoLista => 'grafo::NodoLista';

# CONSTRUCTOR: new()
# Crea una lista de adyacencia vacia.
sub new {
    my ($class) = @_;

    my $self = {
        cabeza   => undef, # Primer NodoLista de la cadena, undef = lista vacia
        tamanio  => 0,     
            };

    bless $self, $class;
    return $self;
}

# Retorna 1 si la lista no tiene ningun vecino, 0 si tiene al menos uno.
sub esta_vacia {
    my ($self) = @_;
    return !defined($self->{cabeza}) ? 1 : 0;
}

# get_tamanio()
sub get_tamanio {
    my ($self) = @_;
    return $self->{tamanio};
}

# Retorna el primer NodoLista. Util para recorrer la lista externamente.
sub get_cabeza {
    return $_[0]->{cabeza};
}

# Agrega un nuevo vecino AL FINAL de la lista.
#  al final para respetar el orden de insercion. Los vecinos aparecen en el orden en que fueron conectados.
sub agregar {
    my ($self, $nodo_grafo) = @_;

    # Crear el nodo de lista que envuelve al nodo del grafo
    my $nuevo = NodoLista->new($nodo_grafo);

    # CASO 1: La lista esta vacia -> el nuevo nodo es la cabeza
    if (!defined($self->{cabeza})) {
        $self->{cabeza} = $nuevo;
        $self->{tamanio}++;
        return;
    }

    # CASO 2: La lista tiene elementos -> recorrer hasta el final y enlazar
    my $actual = $self->{cabeza};
    while (defined($actual->get_siguiente())) {
        $actual = $actual->get_siguiente();
    }
    # Ahora $actual apunta al ultimo NodoLista de la cadena
    $actual->set_siguiente($nuevo);
    $self->{tamanio}++;
}

# contiene($id)
# Revisa si la lista ya tiene un vecino con ese ID.
# Retorna 1 si lo encuentra, 0 si no.
#
# esto importa porque:
#   a) Evitar agregar duplicados al construir el grafo
#   b) Verificar antes de agregar una arista
sub contiene {
    my ($self, $id) = @_;

    my $actual = $self->{cabeza};
    while (defined($actual)) {
        # get_data() retorna el NodoGrafo; get_id() retorna su identificador
        if ($actual->get_data()->get_id() eq $id) {
            return 1;  # Encontrado
        }
        $actual = $actual->get_siguiente();
    }
    return 0;  # No encontrado
}

# Elimina de la lista el NodoLista cuyo NodoGrafo tiene ese ID.
#   Para eliminar un nodo de una lista enlazada, necesitamos al nodo
#   ANTERIOR para redirigir su puntero "siguiente".
# Casos especiales:
#   - El objetivo es la CABEZA: actualizar $self->{cabeza}
#   - El objetivo esta en MEDIO o al FINAL: redirigir el "siguiente" del previo
#
# Retorna 1 si se elimino, 0 si no se encontro.
sub eliminar {
    my ($self, $id) = @_;

    if ($self->esta_vacia()) {
        return 0;
    }

    # CASO ESPECIAL: El primer elemento es el que queremos eliminar
    if ($self->{cabeza}->get_data()->get_id() eq $id) {
        $self->{cabeza} = $self->{cabeza}->get_siguiente();
        $self->{tamanio}--;
        return 1;
    }

    # CASO GENERAL: Recorrer con dos punteros: previo y actual
    my $previo = $self->{cabeza};
    my $actual = $self->{cabeza}->get_siguiente();

    while (defined($actual)) {
        if ($actual->get_data()->get_id() eq $id) {
            # Encontrado: el previo "salta" sobre el actual
            $previo->set_siguiente($actual->get_siguiente());
            $self->{tamanio}--;
            return 1;
        }
        $previo = $actual;
        $actual = $actual->get_siguiente();
    }

    return 0;  # No se encontro el ID en la lista
}

# imprimir()
# Imprime todos los vecinos de esta lista en formato legible.
# Util para depuracion.
sub imprimir {
    my ($self) = @_;

    if ($self->esta_vacia()) {
        print "(sin vecinos)\n";
        return;
    }

    my $actual = $self->{cabeza};
    while (defined($actual)) {
        my $vecino = $actual->get_data();
        print $vecino->get_id();
        if (defined($actual->get_siguiente())) {
            print " -> ";
        }
        $actual = $actual->get_siguiente();
    }
    print "\n";
}

1;