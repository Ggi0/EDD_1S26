
use strict;
use warnings;

use FindBin;
use lib "$FindBin::Bin";

use matriz_dispersa::MatrizDispersa;
use matriz_dispersa::Graficar;
use matriz_dispersa::Pelicula;

use constant MatrizDispersa => 'matriz_dispersa::MatrizDispersa';
use constant Graficar       => 'matriz_dispersa::Graficar';
use constant Pelicula       => 'matriz_dispersa::Pelicula';

# MAPEO de indices:
#
#   Directores (filas):          Generos (columnas):
#     0 = Francis Ford Coppola     0 = Drama
#     1 = Quentin Tarantino        1 = Thriller
#     2 = Christopher Nolan        2 = Ciencia Ficcion
#     3 = Peter Jackson            3 = Fantasia

sub main {
    print "  Matriz Dispersa con Peliculas\n";
    print "  Filas = Directores | Columnas = Generos\n";


    # 1. CREAR OBJETOS PELICULA
    # Los objetos son independientes de la matriz. La matriz solo guarda
    # una REFERENCIA a cada objeto en el campo "valor" del NodoDato.

    my $el_padrino = Pelicula->new(
        "El Padrino",
        "Francis Ford Coppola",
        175,
        1972,
        "Drama"
    );

    my $pulp_fiction = Pelicula->new(
        "Pulp Fiction",
        "Quentin Tarantino",
        154,
        1994,
        "Thriller"
    );

    my $memento = Pelicula->new(
        "Memento",
        "Christopher Nolan",
        113,
        2000,
        "Thriller"
    );

    my $inception = Pelicula->new(
        "Inception",
        "Christopher Nolan",
        148,
        2010,
        "CienciaFiccion"
    );

    my $esdla = Pelicula->new(
        "El Señor de los Anillos",
        "Peter Jackson",
        178,
        2001,
        "Fantasia"
    );

    my $django = Pelicula->new(
        "Django Unchained",
        "Quentin Tarantino",
        165,
        2012,
        "Drama"
    );

    $el_padrino->imprimir_info();

    #  CREAR LA MATRIZ (4 directores x 4 generos)
    my $M = MatrizDispersa->new(4, 4);

    # metemos las peliculas a la lista
    $M->insertar(0, 0, $el_padrino);      # Coppola- Drama
    $M->insertar(1, 1, $pulp_fiction);    # Tarantino- Thriller
    $M->insertar(2, 1, $memento);         # Nolan- Thriller
    $M->insertar(2, 2, $inception);       # Nolan- Ciencia Ficcion
    $M->insertar(3, 3, $esdla);           # Jackson-Fantasia
    $M->insertar(1, 0, $django);          # Tarantino-Drama


    # buscar pelicula
    my $nodo = $M->obtener(2, 2);
    if (defined $nodo) {
        my $pelicula = $nodo->get_valor();
        $pelicula->imprimir_info();
    }

    # RECORRER LA COLUMNA 1 (todas las peliculas de genero Thriller)
    _imprimir_columna($M, 1, "Thriller");

    # RECORRER LA FILA 1 (todas las peliculas de Tarantino)
    _imprimir_fila($M, 1, "Quentin Tarantino");


    Graficar->graficar($M, "ejemplo2");
}

# AUXILIARES DE EJEMPLO
# _imprimir_columna($M, $col_idx, $nombre_col)
sub _imprimir_columna {
    my ($M, $col_idx, $nombre_col) = @_;

    print "  Genero '$nombre_col' (columna $col_idx):\n";

    # Buscamos la cabecera de la columna directamente
    my $cab = $M->{lista_cols};
    while (defined $cab && $cab->get_label() != $col_idx) {
        $cab = $cab->get_next();
    }

    unless (defined $cab) {
        print "    (sin peliculas en este genero)\n\n";
        return;
    }

    # Recorrer hacia abajo (down)
    my $nodo = $cab->get_down();
    while (defined $nodo) {
        my $f   = $nodo->get_fila();
        my $pel = $nodo->get_valor();
        print "    Fila $f: ", $pel->get_nombre(), " (", $pel->get_anio(), ")\n";
        $nodo = $nodo->get_down();
    }
    print "\n";
}

# _imprimir_fila($M, $fila_idx, $nombre_fila)
sub _imprimir_fila {
    my ($M, $fila_idx, $nombre_fila) = @_;

    print "  Director '$nombre_fila' (fila $fila_idx):\n";

    my $cab = $M->{lista_filas};
    while (defined $cab && $cab->get_label() != $fila_idx) {
        $cab = $cab->get_next();
    }

    unless (defined $cab) {
        print "    (sin peliculas registradas)\n\n";
        return;
    }

    my $nodo = $cab->get_right();
    while (defined $nodo) {
        my $c   = $nodo->get_col();
        my $pel = $nodo->get_valor();
        print "    Col $c: ", $pel->get_nombre(), " (", $pel->get_anio(), ")\n";
        $nodo = $nodo->get_right();
    }
    print "\n";
}

main() unless caller;