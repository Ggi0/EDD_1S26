package D_linked_list::Graficar;


use strict;
use warnings;
use D_linked_list::D_linkedList;
use constant LinkedList => 'D_linked_list::D_linkedList';


sub graficar {
    my ($class, $lista, $basename) = @_;
    
    my $dot_file = "clase2/D_linked_list/reportes/$basename.dot";
    my $png_file = "clase2/D_linked_list/reportes/$basename.png";
    
    # PARTE 1: Generar archivo .dot
    open(my $fh, '>', $dot_file) or die "No se pudo crear $dot_file: $!";

    # Encabezado DOT
    print $fh "digraph ListaDoble {\n";
    print $fh "    // Configuración general\n";
    print $fh "    rankdir=LR;\n";
    print $fh "    node [shape=circle, style=filled, fillcolor=lightblue, fontsize=14];\n";
    
    # Color diferente para flechas bidireccionales ***
    print $fh "    edge [color=darkgreen, penwidth=2, dir=both];\n\n";

    if ($lista->is_empty()) {
        print $fh "    // Lista vacía\n";
        print $fh "    empty [label=\"VACÍA\", shape=box, fillcolor=lightgray];\n";
    } else {
        my $current = $lista->{head};
        my $node_id = 0;
        
        # Crear todos los nodos
        print $fh "    // Nodos de la lista\n";
        while (defined($current)) {
            my $data = $current->get_data();
            print $fh "    node$node_id [label=\"$data\"];\n";
            
            $current = $current->get_next();
            $node_id++;
        }
        
        print $fh "\n    // Conexiones bidireccionales (next y prev)\n";
        $current = $lista->{head};
        $node_id = 0;
        
        while (defined($current->get_next())) {
            my $next_id = $node_id + 1;
            
            # Flecha bidireccional entre nodos
            print $fh "    node$node_id -> node$next_id [dir=both];\n";
            
            $current = $current->get_next();
            $node_id++;
        }
        
        # NULL al inicio y al final
        print $fh "\n    // NULL en ambos extremos\n";
        print $fh "    null_inicio [label=\"NULL\", shape=box, fillcolor=lightcoral];\n";
        print $fh "    null_fin [label=\"NULL\", shape=box, fillcolor=lightcoral];\n";
        print $fh "    null_inicio -> node0 [dir=forward];\n";  # Solo hacia adelante
        print $fh "    node$node_id -> null_fin [dir=forward];\n";  # Solo hacia adelante
    }
    
    print $fh "}\n";
    close($fh);
    
    print "Archivo DOT generado: $dot_file\n";

    # PARTE 2: Generar imagen PNG
    my $command = "dot -Tpng $dot_file -o $png_file 2>&1";
    my $output = `$command`;
    my $exit_code = $? >> 8;
    
    if ($exit_code == 0) {
        print "Imagen PNG generada: $png_file\n";
        return 1;
    } else {
        return 0;
    }
}

1;
