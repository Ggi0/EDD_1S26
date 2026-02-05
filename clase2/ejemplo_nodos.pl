use strict;
use warnings;


# importación
use FindBin;
use lib "$FindBin::Bin";   # <-- agrega "clase2" a @INC

use linked_list::Nodo; # linked_list/Nodo.pm

use constant Nodo => 'linked_list::Nodo'; # alias para llamar al objeto `Nodo`
# use aliased 'linked_list::Nodo';

# IMPORTANTE: Esete es solo un ejemplo de como podemos manejar Nodos 
#             como se ve usando get y set
#             y la diferencia de como se haría sin la encapsulación.

sub main_nodos {
    print(" hola bienvenido al ejmplo de como manejar los nodos \n\n");

    # con set y get
    my $Nodo1 = Nodo->new(10);
    $Nodo1->imprimir_nodo();

    $Nodo1->set_data(20);
    $Nodo1->imprimir_nodo();

    print $Nodo1->to_string();

    # sin get ni set:
    print "$Nodo1->{data}\n";
    $Nodo1->{data} = 60;
    $Nodo1->imprimir_nodo();

    my $Nodo2 = Nodo->new(90);

    $Nodo1->{next} = $Nodo2; #Nodo->new(90);
    print $Nodo1->to_string();

}

main_nodos() unless caller; # esto se asegur que se ejecute solo si corremos el main_nodos.pl directamente
