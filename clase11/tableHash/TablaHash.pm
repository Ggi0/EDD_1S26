package tableHash::TablaHash;


# Una tabla hash mapea una CLAVE -> INDICE -> BUCKET, donde
# el bucket almacena todos los elementos que comparten esa clave.
#
# El acceso es O(1) promedio: en lugar de recorrer toda una lista
# para encontrar "todos los TIPO_A", simplemente calculamos el
# indice del bucket TIPO_A y lo retornamos directamente.
#
# FUNCION HASH
# Nuestra funcion hash convierte el tipo de usuario en un indice numerico:
#
#   f("TIPO_A") -> ord('A') - ord('A') = 0  -> Slot 0
#   f("TIPO_B") -> ord('B') - ord('A') = 1  -> Slot 1
#   f("TIPO_C") -> ord('C') - ord('A') = 2  -> Slot 2
#   f("TIPO_D") -> ord('D') - ord('A') = 3  -> Slot 3
#
# La funcion extrae el ultimo caracter del string "TIPO_X" y calcula
# su distancia desde 'A'. Esto es real: convertimos una clave en un numero.
#
# COLISIONES
# Dos personas con el MISMO tipo caen en el MISMO slot -> colision.
# La resolvemos con ENCADENAMIENTO SEPARADO: cada slot tiene una
# lista enlazada interna. Al insertar, simplemente agregamos al final
# de esa lista. No perdemos ningun elemento.


use strict;
use warnings;

use tableHash::Persona;

use constant CAPACIDAD => 4;

# Mapeo de indice -> nombre del tipo (para etiquetas)
my $ETIQUETA_TIPO = {
    0 => 'TIPO_A',
    1 => 'TIPO_B',
    2 => 'TIPO_C',
    3 => 'TIPO_D',
};


# CLASE INTERNA: NodoHash
# Nodo de la lista enlazada dentro de cada slot.
# Almacena una referencia a un objeto Persona y apunta al siguiente nodo.
#   [NodoHash]
#     persona   -> ref a objeto Persona
#     siguiente -> ref al proximo NodoHash, o undef

package tableHash::NodoHash;

sub new {
    my ($class, $persona) = @_;
    bless {
        persona   => $persona,
        siguiente => undef,
    }, $class;
}

sub get_persona{ return $_[0]->{persona};   }
sub get_siguiente{ return $_[0]->{siguiente}; }
sub set_siguiente{ my ($s, $n) = @_; $s->{siguiente} = $n; }


# CLASE INTERNA: SlotNodo
# Representa UN SLOT (bucket) de la tabla hash.
# Es un nodo de la lista enlazada que simula el arreglo de slots.
#
#   [SlotNodo]
#     indice       -> posicion numerica del slot (0..3)
#     tipo         -> etiqueta del tipo ("TIPO_A".."TIPO_D")
#     lista_cabeza -> primer NodoHash de la cadena de este slot (o undef si vacio)
#     cantidad     -> cuantos elementos hay en este slot
#     colisiones   -> cuantas veces hubo mas de 1 insercion en este slot
#     siguiente    -> siguiente SlotNodo en la lista de slots

package tableHash::SlotNodo;

sub new {
    my ($class, $indice, $tipo) = @_;
    bless {
        indice => $indice,
        tipo => $tipo,
        lista_cabeza => undef,   # primer NodoHash de la cadena
        cantidad => 0,  # elementos en este slot
        colisiones => 0, # inserciones que encontraron el slot ocupado
        siguiente => undef, # proximo SlotNodo
    }, $class;
}

sub get_indice { return $_[0]->{indice};       }
sub get_tipo{ return $_[0]->{tipo};         }
sub get_lista_cabeza { return $_[0]->{lista_cabeza}; }
sub get_cantidad { return $_[0]->{cantidad};     }
sub get_colisiones { return $_[0]->{colisiones};   }
sub get_siguiente { return $_[0]->{siguiente};    }

sub set_lista_cabeza { my ($s, $v) = @_; $s->{lista_cabeza} = $v; }
sub set_cantidad     { my ($s, $v) = @_; $s->{cantidad}     = $v; }
sub set_colisiones   { my ($s, $v) = @_; $s->{colisiones}   = $v; }
sub set_siguiente    { my ($s, $v) = @_; $s->{siguiente}    = $v; }

# esta_vacio()
# Retorna 1 si no hay ningun elemento en este slot.
sub esta_vacio { return !defined($_[0]->{lista_cabeza}) ? 1 : 0; }



package tableHash::TablaHash;

# new()
# Constructor. Inicializa los 4 slots vacios como lista enlazada.
# Los slots se crean en orden (0,1,2,3) y se enlazan entre si.
# La cabeza apunta al Slot 0.
sub new {
    my ($class) = @_;

    my $self = {
        cabeza  => undef,   # Primer SlotNodo (Slot 0 = TIPO_A)
        total_elementos => 0,  # Cuantas personas hay en toda la tabla
    };

    bless $self, $class;

    # Inicializar los 4 slots vacios
    # Los creamos en orden inverso para enlazarlos de adelante hacia atras de forma que la cabeza quede apuntando al slot 0.
    my $ultimo = undef;
    for my $i (reverse 0 .. CAPACIDAD - 1) {
        my $tipo  = $ETIQUETA_TIPO->{$i};
        my $slot  = tableHash::SlotNodo->new($i, $tipo);
        $slot->set_siguiente($ultimo);
        $ultimo = $slot;
    }
    $self->{cabeza} = $ultimo;   # La cabeza apunta al Slot 0

    return $self;
}


# FUNCION HASH
# _calcular_indice($tipo)
# Convierte el string de tipo en el indice del slot correspondiente.
#
# Mecanismo:
#   "TIPO_A" --> ultimo caracter = 'A' --> ord('A') - ord('A') = 0
#   "TIPO_B" --> ultimo caracter = 'B' --> ord('B') - ord('A') = 1
#   "TIPO_C" --> ultimo caracter = 'C' --> ord('C') - ord('A') = 2
#   "TIPO_D" --> ultimo caracter = 'D' --> ord('D') - ord('A') = 3
#
# Si el tipo no es reconocido, retorna -1.
sub _calcular_indice {
    my ($self, $tipo) = @_;

    return -1 unless defined $tipo;

    # Extraer el ultimo caracter del string (la letra del tipo)
    my $ultimo_char = substr($tipo, -1);

    # Calcular la posicion relativa desde 'A'
    my $indice = ord($ultimo_char) - ord('A');

    # Verificar que este dentro del rango valido
    if ($indice < 0 || $indice >= CAPACIDAD) {
        return -1;  # Tipo fuera de rango
    }

    return $indice;
}



# NAVEGACION DE SLOTS
# _obtener_slot($indice)
# Recorre la lista enlazada de slots y retorna el SlotNodo con ese indice.
# Retorna undef si no existe.
sub _obtener_slot {
    my ($self, $indice) = @_;

    my $actual = $self->{cabeza};
    while (defined $actual) {
        return $actual if $actual->get_indice() == $indice;
        $actual = $actual->get_siguiente();
    }
    return undef;
}


# insertar($persona)
# Inserta un objeto Persona en el slot correspondiente a su tipo.
#
# Pasos:
#   1. Calcular el indice con la funcion hash (tipo -> indice)
#   2. Navegar hasta el slot en la lista enlazada
#   3. Si el slot ya tiene elementos -> es una colision (la registramos)
#   4. Crear un NodoHash con la persona
#   5. Agregarlo al FINAL de la lista del slot (encadenamiento)
sub insertar {
    my ($self, $persona) = @_;

    unless (defined $persona) {
        print "ERROR: No se puede insertar una persona undef.\n";
        return 0;
    }

    my $tipo = $persona->get_tipo();
    unless (defined $tipo) {
        print "ERROR: La persona no tiene tipo asignado.\n";
        return 0;
    }

    # PASO 1: Calcular el indice con la funcion hash
    my $indice = $self->_calcular_indice($tipo);
    if ($indice == -1) {
        print "ERROR: Tipo '$tipo' produce un indice invalido.\n";
        return 0;
    }

    # PASO 2: Obtener el slot
    my $slot = $self->_obtener_slot($indice);
    unless (defined $slot) {
        print "ERROR: Slot $indice no encontrado en la tabla.\n";
        return 0;
    }

    # PASO 3: Detectar colision
    # Una colision ocurre cuando el slot ya tiene al menos un elemento.
    # La resolvemos simplemente agregando al final de la cadena.
    if (!$slot->esta_vacio()) {
        # Hay colision: registrarla en el contador del slot
        $slot->set_colisiones($slot->get_colisiones() + 1);
        printf "  [HASH] Colision en Slot %d (%s): '%s' se encadena con %d elemento(s) existente(s).\n",
            $indice, $tipo, $persona->get_nombre(), $slot->get_cantidad();
    }

    # PASO 4: Crear el NodoHash
    my $nuevo_nodo = tableHash::NodoHash->new($persona);

    # PASO 5: Agregar al FINAL de la cadena del slot
    if ($slot->esta_vacio()) {
        # Slot vacio: el nuevo nodo es la cabeza
        $slot->set_lista_cabeza($nuevo_nodo);
    } else {
        # Recorrer hasta el ultimo nodo de la cadena
        my $actual = $slot->get_lista_cabeza();
        while (defined $actual->get_siguiente()) {
            $actual = $actual->get_siguiente();
        }
        $actual->set_siguiente($nuevo_nodo);
    }

    # Actualizar contadores
    $slot->set_cantidad($slot->get_cantidad() + 1);
    $self->{total_elementos}++;

    printf "  [HASH] Insertado '%s' en Slot %d (%s).\n",
        $persona->get_nombre(), $indice, $tipo;

    return 1;
}

# buscar_por_tipo($tipo)
# Retorna la cabeza de la lista enlazada de NodoHash del slot correspondiente.
# El llamador puede recorrer la lista para procesar todos los elementos.
sub buscar_por_tipo {
    my ($self, $tipo) = @_;

    my $indice = $self->_calcular_indice($tipo);
    if ($indice == -1) {
        print "ERROR: Tipo '$tipo' no es valido.\n";
        return undef;
    }

    my $slot = $self->_obtener_slot($indice);
    return undef unless defined $slot;

    return $slot->get_lista_cabeza();  # Cabeza de la cadena (puede ser undef si esta vacio)
}

# eliminar($nombre_persona, $tipo)
# Elimina la primera persona con ese nombre del slot correspondiente a ese tipo.
# Pasos:
#   1. Calcular el indice con la funcion hash
#   2. Recorrer la lista del slot con patron previo+actual
#   3. Al encontrar la persona por nombre, desenganchar el nodo
sub eliminar {
    my ($self, $nombre, $tipo) = @_;

    my $indice = $self->_calcular_indice($tipo);
    if ($indice == -1) {
        print "ERROR: Tipo '$tipo' no es valido.\n";
        return 0;
    }

    my $slot = $self->_obtener_slot($indice);
    return 0 unless defined $slot;

    # Patron de eliminacion en lista enlazada: previo + actual
    my $previo = undef;
    my $actual = $slot->get_lista_cabeza();

    while (defined $actual) {
        if ($actual->get_persona()->get_nombre() eq $nombre) {

            # Desenganche del nodo
            if (!defined $previo) {
                # Es la cabeza de la lista del slot
                $slot->set_lista_cabeza($actual->get_siguiente());
            } else {
                $previo->set_siguiente($actual->get_siguiente());
            }

            $slot->set_cantidad($slot->get_cantidad() - 1);
            $self->{total_elementos}--;
            printf "  [HASH] Eliminado '%s' del Slot %d (%s).\n", $nombre, $indice, $tipo;
            return 1;
        }
        $previo = $actual;
        $actual = $actual->get_siguiente();
    }

    print "  [HASH] No se encontro '$nombre' en el Slot $indice ($tipo).\n";
    return 0;
}


# get_total_elementos()
# Retorna cuantas personas hay en toda la tabla.
sub get_total_elementos { return $_[0]->{total_elementos}; }

# get_cantidad_por_tipo($tipo)
# Retorna cuantas personas hay en el slot de ese tipo.
sub get_cantidad_por_tipo {
    my ($self, $tipo) = @_;
    my $indice = $self->_calcular_indice($tipo);
    return 0 if $indice == -1;
    my $slot = $self->_obtener_slot($indice);
    return 0 unless defined $slot;
    return $slot->get_cantidad();
}

# imprimir_tabla()
# Imprime el estado completo de la tabla hash por consola:
# cada slot, sus elementos, colisiones y estado de ocupacion.
sub imprimir_tabla {
    my ($self) = @_;

    print "\n";
    print "=" x 60 . "\n";
    print "  TABLA HASH -- Directorio de Personal por Tipo\n";
    printf "  Capacidad: %d slots  |  Total elementos: %d\n", CAPACIDAD, $self->{total_elementos};
    print "=" x 60 . "\n\n";

    my $slot = $self->{cabeza};
    while (defined $slot) {
        my $estado    = $slot->esta_vacio() ? "[VACIO]" : "[OCUPADO]";
        my $colisiones = $slot->get_colisiones();

        printf "  Slot %d | %-6s | %s | %d elemento(s) | %d colision(es)\n",
            $slot->get_indice(),
            $slot->get_tipo(),
            $estado,
            $slot->get_cantidad(),
            $colisiones;

        # Recorrer la cadena de este slot
        my $nodo = $slot->get_lista_cabeza();
        while (defined $nodo) {
            my $p = $nodo->get_persona();
            printf "       -> %-30s | Edad: %2d | %s\n",
                $p->get_nombre(), $p->get_edad(), $p->get_carrera();
            $nodo = $nodo->get_siguiente();
        }

        print "\n";
        $slot = $slot->get_siguiente();
    }

    print "=" x 60 . "\n\n";
}

# get_cabeza_slots()
# Retorna la cabeza de la lista de SlotNodos.
# Necesario para que Graficar.pm pueda recorrer la tabla.
sub get_cabeza_slots { return $_[0]->{cabeza}; }

1;