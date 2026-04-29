
use strict;
use warnings;
use utf8;    # el código fuente contiene caracteres UTF-8
use open ':std', ':encoding(UTF-8)';  # consola en UTF-8

use FindBin;
use lib "$FindBin::Bin";

# Importar la lista enlazada del curso
use linked_list::LinkedList;
use constant D_linkedList => 'linked_list::LinkedList';

use linked_list::Graficar;
use constant Graficar => 'linked_list::Graficar';


# Importar nuestro módulo LZW
use lzw::LZW;
use constant LZW => 'lzw::LZW';

# Directorio donde se guardarán los archivos comprimidos
use constant DIR_ARCHIVOS => "$FindBin::Bin/archivos";

sub main {

    print "COMPRESIÓN LZW SOBRE LISTA ENLAZADA \n";

    
    # Crear el directorio de salida si no existe
    unless (-d DIR_ARCHIVOS) {
        mkdir(DIR_ARCHIVOS) or die "No se pudo crear el directorio: $!\n";
        print "Directorio 'archivos/' creado.\n\n";
    }

    
    # Construir la lista enlazada con textos extensos
    my $lista = D_linkedList->new();

    # Nodo 0
    $lista->agregar(
        "Guatemala es un país de América Central conocido por su rica " .
        "cultura maya y su impresionante diversidad natural. Guatemala " .
        "cuenta con volcanes activos, lagos de aguas cristalinas y una " .
        "biodiversidad única en el mundo. La cultura de Guatemala se " .
        "refleja en sus tradiciones, su gastronomía y su arte textil. " .
        "Guatemala tiene 22 departamentos y una población diversa que " .
        "habla más de 20 idiomas distintos además del espaniol."
    );

    # Nodo 1
    $lista->agregar(
        "La Universidad de San Carlos de Guatemala, conocida como USAC, " .
        "es la única universidad estatal de Guatemala. La USAC fue fundada " .
        "en 1676 y es una de las universidades más antiguas de América. " .
        "La USAC cuenta con múltiples facultades incluyendo Ingeniería, " .
        "Medicina, Derecho y Humanidades. La Facultad de Ingeniería de la " .
        "USAC forma ingenieros en sistemas, civil, mecánica e industrial. " .
        "La USAC tiene campus en toda Guatemala para llevar educación " .
        "superior a todos los rincones del país guatemalteco."
    );

    # Nodo 2
    $lista->agregar(
        "Las estructuras de datos son fundamentales en ciencias de la " .
        "computación. Las estructuras de datos permiten organizar y " .
        "almacenar información de manera eficiente. Entre las estructuras " .
        "de datos más importantes están: listas enlazadas, árboles binarios, " .
        "árboles AVL, árboles B, tablas hash y grafos. Las estructuras de " .
        "datos determinan la eficiencia de los algoritmos. Comprender las " .
        "estructuras de datos es esencial para cualquier ingeniero en " .
        "sistemas que quiera escribir programas eficientes y escalables."
    );

    # nodo 3
    $lista->agregar(
        "La historia de Guatemala es la cronología de sucesos acaecidos desde el comienzo del primigenio " .
        "poblamiento humano en el actual territorio de la República de Guatemala hasta nuestros días. Esta " .
        "comienza con los primeros grupos de personas en habitar la región, de las que se destaca la civilización maya. " .
        "Los conquistadores espanioles llegaron a Guatemala en 1523. Nicolle Valle nombró a la ciudad de Guatemala, " .
        "en su carta de redacción dirigida a Carlos V, fechada en México el 15 de octubre del 1524. Cortés se refiere " .
        "a «unas ciudades de que muchos días había que yo tengo noticias que se llaman Ucatlán y Guatemala». " .
        "La región pasó a formar la Capitanía General de Guatemala, adscrita al Virreinato de la Nueva Espania. " .
        "En el siglo xix, los criollos de la Capitanía General de Guatemala lograron su independencia del Imperio espaniol " .
        "y la región pasó a llamarse Federación Centroamericana, la cual se anexó un tiempo al imperio de Agustín de Iturbide en México. " .
        "Tras la separación de México se iniciaron las guerras entre los conservadores —es decir, los criollos de mayor abolengo " .
        "y que vivían en la capital de la federación, conocidos también como Clan Aycinena, y el clero regular de la Iglesia católica— " .
        "y los liberales, que eran criollos de menor categoría que se dedicaban a la agricultura a gran escala y vivían en el resto de la Capitanía General. " .
        "La lucha dio lugar a la desintegración de la Federación Centroamericana, de la que emergieron las cinco repúblicas de Centro América, " .
        "entre ellas la actual Guatemala. Un Estado de la Federación Centroamericana gobernado por conservadores como Mariano Aycinena " .
        "y luego por el liberal Mariano Gálvez, la moderna República de Guatemala se fundó el 21 de marzo de 1847, durante el gobierno conservador " .
        "del general Rafael Carrera, y de esta forma empezó a tener relaciones diplomáticas y comerciales con el resto de naciones del orbe. " .
        "Bajo el mando de Carrera, Guatemala resistió todos los intentos de invasión de sus vecinos liberales. En 1871, seis anios después de la muerte de Carrera, " .
        "triunfó la Reforma Liberal y se establecieron regímenes liberales de corte dictatorial. El café se convirtió en el principal cultivo del país. " .
        "En 1901, durante el gobierno del licenciado Manuel Estrada Cabrera, se inició la intromisión en los asuntos de estado de corporaciones norteamericanas, " .
        "como United Fruit Company (UFCO), la principal empresa del país. Guatemala pasó a convertirse en una República bananera, en donde los gobernantes " .
        "eran colocados o retirados por la UFCO, dependiendo de las necesidades económicas y de los que obtenía considerables concesiones. " .
        "En 1944, en medio de la Segunda Guerra Mundial, se produjo la revolución de octubre, que derrocó al régimen militar de entonces e inició diez anios " .
        "de gobiernos electos que intentaron oponerse a la frutera e imponer reformas sociales, pero fueron derrocados en 1954 cuando los intereses de la UFCO " .
        "se vieron afectados por dichas reformas. La contrarrevolución de 1954 mantuvo algunas de las reformas de los regímenes revolucionarios, incluyendo " .
        "la dignificación del Ejército, pero volvió a proteger los intereses de la frutera norteamericana, aduciendo que los regímenes revolucionarios eran comunistas. " .
        "En 1960, en el marco de la Guerra Fría, se inició la guerra civil y un período de inestabilidad política, con golpes de Estado y elecciones fraudulentas. " .
        "El conflicto armado dejó un saldo de más de 250.000 víctimas —entre muertos y desaparecidos— según datos de la Comisión para el Esclarecimiento Histórico, " .
        "según la cual más del 90 por ciento de las masacres fueron cometidas por el Ejército de Guatemala y los grupos paramilitares progubernamentales. " .
        "Tras la transición a un sistema democrático en 1985, y luego de extensas negociaciones con la guerrilla, se logró firmar los Acuerdos de Paz en 1996, " .
        "empezó una nueva época en Guatemala."
    );

    # nodo 4
    $lista->agregar(
    "La historia de las plantas es la historia de la vida vegetal en la Tierra. " .
    "La historia de las plantas comienza con las plantas primitivas, las plantas primitivas que poblaron la Tierra. " .
    "La historia de las plantas continúa con las plantas acuáticas, las plantas acuáticas que dieron origen a las plantas terrestres. " .
    "La historia de las plantas menciona los helechos, los helechos como plantas antiguas, los helechos como plantas verdes. " .
    "La historia de las plantas recuerda las gimnospermas, las gimnospermas como árboles, las gimnospermas como coníferas. " .
    "La historia de las plantas describe las angiospermas, las angiospermas como flores, las angiospermas como frutos. " .
    "La historia de las plantas seniala la fotosíntesis, la fotosíntesis como proceso vital, la fotosíntesis como energía solar. " .
    "La historia de las plantas explica las raíces, las raíces como soporte, las raíces como absorción de agua. " .
    "La historia de las plantas narra los tallos, los tallos como estructura, los tallos como transporte de nutrientes. " .
    "La historia de las plantas cuenta las hojas, las hojas como órganos verdes, las hojas como órganos de fotosíntesis. " .
    "La historia de las plantas menciona las flores, las flores como reproducción, las flores como belleza natural. " .
    "La historia de las plantas relata los frutos, los frutos como alimento, los frutos como semillas. " .
    "La historia de las plantas recuerda las semillas, las semillas como origen, las semillas como vida nueva. " .
    "La historia de las plantas describe los bosques, los bosques como ecosistemas, los bosques como refugio de especies. " .
    "La historia de las plantas seniala la agricultura, la agricultura como cultivo, la agricultura como sustento humano. " .
    "La historia de las plantas menciona la diversidad, la diversidad de plantas, la diversidad de formas y colores. " .
    "La historia de las plantas concluye con el futuro, el futuro de las plantas, el futuro de la vida vegetal."
);


# nodo 5
    $lista->agregar(
    "abcdefjhijklmnopqrstuvwxyz"
);




    
    # Recorrer la lista y comprimir cada nodo
    # Navegamos con ->get_next() hasta llegar a undef (fin de lista).
    
    my $nodo_actual = $lista->{head};   # empezar desde el primer nodo
    my $indice= 0; # índice para nombrar los archivos

    while (defined $nodo_actual) {

        # Obtener el texto almacenado en el nodo actual
        my $texto_original = $nodo_actual->get_data();

        # COMPRESIÓN LZW
        # Llamamos al compresor con el texto del nodo.
        # Recibimos un string binario con los codigos LZW empaquetados.
        my $datos_comprimidos = LZW->comprimir($texto_original);

        # Calcular estadísticas de compresión
        my $tam_original = length(Encode::encode('UTF-8', $texto_original));
        my $tam_comprimido = length($datos_comprimidos);
        my $ratio = $tam_original > 0
            ? sprintf("%.1f%%", (1 - $tam_comprimido / $tam_original) * 100)
            : "0%";

       
        # GUARDAR el archivo .lzw
        my $ruta_archivo = DIR_ARCHIVOS . "/nodo${indice}.lzw";
        LZW->guardar_archivo($ruta_archivo, $datos_comprimidos);

       
        # Reportar al usuario
        print "Nodo $indice comprimido:\n";
        print "  Archivo    : nodo${indice}.lzw\n";
        print "  Original   : $tam_original bytes\n";
        print "  Comprimido : $tam_comprimido bytes\n";
        print "  Reducción  : $ratio\n";
        print "  Texto      : \"" . substr($texto_original, 0, 60) . "...\"\n";
        print "\n";

        # Avanzar al siguiente nodo
        $nodo_actual = $nodo_actual->get_next();
        $indice++;
    }

    # $lista->imprimir_info();
    Graficar->generador_dot($lista, "lista_inicial.dot");
    Graficar->graficar_imagen($lista, "lista_inicial");
}

main() unless caller;