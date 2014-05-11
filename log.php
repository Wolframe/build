<?php

require 'config.php';

$file = $_GET["file"];
$pos = $_GET["pos"];
$filter = $_GET["filter"];

$localFile = substr( $file, strlen( $BASE_URL ) );

if( $filter != '' ) {
  $tmp = tempnam( "/tmp", "BUILD" );
  $cmd = "grep \"$filter\" $localFile > $tmp";
  system( $cmd );
}

if( $filter != '' ) {
  exec( "wc -l $tmp | cut -f 1 -d ' '", $lines );
} else {
  exec( "wc -l $localFile | cut -f 1 -d ' '", $lines );
}

if( $filter == '' ) {
  $cmd = "sed -n -e $pos," . ( $pos + 20 ) . "p -e " . ( $pos + 21 ) . "q < $localFile";
} else {
  $cmd = "sed -n -e $pos," . ( $pos + 20 ) . "p -e " . ( $pos + 21 ) . "q < $tmp";
}

print $lines[0] . "\n";
exec( $cmd, $output );
$n = 0;

$output = str_replace( "&", "&amp;", $output );
$output = str_replace( ">", "&gt;", $output );
$output = str_replace( "<", "&lt;", $output );
foreach( $output as $line ) {
  print $line . "\n";
  $n++;
}

if( $filter != '' ) {
  unlink( $tmp );
}
