
# funcionamiento del Array Especial @-


* Persona.pm:
```{perl}
package Persona;

sub new {
    my ($class, $nombre) = @_;   # primer arg: clase, segundo arg: nombre
    my $self = { 
        nombre => $nombre 
        };
        
    bless $self, $class;
    
    return $self;
}

1;
```

main.pl:
```{perl}
use Persona;

my $p = Persona->new("Giovanni");

print $p->{nombre};  # Giovanni

```

Aquí internamente pasa esto:
```
@_ = ("Persona", "Giovanni")
$class = "Persona"
$nombre = "Giovanni"

```