

use strict;
use warnings;

use FindBin;
use lib "$FindBin::Bin";

use grafo::Grafo;
use grafo::Graficar;

use constant Grafo    => 'grafo::Grafo';
use constant Graficar => 'grafo::Graficar';

sub main {

    # 1 CREAR EL GRAFO
    my $grafo = Grafo->new();

    # 2 AGREGAR VERTICES
    # Cada vertice tiene:
    #   - Un ID unico (usamos el numero como string para el ID)
    #   - Un dato (aqui es el mismo numero entero)
    $grafo->agregar_vertice("1", 1);
    $grafo->agregar_vertice("2", 2);
    $grafo->agregar_vertice("3", 3);
    $grafo->agregar_vertice("4", 4);
    $grafo->agregar_vertice("5", 5);


    # 3 AGREGAR ARISTAS
    # Cada llamada conecta DOS vertices en AMBAS DIRECCIONES.
    # Esto es lo que hace al grafo "no dirigido".
    #   agregar_arista("1", "2") hace:
    #     - agrega "2" a la lista de adyacencia de "1"
    #     - agrega "1" a la lista de adyacencia de "2"
    $grafo->agregar_arista("1", "2");
    $grafo->agregar_arista("1", "3");
    $grafo->agregar_arista("2", "3");
    $grafo->agregar_arista("2", "4");
    $grafo->agregar_arista("3", "4");
    $grafo->agregar_arista("4", "5");

    # 3 IMPRIMIR EL GRAFO
    # Muestra la lista de adyacencia de cada vertice
    $grafo->imprimir_grafo();

    # BUSCAR UN VERTICE
    print " Buscando vertice '3' \n";
    my $encontrado = $grafo->buscar_vertice("3");
    if (defined $encontrado) {
        print "  Vertice encontrado: ID=" . $encontrado->get_id() .
              ", dato=" . $encontrado->get_data() . "\n\n";
    }

    # SUGERENCIAS ---> (BFS 2 saltos)
    # Para el vertice "1":
    #   Sus amigos directos son: 2, 3
    #   Amigos de 2: 1 (ya amigo), 3 (ya amigo), 4 -> NUEVO
    #   Amigos de 3: 1 (ya amigo), 2 (ya amigo), 4 (ya visto)
    #   Resultado: sugerencia = 4
    print " BFS 2 saltos: sugerencias para vertice '1' \n";
    $grafo->imprimir_sugerencias("1");

    # Para el vertice "4":
    #   Sus amigos directos son: 2, 3, 5
    #   Amigos de 2: 1 -> NUEVO, 3 (ya amigo), 4 (es el origen)
    #   Amigos de 3: 1 (ya visto), 2 (ya amigo), 4 (origen)
    #   Amigos de 5: 4 (origen)
    #   Resultado: sugerencia = 1
    print " BFS 2 saltos: sugerencias para vertice '4' \n";
    $grafo->imprimir_sugerencias("4");

    # 7: ELIMINAR UNA ARISTA
    print " Eliminando arista 2 <---> 3 \n";
    $grafo->eliminar_arista("2", "3");
    $grafo->imprimir_grafo();

    # 8 ELIMINAR UN VERTICE
    # Al eliminar el vertice "5", se limpia su referencia de la lista de adyacencia de "4" automaticamente.
    print " Eliminando vertice '5' \n";
    $grafo->eliminar_vertice("5");
    $grafo->imprimir_grafo();


    Graficar->graficar($grafo, "1_ejemplo1_grafo");
    Graficar->graficar_lista_adyacencia($grafo, "1_ejemplo1");

}

main();