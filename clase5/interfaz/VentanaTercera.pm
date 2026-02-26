package interfaz::VentanaTercera;


use strict;
use warnings;
use Gtk3;

# new($ruta_imagen)
# Recibe la ruta del archivo PNG que debe mostrar.
sub new {
    my ($class, $ruta_imagen) = @_;

    my $self = {
        ruta_imagen => $ruta_imagen,
    };
    bless $self, $class;

    # VENTANA
    $self->{window} = Gtk3::Window->new('toplevel');
    $self->{window}->set_title(" Visualizacion de la Lista Circular");
    $self->{window}->set_default_size(700, 500);
    $self->{window}->set_position('center');

    # CONTENEDOR PRINCIPAL
    my $box = Gtk3::Box->new('vertical', 8);
    $box->set_border_width(12);

    # TÍTULO / RUTA DE LA IMAGEN
    my $lbl_titulo = Gtk3::Label->new("Lista Circular de Peliculas");
    my $lbl_ruta   = Gtk3::Label->new("Archivo: $ruta_imagen");

    # Aplicar markup Pango para cambiar el estilo del texto
    # Pango es la biblioteca de renderizado de texto de GTK.
    # set_markup() permite usar etiquetas similares a HTML.
    $lbl_titulo->set_markup(
        "<span font='14' weight='bold' color='#2c3e50'>Lista Circular de Películas</span>"
    );
    $lbl_ruta->set_markup(
        "<span font='9' color='#95a5a6' style='italic'>$ruta_imagen</span>"
    );

    $lbl_titulo->set_halign('center');
    $lbl_ruta->set_halign('center');

    # SEPARADOR
    my $sep = Gtk3::Separator->new('horizontal');

    # IMAGEN
    my $imagen_widget;

    # Verificamos si el archivo existe antes de intentar cargarlo
    if (-f $ruta_imagen) {

        # GdkPixbuf::Pixbuf::new_from_file($ruta)
        # Carga la imagen desde disco en memoria como un objeto Pixbuf.
        # Pixbuf guarda los datos de pixels (r,g,b,a) de la imagen.
        my $pixbuf = Gtk3::Gdk::Pixbuf->new_from_file($ruta_imagen);

        # Obtener las dimensiones originales de la imagen
        my $ancho_orig = $pixbuf->get_width();
        my $alto_orig  = $pixbuf->get_height();

        # Si la imagen es muy grande, escalarla para que quepa en la ventana
        my $max_ancho = 660;
        my $max_alto  = 400;

        if ($ancho_orig > $max_ancho || $alto_orig > $max_alto) {
            # Calcular el factor de escala manteniendo la proporción
            my $factor = $ancho_orig / $max_ancho;
            $factor = $alto_orig / $max_alto if ($alto_orig / $max_alto) > $factor;

            my $nuevo_ancho = int($ancho_orig / $factor);
            my $nuevo_alto  = int($alto_orig  / $factor);

            # scale_simple($ancho, $alto, $filtro_interpolacion)
            # 'bilinear' → interpolación suave (buena calidad)
            # 'nearest'  → más rápido pero pixelado
            $pixbuf = $pixbuf->scale_simple(
                $nuevo_ancho, $nuevo_alto, 'bilinear'
            );
        }

        # Gtk3::Image->new_from_pixbuf($pixbuf) crea el widget de imagen
        $imagen_widget = Gtk3::Image->new_from_pixbuf($pixbuf);

    } else {
        # Si no se encontruenttra el archivo, mostrar un mensaje de error en lugar
        $imagen_widget = Gtk3::Label->new(
            " No se encontró la imagen:\n$ruta_imagen"
        );
    }

    # SCROLLED WINDOW para la imagen
    # Si la imagen es grande, el usuario puede hacer scroll.
    my $scroll = Gtk3::ScrolledWindow->new(undef, undef);
    $scroll->set_policy('automatic', 'automatic');
    $scroll->set_vexpand(1);   # que el scroll ocupe el espacio vertical disponible

    # Gtk3::Viewport -> necesario para poner widgets no scrollables dentro de ScrolledWindow
    $scroll->add_with_viewport($imagen_widget);

    # BOTÓN CERRAR
    my $btn_cerrar = Gtk3::Button->new("  Cerrar  ");
    $btn_cerrar->set_halign('center');

    $btn_cerrar->signal_connect(clicked => sub {
        $self->{window}->destroy();
    });

    # EMPAQUETAR
    $box->pack_start($lbl_titulo, 0, 0, 0);
    $box->pack_start($lbl_ruta,0, 0, 0);
    $box->pack_start($sep, 0, 1, 4);
    $box->pack_start($scroll, 1, 1, 0);  # expand=1 para ocupar espacio vertical
    $box->pack_start($btn_cerrar,0, 0, 8);

    $self->{window}->add($box);

    # Cerrar solo esta ventana (no toda la app)
    $self->{window}->signal_connect('delete-event' => sub { return 0; });

    return $self;
}

# mostrar()
sub mostrar {
    my ($self) = @_;
    $self->{window}->show_all();
}

1;