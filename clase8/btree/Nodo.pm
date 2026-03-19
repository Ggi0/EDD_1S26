package btree::nodo;

# NODO PARA ARBOL B (B-Tree Node)
#
# Un nodo de Arbol B es MUY diferente a un nodo de BST o AVL.
# En BST/AVL cada nodo tenia UN solo valor y DOS hijos (izquierdo, derecho).
#
# En un Arbol B de orden M, cada nodo puede tener:
#   - HASTA (M-1) claves (valores almacenados)
#   - HASTA M hijos
#
# La estructura interna usa una LISTA ENLAZADA de claves y una LISTA ENLAZADA
# de hijos, representadas como hash refs encadenados.
#
# Ejemplo de un nodo con claves [10, 20, 30] y 4 hijos:
#
#   nodo->claves_head -> { val=>10, sig=>{ val=>20, sig=>{ val=>30, sig=>undef } } }
#
#   nodo->hijos_head  -> { hijo=>nodo_A, sig->{ hijo=>nodo_B, sig=>{ hijo=>nodo_C, sig=>{ hijo=>nodo_D, sig=>undef } } } }
#
#   nodo_A contiene valores < 10
#   nodo_B contiene valores entre 10 y 20
#   nodo_C contiene valores entre 20 y 30
#   nodo_D contiene valores > 30
#
# Esta correspondencia entre claves e hijos es la PROPIEDAD CENTRAL del Arbol B.

use strict;
use warnings;

# CONSTRUCTOR
# Crea un nodo vacio: sin claves y sin hijos todavia.
sub new {
    my ($class) = @_;

    my $self = {
        # Lista enlazada de claves almacenadas en este nodo.
        # Cada celda: { val => <numero>, sig => <siguiente_celda_o_undef> }
        claves_head => undef,

        # Lista enlazada de hijos (punteros a nodos hijos).
        # Cada celda: { hijo => <ref_a_nodo_btree>, sig => <siguiente_celda_o_undef> }
        hijos_head  => undef,

        # Cantidad de claves actualmente en este nodo.
        # Lo mantenemos actualizado para no tener que contar cada vez.
        num_claves  => 0,

        # Cantidad de hijos actualmente en este nodo.
        num_hijos   => 0,
    };

    bless $self, $class;
    return $self;
}



#   GETTERS Y SETTERS BASICOS

sub get_num_claves {return $_[0]->{num_claves}; }
sub get_num_hijos  {return $_[0]->{num_hijos};}

# get_claves_head()
# Retorna el primer eslabon de la lista enlazada de claves.
sub get_claves_head {
    return $_[0]->{claves_head}; }

# get_hijos_head()
# Retorna el primer eslabon de la lista enlazada de hijos.
sub get_hijos_head  {return $_[0]->{hijos_head};  }



#   METODOS DE MANIPULACION DE CLAVES


# agregar_clave_ordenada($val)
# Inserta una clave en la lista enlazada de claves manteniendo el ORDEN ASCENDENTE.
# Esto es necesario porque el Arbol B requiere que las claves dentro de cada
# nodo esten siempre ordenadas de menor a mayor.
sub agregar_clave_ordenada {
    my ($self, $val) = @_;

    my $nueva_celda = { val => $val, sig => undef };

    # CASO 1: La lista de claves esta vacia
    if (!defined($self->{claves_head})) {
        $self->{claves_head} = $nueva_celda;
        $self->{num_claves}++;
        return;
    }

    # CASO 2: La nueva clave es menor que la primera clave existente
    # -> Insertar antes de la cabeza
    if ($val < $self->{claves_head}->{val}) {
        $nueva_celda->{sig}    = $self->{claves_head};
        $self->{claves_head}   = $nueva_celda;
        $self->{num_claves}++;
        return;
    }

    # CASO 3: Buscar la posicion correcta recorriendo la lista
    # Nos detenemos cuando el siguiente elemento sea mayor que val,
    # o cuando lleguemos al final.
    my $actual = $self->{claves_head};
    while (defined($actual->{sig}) && $actual->{sig}->{val} < $val) {
        $actual = $actual->{sig};   # avanzar al siguiente eslabon
    }

    # Insertar la nueva celda DESPUES de $actual
    $nueva_celda->{sig} = $actual->{sig};
    $actual->{sig}      = $nueva_celda;
    $self->{num_claves}++;
}


# eliminar_clave($val)
# Elimina la primera aparicion del valor $val de la lista de claves.
# Retorna 1 si se elimino, 0 si no se encontro.
sub eliminar_clave {
    my ($self, $val) = @_;

    return 0 unless defined($self->{claves_head});

    # CASO 1: La clave a eliminar es la cabeza
    if ($self->{claves_head}->{val} == $val) {
        $self->{claves_head} = $self->{claves_head}->{sig};
        $self->{num_claves}--;
        return 1;
    }

    # CASO 2: Buscar en el resto de la lista
    my $anterior = $self->{claves_head};
    my $actual   = $anterior->{sig};

    while (defined($actual)) {
        if ($actual->{val} == $val) {
            # Saltamos sobre el nodo a eliminar
            $anterior->{sig} = $actual->{sig};
            $self->{num_claves}--;
            return 1;
        }
        $anterior = $actual;
        $actual   = $actual->{sig};
    }

    return 0; # no se encontro
}


# get_clave_en_pos($pos)
#
# Retorna el VALOR de la clave en la posicion $pos (base 0).
# Recorre la lista enlazada $pos veces.
# Retorna undef si la posicion esta fuera de rango.
#              si las claves son [10, 20, 30]:
#   get_clave_en_pos(0) -> 10
#   get_clave_en_pos(1) -> 20
#   get_clave_en_pos(2) -> 30
#
sub get_clave_en_pos {
    my ($self, $pos) = @_;

    my $actual = $self->{claves_head};
    my $i = 0;

    while (defined($actual)) {
        return $actual->{val} if $i == $pos;
        $actual = $actual->{sig};
        $i++;
    }

    return undef; # posicion fuera de rango
}


# get_primera_clave() y get_ultima_clave()
sub get_primera_clave {
    my ($self) = @_;
    return undef unless defined($self->{claves_head});
    return $self->{claves_head}->{val};
}

sub get_ultima_clave {
    my ($self) = @_;
    return undef unless defined($self->{claves_head});

    my $actual = $self->{claves_head};
    $actual = $actual->{sig} while defined($actual->{sig});
    return $actual->{val};
}



#   METODOS DE MANIPULACION DE HIJOS


# agregar_hijo_al_final($nodo_hijo)
#
# Agrega un puntero a un nodo hijo AL FINAL de la lista de hijos.
# En el Arbol B, el orden de los hijos importa: corresponden a los
# intervalos entre claves. Por eso el orden en que se agregan importa.
#
# Cuando se parte un nodo (split), los hijos se redistribuyen en orden,
# por lo que se agregan de izquierda a derecha usando este metodo.
sub agregar_hijo_al_final {
    my ($self, $nodo_hijo) = @_;

    my $nueva_celda = { hijo => $nodo_hijo, sig => undef };

    # Lista de hijos vacia: este es el primer hijo
    if (!defined($self->{hijos_head})) {
        $self->{hijos_head} = $nueva_celda;
        $self->{num_hijos}++;
        return;
    }

    # Lista no vacia: recorrer hasta el final y agregar ahi
    my $actual = $self->{hijos_head};
    $actual = $actual->{sig} while defined($actual->{sig});
    $actual->{sig} = $nueva_celda;
    $self->{num_hijos}++;
}


# insertar_hijo_en_pos($pos, $nodo_hijo)
#
# Inserta un hijo en una posicion especifica (base 0) de la lista de hijos.
# Desplaza los hijos que estaban en esa posicion y despues hacia la derecha.
#
# Este metodo es necesario cuando se hace un split: el nuevo hijo (la mitad derecha del nodo partido)
# debe colocarse EXACTAMENTE despues de la clave mediana que subio al padre.
#
# Ejemplo: hijos = [A, B, C], insertar D en pos=1 -> [A, D, B, C]
#
sub insertar_hijo_en_pos {
    my ($self, $pos, $nodo_hijo) = @_;

    my $nueva_celda = { hijo => $nodo_hijo, sig => undef };

    # Caso especial: insertar al inicio (pos = 0)
    if ($pos == 0) {
        $nueva_celda->{sig} = $self->{hijos_head};
        $self->{hijos_head} = $nueva_celda;
        $self->{num_hijos}++;
        return;
    }

    # Caso general: avanzar hasta la posicion (pos-1) e insertar despues
    my $actual = $self->{hijos_head};
    my $i = 0;

    while (defined($actual) && $i < $pos - 1) {
        $actual = $actual->{sig};
        $i++;
    }

    # Insertar despues de $actual
    $nueva_celda->{sig} = $actual->{sig};
    $actual->{sig}      = $nueva_celda;
    $self->{num_hijos}++;
}


# get_hijo_en_pos($pos)
#
# Retorna la REFERENCIA AL NODO hijo en la posicion $pos (base 0).
# Retorna undef si la posicion esta fuera de rango.
#
# Ejemplo: si hijos = [nodoA, nodoB, nodoC]:
#   get_hijo_en_pos(0) -> nodoA
#   get_hijo_en_pos(1) -> nodoB
#
sub get_hijo_en_pos {
    my ($self, $pos) = @_;

    my $actual = $self->{hijos_head};
    my $i = 0;

    while (defined($actual)) {
        return $actual->{hijo} if $i == $pos;
        $actual = $actual->{sig};
        $i++;
    }

    return undef;
}


# eliminar_hijo_en_pos($pos)
#
# Elimina el hijo en la posicion $pos de la lista de hijos.
# Retorna la referencia al nodo hijo eliminado, o undef si no existe.
#
sub eliminar_hijo_en_pos {
    my ($self, $pos) = @_;

    return undef unless defined($self->{hijos_head});

    # Caso especial: eliminar el primer hijo
    if ($pos == 0) {
        my $hijo_eliminado   = $self->{hijos_head}->{hijo};
        $self->{hijos_head}  = $self->{hijos_head}->{sig};
        $self->{num_hijos}--;
        return $hijo_eliminado;
    }

    # Caso general: avanzar hasta pos-1 y saltar el siguiente
    my $anterior = $self->{hijos_head};
    my $i = 0;

    while (defined($anterior->{sig}) && $i < $pos - 1) {
        $anterior = $anterior->{sig};
        $i++;
    }

    if (defined($anterior->{sig})) {
        my $hijo_eliminado = $anterior->{sig}->{hijo};
        $anterior->{sig}   = $anterior->{sig}->{sig};
        $self->{num_hijos}--;
        return $hijo_eliminado;
    }

    return undef;
}



#   METODOS DE CONSULTA
# es_hoja()
# Un nodo es HOJA si no tiene ningun hijo.
# En un Arbol B, TODAS las hojas estan en el mismo nivel.
sub es_hoja {
    my ($self) = @_;
    return !defined($self->{hijos_head}) ? 1 : 0;
}

# contiene_clave($val)
# Retorna 1 si el nodo contiene la clave $val, 0 si no.
sub contiene_clave {
    my ($self, $val) = @_;

    my $actual = $self->{claves_head};
    while (defined($actual)) {
        return 1 if $actual->{val} == $val;
        $actual = $actual->{sig};
    }
    return 0;
}


# get_pos_clave($val)
#
# Retorna la posicion (base 0) de la clave $val dentro de la lista de claves.
# Retorna undef si no se encuentra.
#
# Esto es util para la eliminacion: necesitamos saber en que posicion
# esta la clave para saber cual hijo usar.
sub get_pos_clave {
    my ($self, $val) = @_;

    my $actual = $self->{claves_head};
    my $i = 0;

    while (defined($actual)) {
        return $i if $actual->{val} == $val;
        $actual = $actual->{sig};
        $i++;
    }

    return undef;
}


# encontrar_pos_hijo($val)
#
# Dados los valores de las claves [k0, k1, k2, ...] y los hijos [h0, h1, h2, h3, ...]:
#
#   h0 < k0 <= h1 < k1 <= h2 < k2 <= h3
#
# Este metodo retorna el INDICE del hijo al que hay que descender para buscar/insertar $val.
#
# Logica:
#   - Si $val < k0  -> hijo 0
#   - Si k0 <= $val < k1 -> hijo 1
#   - Si k1 <= $val < k2 -> hijo 2
#   - ...
#   - Si $val >= kN-1 -> hijo N (el ultimo)
#
sub encontrar_pos_hijo {
    my ($self, $val) = @_;

    my $actual = $self->{claves_head};
    my $i = 0;

    while (defined($actual)) {
        # Si el valor es menor que la clave actual, el hijo esta a la izquierda
        return $i if $val < $actual->{val};
        $actual = $actual->{sig};
        $i++;
    }

    # Si el valor es mayor que todas las claves, va al hijo mas a la derecha
    return $i;
}


1;