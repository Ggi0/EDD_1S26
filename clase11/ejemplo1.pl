
use strict;
use warnings;

use FindBin;
use lib "$FindBin::Bin";

use tableHash::Persona;
use tableHash::TablaHash;
use tableHash::Graficar;

use constant Persona   => 'tableHash::Persona';
use constant TablaHash => 'tableHash::TablaHash';
use constant Graficar  => 'tableHash::Graficar';

sub main {

    
    # PASO 1: Crear las personas
    
    # Cada persona recibe: nombre, edad, carrera, tipo
    # El tipo determina en QUE SLOT de la tabla hash va a quedar.
    # Funcion hash: f(tipo) = ord(ultima_letra) - ord('A')
    #   TIPO_A -> Slot 0   (Medicos Generales)
    #   TIPO_B -> Slot 1   (Medicos Especialistas)
    #   TIPO_C -> Slot 2   (Enfermeros)
    #   TIPO_D -> Slot 3   (Administrativos)

   my $p1  = Persona->new("Ana Lopez", 38, "Ingeniería Civil", "TIPO_A");
   my $p2  = Persona->new("Carlos Mendez",45, "Administración de Empresas", "TIPO_A");
   my $p3  = Persona->new("Roberto Fuentes",52, "Contaduría Pública", "TIPO_A");
   my $p4  = Persona->new("Jorge Castillo", 41, "Derecho", "TIPO_B");
   my $p5  = Persona->new("Maria Hernandez",36, "Arquitectura","TIPO_B");
   my $p6  = Persona->new("Pablo Alvarado",48, "Ingeniería en Sistemas", "TIPO_B");
   my $p7  = Persona->new("Sofiaaaa Ramirez",29, "Psicología", "TIPO_C");
   my $p8  = Persona->new("Luis Morales",33, "Pedagogía", "TIPO_C");
   my $p9  = Persona->new("Elena Torres", 27, "Comunicación Social", "TIPO_D");
   my $p10 = Persona->new("Diego Perez", 31, "Relaciones Internacionales", "TIPO_A");


    
    # PASO 2: Crear la tabla hash e insertar
    # Observa en consola como cada insercion:
    #   - Calcula el indice: f("TIPO_A") = 0, etc.
    #   - Detecta y reporta colisiones cuando el slot ya tenia elementos
    #   - Encadena el nuevo nodo al final de la lista del slot

    my $tabla = TablaHash->new();

    $tabla->insertar($p1);    # TIPO_A -> Slot 0, primera insercion, sin colision
    $tabla->insertar($p2);    # TIPO_A -> Slot 0, colision (ya habia 1 elemento)
    $tabla->insertar($p3);    # TIPO_A -> Slot 0, colision (ya habia 2 elementos)
    $tabla->insertar($p4);    # TIPO_B -> Slot 1, primera insercion, sin colision
    $tabla->insertar($p5);    # TIPO_B -> Slot 1, colision
    $tabla->insertar($p6);    # TIPO_B -> Slot 1, colision
    $tabla->insertar($p7);    # TIPO_C -> Slot 2, primera insercion, sin colision
    $tabla->insertar($p8);    # TIPO_C -> Slot 2, colision
    $tabla->insertar($p9);    # TIPO_D -> Slot 3, primera insercion, sin colision
    $tabla->insertar($p10);   # TIPO_D -> Slot 3, colision

    
    # PASO 3: Imprimir el estado completo de la tabla
    $tabla->imprimir_tabla();

    
    # PASO 4: Consultar por tipo
    # Esta es la utilidad principal de la tabla hash:
    # sin tener que recorrer toda la estructura.
    my $cabeza_a = $tabla->buscar_por_tipo("TIPO_A");
    my $nodo_iter = $cabeza_a;
    while (defined $nodo_iter) {
        my $p = $nodo_iter->get_persona();
        printf "  %-30s | Edad: %2d | %s\n",
            $p->get_nombre(), $p->get_edad(), $p->get_carrera();
        $nodo_iter = $nodo_iter->get_siguiente();
    }
    print "\n";

    print "Cuantos enfermeros hay? (TIPO_C) \n\n";
    my $total_c = $tabla->get_cantidad_por_tipo("TIPO_C");
    print "  Total de enfermeros/as en el sistema: $total_c\n\n";

    
    # PASO 5: Eliminar un elemento y ver la cadena resultante
    # print "-- Eliminando al Carlos Mendez (TIPO_A)";
    $tabla->eliminar("Carlos Mendez", "TIPO_A");

    print "Estado de TIPO_A despues de la eliminacion\n\n";
    my $cabeza_a2 = $tabla->buscar_por_tipo("TIPO_A");
    $nodo_iter = $cabeza_a2;
    while (defined $nodo_iter) {
        my $p = $nodo_iter->get_persona();
        printf "  %-30s | %s\n", $p->get_nombre(), $p->get_carrera();
        $nodo_iter = $nodo_iter->get_siguiente();
    }
    print "\n";

    # PASO 6: Imprimir tabla final
    $tabla->imprimir_tabla();

    
    # PASO 7: Generar reporte Graphviz
    
    Graficar->graficar_tabla_hash($tabla, "ejemplo1");

}

main();