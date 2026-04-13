package grafo::NodoGrafo;

# un nodo en grafos tambien lo pedemos llamar vertices VERTICES.
# Cada vertice tiene:
#   - Un identificador unico (id): sirve para encontrarlo y para comparar
#   - Un dato (data): puede ser cualquier cosa (un entero, un string, un objeto Persona...)
#   ----> Su lista de adyacencia: la lista de todos sus vecinos directos
#
#  
# Si "Alice" tiene amigos "Bob", "Carlos" y "Ale", su nodo se ve asi:
#
#   NodoGrafo {
#       id:   "alice"
#       data: objeto Persona("Alice", 25, "Ingenieria")
#       lista: [Bob] -> [Carlos] -> [Ale] -> undef
#   }
#

use strict;
use warnings;

use grafo::ListaAdyacencia;

use constant ListaAdyacencia => 'grafo::ListaAdyacencia';

# CONSTRUCTOR: new($id, $data)
#
# Parametros:
#   $id   -> identificador unico del vertice (string o numero)
#   $data -> el valor que almacena el vertice (objeto, string, numero, etc.)
#
sub new {
    my ($class, $id, $data) = @_;

    my $self = {
        id               => $id,  # Identificador unico
        data             => $data,    # Valor/objeto almacenado
        lista_adyacencia => ListaAdyacencia->new(),     # Lista de vecinos (inicialmente vacia)
    };

    bless $self, $class;
    return $self;
}

# Retorna el identificador unico del vertice.
sub get_id {
    return $_[0]->{id};
}

# Retorna el valor/objeto almacenado en este vertice.
# Puede ser un entero, un string, un objeto Persona, etc.
sub get_data {
    return $_[0]->{data};
}

# Reemplaza el dato almacenado en el vertice.
sub set_data {
    my ($self, $nuevo_data) = @_;
    $self->{data} = $nuevo_data;
}

# Retorna el objeto ListaAdyacencia de este vertice.
# Con esta referencia podemos recorrer todos los vecinos.
sub get_lista_adyacencia {
    return $_[0]->{lista_adyacencia};
}

# Agrega un vecino a la lista de adyacencia de este vertice.
# Delega la operacion al objeto ListaAdyacencia.
sub agregar_vecino {
    my ($self, $nodo_grafo) = @_;
    $self->{lista_adyacencia}->agregar($nodo_grafo);
}

# Elimina un vecino de la lista de adyacencia buscandolo por ID.
# Retorna 1 si se elimino, 0 si no se encontro.
sub eliminar_vecino {
    my ($self, $id) = @_;
    return $self->{lista_adyacencia}->eliminar($id);
}

# Retorna 1 si el vertice con ese ID ya es vecino directo, 0 si no.
sub es_vecino_de {
    my ($self, $id) = @_;
    return $self->{lista_adyacencia}->contiene($id);
}

# Imprime en consola la lista de vecinos directos de este vertice.
sub imprimir_vecinos {
    my ($self) = @_;
    print "  Vecinos de '" . $self->{id} . "': ";
    $self->{lista_adyacencia}->imprimir();
}

1;