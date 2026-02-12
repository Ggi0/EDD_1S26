package lista_circular::Graficar;


# El ultimo nodo tiene una flecha que apunta de vuelta al primer nodo (head)
# para mostrar visualmente la naturaleza circular de la estructura

use strict;
use warnings;

use lista_circular::ListaCircular;
use constant ListaCircular => 'circular_list::ListaCircular';

# graficar($lista, $basename)
#
# Parametros:
#   $lista: objeto ListaCircular a visualizar
#   $basename: nombre base para los archivos (sin extension)
#               se generaran: basename.dot y basename.png
#
# Retorna: 1 si tuvo exito, 0 si hubo error
sub graficar {
    my ($class, $lista, $basename) = @_;
    
    my $dot_file = "clase3/reportes/$basename.dot";
    my $png_file = "clase3/reportes/$basename.png";
    
    # PASO 1: Generar el archivo DOT
    print "Generando archivo DOT: $dot_file\n";
    
    # Abrir el archivo para escritura
    open(my $fh, '>', $dot_file) or die "No se pudo crear $dot_file: $!";
    
    # Escribir el encabezado del archivo DOT
    # digraph = grafo dirigido (las flechas tienen direccion)
    print $fh "digraph ListaCircular {\n";
    print $fh "    // Configuracion general del grafo\n";
    print $fh "    rankdir=LR;  // Orientacion horizontal (Left to Right)\n";
    print $fh "    \n";
    print $fh "    // Estilo de los nodos\n";
    print $fh "    node [\n";
    print $fh "        shape=circle,           // Forma circulo con divisiones\n";
    print $fh "        style=filled,\n";
    print $fh "        fillcolor=lightblue,\n";
    print $fh "        fontsize=12,\n";
    print $fh "        fontname=\"Arial\"\n";
    print $fh "    ];\n";
    print $fh "    \n";
    print $fh "    // Estilo de las flechas\n";
    print $fh "    edge [\n";
    print $fh "        color=darkgreen,\n";
    print $fh "        penwidth=2,\n";
    print $fh "        arrowsize=1.0\n";
    print $fh "    ];\n\n";
    
    # Si la lista esta vacia
    if ($lista->is_empty()) {
        print $fh "    // Lista vacia\n";
        print $fh "    empty [\n";
        print $fh "        label=\"LISTA VACIA\",\n";
        print $fh "        shape=box,\n";
        print $fh "        fillcolor=lightgray\n";
        print $fh "    ];\n";
    } else {
        # PASO A: Crear todos los nodos
        # Recorremos la lista una vez para generar los nodos
        my $current = $lista->{head};
        my $node_id = 0;
        
        print $fh "    // === NODOS DE LA LISTA ===\n";
        
        do {
            my $data = $current->get_data();

            
            
            # Si el dato es un objeto con metodo get_nombre, usamos eso
            my $label;
            # TODO:    $label = $data->get_info_graphviz();
            if (ref($data) && $data->can('get_info_graphviz')) {
                $label = $data->get_info_graphviz();
            } else {
                $label = $data;
            }
            
            # Escapar caracteres especiales en el label
            $label =~ s/"/\\"/g;
            
            # Crear el nodo en formato DOT
            # El formato "record" permite dividir el nodo en secciones
            print $fh "    node$node_id [\n";
            print $fh "        label=\" $label \"\n";
            print $fh "    ];\n";
            
            $current = $current->get_next();
            $node_id++;
        } while ($current != $lista->{head});
        
        my $total_nodos = $node_id;
        
        # PASO B: Crear las conexiones (flechas) entre nodos
        print $fh "\n    // === CONEXIONES ENTRE NODOS ===\n";
        
        $current = $lista->{head};
        $node_id = 0;
        
        do {
            my $next_id = ($node_id + 1) % $total_nodos;  # Modulo para la circularidad
            
            # Si es la ultima flecha (la que cierra el circulo)
            if ($next_id == 0) {
                print $fh "    // Flecha que cierra el circulo (vuelve a HEAD)\n";
                print $fh "    node$node_id -> node$next_id [\n";
                print $fh "    ];\n";
            } else {
                # Flechas normales
                print $fh "    node$node_id -> node$next_id;\n";
            }
            
            $current = $current->get_next();
            $node_id++;
        } while ($current != $lista->{head});
        
    }
    
    # Cerrar el archivo DOT
    print $fh "}\n";
    close($fh);
    
    print "Archivo DOT generado exitosamente.\n";
    
    # PASO 2: Generar la imagen PNG usando Graphviz
    print "Generando imagen PNG: $png_file\n";
    
    # Ejecutar el comando 'dot' de Graphviz
    # -Tpng: formato de salida PNG
    # -o: archivo de salida
    my $command = "dot -Tpng $dot_file -o $png_file 2>&1";
    my $output = `$command`;
    my $exit_code = $? >> 8;
    
    # Verificar si el comando tuvo exito
    if ($exit_code == 0) {
        print "Imagen PNG generada exitosamente: $png_file\n";
        return 1;
    } else {
        return 0;
    }
}

1;