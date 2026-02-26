#!/usr/bin/env perl
use strict;
use warnings;

use FindBin;
use lib "$FindBin::Bin";   # Permite buscar módulos en la carpeta actual

use Gtk3 -init;

# Importar ventana principal
use interfaz::VentanaPrincipal;

use constant VentanaPrincipal => 'interfaz::VentanaPrincipal';


sub main {

    print "Iniciando aplicación con GTK3...\n";

    my $app = VentanaPrincipal->new();
    $app->mostrar();
    Gtk3->main();
}

main();