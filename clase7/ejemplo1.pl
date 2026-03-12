

use strict;
use warnings;

use FindBin;
use lib "$FindBin::Bin";

use avl::avl;
use avl::graficar;

use constant AVL => 'avl::avl';
use constant Graficar => 'avl::graficar';

# llamabos al bst para ver comparaciones
use lib "$FindBin::Bin/../clase6";
use bst::bst;
use bst::graficar;

use constant BST => 'bst::bst';
use constant Graficar_bst => 'bst::graficar';


sub main {

    my $arbol_avl = AVL->new();
    my $arbol_bst = BST->new();

    print "Arbol vacio al inicio? " . ($arbol_avl->is_empty() ? "Simonchos" : "Nomonchos") . "\n\n";


    
    # balanceo 1: Provocar rotacion LL (doble carga a la izquierda)
    #
    #      30          <- FE = -2 (desbalanceado)
    #     /
    #    20            <- FE = -1
    #   /
    #  10
    #
    # El nodo 30 tiene FE = -2 y su hijo izquierdo (20) tiene FE = -1.
    # Caso LL -> rotacion simple a la DERECHA en el nodo 30.
    # Resultado:
    #
    #    20
    #   /  \
    #  10   30        <- todo balanceado, FE de cada nodo en {-1,0,+1}
    
# primero miremos que sucede en el bst
    $arbol_bst->insertar(30);
    $arbol_bst->insertar(20);
    $arbol_bst->insertar(10); 

    $arbol_avl->insertar(30);
    $arbol_avl->insertar(20);
    $arbol_avl->insertar(10);   #aqui se va aplicar el LL

    Graficar_bst->graficar($arbol_bst, "1_bst_desbalanceado"); # este se genera en `clase6/reportes/ ` pero lo traje a la carpeta actual de la clase7
    Graficar->graficar($arbol_avl, "1_avl_rotacion_LL");


    
    # Balanceo 2: Provocar rotacion RR (doble carga a la derecha)
    #
    #    20
    #   /  \
    #  10   30        <- FE = -2 despues de agregar 40 y 50? No, es el 20 que se desbalancea
    #         \
    #          40
    #            \
    #             50
    #
    # El nodo 30 (hijo de 20) queda con FE = +2 y su hijo derecho (40) con FE = +1.
    # Caso RR -> rotacion simple a la IZQUIERDA.

    my $arbol_bst2 = BST->new();
    $arbol_bst2->insertar(20);
    $arbol_bst2->insertar(10);
    $arbol_bst2->insertar(30);
    $arbol_bst2->insertar(40);
    $arbol_bst2->insertar(50);

            $arbol_avl->insertar(40);
            $arbol_avl->insertar(50);   # aqui se va aplicar rotacion RR

    Graficar->graficar($arbol_avl, "2_avl_rotacion_RR");
    Graficar_bst->graficar($arbol_bst2, "2_bst_desbalanceado_RR");


    
    # balanceo 3: Provocar rotacion LR (codo izquierda-derecha)
    #
    # Insertamos 25.
    # El nodo 40 o alguno de sus ancestros quedara con FE = -2,
    # pero el hijo izquierdo de ese nodo tendra FE = +1 (pesa a la derecha).
    # Eso es el caso LR: primero rotar izquierda el hijo, luego derecha el nodo.
    my $arbol_bst3 = BST->new();
    $arbol_bst3->insertar(20);
    $arbol_bst3->insertar(10);
    $arbol_bst3->insertar(40);
    $arbol_bst3->insertar(30);
    $arbol_bst3->insertar(50);
    $arbol_bst3->insertar(25);
    
                $arbol_avl->insertar(25);   # puede provocar rotacion LR

    Graficar->graficar($arbol_avl, "3_avl_rotacion_LR");
    Graficar_bst->graficar($arbol_bst3, "3_bst_desbalanceado_LR");



    
    # Mas inserciones para ver el arbol_avl crecer balanceado
    $arbol_avl->insertar(35);
    $arbol_avl->insertar(5);
    $arbol_avl->insertar(15);
    $arbol_avl->insertar(45);

    # despues de estas inseciones el arbol queda asi:
    #               30
    #             /    \
    #           20       40
    #        /    \     /  \
    #       10    25   35   50
    #       / \             /
    #      5   15          45
    Graficar->graficar($arbol_avl, "4_avl_arbol_completo");


    
    # RECORRIDOS
    # El inorden siempre da los valores en orden ascendente,
    # independientemente de cuantas rotaciones haya habido.

    # esto le toca a ustedes (es lo mismo que en el bst ._.)
    # $arbol_avl->recorrido_inorden();    
    # $arbol_avl->recorrido_preorden();
    # $arbol_avl->recorrido_postorden();

    print "\nAltura e informacion de cada nodo (inorden):\n";
    $arbol_avl->imprimir_arbol();       # muestra valor, altura y FE de cada nodo


    
    # BUSQUEDA
    # es lo mismo que el bst

    
    # ELIMINACIONES con balanceo    ->   lo importante es que después de cada recursión se vuelve a balancear
    # Eliminar una hoja
    $arbol_avl->eliminar(5);
    Graficar->graficar($arbol_avl, "5_avl_borrar_hoja");

    # Eliminar nodo con un hijo
    $arbol_avl->eliminar(45);
    Graficar->graficar($arbol_avl, "6_avl_borrar_un_hijo");

    # Eliminar nodo con dos hijos (la raiz o un nodo interior importante)
    $arbol_avl->eliminar(30);
    Graficar->graficar($arbol_avl, "7_avl_borrar_dos_hijos");

    $arbol_avl->recorrido_inorden();
}

main() unless caller;