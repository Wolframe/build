<?php

require 'config.php';

$file = $_GET["file"];
$pos = $_GET["pos"];

$localFile = substr( $file, strlen( $BASE_URL ) );

$cmd = "sed -n -e $pos," . ( $pos + 20 ) . "p -e " . ( $pos + 21 ) . "q < $localFile";
exec( $cmd, $output );
$n = 0;
foreach( $output as $line ) {
  print "[" . ( $pos + $n ) . "] " . $line . "\n";
  $n++;
}
