

use strict;
use warnings;

use FindBin;
use lib "$FindBin::Bin";

use grafo::Grafo;
use grafo::Graficar;
use grafo::Persona;

use constant Grafo    => 'grafo::Grafo';
use constant Graficar => 'grafo::Graficar';
use constant Persona  => 'grafo::Persona';

sub main {

    # hacienod a las personas
    my $alice    = Persona->new("Alice Lopez",    22, "Ingenieria en Sistemas");
    my $bob      = Persona->new("Bob Ramirez",    24, "Ciencias de la Computacion");
    my $carlos   = Persona->new("Carlos Mendez",  21, "Ingenieria en Sistemas");
    my $Ale    = Persona->new("Ale Perez",    23, "Matematica Aplicada");
    my $elena    = Persona->new("Elena Torres",   22, "Ingenieria Civil");
    my $fernando = Persona->new("Fernando Ruiz",  25, "Arquitectura");

    $alice->imprimir_info();
    $bob->imprimir_info();

    # hacer el grafo
    my $grafo = Grafo->new();

    # agregar al grafo las personas
    $grafo->agregar_vertice("alice",    $alice);
    $grafo->agregar_vertice("bob",      $bob);
    $grafo->agregar_vertice("carlos",   $carlos);
    $grafo->agregar_vertice("Ale",    $Ale);
    $grafo->agregar_vertice("elena",    $elena);
    $grafo->agregar_vertice("fernando", $fernando);

    # Cada arista representa una amistad mutua.
    $grafo->agregar_arista("alice",  "bob");
    $grafo->agregar_arista("alice",  "carlos");
    $grafo->agregar_arista("bob",    "carlos");
    $grafo->agregar_arista("bob",    "Ale");
    $grafo->agregar_arista("bob",    "elena");
    $grafo->agregar_arista("carlos", "fernando");

    $grafo->imprimir_grafo();

# buscar
    my $nodo_bob = $grafo->buscar_vertice("bob");
    if (defined $nodo_bob) {
        my $persona_bob = $nodo_bob->get_data();
        print "  Encontrado: " . $persona_bob->get_nombre() . "\n";
        $nodo_bob->imprimir_vecinos();
    }

    # SUGERENCIAS DE AMISTAD PARA ALICE
    # La funcion BFS de 2 saltos encuentra:
    #   - Amigos directos de alice: {bob, carlos}
    #   - Amigos de bob:    {alice(ori), carlos(ya amigo), Ale(SUGERENCIA), elena(SUGERENCIA)}
    #   - Amigos de carlos: {alice(ori), bob(ya amigo), fernando(SUGERENCIA)}
    # Resultado: Ale, elena, fernando
    print " Sugerencias de amistad para Alice \n";
    $grafo->imprimir_sugerencias("alice");

    # Tambien podemos imprimir el nombre de la persona en cada sugerencia
    print " Sugerencias detalladas para Alice \n";
    my $sugerencias = $grafo->bfs_dos_saltos("alice");
    my $actual      = $sugerencias;
    while (defined $actual) {
        my $nodo    = $actual->get_data();
        my $persona = $nodo->get_data();   # get_data() del NodoGrafo = objeto Persona
        print "  Quizas conozcas a: " . $persona->get_nombre() .
              " (" . $persona->get_carrera() . ")\n";
        $actual = $actual->get_siguiente();
    }
    print "\n";

    # SUGERENCIAS PARA Ale
    # Ale solo conoce a Bob.
    # Amigos de Bob: alice, carlos, elena -> todos son sugerencias para Ale
    print " Sugerencias de amistad para Ale \n";
    $grafo->imprimir_sugerencias("Ale");

    # ELIMINAR UNA AMISTAD
    # Alice y Bob ya no son amigos.
    print " Eliminando amistad Alice <----> Bob \n";
    $grafo->eliminar_arista("alice", "bob");
    $grafo->imprimir_grafo();

    # Las sugerencias de Alice cambian: ahora Bob podria ser sugerencia
    # a traves de Carlos (alice -> carlos -> bob)
    $grafo->imprimir_sugerencias("alice");

    # ELIMINAR UN VERTICE
    # Fernando se va de la red social.
    # Sus aristas (con Carlos) se limpian automaticamente.
    $grafo->eliminar_vertice("fernando");
    $grafo->imprimir_grafo();

    # graficacion
    Graficar->graficar($grafo, "2_ejemplo2_grafo");
    Graficar->graficar_lista_adyacencia($grafo, "2_ejemplo2");

}

main();