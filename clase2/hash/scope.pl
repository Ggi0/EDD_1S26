
# como funciona el `my`
# las varibles declarada con my unicamente "viven" dentro de la funcion
# realizar la llamada a la misma fuera de dicha función (scope), no funcionará.

$valor_fueraFuncion = 30;

sub multiplicacion{
    my $valor_dentroFuncion = 10;

    print "-> variable dentro de la funcion: $valor_dentroFuncion\n";
    print "-> variable dentro de la funcion, pero declarada afuera :$valor_fueraFuncion\n\n";
}


print "\n-> variable dentro de la funcion, pero la llamamos desde afuera:$valor_dentroFuncion\n";
print "-> variable declarada fuera de la función: $valor_fueraFuncion\n";

print "$hola\n";

multiplicacion();
