package backend;


# backend.pm  
use Mojo::Base 'Mojolicious', -signatures;

sub startup ($self) {
    
    my $config = $self->plugin('NotYAMLConfig');
    $self->secrets($config->{secrets});

    
    # CORS
    # CORS = Cross-Origin Resource Sharing
    $self->hook(before_dispatch => sub ($c) {

        # Permitir peticiones desde el frontend de React (Vite corre en 5173)
        $c->res->headers->header('Access-Control-Allow-Origin'  => 'http://localhost:5173');
        $c->res->headers->header('Access-Control-Allow-Methods' => 'GET, POST, OPTIONS');
        $c->res->headers->header('Access-Control-Allow-Headers' => 'Content-Type');

        # Debemos responderlas con 200 OK para que CORS funcione
        if ($c->req->method eq 'OPTIONS') {
            $c->render(text => '', status => 200);
        }
    });

    
    # DEFINIR RUTAS
    # $router es el objeto Router de Mojolicious (o sea el router de nodejs)
    # Aquí conectamos: URL + método HTTP --> Controlador#acción
    # Convención de Mojolicious:
    #   'Peliculas#home'  -->  lib/backend/Controller/Peliculas.pm --> sub home()
    
    my $router = $self->routes;

    # --- Ruta por defecto (la de Mojolicious, la dejamos para referencia) ---
    $router->get('/')->to('example#welcome');

    
    # RUTAS DE NUESTRA API DE PELÍCULAS

    # GET /api/home
    # Devuelve un mensaje de bienvenida en JSON
    # backend / peliculas --> home ()
    $router->get('/api/home')->to('peliculas#home');

    # POST /api/registrar_pelis
    $router->post('/api/registrar_pelis')->to('peliculas#registrar');

    # GET /api/ver_pelis
    # Devuelve todas las películas de la lista circular en formato JSON
    $router->get('/api/ver_pelis')->to('peliculas#ver');

    # GET /api/graficar
    $router->get('/api/graficar')->to('peliculas#graficar');
}

1;