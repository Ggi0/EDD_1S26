package avl::avl;

#   Para CADA nodo del arbol, la diferencia de alturas entre su subarbol
#   derecho y su subarbol izquierdo debe ser -1, 0 o +1.
#
# A esa diferencia se le llama FACTOR DE EQUILIBRIO (FE)
#   FE(nodo) = altura(subarbol_derecho) - altura(subarbol_izquierdo)
use strict;
use warnings;

use avl::nodo;

use constant Nodo => 'avl::nodo';

# CONSTRUCTOR
sub new {
    my ($class) = @_;
    my $self = {
        root => undef,
        size => 0,
    };
    bless $self, $class;
    return $self;
}

sub is_empty  {
    return !defined($_[0]->{root}) ? 1 : 0;
}

sub get_size{ 
    return $_[0]->{size}; }


#                                                    FUNCIONES DE ALTURA Y FACTOR DE EQUILIBRIO

# _altura($nodo)
# Retorna la altura del nodo dado.
# Si el nodo es undef (null), retorna -1 por convencion.
sub _altura {
    my ($self, $nodo) = @_;
    return -1 unless defined($nodo);
    return $nodo->get_altura();
}

# _factor_equilibrio($nodo)
#
# Calcula el factor de equilibrio del nodo:
#   FE = altura(subarbol_derecho) - altura(subarbol_izquierdo)
#
#   FE = -1 -> subarbol izquierdo es un poquito mas alto (ta weno)
#   FE =  0 -> ambos subarboles tienen igual altura (excelente, efevescente)
#   FE = +1 -> subarbol derecho es un poco mas alto (ta weno)
#   FE = -2 -> demasiado cargado a la izquierda -> hay que rotar
#   FE = +2 -> demasiado cargado a la derecha -> hay que rotar
#
sub _factor_equilibrio {
    my ($self, $nodo) = @_;
    return 0 unless defined($nodo);
    return $self->_altura($nodo->get_right()) - $self->_altura($nodo->get_left());
}

# _actualizar_altura($nodo)
#
# Recalcula y actualiza la altura almacenada en el nodo.
# Se llama despues de cada rotacion o modificacion del arbol.
#   altura(N) = 1 + max(altura(N.izquierdo), altura(N.derecho))
#
# El +1 representa la arista entre N y su hijo mas alto.
sub _actualizar_altura {
    my ($self, $nodo) = @_;
    return unless defined($nodo);

    my $h_izq = $self->_altura($nodo->get_left());
    my $h_der = $self->_altura($nodo->get_right());

    # max entre ambas alturas, mas 1 por la arista hacia el hijo
    my $nueva_altura = 1 + ($h_izq > $h_der ? $h_izq : $h_der);
    $nodo->set_altura($nueva_altura);
}



# Cada rotacion toma un nodo desbalanceado y retorna la nueva raiz
# que debe quedar en esa posicion.
#   $nodo = $self->_rotar_X($nodo);


# Rotacion simple hacia la DERECHA.
# Se aplica cuando el subarbol IZQUIERDO esta sobrecargado (FE = -2)
# y el hijo izquierdo tambien carga a la izquierda (FE = -1 o 0).
# Esto se conoce como el caso IZQUIERDA-IZQUIERDA (LL).
#   x sube y toma el lugar de y
#   El hijo derecho de x (T2) se convierte en hijo izquierdo de y
#    y se convierte en hijo derecho de x
#       y                        x
#      / \                      / \
#     x   T3        ->         T1   y
#    / \                           / \
#   T1  T2                        T2  T3
#
# T1, T2, T3 son subarboles (pueden estar vacios).
#
sub _rotar_derecha {
    my ($self, $y) = @_;

    #  Paso 1: identificar los nodos involucrados 
    my $x  = $y->get_left();    # x es quien va a subir
    my $T2 = $x->get_right();   # T2 es el subarbol que "cambia de duenio"

    # Paso 2: realizar la rotacion
    $x->set_right($y);   # y se convierte en hijo derecho de x
    $y->set_left($T2);   # T2 pasa a ser hijo izquierdo de y

    # 3 actualizar alturas (primero y, luego x, porque y ahora es hijo de x)
    $self->_actualizar_altura($y);
    $self->_actualizar_altura($x);

    # x es ahora la nueva raiz de este subarbol
    return $x;
}


# Rotacion simple hacia la IZQUIERDA.
# Se aplica cuando el subarbol DERECHO esta sobrecargado (FE = +2)
# y el hijo derecho tambien carga a la derecha (FE = +1 o 0).
# Esto se conoce como el caso DERECHA-DERECHA (RR).
# Antes de rotar:           Despues de rotar:
#
#     x                          y
#    / \                        / \
#   T1   y           ->        x   T3
#       / \                   / \
#      T2  T3                T1  T2
#   1 y sube y toma el lugar de x
#   2 El hijo izquierdo de y (T2) se convierte en hijo derecho de x
#   3 x se convierte en hijo izquierdo de y
#
sub _rotar_izquierda {
    my ($self, $x) = @_;

    # Paso 1 identificar los nodos involucrados
    my $y  = $x->get_right();   # y es quien va a subir
    my $T2 = $y->get_left();    # T2 es el subarbol que "cambia de duenio"

    # Paso 2: realizar la rotacion
    $y->set_left($x);  # x se convierte en hijo izquierdo de y
    $x->set_right($T2);  # T2 pasa a ser hijo derecho de x

    #Paso 3: actualizar alturas (primero x, luego y)
    $self->_actualizar_altura($x);
    $self->_actualizar_altura($y);

    # y es ahora la nueva raiz de este subarbol
    return $y;
}

# _balancear($nodo)
# CASO 1 - Izquierda-Izquierda (LL): FE = -2, FE(hijo_izq) <= 0
#   El subarbol izquierdo es demasiado alto y su propio hijo izquierdo
#   es el que lo hace pesado. Solucion: rotacion simple a la derecha.
#
# CASO 2 - Izquierda-Derecha (LR): FE = -2, FE(hijo_izq) > 0
#   El subarbol izquierdo es demasiado alto pero su hijo DERECHO
#   es el que lo hace pesado (forma en "codo"). 
#   Solucion: primero rotar el hijo izquierdo a la izquierda (lo convierte
#   en caso LL), luego rotar el nodo actual a la derecha.
#
# CASO 3 - Derecha-Derecha (RR): FE = +2, FE(hijo_der) >= 0
#   El subarbol derecho es demasiado alto y su propio hijo derecho
#   es el que lo hace pesado. Solucion: rotacion simple a la izquierda.
#
# CASO 4 - Derecha-Izquierda (RL): FE = +2, FE(hijo_der) < 0
#   El subarbol derecho es demasiado alto pero su hijo IZQUIERDO
#   es el que lo hace pesado (forma en "codo").
#   Solucion: primero rotar el hijo derecho a la derecha (lo convierte
#   en caso RR), luego rotar el nodo actual a la izquierda.
sub _balancear {
    my ($self, $nodo) = @_;

    return undef unless defined($nodo);

    # Actualizar la altura del nodo actual antes de verificar balance
    $self->_actualizar_altura($nodo);

    my $fe = $self->_factor_equilibrio($nodo);

    # CASO 1: LL (pesado a la izquierda, hijo izquierdo tambien pesa a la izq)
    if ($fe == -2 && $self->_factor_equilibrio($nodo->get_left()) <= 0) {
        print "  [ ----> AVL] Rotacion DERECHA en nodo " . $nodo->get_data() . " (caso LL)\n";
        return $self->_rotar_derecha($nodo);
    }

    # CASO 2: LR (pesado a la izquierda, pero el hijo izquierdo pesa a la der)
    if ($fe == -2 && $self->_factor_equilibrio($nodo->get_left()) > 0) {
        print "  [--> AVL] Rotacion IZQUIERDA en hijo izquierdo " . $nodo->get_left()->get_data() . " (caso LR paso 1)\n";
        print "  [--> AVL] Rotacion DERECHA en nodo " . $nodo->get_data() . " (caso LR paso 2)\n";
        $nodo->set_left($self->_rotar_izquierda($nodo->get_left()));
        return $self->_rotar_derecha($nodo);
    }

    # CASO 3: RR (pesado a la derecha, hijo derecho tambien pesa a la der)
    if ($fe == 2 && $self->_factor_equilibrio($nodo->get_right()) >= 0) {
        print "  [-> AVL] Rotacion IZQUIERDA en nodo " . $nodo->get_data() . " (caso RR)\n";
        return $self->_rotar_izquierda($nodo);
    }

    # CASO 4: RL (pesado a la derecha, pero el hijo derecho pesa a la izq)
    if ($fe == 2 && $self->_factor_equilibrio($nodo->get_right()) < 0) {
        print "  [AVL] Rotacion DERECHA en hijo derecho " . $nodo->get_right()->get_data() . " (caso RL paso 1)\n";
        print "  [AVL] Rotacion IZQUIERDA en nodo " . $nodo->get_data() . " (caso RL paso 2)\n";
        $nodo->set_right($self->_rotar_derecha($nodo->get_right()));
        return $self->_rotar_izquierda($nodo);
    }

    # Si FE esta en {-1, 0, +1}, el nodo ya esta balanceado, no hay que hacer nada
    return $nodo;
}



# INSERCION


# insertar($data)
# Inserta un valor en el AVL. Despues de insertar, el arbol se rebalancea
# automaticamente subiendo por la recursion desde el punto de insercion
# hasta la raiz.
sub insertar {
    my ($self, $data) = @_;

    my ($nueva_raiz, $insertado) = $self->_insertar_recursivo($self->{root}, $data);
    $self->{root} = $nueva_raiz;

    if ($insertado) {
        $self->{size}++;
    }
}

# _insertar_recursivo($nodo_actual, $data)
# La diferencia con el bst es lo que pasa AL SUBIR (cuando la recursion retorna):
#   - Cada nodo en el camino de regreso actualiza su altura
#   - Cada nodo verifica su factor de equilibrio
#   - Si un nodo esta desbalanceado, se aplica la rotacion correspondiente
sub _insertar_recursivo {
    my ($self, $nodo_actual, $data) = @_;

    # CASO BASE: llegamos a una posicion vacia -> aqui va el nuevo nodo
    if (!defined($nodo_actual)) {
        print "Insertado '$data' como nuevo nodo.\n";
        return (Nodo->new($data), 1);
    }

    my $valor_actual = $nodo_actual->get_data();

    # DESCENDER: igual que en BST

    if ($data < $valor_actual) {
        # El valor va al subarbol izquierdo
        # RECURSION: bajar a la izquierda
        my ($hijo_izq_actualizado, $insertado) =
            $self->_insertar_recursivo($nodo_actual->get_left(), $data);
        $nodo_actual->set_left($hijo_izq_actualizado);

        # AL SUBIR: balancear este nodo antes de retornar
        return ($self->_balancear($nodo_actual), $insertado);     # <------- estooo es lo importante!!! posible pregunta ¿despues de insertar un nodo como se mantiene balanceado el arbol?

    } elsif ($data > $valor_actual) {
        # El valor va al subarbol derecho
        # RECURSION: bajar a la derecha
        my ($hijo_der_actualizado, $insertado) =
            $self->_insertar_recursivo($nodo_actual->get_right(), $data);
        $nodo_actual->set_right($hijo_der_actualizado);

        # AL SUBIR: balancear este nodo antes de retornar
        return ($self->_balancear($nodo_actual), $insertado); # <------- estooo es lo importante!! balancear despues de cada movimiento!

    } else {
        # El valor ya existe, no se insertan duplicados
        print "El valor '$data' ya existe en el arbol. No se permiten duplicados.\n";
        return ($nodo_actual, 0);
    }
}



# ELIMINACION
# eliminar($data)
#
# Elimina un valor del AVL. Al igual que con la insercion, el arbol
# se rebalancea automaticamente al subir en la recursion.
#
sub eliminar {
    my ($self, $data) = @_;

    if ($self->is_empty()) {
        print "El arbol esta vacio. No hay nada que eliminar.\n";
        return;
    }

    # Verificar si existe antes de intentar eliminar
    #my $existe = $self->buscar($data);
    #if (!defined($existe)) {
    #    print "El valor '$data' no existe en el arbol.\n";
    #    return;
    #}

    my $nueva_raiz = $self->_eliminar_recursivo($self->{root}, $data);
    $self->{root} = $nueva_raiz;
    $self->{size}--;
    print "Valor '$data' eliminado exitosamente.\n";
}

# _eliminar_recursivo($nodo_actual, $data)
#
# La eliminacion en AVL sigue los mismos 3 casos que en BST:
#   CASO 1: El nodo a eliminar es hoja -> simplemente eliminarlo (retornar undef)
#   CASO 2: El nodo tiene un solo hijo -> el padre adopta al nieto
#   CASO 3: El nodo tiene dos hijos -> reemplazar con el sucesor inorden
#
# La diferencia con BST es que al SUBIR en la recursion, cada nodo
# verifica y corrige su balance con _balancear(). !!!!
#
sub _eliminar_recursivo {
    my ($self, $nodo_actual, $data) = @_;

    return undef unless defined($nodo_actual);

    my $valor_actual = $nodo_actual->get_data();

    # FASE 1: DESCENDER hasta encontrar el nodo

    if ($data < $valor_actual) {
        # RECURSION: bajar a la izquierda
        $nodo_actual->set_left(
            $self->_eliminar_recursivo($nodo_actual->get_left(), $data)
        );

    } elsif ($data > $valor_actual) {
        # RECURSION: bajar a la derecha
        $nodo_actual->set_right(
            $self->_eliminar_recursivo($nodo_actual->get_right(), $data)
        );

    } else {
        # Encontramos el nodo. Manejar los 3 casos de eliminacion:

        # CASO 1: Nodo hoja
        if ($nodo_actual->es_hoja()) {
            print "Eliminando hoja '$valor_actual'.\n";
            return undef;
        }

        # CASO 2a: Solo tiene hijo derecho
        elsif (!defined($nodo_actual->get_left())) {
            print "Eliminando '$valor_actual' (solo tiene hijo derecho).\n";
            return $nodo_actual->get_right();
            # No hace falta balancear aqui porque el hijo ya esta balanceado
        }

        # CASO 2b: Solo tiene hijo izquierdo
        elsif (!defined($nodo_actual->get_right())) {
            print "Eliminando '$valor_actual' (solo tiene hijo izquierdo).\n";
            return $nodo_actual->get_left();
        }

        # CASO 3: Tiene dos hijos
        # -----> reemplazar el valor con el SUCESOR INORDEN
        # (el nodo de menor valor en el subarbol derecho).
        # Luego eliminar ese sucesor del subarbol derecho.
        # Esto mantiene la propiedad BST porque el sucesor inorden
        # es mayor que todo el subarbol izquierdo y menor que el
        # resto del subarbol derecho.
        else {
            print "Eliminando '$valor_actual' (tiene dos hijos). Buscando sucesor inorden...\n";
            my $sucesor = $self->_encontrar_minimo($nodo_actual->get_right());
            my $valor_sucesor = $sucesor->get_data();
 
            print "Sucesor inorden: '$valor_sucesor'. Reemplazando...\n";
 
            # Copiar el valor del sucesor al nodo actual
            $nodo_actual->set_data($valor_sucesor);
 
            # Eliminar el sucesor del subarbol derecho (RECURSION)
            $nodo_actual->set_right(
                $self->_eliminar_recursivo($nodo_actual->get_right(), $valor_sucesor)
            );
        }
    }

    # AL SUBIR: balancear este nodo antes de retornarlo al padre ---
    # Esta es la parte clave: en cada nivel de la recursion de vuelta
    # se verifica y corrige el balance si es necesario.
    return $self->_balancear($nodo_actual);
}

# _encontrar_minimo($nodo)
# El minimo de un subarbol siempre es el nodo mas a la izquierda.
sub _encontrar_minimo {
    my ($self, $nodo) = @_;
    return $nodo unless defined($nodo->get_left());
    return $self->_encontrar_minimo($nodo->get_left());
}



# BUSQUEDA
# Identica a BST. El AVL no necesita cambios en busqueda porque
# la propiedad de orden se conserva en todas las rotaciones.
sub buscar {
    # igualito al bst -_-  
}

# RECORRIDOS
# Identicos al BST. Las rotaciones no afectan el orden logico del arbol,
# solo su estructura fisica.

# INORDEN: Izquierda -> Raiz -> Derecha
# Visita los nodos en orden ASCENDENTE.
sub recorrido_inorden {
    my ($self) = @_;
    print "Recorrido INORDEN (ascendente): ";
    if ($self->is_empty()) { print "(arbol vacio)\n"; return; }
    $self->_inorden_rec($self->{root});
    print "\n";
}

sub _inorden_rec {
    my ($self, $nodo) = @_;
    return unless defined($nodo);
    $self->_inorden_rec($nodo->get_left());   # RECURSION izquierda
    print $nodo->get_data() . " ";
    $self->_inorden_rec($nodo->get_right());  # RECURSION derecha
}

# PREORDEN: Raiz -> Izquierda -> Derecha
# Visita la raiz ANTES que sus hijos.
sub recorrido_preorden {
    my ($self) = @_;
    print "Recorrido PREORDEN (raiz primero): ";
    if ($self->is_empty()) { print "(arbol vacio)\n"; return; }
    $self->_preorden_rec($self->{root});
    print "\n";
}

sub _preorden_rec {
    my ($self, $nodo) = @_;
    return unless defined($nodo);
    print $nodo->get_data() . " ";
    $self->_preorden_rec($nodo->get_left());   # RECURSION izquierda
    $self->_preorden_rec($nodo->get_right());  # RECURSION derecha
}

# POSTORDEN: Izquierda -> Derecha -> Raiz
# Visita la raiz DESPUES de sus hijos.
sub recorrido_postorden {
    my ($self) = @_;
    print "Recorrido POSTORDEN (raiz al final): ";
    if ($self->is_empty()) { print "(arbol vacio)\n"; return; }
    $self->_postorden_rec($self->{root});
    print "\n";
}

sub _postorden_rec {
    my ($self, $nodo) = @_;
    return unless defined($nodo);
    $self->_postorden_rec($nodo->get_left());   # RECURSION izquierda
    $self->_postorden_rec($nodo->get_right());  # RECURSION derecha
    print $nodo->get_data() . " ";
}


sub encontrar_minimo {
    my ($self) = @_;
    return undef if $self->is_empty();
    return $self->_encontrar_minimo($self->{root})->get_data();
}

sub encontrar_maximo {
    my ($self) = @_;
    return undef if $self->is_empty();
    my $nodo = $self->{root};
    $nodo = $nodo->get_right() while defined($nodo->get_right());
    return $nodo->get_data();
}

sub imprimir_arbol {
    my ($self) = @_;
    $self->_imprimir_rec($self->{root});
    print "\n";
}

sub _imprimir_rec {
    my ($self, $nodo) = @_;
    return unless defined($nodo);
    $self->_imprimir_rec($nodo->get_left());
    print $nodo->get_data() . "(h=" . $nodo->get_altura() .
          ",fe=" . $self->_factor_equilibrio($nodo) . ") ";
    $self->_imprimir_rec($nodo->get_right());
}

1;