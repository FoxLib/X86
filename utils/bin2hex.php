<?php

$s = array();
$bin = file_get_contents($argv[1]);
for ($i = 0; $i < strlen($bin); $i++) {
    $s[] = sprintf("%02x\n", ord($bin[$i]));
}
file_put_contents($argv[2], join($s));