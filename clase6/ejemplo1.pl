
use strict;
use warnings;

use FindBin;
use lib "$FindBin::Bin";

# Importar nuestros módulos BST
use bst::bst;
use bst::graficar;

# Constantes para no escribir el nombre completo del paquete
use constant BST      => 'bst::bst';
use constant Graficar => 'bst::graficar';

sub main {

    # 1. Crear el árbol
    my $arbol = BST->new();

    print "arbol vacío al inicio? " . ($arbol->is_empty() ? "SÍ" : "NO") . "\n\n";


# metemos los datos al arbol
    $arbol->insertar(20);
    $arbol->insertar(15);
    $arbol->insertar(28);
    $arbol->insertar(6);
    $arbol->insertar(17);
    $arbol->insertar(16);
    $arbol->insertar(19);
    $arbol->insertar(32);



    print "Tamaño del árbol: " . $arbol->get_size() . " nodos\n\n";

    #  Mostrar estructura
    $arbol->imprimir_arbol();

    # Recorridos
    print "\nRecorridos del arbol:\n\n";

    $arbol->recorrido_preorden();    # 20, 15, 6, 17, 16, 19, 28 , 32
        $arbol->recorrido_inorden();     # 6,  15, 16, 17, 19, 20, 28 , 32
            $arbol->recorrido_postorden();   # 6,  16, 19, 17, 15,, 32, 28, 20,

    # buscar
    my $resultado;

    $resultado = $arbol->buscar(16);
    print "Buscar 16: " . (defined($resultado) ? "ENCONTRAO'" : "No encontrado pipiip") . "\n";

    $resultado = $arbol->buscar(20);
    print "Buscar 20: " . (defined($resultado) ? "ENCONTRADO'" : "No encontrado :(") . "\n";

    $resultado = $arbol->buscar(19);
    print "Buscar 19: " . (defined($resultado) ? "ENCONTRADO'" : "No encontrado") . "\n";


    # Graficar
    Graficar->graficar($arbol, "1_bst_completo");

    # eliminar una hoja --> un nodo que ya no tiene hijos
    $arbol->eliminar(19);
    Graficar->graficar($arbol, "2_bst_borrar_hoja");

    $arbol->insertar(19);
    
    # eliminar una nodo con 1 hijo ---> nodo padre de un hijos --> es como un salto
    $arbol->eliminar(28);
    Graficar->graficar($arbol, "3_bst_borrar_nodo_padre_1hijo");

    $arbol->insertar(28);
    # caso importante para ver como funciona la eliminación de un nodo con 2 hijos
    # posible pregunta en la calificación ;) guinio guinio
    $arbol->eliminar(15);
    Graficar->graficar($arbol, "4_bst_borrar_nodo_padre_2hijos");

    $arbol->insertar(18);
    $arbol->insertar(5);
    $arbol->insertar(8);
    $arbol->insertar(15);
    Graficar->graficar($arbol, "5_bst_pruebas");
    
    
    $arbol->eliminar(20);
    Graficar->graficar($arbol, "6_bst_borrar_root");

}

main() unless caller;