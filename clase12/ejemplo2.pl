
use strict;
use warnings;
use utf8;
use open ':std', ':encoding(UTF-8)';

use FindBin;
use lib "$FindBin::Bin";

# Importar la lista enlazada del curso
use linked_list::LinkedList;
use constant D_linkedList => 'linked_list::LinkedList';

use linked_list::Graficar;
use constant Graficar => 'linked_list::Graficar';


# Importar nuestro módulo LZW
use lzw::LZW;
use constant LZW => 'lzw::LZW';

# Directorio donde están los archivos comprimidos
use constant DIR_ARCHIVOS => "$FindBin::Bin/archivos";

sub main {

    print "  DESCOMPRESIÓN LZW\n";

    # Verificar que existe el directorio de archivos
    unless (-d DIR_ARCHIVOS) {
        die "ERROR: No existe el directorio 'archivos/'.\n";
    }

    
    # glob() devuelve todos los archivos que coincidan con el patrón.
    # Ordenamos numéricamente por el número en el nombre (nodo0, nodo1...) para reconstruir la lista en el mismo orden original.
    my @archivos = glob(DIR_ARCHIVOS . "/nodo*.lzw");

    unless (@archivos) {
        die "ERROR: No se encontraron archivos .lzw en 'archivos/'.\n";
    }

    # Ordenar: nodo0.lzw < nodo1.lzw < nodo2.lzw ...
    # Extraemos el número con una expresión regular y ordenamos numéricamente.
    @archivos = sort {
        my ($num_a) = $a =~ /nodo(\d+)\.lzw$/;
        my ($num_b) = $b =~ /nodo(\d+)\.lzw$/;
        $num_a <=> $num_b;   # <=> es el operador de comparación numérica
    } @archivos;

    print "Archivos .lzw encontrados: " . scalar(@archivos) . "\n";
    print join("\n", map { "  $_" } @archivos) . "\n\n";

    
    # Crear la lista enlazada de destino (vacía)
    
    my $lista_reconstruida = D_linkedList->new();
    #Graficar->generador_dot($lista_reconstruida, "lista_r_2.dot");
    #Graficar->graficar_imagen($lista_reconstruida, "lista_r_2");

    
    #Leer, descomprimir e insertar cada nodo
    

    my $indice = 0;

    for my $ruta_archivo (@archivos) {

        # Extraer el nombre del archivo para mostrarlo
        (my $nombre_archivo = $ruta_archivo) =~ s{.*/}{};

        #$ruta_archivo = "/Users/gio/documentos/archivo.txt";
        #$nombre_archivo = "archivo.txt";

        
        # LEER el archivo binario .lzw
        # Es importante leer en modo binario (:raw) para no alterar bytes
        my $datos_comprimidos = LZW->leer_archivo($ruta_archivo);
        my $tam_comprimido = length($datos_comprimidos);

    
        # DESCOMPRESIÓN LZW
        # El algoritmo reconstruye el diccionario internamente.
        # El resultado debe ser IDÉNTICO al texto original.
        my $texto_recuperado = LZW->descomprimir($datos_comprimidos);
        my $tam_recuperado = length(Encode::encode('UTF-8', $texto_recuperado));

        
        # Insertar el texto descomprimido en la lista reconstruida
        $lista_reconstruida->agregar($texto_recuperado);

        # Reportar
        print "Nodo $indice (desde $nombre_archivo):\n";
        print "  Leído      : $tam_comprimido bytes comprimidos\n";
        print "  Recuperado : $tam_recuperado bytes\n";
        print "  Texto      : \"" . substr($texto_recuperado, 0, 60) . "...\"\n";
        print "\n";

        $indice++;
    }

    
    # mostrar el estado final de la lista reconstruida
    
    # Imprimir el contenido completo de cada nodo (verificación)
    print "CONTENIDO COMPLETO DE LA LISTA RECONSTRUIDA:\n";

    my $nodo = $lista_reconstruida->{head};
    # my $nodo_actual = $lista->{head};
    my $i    = 0;

    while (defined $nodo) {
        print "----> NODO $i \n";
        print $nodo->get_data() . "\n\n";
        $nodo = $nodo->get_next();
        $i++;
    }

    print "\n\n\n";
    #$lista_reconstruida ->imprimir_info();
    Graficar->generador_dot($lista_reconstruida, "lista_final.dot");
    Graficar->graficar_imagen($lista_reconstruida, "lista_final");

}
main() unless caller;