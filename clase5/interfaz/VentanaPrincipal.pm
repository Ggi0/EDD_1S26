package interfaz::VentanaPrincipal;

use strict;
use warnings;
use Gtk3;

# Constructor --> hace todos los widgets y los conecta
sub new {
    my ($class) = @_;

    # Crear objeto Perl
    my $self = {};
    bless $self, $class;

    # Crear ventana principal
    $self->{window} = Gtk3::Window->new('toplevel'); # top level, o sea es una ventana independiente, no es una subventana o una emergente
    
    $self->{window}->set_title("PRINCIPAL - Gestor de Películas");
    $self->{window}->set_default_size(500, 320);

    #centrar ventana
    $self->{window}->set_position('center');

    my $css_provider = Gtk3::CssProvider->new();
        $css_provider->load_from_data(
            "window { background-color:rgb(217, 217, 217); }\n" .
            "label#titulo { font-size: 22px; font-weight: bold; color: #2c3e50; }\n" .
            "label#subtitulo { font-size: 13px; color: #7f8c8d; }\n" .
            "button { padding: 10px 24px; font-size: 14px; border-radius: 6px; }\n"
        );

    # Aplicar el los estilos a TODA la pantalla (display por defecto)
    Gtk3::StyleContext::add_provider_for_screen(
        Gtk3::Gdk::Screen::get_default(),
        $css_provider,
        Gtk3::STYLE_PROVIDER_PRIORITY_APPLICATION  # prioridad sobre estilos del tema
    );



    # Crear contenedor vertical
    # apila los widgets de arriba hacia abajo.
    my $box_principal = Gtk3::Box->new('vertical', 20);

    # set_border_width agrega un margen interior a todo el contenedor
    $box_principal->set_border_width(40);

    # Gtk3::Label->new("texto") crea texto estático.
    my $label_titulo = Gtk3::Label->new("PRINCIPAL - Gestor de Peliculas");
    $label_titulo->set_name("titulo");   # ID para CSS

    # set_halign y set_valign controlan la alineación dentro del espacio asignado
    $label_titulo->set_halign('center');

    # lo mismo que con el titulo principal pero son el subtitulo
    my $label_sub = Gtk3::Label->new(
        "Administra tu coleccion en una Lista Circular"
    );
    $label_sub->set_name("subtitulo");
    $label_sub->set_halign('center');

    # Gtk3::Separator->new('horizontal') dibuja una lineea divisoria.
    my $separador = Gtk3::Separator->new('horizontal');

    # haciendo un boton - va hacer un botón ocn lo que este adentro del las comills
    my $boton_abrir = Gtk3::Button->new(" -> Gestionar Peliculas <- ");

    # Centrar el boton: lo metemos en una Box horizontal para controlarlo -> el 0 es el epsacio entre los widgets pero ya lo definimos arriba
    my $box_boton = Gtk3::Box->new('horizontal', 0);
    
    $box_boton->set_halign('center');  # centrar la box horizontalmente
    $box_boton->pack_start($boton_abrir, 0, 0, 0);


    # SEÑAL: signal_connect
    # signal_connect($señal, $callback) engancha un evento a una subrutina.
    # 'clicked' se dispara cuando el usuario hace click en el botón.
    $boton_abrir->signal_connect(
        clicked => sub {
            # Cargamos VentanaSecundaria solo cuando se necesita
            require interfaz::VentanaSecundaria;
            my $secundaria = interfaz::VentanaSecundaria->new();
            $secundaria->mostrar();
        });


    my $label_nota = Gtk3::Label->new("Estructura de datos: Lista Circular Enlazada, esto es lo de abajo");
    $label_nota->set_name("subtitulo");
    $label_nota->set_halign('center');

    # --------> $expand, $fill, $padding
    $box_principal->pack_start($label_titulo, 0, 0, 0);
    $box_principal->pack_start($label_sub, 0, 0, 0);
    $box_principal->pack_start($separador,0, 1, 0);
    $box_principal->pack_start($box_boton,1, 0, 0);  # expand=1 para centrar verticalmente
    $box_principal->pack_start($label_nota, 0, 0, 0);

    # Agregar el contenedor a la ventana (una ventana solo admite UN hijo directo)
    $self->{window}->add($box_principal);

    $self->{window}->signal_connect(
        destroy => sub { Gtk3->main_quit();}
    );

    return $self;
}


sub mostrar {
    my ($self) = @_;
    $self->{window}->show_all();
}

1;