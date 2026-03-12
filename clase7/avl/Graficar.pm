package avl::graficar;

# GRAFICADOR PARA ARBOL AVL
#
# Genera una imagen PNG del arbol usando Graphviz (dot).
# A diferencia del graficador BST, este muestra informacion AVL en cada nodo:
#   - El valor del nodo
#   - La altura del nodo
#   - El factor de equilibrio (FE)
#
# Ademas, colorea los nodos segun su factor de equilibrio para
# que sea visualmente obvio el estado de balance del arbol:
#   Verde   -> FE = 0  (perfectamente balanceado)
#   Azul    -> FE = -1 (ligeramente cargado a la izquierda, OK)
#   Naranja -> FE = +1 (ligeramente cargado a la derecha, OK)
#   Rojo    -> FE = -2 o +2 (desbalanceado, no deberia aparecer en un AVL correcto ... perooo por si las moscas)

use strict;
use warnings;

use avl::avl;

sub graficar {
    my ($class, $arbol, $basename) = @_;

    my $dot_file = "clase7/reportes/$basename.dot";
    my $png_file = "clase7/reportes/$basename.png";

    system("mkdir -p clase7/reportes") unless -d "clase7/reportes";

    open(my $fh, '>', $dot_file) or die "No se pudo crear $dot_file: $!";

    print $fh "digraph AVL {\n";
    print $fh "    rankdir=TB;\n";
    print $fh "    node [\n";
    print $fh "        shape=circle,\n";
    print $fh "        style=filled,\n";
    print $fh "        fontname=\"Arial Bold\",\n";
    print $fh "        fontsize=11\n";
    print $fh "    ];\n\n";

    # Estilo para las aristas
    print $fh "    edge [fontname=\"Arial\", fontsize=9, color=\"#546E7A\"];\n\n";

    if ($arbol->is_empty()) {
        print $fh "    empty [label=\"ARBOL VACIO\", shape=box];\n";
    } else {
        $class->_generar_nodos($fh, $arbol->{root}, $arbol);
        $class->_generar_aristas($fh, $arbol->{root});
    }

    print $fh "}\n";
    close($fh);

    my $output = `dot -Tpng "$dot_file" -o "$png_file" 2>&1`;
    my $exit   = $? >> 8;

    if ($exit == 0) {
        print "Imagen generada: $png_file\n";
        return 1;
    } else {
        print "Error al generar imagen.\n$output\n";
        return 0;
    }
}

# _generar_nodos($fh, $nodo, $arbol)
#
# Recorre el arbol en PREORDEN y declara cada nodo con:
#   - Etiqueta que muestra: valor, altura y factor de equilibrio
#   - Color de relleno segun el factor de equilibrio
#
sub _generar_nodos {
    my ($class, $fh, $nodo, $arbol) = @_;

    return unless defined($nodo);

    my $valor = $nodo->get_data();
    my $id    = "n$valor";
    my $h     = $nodo->get_altura();

    # Calcular factor de equilibrio para este nodo
    # _factor_equilibrio es un metodo de instancia, necesitamos el objeto arbol
    my $fe = $arbol->_factor_equilibrio($nodo);

    # Elegir color segun el factor de equilibrio
    my $color;
    if    ($fe ==  0){ $color = '"#A5D6A7"'; }  # Verde: perfectamente balanceado
    elsif ($fe == -1) { $color = '"#90CAF9"'; }  # Azul claro: cargado izquierda (OK)
    elsif ($fe ==  1) { $color = '"#FFCC80"'; }  # Naranja claro: cargado derecha (OK)
    else   { $color = '"#EF9A9A"'; }  # Rojo: desbalanceado (no deberia ocurrir....)

    # La etiqueta muestra el valor, la altura y el FE
    # h=altura, fe=factor de equilibrio
    my $label = "$valor\\nh=$h  fe=$fe";

    print $fh "    $id [label=\"$label\", fillcolor=$color];\n";

    # RECURSION izquierda y derecha (preorden)
    $class->_generar_nodos($fh, $nodo->get_left(),  $arbol);
    $class->_generar_nodos($fh, $nodo->get_right(), $arbol);
}

# _generar_aristas($fh, $nodo)
# Recorre el arbol y genera las conexiones padre -> hijo.
sub _generar_aristas {
    my ($class, $fh, $nodo) = @_;

    return unless defined($nodo);

    my $id_padre = "n" . $nodo->get_data();

    if (defined($nodo->get_left())) {
        my $id_izq = "n" . $nodo->get_left()->get_data();
        print $fh "    $id_padre -> $id_izq [label=\"\"];\n";
        $class->_generar_aristas($fh, $nodo->get_left());
    }

    if (defined($nodo->get_right())) {
        my $id_der = "n" . $nodo->get_right()->get_data();
        print $fh "    $id_padre -> $id_der [label=\"\"];\n";
        $class->_generar_aristas($fh, $nodo->get_right());
    }
}

1;