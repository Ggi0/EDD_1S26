

# @_ array especial, en donde las subrutinas reciben sus argumentos
sub ejemplo {
    print "Argumentos: @_ \n";
}

# no existe como tal el 
# void saludar(String nombre, int edad) { ... }
ejemplo("uno", "dos", "tres");


# Si pasamos más de dos argumentos, los demás se ignoran (a menos que los captures).
# Si pasas menos de dos, las variables que faltan quedan en undef.



sub demo {
    my ($x, $y) = @_;
    print "x=$x, y=$y\n";
}

demo("uno", "dos", "tres");
# x=uno, y=dos   (el "tres" se ignora)



