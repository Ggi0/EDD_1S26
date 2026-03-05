package bst::graficar;

use strict;
use warnings;

use bst::bst;


# Genera una representación básica del árbol BST usando Graphviz.
# Solo muestra:
#   - Nodos (todos con el mismo estilo neutro)
#   - Conexiones padre -> hijo
#
# El objetivo es visualizar claramente la ESTRUCTURA del árbol.
#
sub graficar {
    my ($class, $arbol, $basename) = @_;

    my $dot_file = "clase6/reportes/$basename.dot";
    my $png_file = "clase6/reportes/$basename.png";

    # Crear carpeta si no existe
    system("mkdir -p clase6/reportes") unless -d "clase6/reportes";

    
    # Crear archivo DOT
    
    open(my $fh, '>', $dot_file) or die "No se pudo crear $dot_file: $!";

    print $fh "digraph BST {\n";
    print $fh "    rankdir=TB;\n";  # Raíz arriba, hijos abajo

    # Estilo SIMPLE y NEUTRO para todos los nodos
    print $fh "    node [\n";
    print $fh "        shape=circle,\n";
    print $fh "        style=filled,\n";
    print $fh "        fillcolor=\"#B0BEC5\",\n";  # Gris neutro
    print $fh "        fontname=\"Arial\"\n";
    print $fh "    ];\n\n";

    # Si el árbol está vacío
    if ($arbol->is_empty()) {
        print $fh "    empty [label=\"ÁRBOL VACÍO\", shape=box];\n";
    } else {

        
        # PASO 1: Generar nodos
        # Recorremos el árbol en PREORDEN:
        # 1. Nodo actual
        # 2. Subárbol izquierdo
        # 3. Subárbol derecho
        $class->_generar_nodos($fh, $arbol->{root});

        
        # PASO 2: Generar conexiones padre -> hijo
        $class->_generar_aristas($fh, $arbol->{root});
    }

    print $fh "}\n";
    close($fh);

    
    # Convertir DOT a PNG
    
    my $command = "dot -Tpng \"$dot_file\" -o \"$png_file\" 2>&1";
    my $output  = `$command`;
    my $exit    = $? >> 8;

    if ($exit == 0) {
        print "Imagen generada correctamente: $png_file\n";
        return 1;
    } else {
        print "Error al generar imagen.\n$output\n";
        return 0;
    }
}


# Recorre el árbol en PREORDEN para declarar todos los nodos.
#
# Cada nodo se declara con:
#   nVALOR [label="VALOR"];
#
# Usamos "n" como prefijo para evitar conflictos con nombres numéricos.
#
sub _generar_nodos {
    my ($class, $fh, $nodo) = @_;

    return if !defined($nodo);   # Caso base

    my $valor = $nodo->get_data();
    my $id    = "n$valor";

    # Declaración simple del nodo
    print $fh "    $id [label=\"$valor\"];\n";

    # Recursión izquierda
    $class->_generar_nodos($fh, $nodo->get_left());

    # Recursión derecha
    $class->_generar_nodos($fh, $nodo->get_right());
}


# Recorre el árbol y genera las conexiones padre -> hijo.
#
# Si el nodo tiene hijo izquierdo:
#   nPadre -> nHijoIzq;
#
# Si el nodo tiene hijo derecho:
#   nPadre -> nHijoDer;
#
sub _generar_aristas {
    my ($class, $fh, $nodo) = @_;

    return if !defined($nodo);  # Caso base

    my $valor_padre = $nodo->get_data();
    my $id_padre    = "n$valor_padre";

    # Conexión izquierda
    if (defined($nodo->get_left())) {
        my $valor_izq = $nodo->get_left()->get_data();
        my $id_izq    = "n$valor_izq";

        print $fh "    $id_padre -> $id_izq;\n";

        $class->_generar_aristas($fh, $nodo->get_left());
    }

    # Conexión derecha
    if (defined($nodo->get_right())) {
        my $valor_der = $nodo->get_right()->get_data();
        my $id_der    = "n$valor_der";

        print $fh "    $id_padre -> $id_der;\n";

        $class->_generar_aristas($fh, $nodo->get_right());
    }
}

1;