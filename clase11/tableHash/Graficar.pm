package tableHash::Graficar;

use strict;
use warnings;

use tableHash::TablaHash;

# Directorio donde se guardan los reportes generados
use constant DIR_REPORTES => "clase11/reportes";

# UTILIDAD: asegurar directorio de reportes
sub _asegurar_directorio {
    my $dir = DIR_REPORTES;
    unless (-d $dir) {
        mkdir $dir or die "No se pudo crear el directorio '$dir': $!";
    }
}

# graficar_tabla_hash($tabla, $nombre_archivo)
# Genera una visualización SIMPLE de la tabla hash:
#   - Solo muestra los slots
#   - Contenido en forma de lista (A → B → C)
sub graficar_tabla_hash {
    my ($class, $tabla, $nombre_archivo) = @_;

    _asegurar_directorio();

    my $ruta_dot = DIR_REPORTES . "/$nombre_archivo.dot";
    my $ruta_png = DIR_REPORTES . "/$nombre_archivo.png";

    open(my $fh, '>', $ruta_dot) or die "No se pudo crear '$ruta_dot': $!";

    # ENCABEZADO SIMPLE
    print $fh "digraph TablaHash {\n";
    print $fh "    graph [\n";
    print $fh "        rankdir = TB\n";
    print $fh "        bgcolor = \"#FFFFFF\"\n";
    print $fh "        fontname = \"Helvetica\"\n";
    print $fh "    ]\n\n";

    print $fh "    node [shape=none fontname=\"Helvetica\"]\n\n";

    # TABLA PRINCIPAL
    print $fh "    tabla [label=<\n";
    print $fh "        <TABLE BORDER=\"1\" CELLBORDER=\"1\" CELLSPACING=\"0\" CELLPADDING=\"6\">\n";
    print $fh "            <TR>\n";
    print $fh "                <TD><B>Slot</B></TD>\n";
    print $fh "                <TD><B>Contenido</B></TD>\n";
    print $fh "            </TR>\n";

    my $slot = $tabla->get_cabeza_slots();

    while (defined $slot) {
        my $indice = $slot->get_indice();

        my @personas;
        my $nodo = $slot->get_lista_cabeza();

        while (defined $nodo) {
            my $nombre = $nodo->get_persona()->get_nombre();

            # Escapar caracteres HTML
            $nombre =~ s/&/&amp;/g;
            $nombre =~ s/</&lt;/g;
            $nombre =~ s/>/&gt;/g;

            push @personas, $nombre;

            $nodo = $nodo->get_siguiente();
        }

        my $contenido = @personas ? join(" → ", @personas) : "NULL";

        print $fh "            <TR>\n";
        print $fh "                <TD>[$indice]</TD>\n";
        print $fh "                <TD>$contenido</TD>\n";
        print $fh "            </TR>\n";

        $slot = $slot->get_siguiente();
    }

    print $fh "        </TABLE>\n";
    print $fh "    >];\n";

    print $fh "}\n";

    close($fh);

    # COMPILAR CON GRAPHVIZ
    my $cmd    = "dot -Tpng \"$ruta_dot\" -o \"$ruta_png\"";
    my $retval = system($cmd);

    if ($retval == 0) {
        print "Reporte generado: $ruta_png\n";
    } else {
        print "AVISO: No se pudo compilar con Graphviz. Archivo DOT en: $ruta_dot\n";
        print "Ejecutar manualmente: $cmd\n";
    }

    return $ruta_png;
}

1;

