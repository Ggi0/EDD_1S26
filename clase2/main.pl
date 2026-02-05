use strict;
use warnings;


use FindBin;
use lib "$FindBin::Bin";   # <-- agrega "clase2" a @INC

use linked_list::LinkedList;
use constant LinkedList => 'linked_list::LinkedList';

use linked_list::Graficar;
use constant Graficar => 'linked_list::Graficar';


sub main{

    my $lista = LinkedList->new();

    print $lista->is_empty() . "\n";
    $lista->imprimir_lista();
    

    $lista->agregar(101);
    $lista->agregar(102);
    $lista->agregar(103);
    $lista->agregar(104);

    Graficar->generador_dot($lista, "lista_simple.dot");
    Graficar->graficar_imagen($lista, "lista_simple");
    
    print $lista->is_empty() . "\n";
    
    $lista->imprimir_lista();

    $lista->delete(102);
    $lista->imprimir_lista(101);

    Graficar->generador_dot($lista, "lista_simple.dot");
    Graficar->graficar_imagen($lista, "lista_simple");

    
}

main() unless caller; # esto se asegur que se ejecute solo si corremos el main.pl directamente
