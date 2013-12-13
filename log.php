<?php

$file = $_GET["file"];
$pos = $_GET["pos"];

$cmd = "sed -n -e $pos," . ( $pos + 30 ) . "p -e " . ( $pos + 31 ) . "q < ../../../$file";
exec( $cmd, $output );
$n = 0;
foreach( $output as $line ) {
  print "[" . ( $pos + $n ) . "] " . $line . "\n";
  $n++;
}
