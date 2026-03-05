package bst::bst;

# ARBOL BINARIO DE BUSQUEDA (BST - Binary Search Tree)


use strict;
use warnings;

use bst::nodo;

use constant Nodo => 'bst::nodo';

# CONSTRUCTOR: new()
# Crea un BST vacio. Solo necesita una referencia a la raiz (root).
sub new {
    my ($class) = @_;

    my $self = {
        root => undef,# La raiz del arbol; undef = arbol vacio
        size => 0, # Cantidad de nodos en el arbol
    };

    bless $self, $class;
    return $self;
}

# is_empty()
# Retorna 1 si el arbol está vacio (root == undef), 0 si tiene nodos.
#
sub is_empty {
    my ($self) = @_;
    return !defined($self->{root}) ? 1 : 0;
}

# get_size()
sub get_size {
    my ($self) = @_;
    return $self->{size};
}

# insertar($data)
# Inserta un nuevo valor en el BST respetando la propiedad de orden.
#   1. Si el arbol está vacio -> el nuevo nodo ES la raiz
#   2. Si NO está vacio -> delegar la inserción al método RECURSIVO privado
sub insertar {
    my ($self, $data) = @_;

    # arbol vacio, el nuevo nodo se convierte en la raiz
    if (!defined($self->{root})) {
        $self->{root} = Nodo->new($data);
        $self->{size}++;
        print " -----> Insertado '$data' como ROOT del arbol.\n";
        return;
    }

    # RECURSIVIDAD
    my $insertado = $self->_insertar_recursivo($self->{root}, $data);

    if ($insertado) {
        $self->{size}++;
    }
}

# para insetar un dato que no es la raiz 
# Este método se llama a sí mismo para descender por el arbol hasta encontrar la posición correcta donde insertar el nuevo nodo.
#   Para insertar el valor X en el subarbol con raiz N:
#
#   if X < N.data:
#       if N.izquierdo == null:
#           N.izquierdo = nuevo_nodo(X)    <- CASO 1, el primer izquiero esta vacio
#       else:
#           insertar_recursivo(N.izquierdo, X)  <- RECURSION: bajar a la izq
#
#   if X > N.data:
#       if N.derecho == null:
#           N.derecho = nuevo_nodo(X)     <- CASO 1, el primer derecho esta vacio
#       else:
#           insertar_recursivo(N.derecho, X)   <- RECURSIoN: bajar a la der
#
#   if X == N.data:
#       No insertamos duplicados
#
# Retorna:
#   1 si se inserto exitosamente
#   0 si el valor ya existía (duplicado)
#
sub _insertar_recursivo {
    my ($self, $nodo_actual, $data) = @_;

    my $valor_actual = $nodo_actual->get_data();

    # CASO: El dato a insertar es MENOR que el nodo actual
    # -> Debe ir al sub- arbol IZQUIERDO
    if ($data < $valor_actual) {

        if (!defined($nodo_actual->get_left())) {
            # CASO 1: El hijo izquierdo está vacio -> INSERTAR AQUÍ
            $nodo_actual->set_left(Nodo->new($data));
            print "Insertado '$data' a la IZQUIERDA de '$valor_actual'.\n";
            return 1;
        } else {
            # CASO RECURSIVO: El hijo izquierdo existe -> bajar más
            # hijo izquierdo es la nueva raiz
            return $self->_insertar_recursivo($nodo_actual->get_left(), $data);
        }
    }

    # CASO: El dato a insertar es MAYOR que el nodo actual
    # -> Debe ir al subarbol DERECHO
    elsif ($data > $valor_actual) {

        if (!defined($nodo_actual->get_right())) {
            # CASO 1: El hijo derecho está vacio -> INSERTAR AQUi
            $nodo_actual->set_right(Nodo->new($data));
            print "Insertado '$data' a la DERECHA de '$valor_actual'.\n";
            return 1;
        } else {
            # CASO RECURSIVO: El hijo derecho existe -> bajar más
            return $self->_insertar_recursivo($nodo_actual->get_right(), $data);
        }
    }

    # CASO: El dato ya EXISTE en el arbol (duplicado)
    # Los BST típicamente no permiten duplicados
    else {
        print "ERRRO: El valor '$data' ya existe en el arbol. No se insertaron duplicados pipipipi.\n";
        return 0;
    }
}

# metodo publico (o sea el normalito) buscar($data)
sub buscar {
    my ($self, $data) = @_;

    if ($self->is_empty()) {
        print "El arbol está vacio. No hay nada que buscar.\n";
        return undef;
    }

    # Delegar la búsqueda al metodo recursivo
    return $self->_buscar_recursivo($self->{root}, $data);
}

#  _buscar_recursivo($nodo_actual, $data)
# La búsqueda en BST aprovecha la propiedad de orden para DESCARTAR mitades del arbol en cada paso (similar a búsqueda binaria).
#   Para buscar X en subarbol con raiz N:
#
#   if N == null:
#       return null        <- CASO 1: no se encontró
#
#   if X == N.data:
#       return N           <- CASO 2: encontrado!!!!!
#
#   if X < N.data:
#       return buscar(N.izquierdo, X)   <- recursion --->: buscar a la izq
#   if X > N.data:
#       return buscar(N.derecho, X)     <- recursion --->: buscar a la der
#
sub _buscar_recursivo {
    my ($self, $nodo_actual, $data) = @_;

    # CASO 1: Llegamos a un nodo nulo -> no se encontró
    if (!defined($nodo_actual)) {
        return undef;
    }

    my $valor_actual = $nodo_actual->get_data();

    # CASO 2: ¡Encontramos el valor!
    if ($data == $valor_actual) {
        return $nodo_actual;
    }

    # CASO RECURSIVO: Buscar en el subarbol izquierdo
    elsif ($data < $valor_actual) {
        # SE LLAMA A SÍ MISMA con el hijo izquierdo
        return $self->_buscar_recursivo($nodo_actual->get_left(), $data);
    }

    # CASO RECURSIVO: Buscar en el subarbol derecho
    else {
        # SE LLAMA A SÍ MISMA con el hijo derecho
        return $self->_buscar_recursivo($nodo_actual->get_right(), $data);
    }
}

#  eliminar($data)
# Elimina un valor del BST manteniendo la propiedad de orden.
# CASOS DE ELIMINACIÓN (3):
#
#   CASO 1: El nodo a eliminar es una HOJA (sin hijos)
#           -> Simplemente eliminar, apuntar al padre a null
#
#   CASO 2: El nodo tiene UN solo hijo
#           -> El padre "salta" sobre el nodo y apunta al hijo directamente
#
#   CASO 3: El nodo tiene DOS hijos
#           -> Reemplazar con el SUCESOR INORDEN (el menor del subarbol derecho)
#              o con el PREDECESOR INORDEN (el mayor del subarbol izquierdo)
#           -> En este BST usamos el SUCESOR INORDEN
#
sub eliminar {
    my ($self, $data) = @_;

    if ($self->is_empty()) {
        print "El arbol está vacio. No hay nada que eliminar.\n";
        return;
    }

    # Verificar primero si el elemento existe
    my $existe = $self->buscar($data);
    if (!defined($existe)) {
        print "El valor '$data' no existe en el arbol.\n";
        return;
    }

    # Llamar al método recursivo que maneja los 3 casos
    # Nota: _eliminar_recursivo retorna el nodo actualizado (puede ser undef si
    # eliminamos la raiz sin hijos)
    $self->{root} = $self->_eliminar_recursivo($self->{root}, $data);
    $self->{size}--;
    print "Valor '$data' eliminado exitosamente.\n";
}


# _eliminar_recursivo($nodo_actual, $data)
# Este método desciende por el arbol para encontrar el nodo a eliminar y luego maneja los 3 casos posibles.
#
# PATRÓN IMPORTANTE:
# En vez de manipular el nodo padre directamente, este método RETORNA
# el nodo actualizado. El padre asigna el retorno a su hijo correspondiente.
# Esto simplifica enormemente el manejo de punteros.
#
# Parámetros:
#   $nodo_actual -> nodo raiz del subarbol actual en la recursion --->
#   $data        -> valor a eliminar
#
# Retorna:
#   El nodo actualizado que debe quedar en esa posición del arbol
#   (puede ser el mismo nodo, su reemplazo, o undef si fue eliminado)
#
sub _eliminar_recursivo {
    my ($self, $nodo_actual, $data) = @_;

    # CASO BASE: llegamos a null -> el nodo no existe (ya verificamos antes)
    if (!defined($nodo_actual)) {
        return undef;
    }

    my $valor_actual = $nodo_actual->get_data();

    
    # FASE 1: DESCENDER hasta encontrar el nodo a eliminar
    if ($data < $valor_actual) {
        # El nodo a eliminar está en el subarbol IZQUIERDO
        # recursion --->: bajar a la izquierda y actualizar el puntero
        $nodo_actual->set_left(
            $self->_eliminar_recursivo($nodo_actual->get_left(), $data)
        );
        return $nodo_actual;

    } elsif ($data > $valor_actual) {
        # El nodo a eliminar está en el subarbol DERECHO
        # recursion --->: bajar a la derecha y actualizar el puntero
        $nodo_actual->set_right(
            $self->_eliminar_recursivo($nodo_actual->get_right(), $data)
        );
        return $nodo_actual;

    } else {
        # Encontramos el nodo a eliminar!!!! ($data == $valor_actual)
        # Ahora manejar los 3 casos:

        
        # CASO 1: El nodo es una HOJA (sin hijos)
        # Simplemente retornamos undef -> el padre apuntará a null
        if ($nodo_actual->es_hoja()) {
            print "Eliminando hoja con valor '$valor_actual'.\n";
            return undef;  # El padre dejará de apuntar a este nodo
        }

        
        # CASO 2a: Solo tiene hijo DERECHO
        # Retornamos el hijo derecho -> el padre lo adoptará directamente
        elsif (!defined($nodo_actual->get_left())) {
            print "Eliminando nodo '$valor_actual' (solo tiene hijo derecho).\n";
            return $nodo_actual->get_right();  # El abuelo adopta al nieto
        }

        
        # CASO 2b: Solo tiene hijo IZQUIERDO
        # Retornamos el hijo izquierdo -> el padre lo adoptará directamente
        elsif (!defined($nodo_actual->get_right())) {
            print "Eliminando nodo '$valor_actual' (solo tiene hijo izquierdo).\n";
            return $nodo_actual->get_left();  # El abuelo adopta al nieto
        }

        
        # CASO 3: Tiene DOS hijos --> el dificilito, ya me hice bolas no entiendo los punteros pipipi
            # No podemos simplemente eliminar el nodo porque romperíamos el arbol.
            # Solución: Reemplazar el valor con el SUCESOR INORDEN.
        # ¿Qué es el SUCESOR INORDEN?
        #   Es el valor más pequeño del subarbol DERECHO.
        #   En el recorrido inorden (izq, raiz, der), es el siguiente valor
        #   después del nodo actual.
        #
        # Por qué funciona??? ya no te entiendo manito?
        #   El sucesor inorden es:
        #   - Mayor que todos los nodos del subarbol izquierdo (mantiene BST)
        #   - El menor del subarbol derecho (mantiene BST)
        #   Por tanto, puede reemplazar al nodo actual sin violar la propiedad BST.
        #
        # Pasos:
        #   1. Encontrar el sucesor inorden (el mínimo del subarbol derecho)
        #   2. Copiar su valor al nodo actual
        #   3. Eliminar el sucesor inorden del subarbol derecho (recursivamente)
        
        else {
            print "Eliminando nodo '$valor_actual' (tiene dos hijos).\n";
            print "Buscando sucesor inorden en el subarbol derecho, o sea izquierda -> root -> derecha (ver pizarron si hay confusión aun en esto)...\n";

            # Paso 1: Encontrar el sucesor inorden (mínimo del subarbol derecho)
            my $sucesor = $self->_encontrar_minimo($nodo_actual->get_right());
            my $valor_sucesor = $sucesor->get_data();

            print "Sucesor inorden encontrado: '$valor_sucesor'. Reemplazando...\n";

            # Paso 2: Copiar el valor del sucesor al nodo actual
            $nodo_actual->set_data($valor_sucesor);

            # Paso 3: Eliminar el sucesor del subarbol derecho (recursivamente)
            # El sucesor es el mínimo del subarbol derecho, así que tiene
            # como máximo UN hijo (el derecho), por lo que será CASO 1 o CASO 2
            $nodo_actual->set_right(
                $self->_eliminar_recursivo($nodo_actual->get_right(), $valor_sucesor)
            );

            return $nodo_actual;  # Retornamos el nodo actualizado (con nuevo valor)
        }
    }
}


#  _encontrar_minimo($nodo)

#
# Encuentra el nodo con el valor MÍNIMO en el subarbol dado.
# En un BST, el mínimo siempre está en el extremo MÁS A LA IZQUIERDA.
#
# *** RECURSIVIDAD: sigue bajando por la izquierda hasta llegar a null ***
#
# Parámetros:
#   $nodo -> raiz del subarbol donde buscar el mínimo
#
# Retorna: referencia al nodo con el valor mínimo
#
sub _encontrar_minimo {
    my ($self, $nodo) = @_;

    # CASO BASE: El nodo no tiene hijo izquierdo -> este ES el mínimo
    if (!defined($nodo->get_left())) {
        return $nodo;
    }

    # CASO RECURSIVO: Seguir bajando a la izquierda
    return $self->_encontrar_minimo($nodo->get_left());
}


# metodo publico (o sea el normalito) encontrar_minimo()

# Retorna el valor mínimo del arbol (el más a la izquierda de todo)
#
sub encontrar_minimo {
    my ($self) = @_;
    if ($self->is_empty()) {
        print "El arbol está vacio.\n";
        return undef;
    }
    my $nodo_min = $self->_encontrar_minimo($self->{root});
    return $nodo_min->get_data();
}


# metodo publico) encontrar_maximo()

# Retorna el valor máximo del arbol (el más a la derecha de todo)
#
sub encontrar_maximo {
    my ($self) = @_;
    if ($self->is_empty()) {
        print "El arbol está vacio.\n";
        return undef;
    }
    my $nodo = $self->{root};
    # El máximo siempre está en el extremo más a la DERECHA
    while (defined($nodo->get_right())) {
        $nodo = $nodo->get_right();
    }
    return $nodo->get_data();
}


# RECORRIDO 1: INORDEN (In-Order) - Izquierda, raiz, Derecha
#   inorden(nodo):
#     inorden(nodo.izquierdo)  <- primero visitar todo lo de la izquierda
#     imprimir(nodo.data)      <- luego visitar la raiz
#     inorden(nodo.derecho)    <- finalmente visitar todo lo de la derecha
#
sub recorrido_inorden {
    my ($self) = @_;
    print "Recorrido INORDEN (ascendente): ";
    if ($self->is_empty()) {
        print "(arbol vacio)\n";
        return;
    }
    $self->_inorden_recursivo($self->{root});
    print "\n";
}

sub _inorden_recursivo {
    my ($self, $nodo_actual) = @_;

    # CASO BASE: Si el nodo es null, no hacer nada (detener la recursion --->)
    return if !defined($nodo_actual);

    # 1. Visitar subarbol IZQUIERDO (recursion ---> hacia la izquierda)
    $self->_inorden_recursivo($nodo_actual->get_left());

    # 2. Visitar el nodo ACTUAL (procesar la raiz)
    print $nodo_actual->get_data() . " ";

    # 3. Visitar subarbol DERECHO (recursion ---> hacia la derecha)
    $self->_inorden_recursivo($nodo_actual->get_right());
}


# RECORRIDO 2: PREORDEN (Pre-Order) - raiz, Izquierda, Derecha
#   preorden(nodo):
#     imprimir(nodo.data)      <- PRImero visitar la raiz
#     preorden(nodo.izquierdo) <- luego visitar izquierda
#     preorden(nodo.derecho)   <- finalmente visitar derecha
#
sub recorrido_preorden {
    my ($self) = @_;
    print "Recorrido PREORDEN (raiz primero): ";
    if ($self->is_empty()) {
        print "(arbol vacio)\n";
        return;
    }
    $self->_preorden_recursivo($self->{root});
    print "\n";
}

sub _preorden_recursivo {
    my ($self, $nodo_actual) = @_;

    # CASO BASE: Si el nodo es null, detener la recursion --->
    return if !defined($nodo_actual);

    # 1. Visitar el nodo ACTUAL primero (PRE = antes)
    print $nodo_actual->get_data() . " ";

    # 2. Visitar subarbol IZQUIERDO (recursion ---> hacia la izquierda)
    $self->_preorden_recursivo($nodo_actual->get_left());

    # 3. Visitar subarbol DERECHO (recursion ---> hacia la derecha)
    $self->_preorden_recursivo($nodo_actual->get_right());
}


# RECORRIDO 3: POSTORDEN (Post-Order) - Izquierda, Derecha, raiz
#   postorden(nodo):
#     postorden(nodo.izquierdo) <- primero visitar izquierda
#     postorden(nodo.derecho)   <- luego visitar derecha
#     imprimir(nodo.data)       <- POSTeriormente visitar la raiz
#
sub recorrido_postorden {
    my ($self) = @_;
    print "Recorrido POSTORDEN (raiz al final): ";
    if ($self->is_empty()) {
        print "(arbol vacio)\n";
        return;
    }
    $self->_postorden_recursivo($self->{root});
    print "\n";
}

sub _postorden_recursivo {
    my ($self, $nodo_actual) = @_;

    # CASO BASE: Si el nodo es null, detener la recursion --->
    return if !defined($nodo_actual);

    # 1. Visitar subarbol IZQUIERDO (recursion ---> hacia la izquierda)
    $self->_postorden_recursivo($nodo_actual->get_left());

    # 2. Visitar subarbol DERECHO (recursion ---> hacia la derecha)
    $self->_postorden_recursivo($nodo_actual->get_right());

    # 3. Visitar el nodo ACTUAL al final (POST = después)
    print $nodo_actual->get_data() . " ";
}


# imprimir_arbol()

sub imprimir_arbol {
    my ($self) = @_;
    $self->_imprimir_recursivo($self->{root});
    print "\n";
}

sub _imprimir_recursivo {
    my ($self, $nodo) = @_;
    return if !defined($nodo);

    $self->_imprimir_recursivo($nodo->get_left());
    print $nodo->get_data() . " ";
    $self->_imprimir_recursivo($nodo->get_right());
}

1; 