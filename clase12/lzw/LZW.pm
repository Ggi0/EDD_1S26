package lzw::LZW;



# La idea priciapal es construir un DICCIONARIO DINÁMICO de patrones mientras
# se leen los datos. El diccionario crece con cada nuevo patrón encontrado.

# La gran ventaja: el descompresor NO necesita recibir el diccionario.
# Puede reconstruirlo por sí solo durante la descompresión, porque ambos
# (compresor y descompresor) siguen exactamente los mismos pasos.


# Al inicio el diccionario tiene 256 entradas --> basta con 8 bits por código.
# A medida que el diccionario crece, se necesitan más bits:
#   256-511   entradas --> 9 bits
#   512-1023  entradas --> 10 bits
#   1024-2047 entradas --> 11 bits
#   ...hasta MAX_BITS

use strict;
use warnings;
use utf8;

# Límite máximo de bits por código.
# Con 12 bits podemos tener hasta 2^12 = 4096 entradas en el diccionario.
# Es el valor clásico del LZW original de Terry Welch (1984).
use constant MAX_BITS  => 12;

# Tamaño máximo del diccionario = 2^MAX_BITS
use constant MAX_SIZE  => (1 << MAX_BITS);  # 4096

# El diccionario inicial siempre tiene las 256 entradas ASCII (0-255)
use constant INIT_SIZE => 256;


# comprimir($texto)
# Una cadena de texto Perl (string)
# Un string binario que representa los códigos LZW empaquetados con ancho de bits variable, precedido de 4 bytes con el conteo.
#
# PASO A PASO:
# 1. Inicializar el diccionario con los 256 caracteres ASCII
# 2. Leer carácter por carácter acumulando en un "buffer"
# 3. Si buffer+carácter existe en el diccionario --> seguir acumulando
# 4. Si buffer+carácter NO existe  --> emitir código de buffer,
#                                    agregar buffer+carácter al diccionario,
#                                    reiniciar buffer con el carácter actual
# 5. Al terminar --> emitir código del buffer restante
sub comprimir {
    my ($clase, $texto) = @_;

    # PASO 1: Inicializar el diccionario de compresión
    # El diccionario mapea: cadena_de_caracteres --> número_de_código
    # Empieza con los 256 caracteres ASCII individuales.
    
    my %diccionario;
    for my $i (0 .. INIT_SIZE - 1) {
        $diccionario{ chr($i) } = $i;
    }

    # Proximo código libre disponible (empieza en 256)
    my $siguiente_codigo = INIT_SIZE;

    # Buffer: cadena que vamos acumulando mientras los prefijos existan
    my $buffer = "";

    # Lista donde guardamos los códigos que vamos emitiendo
    my @codigos;

    
    # PASO 2: Procesar cada carácter del texto de entrada
    # Convertimos el texto a bytes para manejar caracteres especiales y acentos de forma segura.
    my $texto_bytes = encode_to_bytes($texto);
    my @caracteres  = split //, $texto_bytes;

    for my $c (@caracteres) {

        # Candidato = lo que tenemos acumulado + el nuevo carácter
        my $candidato = $buffer . $c;

        if (exists $diccionario{$candidato}) {
           
            # El candidato YA EXISTE en el diccionario.
            # Podemos seguir acumulando --> extender el buffer.
            # Todavía no emitimos nada.
            $buffer = $candidato;

        } else {
           
            # El candidato NO EXISTE en el diccionario.
            # 1) Emitir el código del buffer actual (lo que sí existe)
            # 2) Agregar el candidato al diccionario si hay espacio
            # 3) Reiniciar el buffer con el carácter actual

            # 1) Emitir el código del buffer
            push @codigos, $diccionario{$buffer};

            # 2) Agregar candidato al diccionario (si no llenamos el límite)
            if ($siguiente_codigo < MAX_SIZE) {
                $diccionario{$candidato} = $siguiente_codigo;
                $siguiente_codigo++;
            }

            # 3) Reiniciar buffer con el carácter que no cupo
            $buffer = $c;
        }
    }

    
    # PASO 3: Emitir el código del buffer final
    # Al terminar de leer el texto, el buffer contiene el último
    # prefijo que no llegó a generar una emisión. Lo emitimos ahora.
    if (length($buffer) > 0) {
        push @codigos, $diccionario{$buffer};
    }

    
    # PASO 4: Empaquetar los códigos en binario con ancho variable
    # Esta es la etapa que convierte los números enteros en un
    # stream de bits compacto.
    return empaquetar_codigos(\@codigos);
}



# descomprimir($datos_binarios)
# El string binario producido por comprimir()

# el descompresor reconstruye el diccionario por sí solo.
# No necesita que el compresor le envíe el diccionario.

# CASO ESPECIAL (la parte más difícil de LZW):
# A veces el compresor emite un código que el descompresor TODAVÍA NO tiene
# en su diccionario. Esto ocurre cuando:
#   - El compresor acaba de agregar el código K al diccionario
#   - Inmediatamente después emite el código K
#   - El descompresor aún no ha agregado K
#
# La solución: si recibimos un código desconocido, la entrada debe ser
#   traduccion_anterior + primer_carácter(traduccion_anterior)
# Esto funciona porque ese es exactamente el patrón que el compresor
# estaba viendo cuando creó esa entrada.
sub descomprimir {
    my ($clase, $datos_binarios) = @_;

    # PASO 1: Desempaquetar los bits y recuperar la lista de códigos
    my @codigos = desempaquetar_codigos($datos_binarios);

    return "" unless @codigos;

    # PASO 2: Inicializar el diccionario de descompresión (INVERSO)
    # Este mapea:  número_de_código --> cadena_de_caracteres
    # Igual que el compresor, empieza con los 256 ASCII.
    
    my %diccionario;
    for my $i (0 .. INIT_SIZE - 1) {
        $diccionario{$i} = chr($i);
    }
    my $siguiente_codigo = INIT_SIZE;

    # PASO 3: Procesar el primer código (caso especial de inicio)
    # El primer código siempre existe en el diccionario inicial (ASCII).
    
    my $primer_codigo = shift @codigos; # primer elemento dle @
    my $traduccion_prev  = $diccionario{$primer_codigo};
    my $resultado = $traduccion_prev;

    
    # PASO 4: Procesar el resto de los códigos
    for my $codigo (@codigos) {

        my $entrada;
        if (exists $diccionario{$codigo}) {
            # Caso normal: el código ya está en el diccionario
            $entrada = $diccionario{$codigo};

        } else {
            
            # CASO ESPECIAL: el código NO existe todavía en el diccionario.
            # Esto ocurre cuando el compresor emitió un código que acababa de crear en el mismo paso. El descompresor va un paso atrás.
            # La entrada correcta es:
            #   traduccion_anterior + primer_carácter(traduccion_anterior)
            #
            # el compresor creó esa entrada concatenando exactamente eso: lo que tenía en el buffer
            # (= traduccion_anterior) más el carácter que lo siguió
            # (que debe ser el primer carácter de esa misma secuencia).
            $entrada = $traduccion_prev . substr($traduccion_prev, 0, 1);
        }

        # Acumular en el resultado
        $resultado .= $entrada;

        # Agregar nueva entrada al diccionario (igual que el compresor)
        if ($siguiente_codigo < MAX_SIZE) {
            $diccionario{$siguiente_codigo} = $traduccion_prev . substr($entrada, 0, 1);
            $siguiente_codigo++;
        }

        # Actualizar la traducción anterior para el próximo ciclo
        $traduccion_prev = $entrada;
    }

    # Convertir los bytes de vuelta a texto legible
    return decode_from_bytes($resultado);
}



# empaquetar_codigos(\@codigos)
# Convierte una lista de enteros en un stream de bits empaquetado.
# Usa ancho de bits VARIABLE según el tamaño actual del diccionario.
#
# ESTRUCTURA DEL BINARIO RESULTANTE:
#   [4 bytes: uint32 big-endian con la cantidad de códigos]
#   [bits empaquetados de los códigos]
#
# Los bits se acumulan en un buffer de bits y se vuelcan al resultado
# byte a byte (de izquierda a derecha, bit más significativo primero).
sub empaquetar_codigos {
    my ($codigos_ref) = @_;
    my @codigos = @$codigos_ref;

    # Encabezado: cantidad de códigos en 4 bytes big-endian
    # pack("N", $n) --> uint32 big-endian en Perl
    my $resultado = pack("N", scalar @codigos);

    # Buffer de bits: acumulamos bits aquí antes de volcarlos a bytes
    my $buffer_bits= 0;   # los bits acumulados (como entero)
    my $bits_en_buffer = 0;   # cuántos bits válidos hay en el buffer

    # Calculamos el ancho de bits necesario para cada código según
    # cuántos códigos se han emitido (simula el crecimiento del diccionario)
    my $dict_size = INIT_SIZE;  # empieza en 256

    for my $codigo (@codigos) {

        # ¿Cuántos bits necesitamos para representar este código?
        # Con dict_size entradas, necesitamos ceil(log2(dict_size)) bits.
        my $bits_necesarios = bits_necesarios($dict_size);

        # Insertar el código en el buffer de bits
        # Desplazamos el buffer a la izquierda y OR con el código
        $buffer_bits    = ($buffer_bits << $bits_necesarios) | $codigo;
        $bits_en_buffer += $bits_necesarios;

        # Volcar bytes completos del buffer al resultado
        while ($bits_en_buffer >= 8) {
            $bits_en_buffer -= 8;
            # Extraer el byte más significativo
            my $byte = ($buffer_bits >> $bits_en_buffer) & 0xFF;
            $resultado .= chr($byte);
            # Limpiar esos bits del buffer
            $buffer_bits &= (1 << $bits_en_buffer) - 1;
        }

        # El diccionario crece con cada código emitido (hasta MAX_SIZE)
        $dict_size++ if $dict_size < MAX_SIZE;
    }

    # Si quedaron bits en el buffer, rellenar con ceros y volcar
    if ($bits_en_buffer > 0) {
        my $byte = ($buffer_bits << (8 - $bits_en_buffer)) & 0xFF;
        $resultado .= chr($byte);
    }

    return $resultado;
}



# Fdesempaquetar_codigos($datos_binarios)
# Proceso inverso de empaquetar_codigos.
# Lee el encabezado para saber cuántos códigos hay,
# luego lee los bits con el mismo ancho variable y reconstruye los enteros.
sub desempaquetar_codigos {
    my ($datos) = @_;

    # Verificar que al menos tiene el encabezado de 4 bytes
    return () if length($datos) < 4;

    # Leer la cantidad de códigos del encabezado (4 bytes big-endian)
    my $num_codigos = unpack("N", substr($datos, 0, 4));
    return () unless $num_codigos;

    # El resto son los bits empaquetados
    my $bits_raw = substr($datos, 4);

    # Convertir los bytes a un string de bits ('0' y '1')
    # unpack("B*", ...) --> string de bits del buffer
    my $bits_str = unpack("B*", $bits_raw);

    my @codigos   = ();
    my $pos       = 0;          # posición actual en el string de bits
    my $dict_size = INIT_SIZE;  # simular el crecimiento del diccionario

    for my $i (1 .. $num_codigos) {

        my $bits_necesarios = bits_necesarios($dict_size);

        # Verificar que hay suficientes bits disponibles
        last if ($pos + $bits_necesarios) > length($bits_str);

        # Extraer exactamente $bits_necesarios bits desde $pos
        my $bits_segmento = substr($bits_str, $pos, $bits_necesarios);
        $pos += $bits_necesarios;

        # Convertir el string de bits a entero
        # oct("0b" . $bits) es la forma idiomática de Perl para esto
        my $codigo = oct("0b" . $bits_segmento);
        push @codigos, $codigo;

        # Simular el crecimiento del diccionario
        $dict_size++ if $dict_size < MAX_SIZE;
    }

    return @codigos;
}



#  bits_necesarios($dict_size)
#
# Calcula cuántos bits se necesitan para representar un índice en un
# diccionario de $dict_size entradas.
#
# Ejemplos:
#   dict_size = 256  --> 8 bits  (2^8  = 256)
#   dict_size = 257  --> 9 bits  (2^8  = 256 < 257, necesitamos 9)
#   dict_size = 512  --> 9 bits  (2^9  = 512)
#   dict_size = 513  --> 10 bits
sub bits_necesarios {
    my ($dict_size) = @_;
    my $bits = 8;  # mínimo 8 bits (para los 256 ASCII iniciales)
    while ((1 << $bits) < $dict_size && $bits < MAX_BITS) {
        $bits++;
    }
    return $bits;
}



# encode_to_bytes($texto)
# Convierte un texto UTF-8 a una representación de bytes seguros para LZW.
# LZW opera sobre bytes (0-255), no sobre caracteres Unicode.
# Para manejar caracteres fuera del rango ASCII (ñ, á, é, ü, etc.)
# codificamos cada carácter como su representación UTF-8 escapada.
sub encode_to_bytes {
    my ($texto) = @_;
    # Encode a UTF-8 bytes usando la función de Perl
    # Esto convierte ñ --> \xC3\xB1 (2 bytes), etc.
    use Encode qw(encode);
    return encode('UTF-8', $texto);
}



# decode_from_bytes($bytes)
# Proceso inverso: convierte los bytes UTF-8 de vuelta a texto legible.
sub decode_from_bytes {
    my ($bytes) = @_;
    use Encode qw(decode);
    return decode('UTF-8', $bytes);
}



# guardar_archivo($ruta, $datos_binarios)
# Guarda el contenido binario comprimido en un archivo .lzw
# se abre en modo binario (:raw) para no alterar los bytes.
sub guardar_archivo {
    my ($clase, $ruta, $datos_binarios) = @_;

    open(my $fh, '>:raw', $ruta)
        or die "No se pudo crear el archivo '$ruta': $!\n";
    print $fh $datos_binarios;
    close($fh);
}




# Lee un archivo .lzw en modo binario y retorna su contenido.
sub leer_archivo {
    my ($clase, $ruta) = @_;

    open(my $fh, '<:raw', $ruta)
        or die "No se pudo leer el archivo '$ruta': $!\n";
    local $/;           # slurp mode: leer todo de una vez
    my $contenido = <$fh>;
    close($fh);

    return $contenido;
}

1; 