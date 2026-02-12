use strict;
use warnings;

use FindBin;
use lib "$FindBin::Bin";

use lista_circular::ListaCircular;
use lista_circular::Graficar;

use lista_circular::Pelicula;

use constant ListaCircular => 'lista_circular::ListaCircular';
use constant Graficar => 'lista_circular::Graficar';
use constant Pelicula => 'lista_circular::Pelicula';

sub ejemplo2 {

    print"======== peliculas ==========\n";

 # Crear varias peliculas
    my $pelicula1 = Pelicula->new(
        "El Padrino",           
        "Francis Ford Coppola",
        175,                    
        1972                    
    );
    
    my $pelicula2 = Pelicula->new(
        "Pulp Fiction",
        "Quentin Tarantino",
        154,
        1994
    );
    
    my $pelicula3 = Pelicula->new(
        "El Señor de los Anillos",
        "Peter Jackson",
        178,
        2001
    );
    
    my $pelicula4 = Pelicula->new(
        "Inception",
        "Christopher Nolan",
        148,
        2010
    );
    
    my $pelicula5 = Pelicula->new(
        "pelicula test1",
        "Bong Joon-ho",
        132,
        2019
    );


    $pelicula1->imprimir_info();

    my $lista_peliculas = ListaCircular->new();

    # $lista_peliculas->imprimir_lista();
    
    $lista_peliculas->agregar($pelicula1);
    $lista_peliculas->agregar($pelicula2);
    $lista_peliculas->agregar($pelicula3);
    $lista_peliculas->agregar($pelicula4);
    $lista_peliculas->agregar($pelicula5);

# $lista_peliculas->imprimir_pelicula();

    $lista_peliculas->imprimir_lista();

    Graficar->graficar($lista_peliculas, "ejemplo2");



}


ejemplo2() unless caller;
