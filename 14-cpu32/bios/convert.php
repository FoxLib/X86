<?php

$out  = '';
$bios = file_get_contents(__DIR__ . '/bios.bin');
for ($i = 0; $i < strlen($bios); $i++) {
    $out .= sprintf("%02x\n", ord($bios[$i]));
}
file_put_contents("bios.hex", $out);
