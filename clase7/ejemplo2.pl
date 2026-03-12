

use strict;
use warnings;

use FindBin;
use lib "$FindBin::Bin";

use avl::avl;
use avl::graficar;

use constant AVL      => 'avl::avl';
use constant Graficar => 'avl::graficar';

sub main {

    my $arbol = AVL->new();

    print " Insercion que provoca rotacion LL\n";
    $arbol->insertar(50);
    $arbol->insertar(25);
    $arbol->insertar(75);
$arbol->insertar(90);
$arbol->insertar(80);
$arbol->insertar(115);
$arbol->insertar(85);

$arbol->insertar(15);
$arbol->insertar(10);
$arbol->insertar(20);
$arbol->insertar(17);
$arbol->insertar(22);
$arbol->insertar(18);
$arbol->insertar(19);

    Graficar->graficar($arbol, "10_avl_grande");

}

main() unless caller;