package grafo::Grafo;

# GRAFO NO DIRIGIDO CON LISTA DE ADYACENCIA
#
#   El grafo almacena los vertices en una LISTA ENLAZADA de NodosContenedor.
#   Cada NodoCont tiene:
#       data      -> referencia al NodoGrafo (el vertice)
#       siguiente -> referencia al proximo NodoCont, o undef
#
#   Visualizacion de la estructura completa:
#
#   Grafo:
#     vertices_cabeza -> [NodoCont: Alice] -> [NodoCont: Bob] -> [NodoCont: Carlos] -> undef
#
#   Cada NodoGrafo tiene su propia lista de adyacencia:
#     Alice.lista -> [NodoLista: Bob] -> [NodoLista: Carlos] -> undef
#     Bob.lista   -> [NodoLista: Alice] -> [NodoLista: Carlos] -> undef
#     Carlos.lista -> [NodoLista: Alice] -> [NodoLista: Bob] -> undef

use strict;
use warnings;

use grafo::NodoGrafo;

use constant NodoGrafo => 'grafo::NodoGrafo';

# _NodoCont: nodo contenedor interno para la lista de vertices
# Lo definimos aqui mismo como un hash simple con bless.
# No necesita su propio archivo porque es un detalle de implementacion interno de esta clase
package grafo::_NodoCont;
sub new {
    my ($class, $data) = @_;
    bless { data => $data, siguiente => undef }, $class;
}
sub get_data { return $_[0]->{data};      }
sub get_siguiente { return $_[0]->{siguiente}; }
sub set_siguiente { my ($s, $n) = @_; $s->{siguiente} = $n; }

# Volvemos al paquete principal del Grafo
package grafo::Grafo;

sub new {
    my ($class) = @_;

    my $self = {
        vertices_cabeza => undef, # Primer NodoCont de la lista de vertices
        cantidad => 0, # Cuantos vertices tiene el grafo
    };

    bless $self, $class;
    return $self;
}

# Retorna 1 si el grafo no tiene ningun vertice.
sub esta_vacio {
    my ($self) = @_;
    return !defined($self->{vertices_cabeza}) ? 1 : 0;
}

# Retorna cuantos vertices tiene el grafo.
sub get_cantidad {
    my ($self) = @_;
    return $self->{cantidad};
}

# Agrega un nuevo vertice al grafo.
#   1 Verificar que el ID no exista ya (no duplicados)
#   2 Crear el NodoGrafo con el ID y dato
#   3 Envolver en un NodoCont
#   4 Agregar al final de la lista de vertices
sub agregar_vertice {
    my ($self, $id, $data) = @_;

    # Verificar que no exista ya
    if (defined($self->buscar_vertice($id))) {
        print "ERROR: El vertice '$id' ya existe en el grafo.\n";
        return 0;
    }

    # Crear el vertice y su contenedor
    my $nodo_grafo = NodoGrafo->new($id, $data);
    my $contenedor = grafo::_NodoCont->new($nodo_grafo);

    # CASO 1: El grafo esta vacio -> este vertice es el primero
    if (!defined($self->{vertices_cabeza})) {
        $self->{vertices_cabeza} = $contenedor;
        $self->{cantidad}++;
        print "Vertice '$id' agregado como primero del grafo.\n";
        return 1;
    }

    # CASO 2: Ya hay vertices -> recorrer hasta el final y enlazar
    my $actual = $self->{vertices_cabeza};
    while (defined($actual->get_siguiente())) {
        $actual = $actual->get_siguiente();
    }
    $actual->set_siguiente($contenedor);
    $self->{cantidad}++;
    print "Vertice '$id' agregado al grafo.\n";
    return 1;
}

# buscar_vertice($id)
# Recorre la lista de vertices buscando el que tiene ese ID.
# Retorna el NodoGrafo si lo encuentra, undef si no existe.
# ----> casi todas las demas operaciones lo llaman primero para obtener la referencia al vertice.
sub buscar_vertice {
    my ($self, $id) = @_;

    my $actual = $self->{vertices_cabeza};
    while (defined($actual)) {
        my $nodo = $actual->get_data();
        if ($nodo->get_id() eq $id) {
            return $nodo;  # Encontrado: retornar el NodoGrafo
        }
        $actual = $actual->get_siguiente();
    }
    return undef;  # No encontrado
}

# Conecta dos vertices existentes.
#   1 Buscar ambos vertices (deben existir)
#   2 Verificar que no esten ya conectados (no aristas duplicadas)
#   3 Agregar B a la lista de A
#   4 Agregar A a la lista de B
sub agregar_arista {
    my ($self, $id_a, $id_b) = @_;

    # Verificar que ambos vertices existan
    my $nodo_a = $self->buscar_vertice($id_a);
    my $nodo_b = $self->buscar_vertice($id_b);

    unless (defined $nodo_a) {
        print "ERROR: El vertice '$id_a' no existe en el grafo.\n";
        return 0;
    }
    unless (defined $nodo_b) {
        print "ERROR: El vertice '$id_b' no existe en el grafo.\n";
        return 0;
    }

    # Verificar que no esten ya conectados
    if ($nodo_a->es_vecino_de($id_b)) {
        print "AVISO: La arista '$id_a' <-> '$id_b' ya existe.\n";
        return 0;
    }

    # Agregar la arista en AMBAS DIRECCIONES (no dirigido)
    $nodo_a->agregar_vecino($nodo_b);
    $nodo_b->agregar_vecino($nodo_a);

    print "Arista agregada: '$id_a' <-> '$id_b'\n";
    return 1;
}

# Desconecta dos vertices.
# Al ser no dirigido, elimina la conexion en AMBAS DIRECCIONES.
sub eliminar_arista {
    my ($self, $id_a, $id_b) = @_;

    my $nodo_a = $self->buscar_vertice($id_a);
    my $nodo_b = $self->buscar_vertice($id_b);

    unless (defined $nodo_a && defined $nodo_b) {
        print "ERROR: Uno o ambos vertices no existen.\n";
        return 0;
    }

    # Eliminar en ambas direcciones
    my $ok_a = $nodo_a->eliminar_vecino($id_b);
    my $ok_b = $nodo_b->eliminar_vecino($id_a);

    if ($ok_a && $ok_b) {
        print "Arista eliminada: '$id_a' <-> '$id_b'\n";
        return 1;
    } else {
        print "AVISO: La arista '$id_a' <-> '$id_b' no existia.\n";
        return 0;
    }
}

# Elimina un vertice del grafo y TODAS sus aristas.
# ----> Al eliminar un vertice, todos sus vecinos aun tienen una referencia a el en sus listas de adyacencia. Hay que limpiarlas.
#   1 Buscar el vertice a eliminar
#   2 Para cada vecino del vertice: eliminar la referencia de regreso
#   3 Eliminar el vertice de la lista de vertices del grafo
sub eliminar_vertice {
    my ($self, $id) = @_;

    my $nodo_a_eliminar = $self->buscar_vertice($id);
    unless (defined $nodo_a_eliminar) {
        print "ERROR: El vertice '$id' no existe.\n";
        return 0;
    }

    # PASO 1: Recorrer todos los vecinos del vertice a eliminar
    # y quitarle la referencia de regreso desde cada vecino
    my $lista    = $nodo_a_eliminar->get_lista_adyacencia();
    my $nodo_lst = $lista->get_cabeza();

    while (defined($nodo_lst)) {
        my $vecino = $nodo_lst->get_data();
        # El vecino tiene a $id en su lista -> eliminarlo
        $vecino->eliminar_vecino($id);
        $nodo_lst = $nodo_lst->get_siguiente();
    }

    # PASO 2: Eliminar el NodoCont de la lista de vertices del grafo
    # Usamos el mismo patron de lista enlazada: previo + actual

    # Caso especial: el vertice a eliminar es la cabeza
    if ($self->{vertices_cabeza}->get_data()->get_id() eq $id) {
        $self->{vertices_cabeza} = $self->{vertices_cabeza}->get_siguiente();
        $self->{cantidad}--;
        print "Vertice '$id' eliminado del grafo.\n";
        return 1;
    }

    # Caso general: buscar con previo + actual
    my $previo = $self->{vertices_cabeza};
    my $actual = $self->{vertices_cabeza}->get_siguiente();

    while (defined($actual)) {
        if ($actual->get_data()->get_id() eq $id) {
            $previo->set_siguiente($actual->get_siguiente());
            $self->{cantidad}--;
            print "Vertice '$id' eliminado del grafo.\n";
            return 1;
        }
        $previo = $actual;
        $actual = $actual->get_siguiente();
    }

    return 0;
}

# Reemplaza el dato almacenado en un vertice existente.
# El ID no cambia; solo cambia el valor asociado.
sub editar_dato_vertice {
    my ($self, $id, $nuevo_data) = @_;

    my $nodo = $self->buscar_vertice($id);
    unless (defined $nodo) {
        print "ERROR: El vertice '$id' no existe.\n";
        return 0;
    }

    $nodo->set_data($nuevo_data);
    print "Dato del vertice '$id' actualizado.\n";
    return 1;
}


# Imprime la representacion completa del grafo: para cada vertice, imprime su ID y su lista de adyacencia.
sub imprimir_grafo {
    my ($self) = @_;

    print "\n Grafo (Lista de Adyacencia)\n";

    if ($self->esta_vacio()) {
        print "(grafo vacio)\n";
        return;
    }

    my $actual = $self->{vertices_cabeza};
    while (defined($actual)) {
        my $nodo = $actual->get_data();
        printf "  %-12s -> ", $nodo->get_id();
        $nodo->get_lista_adyacencia()->imprimir();
        $actual = $actual->get_siguiente();
    }
    print "-----------------------------------\n\n";
}

#                                                       bfs_dos_saltos($id_origen)
# Busqueda en Anchura limitada a 2 saltos.
# Retorna los vertices a distancia exactamente 2 del origen que NO son ya vecinos directos del origen.

# PARA QUE SIRVE:
#   Simula la funcion "personas que quizas conozcas" de redes sociales.
#   Si Alice conoce a Bob y Bob conoce a Carlos, Carlos es una
#   sugerencia de amistad para Alice (a menos que ya sean amigos).
#
# COMO FUNCIONA BFS:
#   BFS recorre el grafo NIVEL POR NIVEL, usando una cola (queue).
#   BFS explora primero todos los vecinos directos y luego los vecinos de los vecinos.
#
#   Cola BFS simulada con lista enlazada:
#    Enqueue: agregar al final
#    Dequeue: sacar del frente
#
#   Para dos saltos:
#    Salto 1: todos los vecinos directos del origen (nivel 1)
#    Salto 2: todos los vecinos de los vecinos (nivel 2)
#    Excepciones: excluir el propio origen y sus vecinos directos
sub bfs_dos_saltos {
    my ($self, $id_origen) = @_;

    my $origen = $self->buscar_vertice($id_origen);
    unless (defined $origen) {
        print "ERROR: El vertice '$id_origen' no existe.\n";
        return undef;
    }

    # Para marcar vertices ya visitados usamos un hash
    # clave: ID del vertice valor: 1 (significa "ya visto")
    my %visitados = ();

    # Marcar al origen como visitado
    $visitados{$id_origen} = 1;

    # Marcar a todos los amigos directos como visitados (nivel 1)
    # Estos NO son sugerencias; ya son amigos.
    my $lista_directa = $origen->get_lista_adyacencia();
    my $ptr           = $lista_directa->get_cabeza();
    while (defined $ptr) {
        $visitados{ $ptr->get_data()->get_id() } = 1;
        $ptr = $ptr->get_siguiente();
    }

    # COLA BFS (lista enlazada interna)
    # Empezamos con el origen en la cola
    my $cola_inicio = grafo::_NodoCont->new($origen);
    my $cola_fin    = $cola_inicio;

    # Lista de resultados (sugerencias encontradas)
    # Tambien es una lista enlazada interna
    my $resultado_inicio = undef;
    my $resultado_fin    = undef;

    # BFS nivel 1: procesar el origen
    # Agregar todos sus vecinos directos a la cola
    my $lista_nivel1 = $origen->get_lista_adyacencia();
    my $n1           = $lista_nivel1->get_cabeza();
    while (defined $n1) {
        my $vecino_directo = $n1->get_data();
        my $cont           = grafo::_NodoCont->new($vecino_directo);
        $cola_fin->set_siguiente($cont);
        $cola_fin = $cont;
        $n1 = $n1->get_siguiente();
    }

    # BFS nivel 2: procesar cada vecino directo
    # Saltamos el primer elemento de la cola (era el origen)
    my $procesando = $cola_inicio->get_siguiente();

    while (defined $procesando) {
        my $nodo_nivel1 = $procesando->get_data();

        # Recorrer la lista de adyacencia de este vecino directo
        my $lista_nivel2 = $nodo_nivel1->get_lista_adyacencia();
        my $n2           = $lista_nivel2->get_cabeza();

        while (defined $n2) {
            my $candidato    = $n2->get_data();
            my $id_candidato = $candidato->get_id();

            # Si NO fue marcado como visitado, es una sugerencia nueva
            unless (exists $visitados{$id_candidato}) {
                $visitados{$id_candidato} = 1;  # Marcar para no agregar dos veces

                # Agregar a la lista de resultados
                my $nuevo_resultado = grafo::_NodoCont->new($candidato);
                if (!defined $resultado_inicio) {
                    $resultado_inicio = $nuevo_resultado;
                    $resultado_fin    = $nuevo_resultado;
                } else {
                    $resultado_fin->set_siguiente($nuevo_resultado);
                    $resultado_fin = $nuevo_resultado;
                }
            }

            $n2 = $n2->get_siguiente();
        }

        $procesando = $procesando->get_siguiente();
    }

    return $resultado_inicio;  # Cabeza de la lista de sugerencias
}

# Llama a bfs_dos_saltos e imprime el resultado de forma legible.
sub imprimir_sugerencias {
    my ($self, $id_origen) = @_;

    print "\nSugerencias de amistad para '$id_origen' (amigos de mis amigos):\n";

    my $sugerencias = $self->bfs_dos_saltos($id_origen);

    if (!defined $sugerencias) {
        return;
    }

    my $actual  = $sugerencias;
    my $contador = 0;

    while (defined $actual) {
        my $sugerido = $actual->get_data();
        print "  - " . $sugerido->get_id() . "\n";
        $contador++;
        $actual = $actual->get_siguiente();
    }

    if ($contador == 0) {
        print "  (sin sugerencias: todos los vertices a 2 saltos ya son amigos)\n";
    }

    print "\n";
}

1;