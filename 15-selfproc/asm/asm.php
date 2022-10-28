<?php

include __DIR__ . '/asmparser.php';

$asm = new AsmParser();

try {

    $asm->assign_argv($argv);
    $rows = $asm->assemble($argv[1] ?? "");
    $asm->compile($rows, array_slice($argv, 2));

} catch (Exception $e) {

    echo $e->getMessage();
}

