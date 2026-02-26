package interfaz::VentanaSecundaria;

use strict;
use warnings;
use Gtk3;

# Importamos las clases de datos
use lista_circular::ListaCircular;
use lista_circular::Pelicula;

# VARIABLE $lista_peliculas
# Es compartida entre todas las instancias de VentanaSecundaria.
# Así la lista persiste aunque se cierre y reabra la ventana secundaria.
my $lista_peliculas = lista_circular::ListaCircular->new();

# new()
# Constructor de la ventana secundaria.
sub new {
    my ($class) = @_;

    my $self = {};
    bless $self, $class;


    # VENTANA
    # set_resizable(0) impide que el usuario cambie el tamaño.
    $self->{window} = Gtk3::Window->new('toplevel');
    $self->{window}->set_title("Agregar Peliculas");
    $self->{window}->set_default_size(580, 500);
    $self->{window}->set_position('center');
    $self->{window}->set_border_width(15);

    # CONTENEDOR RAiZ: Box vertical
    # Divide la ventana en dos zonas:
    #   1. Formulario de ingreso (arriba)
    #   2 Lista de películas agregadas (abajo)
    my $box_raiz = Gtk3::Box->new('vertical', 12);

    # PARTE 1 1: FORMULARIO
    # Gtk3::Frame->new("titulo") crea una caja con borde y título decorativo.
    # Es puramente visual, no tiene lógica de layout.
    my $frame_form = Gtk3::Frame->new("  Nueva Película  ");

    # Gtk3::Grid ---> layout en cuadricula (como una tabla HTML)
    # set_row_spacing  -> espacio vertical entre filas
    # set_column_spacing --> espacio horizontal entre columnas
    # set_border_width   -> margen interior del grid
    my $grid = Gtk3::Grid->new();
    $grid->set_row_spacing(10);
    $grid->set_column_spacing(12);
    $grid->set_border_width(15);

    # CAMPOS DEL FORMULARIO
    # Creamos pares: Label (etiqueta) + Entry (campo de texto)
    #
    # Gtk3::Entry->new() -> campo de texto de una línea
    # set_placeholder_text() -> texto gris de ayuda cuando está vacío
    # set_hexpand(1) -> el Entry se expande horizontalmente para llenar la celda

    # en la primera ponemso el nombre
    my $lbl_nombre = Gtk3::Label->new("Nombre:");
    $lbl_nombre->set_halign('end');   # alinear el texto a la derecha

    $self->{entry_nombre} = Gtk3::Entry->new();
    $self->{entry_nombre}->set_placeholder_text("Ej: esto es texot de ejemplo");
    $self->{entry_nombre}->set_hexpand(1);   # crecer horizontalmente

    # 2 director
    my $lbl_director = Gtk3::Label->new("Director:");
    $lbl_director->set_halign('end');

    $self->{entry_director} = Gtk3::Entry->new();
    $self->{entry_director}->set_placeholder_text("Ej: director famoso");
    $self->{entry_director}->set_hexpand(1);

    # -duracion
    my $lbl_duracion = Gtk3::Label->new("Duracion (min):");
    $lbl_duracion->set_halign('end');

    $self->{entry_duracion} = Gtk3::Entry->new();
    $self->{entry_duracion}->set_placeholder_text("Ej: 175");
    $self->{entry_duracion}->set_hexpand(1);

    # anio
    my $lbl_anio = Gtk3::Label->new("Anio:");
    $lbl_anio->set_halign('end');

    $self->{entry_anio} = Gtk3::Entry->new();
    $self->{entry_anio}->set_placeholder_text("Ej: 2027");
    $self->{entry_anio}->set_hexpand(1);

    # AGREGAR WIDGETS AL GRID
    # attach($widget, $col, $fila, $ancho_en_celdas, $alto_en_celdas)
    #   columnas y filas se cuentan desde 0
    $grid->attach($lbl_nombre, 0, 0, 1, 1);
    $grid->attach($self->{entry_nombre}, 1, 0, 1, 1);

    $grid->attach($lbl_director, 0, 1, 1, 1);
    $grid->attach($self->{entry_director}, 1, 1, 1, 1);

    $grid->attach($lbl_duracion, 0, 2, 1, 1);
    $grid->attach($self->{entry_duracion}, 1, 2, 1, 1);

    $grid->attach($lbl_anio, 0, 3, 1, 1);
    $grid->attach($self->{entry_anio}, 1, 3, 1, 1);

    # BOTONES DE ACCIoN
    # Los empaquetamos en una Box horizontal centrada.
    my $box_botones = Gtk3::Box->new('horizontal', 10);
    $box_botones->set_halign('center');

    my $btn_agregar = Gtk3::Button->new("Agregar Pelicula");
    my $btn_graficar = Gtk3::Button->new(" Graficar Lista");


 #$box->pack_start($widget, $expand, $fill, $padding);
    $box_botones->pack_start($btn_agregar, 0, 0, 0);
    $box_botones->pack_start($btn_graficar, 0, 0, 0);

    # Meter los botones al grid también (fila 4, ocupando 2 columnas)
    $grid->attach($box_botones, 0, 4, 2, 1);

    $frame_form->add($grid);

    # ===========================================================================================================

    # ZONA 2: LISTA DE PELÍCULAS AGREGADAS (log visual)
    # Gtk3::ScrolledWindow -> permite scroll cuando el contenido es larg
    my $frame_lista = Gtk3::Frame->new("  Peliculas en la Lista Circular  ");

    # Gtk3::ScrolledWindow->new(hadjustment, vadjustment)
    # undef = usar ajuste automático
    my $scroll = Gtk3::ScrolledWindow->new(undef, undef);
    $scroll->set_min_content_height(150);

    # set_policy(política_horizontal, política_vertical)
    # 'automatic' -> muestra scrollbar solo cuando es necesario
    # 'never'     ->nunca muestra scrollbar
    $scroll->set_policy('automatic', 'automatic');

   # Gtk3::TextView  ->area de texto de multiples líneas
    # Lo usamos como "log" de solo lectura para mostrar las películas.
    $self->{textview} = Gtk3::TextView->new();
    $self->{textview}->set_editable(0);        # solo lectura
    $self->{textview}->set_cursor_visible(0);    # ocultar cursor
    $self->{textview}->set_wrap_mode('word');   # ajustar palabras al ancho
    $self->{textview}->set_left_margin(8);
    $self->{textview}->set_top_margin(6);

    # El TextBuffer es el modelo de datos del TextView (separa vista de datos)
    $self->{buffer} = $self->{textview}->get_buffer();
    $self->{buffer}->set_text("(aun no hay peliculas agregadas)");

    $scroll->add($self->{textview});
    $frame_lista->add($scroll);

    # EMPAQUETAR TODO EN LA BOX RAÍZ
    $box_raiz->pack_start($frame_form, 0, 1, 0);
    $box_raiz->pack_start($frame_lista, 1, 1, 0);  # expand=1 para crecer

    $self->{window}->add($box_raiz);

    # CONECTAR SENiALES DE LOS BOTONES

    # BOToN AGREGAR 
    $btn_agregar->signal_connect(clicked => sub {
        $self->_agregar_pelicula();
    });

    # BOToN GRAFICAR
    $btn_graficar->signal_connect(clicked => sub {
        $self->_graficar_lista();
    });

    # - CERRAR VENTANA --
    # 'delete-event' se dispara cuando el usuario presiona la X.
    # Retornar 0 (falso) permite que la ventana se destruya normalmente.
    # Retornar 1 (verdadero) bloquearía el cierre.
    $self->{window}->signal_connect('delete-event' => sub { return 0; });

    return $self;
}

# _agregar_pelicula() 
# Lee los campos del formulario, valida, crea la Pelicula y la agrega
# a la lista circular. Luego limpia los campos y actualiza el log.
sub _agregar_pelicula {
    my ($self) = @_;

    # Leer valores de los Entry
    # get_text() retorna el string actual del campo de texto.
    my $nombre   = $self->{entry_nombre}->get_text();
    my $director = $self->{entry_director}->get_text();
    my $duracion = $self->{entry_duracion}->get_text();
    my $anio     = $self->{entry_anio}->get_text();

    # Validación básica: ningún campo puede estar vacío
    if (!$nombre || !$director || !$duracion || !$anio) {
        _mostrar_dialogo_error(
            $self->{window},
            "Por favor completa todos los campos"
        );
        return;
    }


    # Crear objeto Pelicula y agregarlo a la Lista Circular
    my $pelicula = lista_circular::Pelicula->new(
        $nombre, $director, $duracion + 0, $anio + 0
    );

    $lista_peliculas->agregar($pelicula);

    # Limpiar los campos del formulario
    # set_text("") vacía el Entry
    $self->{entry_nombre}->set_text("");
    $self->{entry_director}->set_text("");
    $self->{entry_duracion}->set_text("");
    $self->{entry_anio}->set_text("");

    # Poner el foco en el primer campo para agilizar el ingreso
    $self->{entry_nombre}->grab_focus();

    # Actualizar el TextBuffer con el contenido actual de la lista
    $self->_actualizar_log();
}

# _actualizar_log()
# Recorre la lista circular y muestra todas las películas en el TextView.
sub _actualizar_log {
    my ($self) = @_;

    if ($lista_peliculas->is_empty()) {
        $self->{buffer}->set_text("(aun no hay peliculas agregadas)");
        return;
    }

    my $texto = "Total: " . $lista_peliculas->tamanio() . " pelicula(s)\n";

    # Recorremos la lista circular manualmente para leer cada película
    my $actual = $lista_peliculas->{head};
    my $i = 1;
    do {
        my $p = $actual->get_data();
        $texto .= sprintf(
            "%d. %s (%s) - Dir: %s - %d min\n",
            $i,
            $p->get_nombre(),
            $p->get_anio(),
            $p->get_director(),
            $p->get_duracion()
        );
        $actual = $actual->get_next();
        $i++;
    } while ($actual != $lista_peliculas->{head});

    # set_text() reemplaza TODO el contenido del buffer
    $self->{buffer}->set_text($texto);
}

# _graficar_lista()
# Genera el archivo DOT + PNG usando Graficar.pm y abre VentanaTercera.
sub _graficar_lista {
    my ($self) = @_;

    # Asegurarse de que exista el directorio de reportes
    unless (-d "clase5/reportes") {
        mkdir("clase5/reportes") or do {
            _mostrar_dialogo_error(
                $self->{window},
                "No se pudo crear el directorio clase5/reportes: $!"
            );
            return;
        };
    }

    # Llamar al modulo Graficar para generar el .dot y el .png
    require lista_circular::Graficar;
    my $ok = lista_circular::Graficar->graficar($lista_peliculas, "peliculas_ejemplo");

    if (!$ok) {
        _mostrar_dialogo_error(
            $self->{window},
            "Error al generar la imagen.\n" .
            "pipipipi"
        );
        return;
    }

    # Abrir la ventana que muestra la imagen
    require interfaz::VentanaTercera;
    my $tercera = interfaz::VentanaTercera->new("clase5/reportes/peliculas_ejemplo.png");
    $tercera->mostrar();
}

# _mostrar_dialogo_error($ventana_padre, $mensaje)

# Gtk3::MessageDialog → diálogo modal con icono y botones predefinidos
#    ventana_padre: la ventana a la que pertenece (para centrarse sobre ella)
#    flags: 'modal' bloquea la ventana padre hasta cerrar el diálogo
#   tipo: 'error', 'warning', 'info', 'question'
#  botones: 'ok', 'yes-no', 'ok-cancel', etc.
sub _mostrar_dialogo_error {
    my ($ventana_padre, $mensaje) = @_;

    my $dialog = Gtk3::MessageDialog->new(
        $ventana_padre,
        'modal',
        'error',
        'ok',
        $mensaje
    );

    # run() muestra el dialogo y espera a que el usuario lo cierre (bloqueante)
    $dialog->run();

    # Destruir el dialogo despues de que el usuario presione OK
    $dialog->destroy();
}

# mostrar()
sub mostrar {
    my ($self) = @_;
    $self->{window}->show_all();
}

1;