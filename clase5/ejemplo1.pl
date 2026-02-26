use strict;
use warnings;

# Cargar el módulo Gtk3
use Gtk3 -init;

# Crear una ventana simple
my $window = Gtk3::Window->new('toplevel'); # toplevel --> sera la ventana principal del sistema / popup ventanas tipo menu emergente

$window->set_title(" Este es el titulo de nuestra ventana ");

# ancho x alto 
$window->set_default_size(300, 100);

# Crear una etiqueta --. el Label no es ditable
my $label = Gtk3::Label->new("GTK3 esta instalado y funcionando");
my $label2 = Gtk3::Label->new("esto va esta pegado a el toro label");

# contenedor -> label es el widget
$window->add($label);
# $window->add($label2);

# Cerrar la ventana al hacer clic en la X
$window->signal_connect( 
    destroy => sub { 
        Gtk3->main_quit # sin esto al cerrar la ventana el programa seguiría corriendo en segundo plano.
        }
        );

# Mostrar todo
$window->show_all;

# Iniciar el loop principal
Gtk3->main(); # Activa el event loop.
