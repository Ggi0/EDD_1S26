package linked_list::Graficar;

use strict;
use warnings;
use linked_list::LinkedList;
use constant LinkedList => 'linked_list::LinkedList';


# metodo para el archivo .dot
# parametros: $lista: objeto LinekdList
#             $filename: nombre del archivo .dot

sub generador_dot{

    my ($class, $lista, $filename) = @_;
    
    # Abrir el archivo para escritura
    open(my $fh, '>', $filename) or die "No se pudo crear $filename: $!";

    # Escribir el encabezado del archivo DOT
    print $fh "digraph LinkedList {\n";
    print $fh "    // Configuración general\n";
    print $fh "    rankdir=LR;  // Orientación horizontal (Left to Right)\n";
    print $fh "    node [shape=circle, style=filled, fillcolor=lightblue, fontsize=14];\n";
    print $fh "    edge [color=darkgreen, penwidth=2];\n\n";

    # Si la lista está vacía, indicarlo
    if ($lista->is_empty()) {
        print $fh "    // Lista vacía\n";
        print $fh "    empty [label=\"VACÍA\", shape=box, fillcolor=lightgray];\n";
    } else {
        # Recorrer la lista y generar nodos
        my $current = $lista->{head};  # Acceso directo al head
        my $node_id = 0;
        
        print $fh "    // Nodos de la lista\n";
        
        # Primero creamos todos los nodos
        while (defined($current)) {
            my $data = $current->get_data();
            print $fh "    node$node_id [label=\"$data\"];\n";
            
            $current = $current->get_next();
            $node_id++;
        }
        
        # Ahora creamos las conexiones (flechas)
        print $fh "\n    // Conexiones entre nodos\n";
        $current = $lista->{head};
        $node_id = 0;
        
        while (defined($current->get_next())) {
            my $next_id = $node_id + 1;
            print $fh "    node$node_id -> node$next_id;\n";
            
            $current = $current->get_next();
            $node_id++;
        }
        
        # El último nodo apunta a NULL
        print $fh "\n    // NULL al final\n";
        print $fh "    null [label=\"NULL\", shape=box, fillcolor=lightcoral];\n";
        print $fh "    node$node_id -> null;\n";
    }
    
    # Cerrar el archivo DOT
    print $fh "}\n";
    close($fh);
    
    #print "Archivo DOT generado: $filename\n";


}

sub graficar_imagen{
    my ($class, $lista, $basename) = @_;
    
    my $dot_file = "$basename.dot";
    my $png_file = "$basename.png";
    
    # Generar el archivo DOT
    $class->generador_dot($lista, $dot_file);
    
    # Intentar generar la imagen PNG
    my $command = "dot -Tpng $dot_file -o $png_file 2>&1";
    my $output = `$command`;
    my $exit_code = $? >> 8;
    
    if ($exit_code == 0) {
        #print "Imagen PNG generada: $png_file\n";
        return 1;
    } else {
        print "Error al generar PNG.\n";
        print "El archivo DOT está en: $dot_file\n";
        return 0;
    }
}


1;

