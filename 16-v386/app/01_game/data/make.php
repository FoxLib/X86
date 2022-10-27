<?php

$n    = 0;
$file = $argv[1];
$src  = imagecreatefrompng($file);
$w    = imagesx($src);
$h    = imagesy($src);
$str  = '';

$map = [];
for ($y = 0; $y < $h; $y++)
for ($x = 0; $x < $w; $x++)
    $map[$n++] = imagecolorat($src, $x, $y);

// Палитра
for ($i = 0; $i < 256; $i++) {

    $color = imagecolorsforindex($src, $i);
    $r = $color['red']   >> 4;
    $g = $color['green'] >> 4;
    $b = $color['blue']  >> 4;
    $str .= pack('v*', $r*256 + $g*16 + $b);
}

foreach ($map as $byte) $str .= chr($byte);
file_put_contents(preg_replace('~\.\w+$~', '.bin', $file), $str);
