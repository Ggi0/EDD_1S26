#!/usr/bin/perl

use strict;
use warnings;

use FindBin;
use lib "$FindBin::Bin";

use D_linked_list::D_linkedList;
use constant D_linkedList => 'D_linked_list::D_linkedList';

use D_linked_list::Graficar;
use constant Graficar => 'D_linked_list::Graficar';


sub main {
    
    my $lista = D_linkedList->new();
    print "¿Está vacía? " . ($lista->is_empty() ? "SÍ" : "NO") . "\n";
    $lista->imprimir_lista();
    
    Graficar->graficar($lista, "test1_vacia");
    print "\n";

    # Agregar 
    print "TEST 2: Agregar elementos\n";
    
    $lista->agregar(101);
    $lista->agregar(102);
    $lista->agregar(103);
    $lista->agregar(104);
    $lista->agregar(105);

    $lista->imprimir_lista();
    
    Graficar->graficar($lista, "test2_agregar");
    print "\n";

    # Agregar al final 
    print "TEST 3: Agregar elementos al final\n";
    
    $lista->agregar_final(106);
    $lista->agregar_final(107);
    $lista->agregar_final(108);
    
    $lista->imprimir_lista();
    
    Graficar->graficar($lista, "test3_agregarFinal");
    print "\n";


    # Eliminar elementos
    print "TEST 4: Eliminar elementos\n";
    
    print "Antes de eliminar:\n";
    $lista->imprimir_lista();
    
    print "\nEliminando 150 (no existe):\n";
    $lista->delete(150);
    
    print "\nEliminando 101 (el head):\n";
    $lista->delete(101);
    $lista->imprimir_lista();
    
    print "Eliminando 108 (el tail):\n";
    $lista->delete(108);
    $lista->imprimir_lista();
    
    print "Eliminando 103 (en medio):\n";
    $lista->delete(105);
    $lista->imprimir_lista();
    
    Graficar->graficar($lista, "test4_eliminar");
    print "\n";

    # TEST 5: Buscar elementos
    print "TEST 5: Buscar elementos\n";
    
    my @buscar = (102, 104, 105, 999);
    foreach my $val (@buscar) {
        my $encontrado = $lista->buscar($val);
        print "¿Existe $val? " . ($encontrado ? "SÍ" : "NO") . "\n";
    }
    print "\n";

    # TEST 6: Tamaño de la lista
    print "TEST 6: Tamaño de la lista\n";
    
    my $tam = $lista->tamanio();
    print "Tamaño actual: $tam nodos\n";
    $lista->imprimir_lista();
    print "\n";

}

main() unless caller;