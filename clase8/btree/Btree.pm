package btree::btree;

# ARBOL B (B-Tree)

use strict;
use warnings;

use btree::nodo;

use constant Nodo => 'btree::nodo';

# CONSTRUCTOR
#
# Parametros:
#   $orden -> El orden M del arbol. Debe ser >= 2.
#             M=2 es un arbol degenerado (1 clave, 2 hijos max). No muy util.
#             M=3 es el "arbol 2-3" (muy comun en libros de texto).
#             M=5 o mayor es tipico en bases de datos reales.
#
sub new {
    my ($class, $orden) = @_;

    # Validar que el orden sea al menos 2
    $orden = 3 unless defined($orden) && $orden >= 2;

    my $self = {
        raiz   => undef,  # La raiz del arbol; undef = arbol vacio
        orden  => $orden, # M: maximo de hijos por nodo

        # CALCULOS DERIVADOS DEL ORDEN (los calculamos una vez aqui):

        # Maximo de claves por nodo = M - 1
        max_claves => $orden - 1,

        # Minimo de claves por nodo (para nodos que NO son la raiz)
        # = ceil(M/2) - 1
        # En Perl, ceil(M/2) = int((M + 1) / 2)
        min_claves => int(($orden + 1) / 2) - 1,

        # Minimo de hijos por nodo (para nodos que NO son la raiz)
        # = ceil(M/2)
        min_hijos  => int(($orden + 1) / 2),

        size => 0,  # cantidad de claves en todo el arbol
    };

    bless $self, $class;

    #print "Arbol B creado con orden M=$orden\n";
    # print "  -> Max claves por nodo: $self->{max_claves}\n";
    #print "  -> Min claves por nodo (no raiz): $self->{min_claves}\n";
    #print "  -> Min hijos  por nodo (no raiz): $self->{min_hijos}\n\n";

    return $self;
}



#   GETTERS BASICOS
sub get_orden  {return $_[0]->{orden};  }
sub get_size { return $_[0]->{size};   }
sub is_empty{return !defined($_[0]->{raiz}) ? 1 : 0; }



#   BUSQUEDA
# buscar($val)
#
# Busca la clave $val en el arbol.
# Retorna 1 si la encuentra, 0 si no.
#
# La busqueda en Arbol B es una EXTENSION de la busqueda en BST:
#   En BST: en cada nodo comparamos con 1 clave y elegimos izq o der.
#   En B:   en cada nodo comparamos con TODAS las claves del nodo
#            para decidir a cual de los M hijos descender.
#
sub buscar {
    my ($self, $val) = @_;

    if ($self->is_empty()) {
        print "El arbol esta vacio. No hay nada que buscar.\n";
        return 0;
    }

    # RECURSION: delegar al metodo privado desde la raiz
    return $self->_buscar_recursivo($self->{raiz}, $val);
}

# _buscar_recursivo($nodo, $val)
#
# Busca $val en el subarbol cuya raiz es $nodo.
#
# LOGICA en cada nodo:
#   1. Revisar si $val esta en las claves de este nodo -> ENCONTRADO
#   2. Si el nodo es hoja y no esta -> NO ESTA en el arbol
#   3. Si no es hoja, calcular a cual hijo descender y RECURRIR
#
# RECURSIVIDAD:
#   Caso base 1: encontramos la clave -> retornar 1
#   Caso base 2: llegamos a una hoja sin encontrar -> retornar 0
#   Caso recursivo: descender al hijo correcto
#
sub _buscar_recursivo {
    my ($self, $nodo, $val) = @_;

    # CASO BASE: nodo nulo (no deberia ocurrir si el arbol es correcto)
    return 0 unless defined($nodo);

    # Paso 1: Revisar si $val esta en las claves de ESTE nodo
    if ($nodo->contiene_clave($val)) {
        print "Clave '$val' ENCONTRADA en el arbol.\n";
        return 1;
    }

    # Paso 2: Si es hoja y no estaba -> no existe en el arbol
    if ($nodo->es_hoja()) {
        print "Clave '$val' NO encontrada en el arbol.\n";
        return 0;
    }

    # Paso 3: No es hoja, descender al hijo correcto
    # encontrar_pos_hijo() nos dice a cual de los M hijos ir
    my $pos_hijo = $nodo->encontrar_pos_hijo($val);
    my $hijo     = $nodo->get_hijo_en_pos($pos_hijo);

    # RECURSION: buscar en el subarbol hijo
    return $self->_buscar_recursivo($hijo, $val);
}



#   INSERCION
# insertar($val)
#
# Inserta la clave $val en el arbol.
# La insercion siempre ocurre en una HOJA.
# Si al insertar un nodo se llena (supera max_claves), se DIVIDE (split).
# La division puede propagarse hacia arriba hasta la raiz.
#
# CASO ESPECIAL: si la raiz se divide, se crea una nueva raiz.
# Esto hace que el arbol crezca en ALTURA desde arriba, no desde abajo.
# (A diferencia del BST donde el arbol crece hacia abajo.)
#
sub insertar {
    my ($self, $val) = @_;

    print "Insertando '$val'...\n";

    # CASO 1: El arbol esta vacio. Crear la raiz con el primer valor.
    if ($self->is_empty()) {
        $self->{raiz} = Nodo->new();
        $self->{raiz}->agregar_clave_ordenada($val);
        $self->{size}++;
        print "---> insertando --->  '$val' insertado como primera clave en la raiz.\n\n";
        return;
    }

    # CASO 2: El arbol tiene al menos la raiz.
    # Llamar a la insercion recursiva.
    # Si el resultado de la insercion es que la RAIZ SE DIVIDIO,
    # _insertar_recursivo retorna la clave mediana y el nuevo hijo derecho.
    # En ese caso, creamos una nueva raiz.

    my ($mediana, $nuevo_hijo_der) = $self->_insertar_recursivo($self->{raiz}, $val);

    # Si se retorno una mediana, significa que la raiz se dividio
    if (defined($mediana)) {
        print "  La raiz se dividio. Nueva raiz con clave mediana '$mediana'.\n";

        my $nueva_raiz = Nodo->new();
        $nueva_raiz->agregar_clave_ordenada($mediana);

        # El hijo izquierdo de la nueva raiz es la antigua raiz (ya reducida)
        $nueva_raiz->agregar_hijo_al_final($self->{raiz});

        # El hijo derecho es el nuevo nodo creado por el split
        $nueva_raiz->agregar_hijo_al_final($nuevo_hijo_der);

        # La nueva raiz pasa a ser la raiz del arbol
        $self->{raiz} = $nueva_raiz;
    }

    $self->{size}++;
    print "  Insercion de '$val' completada.\n\n";
}


# _insertar_recursivo($nodo, $val)
#
# Inserta $val en el subarbol cuya raiz es $nodo.
#
# RETORNO:
#   - Si el nodo NO se dividio: retorna (undef, undef)
#   - Si el nodo SE DIVIDIO:    retorna ($mediana, $nuevo_nodo_derecho)
#     El llamador debe insertar $mediana en el padre y agregar $nuevo_nodo_derecho
#     como hijo del padre.
#
# RECURSIVIDAD:
#   Caso base: $nodo es HOJA -> insertar aqui. Si se llena, dividir.
#   Caso recursivo: $nodo NO es hoja -> descender al hijo correcto,
#                   luego manejar si el hijo se dividio.
#
sub _insertar_recursivo {
    my ($self, $nodo, $val) = @_;

    # Verificar duplicado en este nodo
    if ($nodo->contiene_clave($val)) {
        print "  La clave '$val' ya existe. No se insertan duplicados.\n";
        $self->{size}--;  # compensar el incremento del llamador
        return (undef, undef);
    }

    #  CASO BASE: El nodo es una HOJA 
    # Insertar la clave directamente en este nodo.
    if ($nodo->es_hoja()) {
        $nodo->agregar_clave_ordenada($val);
        print "  '$val' insertado en hoja.\n";

        # Verificar si el nodo se lleno (supero el maximo de claves)
        if ($nodo->get_num_claves() > $self->{max_claves}) {
            # El nodo esta lleno -> DIVIDIR
            print "  Nodo hoja lleno (tiene " . $nodo->get_num_claves() . " claves, max=" . $self->{max_claves} . "). Dividiendo...\n";
            return $self->_dividir($nodo);  # retorna (mediana, nuevo_nodo_der)
        }

        return (undef, undef); # no hubo division
    }

    #  CASO RECURSIVO: El nodo NO es hoja 
    # Descender al hijo correcto.

    # Encontrar la posicion del hijo al que debemos descender
    my $pos_hijo = $nodo->encontrar_pos_hijo($val);
    my $hijo     = $nodo->get_hijo_en_pos($pos_hijo);

    # RECURSION: insertar en el subarbol hijo
    my ($mediana, $nuevo_hijo_der) = $self->_insertar_recursivo($hijo, $val);

    # Si el hijo se dividio, tenemos que incorporar la mediana en ESTE nodo
    if (defined($mediana)) {
        print "  Hijo se dividio. Incorporando mediana '$mediana' en nodo padre.\n";

        # Agregar la mediana a las claves de este nodo (en orden)
        $nodo->agregar_clave_ordenada($mediana);

        # Agregar el nuevo hijo derecho en la posicion correcta
        # La mediana quedo en pos_clave = pos_hijo (aprox), el nuevo hijo
        # debe quedar INMEDIATAMENTE A LA DERECHA de la mediana.
        # Como el hijo que se dividio estaba en pos_hijo, el nuevo hijo
        # debe estar en pos_hijo + 1.
        $nodo->insertar_hijo_en_pos($pos_hijo + 1, $nuevo_hijo_der);

        # Verificar si ESTE nodo ahora tambien se lleno
        if ($nodo->get_num_claves() > $self->{max_claves}) {
            print "  Nodo interno tambien lleno. Dividiendo hacia arriba...\n";
            return $self->_dividir($nodo); # propagar la division hacia arriba
        }
    }

    return (undef, undef); # no hubo division en este nivel
}



#                                  DIVISION (SPLIT)
# _dividir($nodo_lleno)
#
# CUANDO SE USA:
#   Cuando un nodo tiene (M) claves, es decir, supero el maximo de (M-1).
#   Eso significa que tiene M+1 hijos si no es hoja.
#
# QUE HACE:
#   Divide el nodo lleno en DOS nodos y sube la clave MEDIANA al padre.
#
#   Antes (nodo con M claves, ejemplo M=3, entonces max=2, aqui tiene 3):
#     [ k0 | k1 | k2 ]   <- 3 claves cuando el maximo es 2
#      h0  h1  h2  h3    <- 4 hijos
#
#   La mediana es la clave en la posicion del MEDIO: pos = floor(M/2)
#   Para M=3: pos_mediana = floor(3/2) = 1 -> k1 es la mediana
#
#   Despues de dividir:
#     Nodo izquierdo (el nodo original, reducido): [ k0 ]      hijos: h0, h1
#     Mediana que sube al padre:                    k1
#     Nodo derecho (nuevo nodo):                   [ k2 ]      hijos: h2, h3
#
# RETORNO: ($mediana, $nuevo_nodo_der)
#   El llamador (el padre) debe:
#     1. Agregar $mediana a sus propias claves.
#     2. Agregar $nuevo_nodo_der como hijo a la derecha de $mediana.
#
# RECURSIVIDAD:
#   _dividir no se llama a si misma directamente, pero al retornar la mediana
#   al padre, el padre puede volverse lleno y llamar a _dividir de nuevo.
#   Esto crea una cadena de divisiones que puede llegar hasta la raiz.
#
sub _dividir {
    my ($self, $nodo_lleno) = @_;

    # Total de claves en el nodo lleno (deberia ser max_claves + 1 = M)
    my $total_claves = $nodo_lleno->get_num_claves();

    # Posicion de la clave mediana (base 0)
    # Para M claves, la mediana esta en floor(M/2) = int(M/2)
    # Ejemplo con M=5 (max_claves=4, nodo lleno tiene 5):
    #   claves: [10, 20, 30, 40, 50]  pos_mediana = int(5/2) = 2 -> clave 30
    my $pos_mediana = int($total_claves / 2);

    my $mediana = $nodo_lleno->get_clave_en_pos($pos_mediana);
    print "  Division: mediana=$mediana (pos=$pos_mediana de $total_claves claves)\n";

    #  Crear el nuevo nodo derecho 
    my $nodo_derecho = Nodo->new();

    # Mover las claves DESPUES de la mediana al nodo derecho
    # Posiciones: pos_mediana+1, pos_mediana+2, ..., total_claves-1
    my $i = $pos_mediana + 1;
    while ($i < $total_claves) {
        my $clave_a_mover = $nodo_lleno->get_clave_en_pos($i);
        $nodo_derecho->agregar_clave_ordenada($clave_a_mover);
        $i++;
    }

    # Mover los hijos DESPUES del punto de division al nodo derecho
    # Si el nodo tiene H hijos y K claves, con K+1 = H:
    # Los hijos que van al nodo derecho son los que estan a la DERECHA
    # de la mediana: posiciones pos_mediana+1 hasta H-1
    # (hay pos_mediana+1 hijos en el nodo izquierdo: h0..h_pos_mediana)
    if (!$nodo_lleno->es_hoja()) {
        my $total_hijos = $nodo_lleno->get_num_hijos();
        my $j = $pos_mediana + 1;
        while ($j < $total_hijos) {
            my $hijo_a_mover = $nodo_lleno->get_hijo_en_pos($j);
            $nodo_derecho->agregar_hijo_al_final($hijo_a_mover);
            $j++;
        }
    }

    #  Reducir el nodo izquierdo (nodo_lleno) 
    # Eliminar la mediana y todas las claves que pasaron al nodo derecho.
    # Eliminar de ATRAS hacia adelante para no confundir posiciones.
    my $k = $total_claves - 1;
    while ($k >= $pos_mediana) {
        my $clave_a_eliminar = $nodo_lleno->get_clave_en_pos($k);
        $nodo_lleno->eliminar_clave($clave_a_eliminar);
        $k--;
    }

    # Eliminar los hijos que se movieron al nodo derecho
    # Son los hijos desde pos_mediana+1 en adelante.
    # Eliminamos de atras hacia adelante para no alterar indices.
    if (!$nodo_derecho->es_hoja()) {
        my $total_hijos = $nodo_lleno->get_num_hijos();
        my $j = $total_hijos - 1;
        while ($j > $pos_mediana) {
            $nodo_lleno->eliminar_hijo_en_pos($j);
            $j--;
        }
    }

    print "  Division completada.\n";
    print "    Nodo izquierdo: " . $self->_claves_a_string($nodo_lleno) . "\n";
    print "    Mediana que sube: $mediana\n";
    print "    Nodo derecho:   " . $self->_claves_a_string($nodo_derecho) . "\n";

    return ($mediana, $nodo_derecho);
}



                           #   ELIMINACION
# eliminar($val)
#
# Elimina la clave $val del arbol.
# La eliminacion en Arbol B tiene varios casos:
#
#   CASO A: La clave esta en una HOJA.
#     -> Eliminar directamente. Si el nodo queda con menos de min_claves,
#        aplicar REDISTRIBUCION o FUSION.
#
#   CASO B: La clave esta en un NODO INTERNO.
#     -> No podemos eliminar directamente (romperia la estructura).
#     -> Reemplazar la clave con su PREDECESOR INORDEN
#        (la clave mas grande del subarbol izquierdo de esa clave)
#        o su SUCESOR INORDEN (la clave mas pequeña del subarbol derecho).
#     -> Luego eliminar ese predecesor/sucesor (que siempre esta en una hoja).
#
# Cuando un nodo queda con muy pocas claves (underflow), se corrige con:
#   - REDISTRIBUCION: tomar una clave de un hermano que tenga de sobra.
#   - FUSION: combinar el nodo deficiente con un hermano.
#
sub eliminar {
    my ($self, $val) = @_;

    if ($self->is_empty()) {
        print "El arbol esta vacio. No hay nada que eliminar.\n";
        return;
    }

    print "Eliminando '$val'...\n";

    # Verificar primero si existe
    if (!$self->buscar($val)) {
        return; # buscar ya imprime el mensaje
    }

    # RECURSION: delegar la eliminacion al metodo privado
    $self->_eliminar_recursivo($self->{raiz}, $val, 1); # 1 = es_raiz

    # Caso especial: si la raiz quedo vacia (ocurre cuando la raiz tenia
    # una sola clave y se fusiono con sus hijos), la nueva raiz es su unico hijo.
    if (defined($self->{raiz}) &&
        $self->{raiz}->get_num_claves() == 0 &&
        !$self->{raiz}->es_hoja())
    {
        print "  Raiz vacia. El unico hijo pasa a ser la nueva raiz.\n";
        $self->{raiz} = $self->{raiz}->get_hijo_en_pos(0);
    }

    $self->{size}--;
    print "  Clave '$val' eliminada exitosamente.\n\n";
}


#                                _eliminar_recursivo($nodo, $val, $es_raiz)
# Elimina $val del subarbol cuya raiz es $nodo.
# $es_raiz indica si $nodo es la raiz del arbol (la raiz puede tener menos del minimo de claves, los demas nodos no).
#
# RECURSIVIDAD:
#   Caso base 1: La clave esta en ESTA hoja -> eliminar directamente.
#   Caso base 2: La clave esta en ESTE nodo interno -> reemplazar con predecesor.
#   Caso recursivo: La clave no esta aqui -> descender al hijo correcto.
#
#   Al SUBIR de la recursion, verificar si el hijo quedo con underflow y corregir.
#
sub _eliminar_recursivo {
    my ($self, $nodo, $val, $es_raiz) = @_;

    $es_raiz = 0 unless defined($es_raiz);

    #  Verificar si la clave esta en ESTE nodo 
    if ($nodo->contiene_clave($val)) {

        # CASO A: La clave esta en una HOJA -> eliminar directamente
        if ($nodo->es_hoja()) {
            print "  Eliminando '$val' de hoja.\n";
            $nodo->eliminar_clave($val);
            # El llamador verificara si hay underflow
            return;
        }

        # CASO B: La clave esta en un NODO INTERNO
        # Reemplazar con el PREDECESOR INORDEN (maximo del subarbol izquierdo).
        # El predecesor siempre esta en una hoja, lo cual facilita la eliminacion.
        #
        # ¿Por que el predecesor inorden?
        #   Es la clave mas grande que es menor que $val.
        #   Al sustituir $val por su predecesor, la propiedad de orden se mantiene.
        #
        my $pos_clave = $nodo->get_pos_clave($val);
        my $hijo_izq  = $nodo->get_hijo_en_pos($pos_clave); # hijo a la IZQUIERDA de $val

        # Encontrar el maximo del subarbol izquierdo (sucesor en inorden inverso)
        my $predecesor = $self->_encontrar_maximo_hoja($hijo_izq);
        print "  '$val' en nodo interno. Reemplazando con predecesor inorden '$predecesor'.\n";

        # Sustituir $val por el predecesor en este nodo
        $nodo->eliminar_clave($val);
        $nodo->agregar_clave_ordenada($predecesor);

        # Ahora eliminar el predecesor del subarbol izquierdo
        # RECURSION: bajar a la izquierda a eliminar el predecesor
        $self->_eliminar_recursivo($hijo_izq, $predecesor, 0);

        # Verificar si el hijo izquierdo quedo con underflow
        $self->_corregir_underflow($nodo, $pos_clave);
        return;
    }

    #  La clave NO esta en este nodo 
    # Si es hoja, la clave no existe (ya verificamos en buscar, no deberia llegar aqui)
    if ($nodo->es_hoja()) {
        print "  Clave '$val' no encontrada (nodo hoja).\n";
        return;
    }

    # Descender al hijo correcto
    my $pos_hijo = $nodo->encontrar_pos_hijo($val);
    my $hijo     = $nodo->get_hijo_en_pos($pos_hijo);

    # RECURSION: eliminar en el subarbol hijo
    $self->_eliminar_recursivo($hijo, $val, 0);

    # AL SUBIR: verificar si el hijo quedo con underflow
    $self->_corregir_underflow($nodo, $pos_hijo);
}


# _encontrar_maximo_hoja($nodo)
# Retorna el VALOR de la clave mas grande del subarbol cuya raiz es $nodo.
# En un Arbol B, el maximo de un subarbol se obtiene yendo siempre
# al hijo MAS A LA DERECHA hasta llegar a una hoja.
#
# RECURSIVIDAD:
#   Caso base: $nodo es hoja -> retornar su ultima clave.
#   Caso recursivo: ir al hijo mas a la derecha.
#
sub _encontrar_maximo_hoja {
    my ($self, $nodo) = @_;

    # Caso base: es hoja, la clave mas grande es la ultima
    return $nodo->get_ultima_clave() if $nodo->es_hoja();

    # Caso recursivo: ir al hijo mas a la derecha
    my $ultimo_hijo = $nodo->get_hijo_en_pos($nodo->get_num_hijos() - 1);
    return $self->_encontrar_maximo_hoja($ultimo_hijo);
}


# _corregir_underflow($padre, $pos_hijo_deficiente)
#
# Verifica si el hijo en posicion $pos_hijo_deficiente del nodo $padre
# tiene menos claves que el minimo permitido (underflow).
# Si hay underflow, intenta corregirlo con:
#
#   Opcion 1 - REDISTRIBUCION desde hermano IZQUIERDO:
#     Si el hermano izquierdo tiene mas del minimo de claves,
#     rotar una clave: bajar la clave separadora del padre al hijo deficiente,
#     y subir la ultima clave del hermano izquierdo al padre.
#
#   Opcion 2 - REDISTRIBUCION desde hermano DERECHO:
#     Similar pero con el hermano derecho.
#
#   Opcion 3 - FUSION:
#     Si ningun hermano puede ceder claves (ambos tienen exactamente el minimo),
#     fusionar el hijo deficiente con un hermano y bajar la clave separadora del padre.
#     Esto puede causar que el PADRE quede con underflow -> se propaga hacia arriba.
#
sub _corregir_underflow {
    my ($self, $padre, $pos_hijo) = @_;

    my $hijo = $padre->get_hijo_en_pos($pos_hijo);
    return unless defined($hijo);

    # Si el hijo tiene suficientes claves, no hay underflow
    return if $hijo->get_num_claves() >= $self->{min_claves};

    print "  Underflow en hijo pos=$pos_hijo (" . $self->_claves_a_string($hijo) . ").\n";

    #  Opcion 1: Redistribuir desde el hermano IZQUIERDO 
    if ($pos_hijo > 0) {
        my $hermano_izq = $padre->get_hijo_en_pos($pos_hijo - 1);

        if ($hermano_izq->get_num_claves() > $self->{min_claves}) {
            print "  Redistribucion desde hermano izquierdo.\n";
            $self->_redistribuir_desde_izquierda($padre, $pos_hijo);
            return;
        }
    }

    #  Opcion 2: Redistribuir desde el hermano DERECHO 
    if ($pos_hijo < $padre->get_num_hijos() - 1) {
        my $hermano_der = $padre->get_hijo_en_pos($pos_hijo + 1);

        if ($hermano_der->get_num_claves() > $self->{min_claves}) {
            print "  Redistribucion desde hermano derecho.\n";
            $self->_redistribuir_desde_derecha($padre, $pos_hijo);
            return;
        }
    }

    #  Opcion 3: Fusion
    # Ninguno de los hermanos puede ceder claves. Fusionar.
    if ($pos_hijo > 0) {
        # Fusionar con el hermano IZQUIERDO
        print "  Fusion con hermano izquierdo.\n";
        $self->_fusionar($padre, $pos_hijo - 1); # fusiona hijo[pos-1] con hijo[pos]
    } else {
        # Fusionar con el hermano DERECHO
        print "  Fusion con hermano derecho.\n";
        $self->_fusionar($padre, $pos_hijo);     # fusiona hijo[pos] con hijo[pos+1]
    }
}


# _redistribuir_desde_izquierda($padre, $pos_hijo_deficiente)
# El hermano izquierdo le presta una clave al hijo deficiente.
# Rotacion hacia la DERECHA:
#
#   Antes:
#     padre:         [ ... | sep | ... ]     sep = clave separadora entre hermano_izq e hijo
#     hermano_izq:   [ a | b | c ]           (tiene de sobra)
#     hijo:          [ x ]                   (deficiente)
#
#   Despues:
#     padre:         [ ... | c  | ... ]      c sube desde hermano_izq al padre
#     hermano_izq:   [ a | b ]               se quedo sin c
#     hijo:          [ sep | x ]             sep bajo del padre al inicio del hijo
#
sub _redistribuir_desde_izquierda {
    my ($self, $padre, $pos_hijo) = @_;

    my $hijo        = $padre->get_hijo_en_pos($pos_hijo);
    my $hermano_izq = $padre->get_hijo_en_pos($pos_hijo - 1);

    # La clave separadora en el padre esta en posicion pos_hijo - 1
    # (entre el hermano izquierdo y el hijo deficiente)
    my $clave_sep = $padre->get_clave_en_pos($pos_hijo - 1);

    # Bajar la clave separadora al INICIO del hijo deficiente
    $hijo->agregar_clave_ordenada($clave_sep);

    # Subir la ULTIMA clave del hermano izquierdo al padre (reemplaza sep)
    my $ultima_clave_hermano = $hermano_izq->get_ultima_clave();
    $padre->eliminar_clave($clave_sep);
    $padre->agregar_clave_ordenada($ultima_clave_hermano);
    $hermano_izq->eliminar_clave($ultima_clave_hermano);

    # Si el hermano izquierdo tiene hijos, el ultimo hijo del hermano
    # pasa a ser el primer hijo del hijo deficiente
    if (!$hermano_izq->es_hoja()) {
        my $ultimo_hijo_hermano = $hermano_izq->eliminar_hijo_en_pos(
            $hermano_izq->get_num_hijos() - 1
        );
        $hijo->insertar_hijo_en_pos(0, $ultimo_hijo_hermano);
    }
}


# _redistribuir_desde_derecha($padre, $pos_hijo_deficiente)
#
# El hermano derecho le presta una clave al hijo deficiente.
# Rotacion hacia la IZQUIERDA:
#
#   Antes:
#     padre:         [ ... | sep | ... ]
#     hijo:          [ x ]                   (deficiente)
#     hermano_der:   [ a | b | c ]           (tiene de sobra)
#
#   Despues:
#     padre:         [ ... | a  | ... ]
#     hijo:          [ x | sep ]
#     hermano_der:   [ b | c ]
#
sub _redistribuir_desde_derecha {
    my ($self, $padre, $pos_hijo) = @_;

    my $hijo        = $padre->get_hijo_en_pos($pos_hijo);
    my $hermano_der = $padre->get_hijo_en_pos($pos_hijo + 1);

    # La clave separadora en el padre esta en posicion pos_hijo
    my $clave_sep = $padre->get_clave_en_pos($pos_hijo);

    # Bajar la clave separadora al FINAL del hijo deficiente
    $hijo->agregar_clave_ordenada($clave_sep);

    # Subir la PRIMERA clave del hermano derecho al padre
    my $primera_clave_hermano = $hermano_der->get_primera_clave();
    $padre->eliminar_clave($clave_sep);
    $padre->agregar_clave_ordenada($primera_clave_hermano);
    $hermano_der->eliminar_clave($primera_clave_hermano);

    # Si el hermano derecho tiene hijos, su primer hijo
    # pasa a ser el ultimo hijo del hijo deficiente
    if (!$hermano_der->es_hoja()) {
        my $primer_hijo_hermano = $hermano_der->eliminar_hijo_en_pos(0);
        $hijo->agregar_hijo_al_final($primer_hijo_hermano);
    }
}


# _fusionar($padre, $pos_izq)
#
# Fusiona el hijo en posicion $pos_izq con el hijo en posicion $pos_izq+1.
# La clave separadora del padre (que estaba entre estos dos hijos) BAJA al nodo fusionado.
#
#   Antes:
#     padre:       [ ... | sep | ... ]     (sep entre hijo_izq e hijo_der)
#     hijo_izq:    [ a ]                   (deficiente o minimo)
#     hijo_der:    [ b ]                   (minimo)
#
#   Despues de fusionar:
#     padre:       [ ... ]                 sep ya no esta en el padre
#     nodo_fusion: [ a | sep | b ]         hijo_izq absorbe sep y todo hijo_der
#
# El padre puede quedar con underflow -> se propagara al subir en la recursion.
#
sub _fusionar {
    my ($self, $padre, $pos_izq) = @_;

    my $hijo_izq = $padre->get_hijo_en_pos($pos_izq);
    my $hijo_der = $padre->get_hijo_en_pos($pos_izq + 1);

    # La clave separadora esta en posicion pos_izq en el padre
    my $clave_sep = $padre->get_clave_en_pos($pos_izq);

    print "  Fusionando: [" . $self->_claves_a_string($hijo_izq) . "] + '$clave_sep' + [" .
          $self->_claves_a_string($hijo_der) . "]\n";

    # Bajar la clave separadora al hijo izquierdo
    $hijo_izq->agregar_clave_ordenada($clave_sep);

    # Mover TODAS las claves del hijo derecho al hijo izquierdo
    my $c = $hijo_der->get_claves_head();
    while (defined($c)) {
        $hijo_izq->agregar_clave_ordenada($c->{val});
        $c = $c->{sig};
    }

    # Mover TODOS los hijos del hijo derecho al hijo izquierdo
    my $h = $hijo_der->get_hijos_head();
    while (defined($h)) {
        $hijo_izq->agregar_hijo_al_final($h->{hijo});
        $h = $h->{sig};
    }

    # Eliminar la clave separadora del padre
    $padre->eliminar_clave($clave_sep);

    # Eliminar el puntero al hijo derecho del padre (ya fue absorbido)
    $padre->eliminar_hijo_en_pos($pos_izq + 1);

    print "  Fusion resultado: [" . $self->_claves_a_string($hijo_izq) . "]\n";
}



#   RECORRIDO INORDEN
# recorrido_inorden()
#
# Visita las claves en orden ASCENDENTE.
#
# En un BST, inorden es: visitar izquierdo, visitar raiz, visitar derecho.
# En un Arbol B, es una GENERALIZACION:
#
#   Para un nodo con claves [k0, k1, k2] e hijos [h0, h1, h2, h3]:
#     visitar h0 (todo el subarbol)
#     imprimir k0
#     visitar h1 (todo el subarbol)
#     imprimir k1
#     visitar h2 (todo el subarbol)
#     imprimir k2
#     visitar h3 (todo el subarbol)
#
# Esto garantiza que se visiten los valores en orden ascendente.
#
sub recorrido_inorden {
    # :)
}

# _inorden_rec($nodo)
#
# RECURSIVIDAD:
#   Caso base: $nodo es undef -> no hacer nada (detener la recursion)
#   Caso recursivo: intercalar visitas a hijos con impresion de claves.
#
sub _inorden_rec {
    # :)
}



#   METODO esta($val) - alias de buscar con output booleano
# esta($val)
# Retorna 1 si la clave esta en el arbol, 0 si no.
# Es un alias limpio de buscar().
sub esta {
    my ($self, $val) = @_;
    return $self->_esta_recursivo($self->{raiz}, $val);
}

sub _esta_recursivo {
    my ($self, $nodo, $val) = @_;

    return 0 unless defined($nodo);

    if ($nodo->contiene_clave($val)) { return 1; }
    return 0 if $nodo->es_hoja();

    my $pos  = $nodo->encontrar_pos_hijo($val);
    my $hijo = $nodo->get_hijo_en_pos($pos);

    # RECURSION
    return $self->_esta_recursivo($hijo, $val);
}



#   UTILIDADES INTERNAS
# _claves_a_string($nodo)
# Retorna un string con las claves del nodo separadas por comas.
# Util para los mensajes de depuracion.
sub _claves_a_string {
    my ($self, $nodo) = @_;

    my $resultado = "";
    my $c = $nodo->get_claves_head();
    while (defined($c)) {
        $resultado .= $c->{val};
        $resultado .= ", " if defined($c->{sig});
        $c = $c->{sig};
    }
    return "[$resultado]";
}

# imprimir_arbol()
# Impresion basica nivel por nivel para depuracion en consola.
# Usa una cola simulada con lista enlazada para el recorrido por niveles (BFS).
sub imprimir_arbol {
    my ($self) = @_;

    if ($self->is_empty()) {
        print "(arbol vacio)\n";
        return;
    }

    print "======> Arbol B (orden " . $self->{orden} . ") \n";

    # Cola simulada: lista enlazada de pares { nodo, nivel }
    # Para BFS sin usar arreglos @
    my $cola_head = { dato => { nodo => $self->{raiz}, nivel => 0 }, sig => undef };
    my $cola_tail = $cola_head;
    my $nivel_actual = 0;

    print "Nivel 0: ";

    while (defined($cola_head)) {
        # Desencolar el frente
        my $item  = $cola_head->{dato};
        $cola_head = $cola_head->{sig};

        my $nodo  = $item->{nodo};
        my $nivel = $item->{nivel};

        # Cambio de nivel
        if ($nivel > $nivel_actual) {
            $nivel_actual = $nivel;
            print "\nNivel $nivel: ";
        }

        # Imprimir las claves de este nodo
        print $self->_claves_a_string($nodo) . "  ";

        # Encolar todos los hijos
        my $h = $nodo->get_hijos_head();
        while (defined($h)) {
            my $nuevo = { dato => { nodo => $h->{hijo}, nivel => $nivel + 1 }, sig => undef };
            if (defined($cola_tail)) {
                $cola_tail->{sig} = $nuevo;
            } else {
                $cola_head = $nuevo;
            }
            $cola_tail = $nuevo;
            $h = $h->{sig};
        }
    }

    print "\n===================\n";
}

1;