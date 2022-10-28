<?php

class AsmParser {

    public $cond = ['nz'=>0,'z'=>1,'nc'=>2,'c'=>3,'ns'=>4,'s'=>5,'no'=>6,'o'=>7];
    public $alus = [
        'add'=>0,'adc'=>1,'sub'=>2,'sbc'=>3,'and'=>4,'xor'=>5,'or'=>6,'cmp'=>7,
        'shr'=>0,'sar'=>1,'shl'=>2,'ror'=>3
    ];

    public $src_filename;
    public $proc_name;
    public $proc_args = [];
    public $proc_buffer = [];
    public $proc_count = [];
    public $maps = [];

    public $debug_lst = false;
    public $defines = [];

    public function assign_argv($argv) {

        // Разбор аргументов
        foreach (array_map('trim', $argv) as $param) {

            if ($param == '-d') $this->debug_lst = true;
            if (preg_match('~^-D(.+?)=(.+)$~', $param, $c)) {
                $this->defines['$('.$c[1].')'] = $c[2];
            }
        }
    }

    /**
     * @desc Ассемблировать файл рекурсивно
     *
     * @param $filename
     * @param int $depth
     * @param array $rows
     *
     * @return array
     * @throws Exception
     */
    public function assemble($filename, int $depth = 0, $rows = []): array {

        if ($depth == 0) {
            $this->src_filename = $filename;
        }

        // Препарсер
        foreach (array_map('rtrim', file($filename)) as $row) {

            // Удаление комментария (кроме db ";")
            $row = trim(preg_replace('~;[^"\']*$~m', '', $row));
            $row = str_replace(array_keys($this->defines), array_values($this->defines), $row);

            if ($row === '') continue;

            // Обнаружена метка
            if (preg_match('~^([@.\w]+):(.*)$~', $row, $c)) {
                $rows[] = $c[1].":";
                $row = trim($c[2]);
            }

            // Если есть алиасы, использовать их
            if ($this->maps) {
                if (preg_match_all('~\b(' . join('|', array_keys($this->maps)) . ')\b~', $row, $c)) {
                    foreach ($c[1] as $n) {
                        $row = preg_replace('~\b' . $n . '\b~i', $this->maps[$n], $row);
                    }
                }
            }

            // Ссылки на аргументы
            if ($this->proc_args) {
                if (preg_match_all('~\b(' . join('|', array_keys($this->proc_args)) . ')\b~', $row, $c)) {
                    foreach ($c[1] as $i => $n) {

                        // Обратная нотация + внутренний буфер + 1 вызов call
                        $v   = (count($this->proc_args) - $this->proc_args[$n]) + $this->proc_count;
                        $row = preg_replace('~' . $c[0][$i] . '~i', "sp+$v", $row);
                    }
                }
            }

            // Подключение include
            // -----------------------------------------------------------------
            if (preg_match('~include\s+"(.+)"~i', $row, $c)) {

                $rows = $this->assemble($c[1], $depth + 1, $rows);
            }
            // Замена INC|DEC
            // -----------------------------------------------------------------
            else if (preg_match('~(inc|dec)\s+(r\d+)$~i', $row, $c)) {

                if (strtolower($c[1]) == 'inc') {
                    $rows[] = "addb ".$c[2].", 1";
                } else {
                    $rows[] = "subb ".$c[2].", 1";
                }
            }
            // Старт процедуры
            // -----------------------------------------------------------------
            else if (preg_match('~proc\s+([\w_.]+)\s*\((.*)\)(.*)$~', $row, $c)) {

                $_arg = trim($c[2]);
                $_arg = $_arg ? array_flip(array_map('trim', explode(',', $_arg))) : [];

                $this->proc_name   = $c[1];
                $this->proc_args   = $_arg;
                $this->proc_buffer = [];
                $this->proc_count  = 0;
                $this->maps        = [];

                $rows[] = $this->proc_name.":";

                // Процедурный фрейм
                if (preg_match('~^:\s*(.+)$~', trim($c[3]), $d)) {

                    // Разобрать параметры
                    foreach (preg_split('~\s+~', $d[1]) as $item) {

                        $rows[] = "push $item";
                        $count = 0;

                        if (preg_match('~r(\d+)-r(\d+)~i', $item, $e)) { // push ra-rb

                            $count = $e[2] - $e[1] + 1;
                            $this->proc_buffer[] = "pop r{$e[2]}-r{$e[1]}";

                        } else if (preg_match('~r(\d+)~i', $item, $e)) { // push ra

                            $count = 1;
                            $this->proc_buffer[] = "pop $item";
                        }

                        // Глубина внутреннего фрейма
                        $this->proc_count += $count;
                    }
                }
            }
            // Список переименований
            // -----------------------------------------------------------------
            else if (preg_match('~^map\s+(.+)$~i', $row, $c)) {

                $map = array_map('trim', explode(',', $c[1]));
                foreach ($map as $item) {
                    if (preg_match('~(.+):(.+)~', $item, $d)) {
                        $this->maps[trim($d[1])] = trim($d[2]);
                    }
                }
            }
            // Сброс локальных меток
            // -----------------------------------------------------------------
            else if (preg_match('~^endp$~i', $row)) {

                foreach (array_reverse($this->proc_buffer) as $item) {
                    $rows[] = $item;
                }

                // Определить возврат из процедуры
                if ($this->proc_args) {
                    $rows[] = "ret " . count($this->proc_args);
                } else {
                    $rows[] = "ret";
                }

                $this->proc_name = '';
                $this->proc_count = 0;
                $this->proc_args = [];
                $this->proc_buffer = [];
                $this->maps = [];
            }
            // invoke name(args) -> push... call
            // -----------------------------------------------------------------
            else if (preg_match('~call\s+([\w_.]+)\s*\((.+)\)$~i', $row, $c)) {

                // Список аргументов
                foreach (explode(',', $c[2]) as $push) $rows[] = "push $push";

                // Вызов функции
                $rows[] = "call ".$c[1];
            }
            else {
                $rows[] = $row;
            }
        }

        return $rows;
    }

    /**
     * @param $rows
     * @param array $params
     *
     * @return void
     */
    public function compile($rows, array $params = []) {

        $res = [];
        foreach ($rows as $row) {
            $res[] = $this->decode($row);
        }

        $filename = uniqid(mt_rand()).".asm";
        $output   = join("\n", $res);

        file_put_contents($filename, $output);
        $out = preg_replace('~\.asm~i', '.bin', $this->src_filename);
        $bash = "fasm $filename $out";
        echo `$bash`;

        // Оставлять дебаг
        if ($this->debug_lst) {
            rename($filename, $out.".lst");
        } else {
            unlink($filename);
        }
    }

    /**
     * @param $row
     *
     * @return mixed|string
     */
    public function decode($row) {

        $new_row = $row;

        if ($row) {

            $new_row = $this->decode_instr($row);

            // Сделать PAD на последнюю линию
            $tmpr = explode("\n", $new_row);
            $tmpr = 50 - strlen($tmpr[count($tmpr)-1]);

            // Выдача
            $new_row = $new_row. str_repeat(' ', ($tmpr > 0 ? $tmpr : 0)). "; $row";
        }

        return $new_row;
    }

    /**
     * @desc Декодировать строку
     * @param $row
     *
     * @return string
     */
    public function decode_instr($row): string {

        $row = trim($row);

        // HLT = JMP $
        if ($row == 'hlt') {
            $row = 'db 0x10, 0xFD, 0xFF'; // jmp $-3
        }
        // PUSH/POP regs
        // -------------------------------------------------------------------------
        else if (preg_match('~(push|pop)\s+(r\d+.*)$~i', $row, $c)) {

            $ids  = preg_split('~\s+~', trim($c[2]));
            $code = strtolower($c[1]);
            $rows = [];
            $row  = '';

            foreach ($ids as $rn) {

                // Диапазон
                if (preg_match('~r(\d+)-r(\d+)~i', $rn, $d)) {

                    if ($code == 'push') {
                        $rows[] = sprintf("db 0x0C, %d, %d", $d[1], $d[2]);
                    } else {
                        $rows[] = sprintf("db 0x0D, %d, %d", $d[1], $d[2]);
                    }

                } else if (preg_match('~r(\d+)~i', $rn, $d)) {

                    if ($code == 'push') {
                        $rows[] = sprintf("db 0x08, %d", $d[1]);
                    } else {
                        $rows[] = sprintf("db 0x09, %d", $d[1]);
                    }
                }
            }

            $row .= join("\n", $rows);
        }
        // -------------------------------------------------------------------------
        // MOV ra, [sp+disp]
        else if (preg_match('~mov\s*r(\d+)\s*,\s*\[\s*sp\s*(.+)]~i', $row, $c)) {

            $c[2] = str_replace(' ', '', $c[2]);
            $row = sprintf("db 0x0E, %s, %d", $c[2], $c[1]);
        }
        // MOV [sp+disp], ra
        if (preg_match('~mov\s*\[\s*sp\s*(.+)]\s*,\s*r(\d+)~i', $row, $c)) {

            $c[2] = str_replace(' ', '', $c[2]);
            $row = sprintf("db 0x0F, %d, %s", $c[2], $c[1]);
        }
        // MOV ra, sp
        else if (preg_match('~mov\s+r(\d+)\s*,\s*sp~i', $row, $c)) {
            $row = sprintf("db 0x16, %d", $c[1]);
        }
        // MOV sp, ra
        else if (preg_match('~mov\s+sp\s*,\s*r(\d+)~i', $row, $c)) {
            $row = sprintf("db 0x17, %d", $c[1]);
        }
        // -------------------------------------------------------------------------
        // MOV ra, rb
        else if (preg_match('~mov\s+r(\d+)\s*,\s*r(\d+)~i', $row, $c)) {
            $row = sprintf("db 0x00, %d, %d", $c[2], $c[1]);
        }
        // MOV ra, [expr]
        else if (preg_match('~mov\s+r(\d+)\s*,\s*(.+)~i', $row, $c)) {
            $row = sprintf("db 0x01, %d\ndd %s", $c[1], $c[2]);
        }
        // MOVU ra, u8
        else if (preg_match('~movu\s+r(\d+)\s*,\s*(.+)$~i', $row, $c)) {
            $row = sprintf("db 0x02, %d, %s", $c[1], $c[2]);
        }
        // MOVS ra, u8
        else if (preg_match('~movs\s+r(\d+)\s*,\s*(.+)$~i', $row, $c)) {
            $row = sprintf("db 0x03, %d, %s", $c[1], $c[2]);
        }
        // -------------------------------------------------------------------------
        // MOVB ra, [rb]
        else if (preg_match('~movb\s+r(\d+)\s*,\s*\[\s*r(\d+)\s*]~i', $row, $c)) {
            $row = sprintf("db 0x04, %d, %d", $c[2], $c[1]);
        }
        // MOVD ra, [rb]
        else if (preg_match('~movd\s+r(\d+)\s*,\s*\[\s*r(\d+)\s*]~i', $row, $c)) {
            $row = sprintf("db 0x05, %d, %d", $c[2], $c[1]);
        }
        // MOVB [rb], ra
        else if (preg_match('~movb\s+\[\s*r(\d+)\s*]\s*,\s*r(\d+)~i', $row, $c)) {
            $row = sprintf("db 0x06, %d, %d", $c[1], $c[2]);
        }
        // MOVD [rb], ra
        else if (preg_match('~movd\s+\[\s*r(\d+)\s*]\s*,\s*r(\d+)~i', $row, $c)) {
            $row = sprintf("db 0x07, %d, %d", $c[1], $c[2]);
        }
        // -------------------------------------------------------------------------
        // PUSH u8
        else if (preg_match('~pushb\s+(.+)$~i', $row, $c)) {
            $row = sprintf("db 0x0A, %s", $c[1]);
        }
        // PUSH u32
        else if (preg_match('~push\s+(.+)$~', $row, $c)) {
            $row = sprintf("db 0x0B\ndd %s", $c[1]);
        }
        // -------------------------------------------------------------------------
        // JMP ra
        elseif (preg_match('~jmp\s+r(\d)~i', $row, $c)) {
            $row = sprintf("db 0x11, %d", $c[1]);
        }
        // JMP s16
        elseif (preg_match('~jmp\s+(.+)~i', $row, $c)) {
            $row = sprintf("db 0x10\ndw %s-$-2", $c[1]);
        }
        // CALL ra
        elseif (preg_match('~call\s+r(\d)~i', $row, $c)) {
            $row = sprintf("db 0x13, %d", $c[1]);
        }
        // CALL s16
        elseif (preg_match('~call\s+(.+)~i', $row, $c)) {
            $row = sprintf("db 0x12\ndw %s-$-2", $c[1]);
        }
        else if (preg_match('~ret\s+(.+)$~', $row, $c)) {
            $row = sprintf("db 0x15, %s", $c[1]);
        }
        else if (preg_match('~ret$~', $row, $c)) {
            $row = "db 0x14";
        }
        // J<ccc> label
        else if (preg_match('~j(nc|nz|ns|no|z|c|s|o)\s+(.+)$~i', $row, $c)) {
            $row = sprintf("db 0x%02x, %s-$-1", 0x18 + $this->cond[strtolower($c[1])], $c[2]);
        }
        // Арифметико-логика и сдвиги
        // -------------------------------------------------------------------------
        // ALU ra, rb, rc
        else if (preg_match('~(add|adc|sub|sbc|and|xor|or|cmp)\s+r(\d+)\s*,\s*r(\d+)\s*,\s*r(\d+)~i', $row, $c)) {
            $row = sprintf("db 0x%02x, %d, %d, %d", 0x20 + $this->alus[ strtolower($c[1]) ], $c[4], $c[3], $c[2]);
        }
        // <alu>[b] ra, s8|u32
        else if (preg_match('~(add|adc|sub|sbc|and|xor|or|cmp)(b?)\s+r(\d+)\s*,\s*(.+)~i', $row, $c)) {

            $id = $this->alus[ strtolower($c[1]) ];
            if (strtolower($c[2]) == 'b') {
                $row = sprintf("db 0x%02x, %d, %s", 0x30 + $id, $c[3], $c[4]);
            } else {
                $row = sprintf("db 0x%02x, %d\ndd %s", 0x28 + $id, $c[3], $c[4]);
            }
        }
        // <sft> ra, rb
        else if (preg_match('~(shr|sar|shl|ror)\s+r(\d+)\s*,\s*r(\d+)~i', $row, $c)) {
            $row = sprintf("db 0x%02x, %d, %d", 0x38 + $this->alus[ strtolower($c[1]) ], $c[3], $c[2]);
        }
        // <sft> ra, i8
        else if (preg_match('~(shr|sar|shl|ror)\s+r(\d+)\s*,(.+)~i', $row, $c)) {
            $row = sprintf("db 0x%02x, %d, %s", 0x3c + $this->alus[ strtolower($c[1]) ], $c[2], $c[3]);
        }
        // -----------------------
        // MUL ra, rb
        else if (preg_match('~mul\s+r(\d+)\s*,\s*r(\d+)~i', $row, $c)) {
            $row = sprintf("db 0x40, %d, %d", $c[2], $c[1]);
        }

        return $row;
    }
}
