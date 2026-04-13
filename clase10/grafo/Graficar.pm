package grafo::Graficar;

use strict;
use warnings;

sub graficar {
    my ($class, $grafo, $basename) = @_;

    my $dot_file = "clase10/reportes/$basename.dot";
    my $png_file = "clase10/reportes/$basename.png";

    system("mkdir -p clase10/reportes") unless -d "clase10/reportes";

    open(my $fh, '>', $dot_file) or die "No se pudo crear $dot_file: $!";

    print $fh "graph GRAFO {\n";
    print $fh "    rankdir=LR;\n";  # Izquierda a derecha
    
    print $fh "    node [\n";
    print $fh "        shape=ellipse,\n";
    print $fh "        style=filled,\n";
    print $fh "        fillcolor=\"#B0C4DE\",\n";   # Azul claro
    print $fh "        fontname=\"Arial\",\n";
    print $fh "        fontsize=12\n";
    print $fh "    ];\n";
    print $fh "    edge [\n";
    print $fh "        color=\"#555555\"\n";
    print $fh "    ];\n\n";

    if ($grafo->esta_vacio()) {
        print $fh "    empty [label=\"GRAFO VACIO\", shape=box];\n";
    } else {
        # PASO 1: Declarar todos los vertices
        $class->_escribir_vertices($fh, $grafo);

        print $fh "\n";

        # PASO 2: Declarar las aristas (sin duplicados)
        $class->_escribir_aristas($fh, $grafo);
    }

    print $fh "}\n";
    close($fh);

    return $class->_compilar_dot($dot_file, $png_file);
}

# Genera una representacion visual de las listas de adyacencia.
# Muestra cada vertice y su cadena de vecinos como una lista enlazada.
sub graficar_lista_adyacencia {
    my ($class, $grafo, $basename) = @_;

    my $dot_file = "clase10/reportes/${basename}_lista.dot";
    my $png_file = "clase10/reportes/${basename}_lista.png";

    system("mkdir -p clase10/reportes") unless -d "clase10/reportes";

    open(my $fh, '>', $dot_file) or die "No se pudo crear $dot_file: $!";

    print $fh "digraph LISTA_ADYACENCIA {\n";
print $fh "    rankdir=TB;\n";
    print $fh "    node [shape=box, style=filled, fillcolor=\"#B0C4DE\", fontname=\"Arial\"];\n";
print $fh "    edge [color=\"#333333\", constraint=true];\n";
    if ($grafo->esta_vacio()) {
        print $fh "    empty [label=\"GRAFO VACIO\"];\n";
    } else {

        my $actual = $grafo->{vertices_cabeza};
        my $fila = 0;

        my $anterior_inicio;

        while (defined $actual) {
            my $nodo = $actual->get_data();
            my $id   = $nodo->get_id();

            # Nodo principal (inicio de la fila)
            my $inicio = "v_$id";
            print $fh "    $inicio [label=\"$id\", fillcolor=\"#87CEFA\", group=\"col1\"];\n";

            # Conectar filas verticalmente
            if (defined $anterior_inicio) {
                print $fh "    $anterior_inicio -> $inicio [dir=none];\n";
            }
            $anterior_inicio = $inicio;

            my $lista = $nodo->get_lista_adyacencia();
            my $ptr   = $lista->get_cabeza();

            my $prev = $inicio;

            if (!defined $ptr) {
                my $null = "null_${id}";
                print $fh "    $null [label=\"NULL\", shape=plaintext];\n";
                print $fh "    $prev -> $null;\n";
            }

            while (defined $ptr) {
                my $vecino = $ptr->get_data();
                my $nid = "n_${id}_" . $vecino->get_id();

                print $fh "    $nid [label=\"" . $vecino->get_id() . "\"];\n";
                print $fh "    $prev -> $nid;\n";

                $prev = $nid;
                $ptr = $ptr->get_siguiente();
            }

            # Nodo NULL al final
            if ($prev ne $inicio) {
                my $null = "null_${id}";
                print $fh "    $null [label=\"NULL\", shape=plaintext];\n";
                print $fh "    $prev -> $null;\n";
            }

            # Mantener cada fila alineada            # Mantener cada fila alineada (IMPORTANTE incluir NULL)
            print $fh "    { rank=same; $inicio";

            my $ptr2 = $nodo->get_lista_adyacencia()->get_cabeza();
            while (defined $ptr2) {
                my $nid = "n_${id}_" . $ptr2->get_data()->get_id();
                print $fh " $nid";
                $ptr2 = $ptr2->get_siguiente();
            }

            # Agregar NULL al mismo nivel
            print $fh " null_${id}";

            print $fh " }\n\n";

            $actual = $actual->get_siguiente();
            $fila++;
        }
    }

    print $fh "}\n";
    close($fh);

    return $class->_compilar_dot($dot_file, $png_file);
}

# Recorre la lista de vertices y los declara en el DOT.
# El label muestra el ID del vertice.
sub _escribir_vertices {
    my ($class, $fh, $grafo) = @_;

    my $actual = $grafo->{vertices_cabeza};
    while (defined $actual) {
        my $nodo = $actual->get_data();
        my $id   = $nodo->get_id();
        # Usar comillas en el ID para soportar espacios y caracteres especiales
        print $fh "    \"$id\";\n";
        $actual = $actual->get_siguiente();
    }
}

# Recorre todos los vertices y sus listas de adyacencia para escribir aristas.
sub _escribir_aristas {
    my ($class, $fh, $grafo) = @_;

    my %dibujadas = ();  # Hash para evitar aristas duplicadas

    my $actual = $grafo->{vertices_cabeza};
    while (defined $actual) {
        my $nodo_a = $actual->get_data();
        my $id_a   = $nodo_a->get_id();

        my $lista = $nodo_a->get_lista_adyacencia();
        my $ptr   = $lista->get_cabeza();

        while (defined $ptr) {
            my $nodo_b = $ptr->get_data();
            my $id_b   = $nodo_b->get_id();

            # Normalizar la clave: siempre el menor lexicograficamente primero
            my $clave;
            if ($id_a lt $id_b) {
                $clave = "$id_a|$id_b";
            } else {
                $clave = "$id_b|$id_a";
            }

            # Solo dibujar si esta arista aun no fue procesada
            unless (exists $dibujadas{$clave}) {
                $dibujadas{$clave} = 1;
                # "--" = arista no dirigida
                print $fh "    \"$id_a\" -- \"$id_b\";\n";
            }

            $ptr = $ptr->get_siguiente();
        }

        $actual = $actual->get_siguiente();
    }
}

# Llama al programa "dot" de Graphviz para convertir el .dot a .png.
sub _compilar_dot {
    my ($class, $dot_file, $png_file) = @_;

    my $command = "dot -Tpng \"$dot_file\" -o \"$png_file\" 2>&1";
    my $output  = `$command`;
    my $exit    = $? >> 8;

    if ($exit == 0) {
        print "Imagen generada: $png_file\n";
        return 1;
    } else {
        print "Error al generar imagen desde $dot_file\n$output\n";
        return 0;
    }
}

1;