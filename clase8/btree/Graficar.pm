package btree::graficar;

use strict;
use warnings;

sub graficar {
    my ($class, $arbol, $basename) = @_;

    my $dot_file = "clase8/reportes/$basename.dot";
    my $png_file = "clase8/reportes/$basename.png";

    system("mkdir -p clase8/reportes") unless -d "clase8/reportes";

    open(my $fh, '>', $dot_file) or die "No se pudo crear $dot_file: $!";

    print $fh "digraph BTree {\n";
    print $fh "    rankdir=TB;\n";
    print $fh "    splines=false;\n";
    print $fh "    nodesep=0.4;\n";
    print $fh "    ranksep=1.2;\n";
    print $fh "    ordering=out;\n";
    print $fh "    node [\n";
    print $fh "        shape=record,\n";
    print $fh "        style=filled,\n";
    print $fh "        fontname=\"Arial\",\n";
    print $fh "        fontsize=12,\n";
    print $fh "        height=0.45\n";
    print $fh "    ];\n\n";
    print $fh "    edge [color=\"#111111\", arrowhead=none, penwidth=1.3];\n\n";

    my $orden = $arbol->get_orden();
    my $size  = $arbol->get_size();
    print $fh "    label=\"Arbol B  -  Orden M=$orden  -  Claves totales=$size\";\n";
    print $fh "    labelloc=top;\n";
    print $fh "    fontsize=13;\n\n";

    if ($arbol->is_empty()) {
        print $fh "    empty [label=\"ARBOL VACIO\", shape=box];\n";
    } else {
        my $id_contador = { val => 0 };
        $class->_generar_dot($fh, $arbol->{raiz}, $arbol, $id_contador, undef, undef);
    }

    print $fh "}\n";
    close($fh);

    my $output = `dot -Tpng "$dot_file" -o "$png_file" 2>&1`;
    my $exit   = $? >> 8;

    if ($exit == 0) { print "Imagen generada: $png_file\n"; return 1; }
    else            { print "Error: $output\n";              return 0; }
}


# _generar_dot($fh, $nodo, $arbol, $id_contador, $id_padre, $puerto_padre)
#
# APARIENCIA OBJETIVO:
#
#   Nodo INTERNO con claves [10, 25]:
#     [ <p0> | 10 | <p1> | 25 | <p2> ]
#      slot0  clave slot1  clave slot2
#
#   Los slots <pN> son celdas angostas (sin texto) que representan
#   visualmente los punteros a hijos, igual que en la imagen de referencia.
#   El color gris del fondo del nodo se ve a traves de esas celdas vacias.
#
#   Nodo HOJA con claves [10, 15, 17, 21]:
#     [ 10 | 15 | 17 | 21 ]
#   Sin slots, fondo blanco.
#
# RECURSIVIDAD:
#   Caso base:    $nodo undef -> retornar
#   Caso recursivo: generar nodo, recurrir en cada hijo
#
sub _generar_dot {
    my ($class, $fh, $nodo, $arbol, $id_contador, $id_padre, $puerto_padre) = @_;

    return unless defined($nodo);

    my $id_nodo = "n" . $id_contador->{val};
    $id_contador->{val}++;

    my $num_claves = $nodo->get_num_claves();
    my $es_hoja    = $nodo->es_hoja();

    # ---- Label ----

    my $label;

    if ($es_hoja) {
        # Hojas: solo claves separadas por | , fondo blanco
        # Apariencia final: [ 10 | 15 | 17 | 21 ]
        $label = "";
        my $c = $nodo->get_claves_head();
        my $i = 0;
        while (defined($c)) {
            $label .= " | " if $i > 0;
            $label .= " " . $c->{val} . " ";
            $c = $c->{sig};
            $i++;
        }

    } else {
        # Nodos internos: slots angostos vados intercalados con claves.
        # El slot es solo "<pN>" sin texto adicional -> celda angosta vacia.
        # Apariencia final: [  ][10][  ][25][  ]
        #                    p0      p1      p2
        $label = "<p0>";
        my $c = $nodo->get_claves_head();
        my $i = 0;
        while (defined($c)) {
            $label .= "| " . $c->{val} . " ";
            $label .= "|<p" . ($i + 1) . ">";
            $c = $c->{sig};
            $i++;
        }
    }

    # ---- Color ----
    # Internos: gris (los slots vacios dejan ver el fondo gris, igual a la imagen)
    # Hojas: blanco
    my $color;
    my $max_claves = $arbol->{max_claves};
    my $min_claves = $arbol->{min_claves};

    if    ($es_hoja)                        { $color = '"#FFFFFF"'; }
    elsif ($num_claves == $max_claves)      { $color = '"#BDBDBD"'; }  # lleno: gris oscuro
    elsif ($num_claves <= $min_claves)      { $color = '"#F5F5F5"'; }  # minimo: casi blanco
    else                                    { $color = '"#E0E0E0"'; }  # normal: gris claro

    # ---- Declaracion del nodo ----
    print $fh "    $id_nodo [label=\"$label\", fillcolor=$color];\n";

    # ---- Arista desde el padre ----
    # Sale del puerto (slot) del padre y llega al nodo hijo completo.
    if (defined($id_padre) && defined($puerto_padre)) {
        print $fh "    ${id_padre}:${puerto_padre} -> ${id_nodo};\n";
    }

    # ---- RECURSION en cada hijo ----
    my $h = $nodo->get_hijos_head();
    my $j = 0;
    while (defined($h)) {
        $class->_generar_dot($fh, $h->{hijo}, $arbol, $id_contador, $id_nodo, "p$j");
        $h = $h->{sig};
        $j++;
    }
}

1;