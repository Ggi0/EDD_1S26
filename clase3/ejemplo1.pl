use strict;
use warnings;

use FindBin;
use lib "$FindBin::Bin";

use lista_circular::ListaCircular;
use lista_circular::Graficar;

use constant ListaCircular => 'lista_circular::ListaCircular';
use constant Graficar => 'lista_circular::Graficar';

sub main {

    print "\n\n\n";

    my $lista_prueba = ListaCircular->new();

    print $lista_prueba->is_empty();

    $lista_prueba->delete(6);

    $lista_prueba->agregar(1);

    $lista_prueba->delete(1);

    $lista_prueba->agregar(2);
    $lista_prueba->agregar(3);
    $lista_prueba->agregar(4);

    $lista_prueba->agregar(5);
    $lista_prueba->agregar(6);
    $lista_prueba->agregar(7);


        $lista_prueba->delete(6);


    print $lista_prueba->tamanio();


    $lista_prueba->agregar("hola");
    $lista_prueba->agregar("juan");

    $lista_prueba->imprimir_lista();



    Graficar->graficar($lista_prueba, "ejemplo1");


print "\n\n\n";

}


main() unless caller;
