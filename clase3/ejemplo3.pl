use strict;
use warnings;

use FindBin;
use lib "$FindBin::Bin";

use lista_circular::ListaCircular;
use lista_circular::Graficar;

use lib "$FindBin::Bin/../clase2";
use linked_list::LinkedList;


use constant ListaCircular => 'lista_circular::ListaCircular';
use constant Graficar => 'lista_circular::Graficar';

use constant LinkedList => 'linked_list::LinkedList';


sub ejemplo3 {

    print"======== lista de listas ==========\n";

    my $lista_1 = LinkedList->new();

    $lista_1->agregar("A");
    $lista_1->agregar("B");
    $lista_1->agregar("C");

    $lista_1->imprimir_info();

    my $lista_2 = LinkedList->new();

    $lista_2->agregar("1");
    $lista_2->agregar("2");
    $lista_2->agregar("3");

    $lista_2->imprimir_info();

    my $lista_3 = LinkedList->new();

    $lista_3->agregar("café");
    $lista_3->agregar("azul");
    $lista_3->agregar("celeste");
    $lista_3->agregar("negrp");

    $lista_3->imprimir_info();


    my $lista_circular = ListaCircular->new();
    $lista_circular->agregar($lista_1);
    $lista_circular->agregar($lista_2);
    $lista_circular->agregar($lista_3);

    $lista_circular->imprimir_lista();

    Graficar->graficar($lista_circular, "ejemplo3");

}


ejemplo3() unless caller;
