
# declaracion de hash
my %frutas = (
    manzanas => 6,
    naranjas => 5,
    uvas => 3,
);

print "\n\n";
print (%frutas);
print ("\nDireccion de memoria de FRUTAS: " . \%frutas . "\n");
print "Manzanas: $frutas{manzanas}\n\n";


my $ref_frutas = \%frutas;
    print "\n valor de la variable \$ref_frutas: ";
    print ($ref_frutas);

print "\n valores \$ref_frutas: ";
    print ($ref_frutas{manzanas}); # incorrecto no funciona

print "\n valores \$ref_frutas: ";
    print ("$ref_frutas->{manzanas}, ");
    print ("$ref_frutas->{naranjas}, ");
    print ("$ref_frutas->{uvas}");

        # por que no podemos hacer un hash dentro de otro hash:
        my %hash_malo = (
            a => ( 
                    x => 1, 
                    y => 2,
                ), 
            b => 4,  
        );

        # perl mira esto:
        # a => x => 1, y => 2

        # lo interpreta así: a => x, 1 => y, 2
        # ( a => "x", 1 => "y", 2 => b, 4 => undef)
        print("\n\n ----> $hash_malo{b}");


 # En Perl, si quieres que un valor sea otro hash, necesitas referencias.
 # { ... } crea una referencia a un hash anónimo.
my $ref2_frutas = {
    manzanas => 6,
    naranjas => 5,
    peras    => 3,
    uvas     => 2,
};

print "\nHash FRUTAS:         $frutas{manzanas}\n";
print "Referencia (frutas): $ref_frutas->{manzanas}\n";
print "Referencia (ref2):   $ref2_frutas->{manzanas}\n";


        my %hash_bueno = (
            a => { 
                    x => 1, 
                    y => 2,
                }, 
            b => 4,  
        ); 

       #print("\n\n ----> $hash_bueno{a}->{y}");
        print("\n\n ----> $hash_bueno{a}{x}");

