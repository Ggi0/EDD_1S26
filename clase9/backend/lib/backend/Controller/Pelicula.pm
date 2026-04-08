package backend::Controller::Peliculas;


use Mojo::Base 'Mojolicious::Controller', -signatures;



# podemos importar desde lib/lista_circular/...
use lista_circular::ListaCircular;
use lista_circular::Pelicula;



# En Perl, una variable 'our' a nivel de paquete persiste
# mientras el proceso esté corriendo. Mojolicious (morbo) mantiene
# un proceso vivo, así que la lista persiste entre requests.
our $lista = lista_circular::ListaCircular->new();

use constant REPORTES_DIR => 'public/reportes';



# GET /api/home
sub home ($c) {
    $c->render(json => {
        mensaje => 'Bienvenido a la API de Películas con Lista Circular',
        rutas   => {
            registrar => 'POST /api/registrar_pelis',
            ver       => 'GET /api/ver_pelis',
            graficar  => 'GET /api/graficar',
        },
        estructura => 'Lista Circular Enlazada',
    });
}



# POST /api/registrar_pelis
# El frontend envía un JSON así:
# {
#   "nombre": "Inception",
#   "director": "Christopher Nolan",
#   "duracion": 148,
#   "anio": 2010
# }
#
# $c->req->json  ->  decodifica el body JSON a un hash de Perl
sub registrar ($c) {

    # Leer el cuerpo de la petición como JSON
    my $datos = $c->req->json;

    
    # VALIDACIÓN: verificar que llegaron los campos necesarios
    unless (defined $datos->{nombre} && defined $datos->{director}
         && defined $datos->{duracion} && defined $datos->{anio}) {

        # render con status => 400 devuelve un error HTTP 400 Bad Request
        return $c->render(
            status => 400,
            json   => {
                error   => 'Faltan campos requeridos',
                campos  => ['nombre', 'director', 'duracion', 'anio'],
            }
        );
    }

    
    # CREAR EL OBJETO PELÍCULA y AGREGARLO A LA LISTA CIRCULAR
    my $pelicula = lista_circular::Pelicula->new(
        $datos->{nombre},
        $datos->{director},
        $datos->{duracion},
        $datos->{anio},
    );

    # Agregamos el objeto Pelicula (no texto crudo) al nodo de la lista
    $lista->agregar($pelicula);

    
    # RESPONDER con los datos de confirmación
    
    $c->render(
        status => 201,    # 201 Created = recurso creado exitosamente
        json   => {
            mensaje   => 'Película registrada exitosamente',
            pelicula  => {
                nombre   => $datos->{nombre},
                director => $datos->{director},
                duracion => $datos->{duracion},
                anio     => $datos->{anio},
            },
            total_en_lista => $lista->tamanio(),
        }
    );
}



# GET /api/ver_pelis
sub ver ($c) {

    # Si la lista está vacía, respondemos con arreglo vacío
    if ($lista->is_empty()) {
        return $c->render(json => {
            peliculas => [],
            total     => 0,
            mensaje   => 'No hay películas registradas aún',
        });
    }

    
    # RECORRER la lista circular y construir un arreglo de hashes
    
    # No podemos enviar objetos Perl directamente como JSON,
    # debemos convertirlos a estructuras de datos básicas (hashes/arrays)
    my @peliculas_json = ();

    my $actual = $lista->{head};    # empezamos desde el HEAD

    # do-while: ejecuta al menos una vez (para procesar el HEAD)
    do {
        my $peli = $actual->get_data();    # obtenemos el objeto Pelicula

        # Construimos un hash plano con los datos de la película
        push @peliculas_json, {
            nombre   => $peli->get_nombre(),
            director => $peli->get_director(),
            duracion => $peli->get_duracion(),
            anio     => $peli->get_anio(),
        };

        $actual = $actual->get_next();     # avanzamos al siguiente nodo

    } while ($actual != $lista->{head});   # hasta dar la vuelta completa

    # render(json => ...) serializa el array automáticamente
    $c->render(json => {
        peliculas => \@peliculas_json,     # \@ convierte array a referencia
        total     => scalar @peliculas_json,
    });
}



# ACCIÓN: graficar
# GET /api/graficar

# Genera la imagen de la lista circular con Graphviz
# y la sirve como respuesta binaria (PNG)

sub graficar ($c) {

    if ($lista->is_empty()) {
        return $c->render(
            status => 404,
            json   => { error => 'No hay películas para graficar' }
        );
    }

    
    # Aseguramos que el directorio de reportes existe
    # Mojolicious corre desde el root del proyecto backend/
    # public/reportes/ es accesible como /reportes/lista.png
    
    mkdir REPORTES_DIR unless -d REPORTES_DIR;

    my $ruta_imagen = REPORTES_DIR . '/lista_peliculas.png';

    
    # GENERAR EL ARCHIVO .dot de Graphviz
    # El formato DOT describe un grafo: nodos y aristas
    
    my $dot_content = _generar_dot();

    # Guardamos el archivo .dot temporalmente
    my $ruta_dot = REPORTES_DIR . '/lista_peliculas.dot';
    open(my $fh, '>', $ruta_dot) or do {
        return $c->render(status => 500, json => { error => "No se pudo escribir el archivo dot: $!" });
    };
    print $fh $dot_content;
    close $fh;

    
    # EJECUTAR graphviz para convertir .dot -> .png    
    system("dot -Tpng $ruta_dot -o $ruta_imagen");

    # Verificar que la imagen fue creada
    unless (-f $ruta_imagen) {
        return $c->render(
            status => 500,
            json   => { error => 'Error al generar la imagen.' }
        );
    }

    $c->render(
        json => {
            url     => '/reportes/lista_peliculas.png',
            mensaje => 'Imagen generada exitosamente',
        }
    );
}

# FUNCIÓN PRIVADA: _generar_dot
sub _generar_dot {
    my $dot = "digraph ListaCircular {\n";
    $dot   .= "  rankdir=LR;\n";                          # Left to Right
    $dot   .= "  node [shape=box, style=filled, fillcolor=lightblue];\n";
    $dot   .= "  graph [label=\"Lista Circular de Películas\", fontsize=16];\n\n";

    my @nodos  = ();
    my $actual = $lista->{head};
    my $indice = 0;

    do {
        my $peli      = $actual->get_data();
        my $nombre    = $peli->get_nombre();
        my $director  = $peli->get_director();
        my $anio      = $peli->get_anio();

        # Cada nodo tiene un id numérico y una etiqueta multilínea
        $dot .= "  nodo$indice [label=\"$nombre\\nDir: $director\\nAño: $anio\"];\n";
        push @nodos, "nodo$indice";

        $indice++;
        $actual = $actual->get_next();

    } while ($actual != $lista->{head});

    # Conectar los nodos en orden circular
    $dot .= "\n";
    for my $i (0 .. $#nodos) {
        my $siguiente = ($i + 1) % scalar(@nodos);    # módulo para el ciclo
        $dot .= "  $nodos[$i] -> $nodos[$siguiente];\n";
    }

    $dot .= "}\n";
    return $dot;
}


1;