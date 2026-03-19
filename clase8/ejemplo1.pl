use strict;
use warnings;

use FindBin;
use lib "$FindBin::Bin";

use btree::btree;
use btree::graficar;

use constant BTree    => 'btree::btree';
use constant Graficar => 'btree::graficar';


sub main {

    
    # PARTE 1: Arbol B de ORDEN 3 (arbol "2-3")
    #   - Max 2 claves por nodo, max 3 hijos
    #   - Min 1 clave por nodo (excepto raiz), min 2 hijos
    #   - Es el orden mas pequeno util, muy bueno para ver splits
    

    print "ARBOL B DE ORDEN 3\n";

    my $arbol3 = BTree->new(3);

    # Insertar los valores 1..7 para provocar varios splits
    # Con orden 3, cada nodo tiene maximo 2 claves.
    # Al insertar el 3er valor en un nodo, se divide.
    #
    # Secuencia esperada de eventos:
    #   Insertar 10: raiz = [10]
    #   Insertar 20: raiz = [10, 20]
    #   Insertar 30: raiz se llena [10,20,30] -> split! nueva raiz=[20], hijos=[10],[30]
    #   Insertar 5:  va a hoja [10] -> [5,10]
    #   Insertar 25: va a hoja [30] -> [25,30]
    #   Insertar 15: va a hoja [5,10] se llena [5,10,15] -> split!
    #   etc.

    $arbol3->insertar(10);
    $arbol3->insertar(20);
    $arbol3->insertar(30);  # primer split de raiz
    Graficar->graficar($arbol3, "01_orden3_primer_split");

    $arbol3->insertar(5);
    $arbol3->insertar(25);
    $arbol3->insertar(15);
    Graficar->graficar($arbol3, "02_orden3_mas_inserciones");

    $arbol3->insertar(35);
    $arbol3->insertar(3);
    $arbol3->insertar(7);
    Graficar->graficar($arbol3, "03_orden3_arbol_completo");


    print "\n----- Busquedas ---\n";
    $arbol3->buscar(20);   # debe encontrar
    $arbol3->buscar(99);   # no debe encontrar

    # Verificar esta()
    print "¿Esta 15 en el arbol? " . ($arbol3->esta(15) ? "Si" : "No") . "\n";
    print "¿Esta 99 en el arbol? " . ($arbol3->esta(99) ? "Si" : "Nop") . "\n\n";

    print "\n--- Impresion nivel por nivel ---\n";
    $arbol3->imprimir_arbol();

    # Eliminaciones
    print "\n--- Eliminaciones ---\n";

    # Eliminar una hoja simple
    $arbol3->eliminar(3);
    Graficar->graficar($arbol3, "04_orden3_borrar_hoja");

    # Eliminar valor de nodo interno (se reemplaza con predecesor)
    $arbol3->eliminar(20);
    Graficar->graficar($arbol3, "05_orden3_borrar_interno");

    # Mas eliminaciones para forzar redistribucion/fusion
    $arbol3->eliminar(7);
    $arbol3->eliminar(10);
    Graficar->graficar($arbol3, "06_orden3_despues_fusiones");



    
    # PARTE 2: Arbol B de ORDEN 5
    #   - Max 4 claves por nodo, max 5 hijos
    #   - Min 2 claves por nodo, min 3 hijos    
    print "-------> ARBOL B DE ORDEN 5\n";

    my $arbol5 = BTree->new(5);

    # Insertar 15 valores para ver varios niveles y splits
    my $i = 0;
    while ($i < 15) {
        my $val = ($i * 7 + 3) % 100;  # valores pseudoaleatorios para que sea interesante
        $arbol5->insertar($val);
        $i++;
    }

    Graficar->graficar($arbol5, "07_orden5_insertados");

    # Insertar algunos mas para ver el arbol crecer
    $arbol5->insertar(50);
    $arbol5->insertar(51);
    $arbol5->insertar(52);
    $arbol5->insertar(53);
    $arbol5->insertar(54);
    Graficar->graficar($arbol5, "08_orden5_mas_inserciones");


    print "\n--- Impresion nivel por nivel orden 5 ---\n";
    $arbol5->imprimir_arbol();

    # Eliminaciones en el arbol de orden 5
    $arbol5->eliminar(50);
    $arbol5->eliminar(51);
    $arbol5->eliminar(52);
    Graficar->graficar($arbol5, "09_orden5_despues_eliminaciones");

    
    # PARTE 3: Arbol B de ORDEN 4

    print "ARBOL B DE ORDEN 4\n";
    my $arbol4 = BTree->new(4);

    # Insertar en orden para ver como se divide
    foreach my $val (10, 20, 30, 40, 50, 60, 70, 80, 90, 100, 15, 25, 35) {
        $arbol4->insertar($val);
    }

    Graficar->graficar($arbol4, "10_orden4_arbol_completo");
    $arbol4->imprimir_arbol();
}

main() unless caller;