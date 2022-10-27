// Прочитать байт modrm+sib
fetch_modrm: case (fn2)

    // Считывание регистров
    0: begin

        modrm <= in;
        ip    <= ip_next;
        ea    <= 1'b0;

        // Левый операнд
        case (dir ? in[5:3] : in[2:0])
        0: op1 <= size ? ax : ax[ 7:0];
        1: op1 <= size ? cx : cx[ 7:0];
        2: op1 <= size ? dx : dx[ 7:0];
        3: op1 <= size ? bx : bx[ 7:0];
        4: op1 <= size ? sp : ax[15:8];
        5: op1 <= size ? bp : cx[15:8];
        6: op1 <= size ? si : dx[15:8];
        7: op1 <= size ? di : bx[15:8];
        endcase

        // Правый операнд
        case (dir ? in[2:0] : in[5:3])
        0: op2 <= size ? ax : ax[ 7:0];
        1: op2 <= size ? cx : cx[ 7:0];
        2: op2 <= size ? dx : dx[ 7:0];
        3: op2 <= size ? bx : bx[ 7:0];
        4: op2 <= size ? sp : ax[15:8];
        5: op2 <= size ? bp : cx[15:8];
        6: op2 <= size ? si : dx[15:8];
        7: op2 <= size ? di : bx[15:8];
        endcase

        // Эффективный адрес
        case (in[2:0])
        3'b000: ea[15:0] <= bx + si;
        3'b001: ea[15:0] <= bx + di;
        3'b010: ea[15:0] <= bp + si;
        3'b011: ea[15:0] <= bp + di;
        3'b100: ea[15:0] <= si;
        3'b101: ea[15:0] <= di;
        3'b110: ea[15:0] <= ^in[7:6] ? bp : 1'b0;
        3'b111: ea[15:0] <= bx;
        endcase

        // Выбор сегмента по умолчанию
        if (!override && (in[2:1] == 2'b01 || (^in[7:6] && in[2:0] == 3'b110)))
            segment <= ss;

        // Выбор решения
        case (in[7:6])
        2'b00: begin

            // Читать +disp16
            if (in[2:0] == 3'b110) fn2 <= 1;
            // Сразу читать операнды из памяти
            else begin

                fn2 <= 4;
                src <= 1'b1;

                if (ignoreo) begin t <= exec; fn2 <= 0; end

            end

        end
        2'b01: fn2 <= 3; // 8 bit
        2'b10: fn2 <= 1; // 16 bit
        2'b11: begin fn2 <= 0; t <= exec; end
        endcase

    end

    // DISP16/32
    1: begin fn2 <= 2; ea <= ea + in; ip <= ip_next; end
    2: begin

        fn2      <= 4;
        src      <= 1'b1;
        ea[15:8] <= ea[15:8] + in;
        ip       <= ip_next;

        if (ignoreo) begin t <= exec; fn2 <= 0; end

    end

    // DISP8
    3: begin

        fn2 <= 4;
        ea  <= ea + {{24{in[7]}}, in};
        src <= 1'b1;
        ip <= ip_next;

        if (ignoreo) begin t <= exec; fn2 <= 0; end

    end

    // OPERAND-7:0
    4: begin

        if (dir) op2 <= in; else op1 <= in;
        if (size) begin fn2 <= 5; ea <= ea + 1; end
        else      begin fn2 <= 0; t  <= exec; src <= src_next; end

    end

    // OPERAND-15:8
    5: begin

        if (dir) op2[15:8] <= in; else op1[15:8] <= in;

        fn2 <= 0;
        ea  <= ea - 1;
        t   <= exec;
        src <= src_next;

    end

endcase

// Запись результата в память или регистры
modrm_wb: case (fn2)

    0: begin

        // Проверка на запись в регистр
        if (dir || modrm[7:6] == 2'b11) begin

            case (dir ? modrm[5:3] : modrm[2:0])
            3'b000: if (size) ax <= wb; else ax[ 7:0] <= wb[7:0];
            3'b001: if (size) cx <= wb; else cx[ 7:0] <= wb[7:0];
            3'b010: if (size) dx <= wb; else dx[ 7:0] <= wb[7:0];
            3'b011: if (size) bx <= wb; else bx[ 7:0] <= wb[7:0];
            3'b100: if (size) sp <= wb; else ax[15:8] <= wb[7:0];
            3'b101: if (size) bp <= wb; else cx[15:8] <= wb[7:0];
            3'b110: if (size) si <= wb; else dx[15:8] <= wb[7:0];
            3'b111: if (size) di <= wb; else bx[15:8] <= wb[7:0];
            endcase

            t   <= t_next;
            src <= 1'b0;

        end
        // LO-BYTE
        else begin

            out <= wb[7:0];
            we  <= 1'b1;
            src <= 1'b1;
            fn2 <= 1;

        end

    end

    // HI-BYTE
    1: begin

        if (size) begin out <= wb[15:8]; ea <= ea + 1; fn2 <= 2; end
        else      begin fn2 <= 0; t <= t_next; {src, we} <= 2'b00;  end

    end

    // BYTE-3
    2: begin

        fn2 <= 0;
        t   <= t_next;
        {src, we} <= 2'b00;

    end

endcase

// Считать 16 или 32 бита
fetch_imm16: case (fn2)

    0: begin ip <= ip_next; wb        <= in; fn2 <= 1; end
    1: begin ip <= ip_next; wb[15:8]  <= in; fn2 <= 0; t <= exec; end

endcase

// Загрузка сегмента из wb
loadseg: case (fn2)

    // Пока что загрузка идет только в REALMODE
    0: begin

        t   <= t_next;
        src <= 1'b0;

        // Обновить сегмент | селектор
        case (regn)
        3'h0: begin es[15:0] <= wb; end
        3'h1: begin cs[15:0] <= wb; end
        3'h2: begin ss[15:0] <= wb; end
        // Заместить "скрытый" сегмент
        3'h3: begin ds[15:0] <= wb; __segment[15:0] <= wb; end
        default: t <= exception;
        endcase

    end

endcase

// Запись в стек
push: case (fn2)

    // BYTE-1
    0: begin

        fn2     <= 1;
        segment <= ss;
        ea      <= sp_dec;
        sp      <= sp_dec;
        src     <= 1'b1;
        we      <= 1'b1;
        out     <= wb[7:0];

    end

    // Запись байтов 2/3/4/FIN
    1: begin ea <= ea + 1; out <= wb[ 15:8]; fn2 <= 2; end
    2: begin {we, src} <= 2'b00; fn2 <= 0; t <= t_next; end

endcase

// Извлечь из стека
pop: case (fn2)

    // Установка адреса
    0: begin

        fn2     <= 1;
        segment <= ss;
        ea      <= sp;
        sp      <= sp_inc;
        src     <= 1'b1;

    end

    // 16bit
    1: begin fn2 <= 2; wb <= in; ea <= ea + 1; end
    2: begin

        wb[15:8] <= in;

        fn2 <= 0;
        ea  <= ea + 1;
        src <= 1'b0;
        t   <= t_next;

    end

endcase

// Сдвиги
// alu
// size, opsize
// op1, op2
shift: case (fn2)

    // Вычисление ограничения количества сдвигов
    // Если сдвиг не задан (0), то сдвиг не срабатывает
    0: begin

        fn2 <= 1;

        // 32 bit
        if (size) begin

            // DosBox так обрабатывает (4:0)
            wb  <= 15;
            op2 <= op2[4:0];
            if (op2[4:0] == 0) begin fn2 <= 0; src <= 1'b0; t <= fetch; end

        end
        // 8 bit
        else begin

            wb  <= 7;
            op2 <= op2[2:0];

            if (op2[2:0] == 0) begin fn2 <= 0; src <= 1'b0; t <= fetch; end

        end

    end

    // Вычисление
    1: begin

        // Сдвиги
        if (op2) begin

            op2 <= op2 - 1;

            case (alu)

                0: // ROL
                begin op1 <= size ? {op1[14:0],op1[15]} : {op1[6:0],op1[7]}; end

                1: // ROR
                begin op1 <= size ? {op1[0],op1[15:1]} : {op1[0],op1[7:1]}; end

                2: // RCL
                begin

                    op1 <= size ? {op1[14:0],flags[CF]} : {op1[6:0],flags[CF]};
                    flags[CF] <= op1[wb];

                end

                3: // RCR
                begin

                    op1 <= size ? {flags[CF], op1[15:1]} : {flags[CF], op1[7:1]};
                    flags[CF] <= op1[0];

                end

                4, 6: // SHL
                begin

                    flags[CF] <= op1[wb-op2+1];
                    op1 <= op1 << op2;
                    op2 <= 0;

                end

                5: // SHR
                begin

                    flags[CF] <= op1[op2-1];
                    op1 <= op1 >> op2;
                    op2 <= 0;

                end

                7: // SAR
                begin

                    op1 <= size ? {op1[15],op1[15:1]} : {op1[7],op1[7:1]};
                    flags[CF] <= op1[0];

                end

            endcase

        end
        // Расчет флагов
        else begin

            fn2 <= 0;
            t   <= modrm_wb;
            wb  <= op1;

            case (alu)

                0: begin flags[CF] <= op1[0];  flags[OF] <= op1[0]  ^ op1[wb];   end
                1: begin flags[CF] <= op1[wb]; flags[OF] <= op1[wb] ^ op1[wb-1]; end
                2: begin flags[OF] <= flags[CF] ^ op1[wb]; end
                3: begin flags[OF] <= op1[wb] ^ op1[wb-1]; end
                default: begin

                    flags[ZF] <= !op1;
                    flags[SF] <= op1[wb];
                    flags[PF] <= ~^op1[7:0];
                    flags[AF] <= 1'b1;

                end

            endcase

        end
    end

endcase

// Процедура деления [diva, divb, divcnt]
divide: begin

    if (divcnt) begin

        // Следующий остаток
        divrem <= _divr >= divb ? _divr - divb : _divr;

        // Вдвиг нового бита результата
        divres <= {divres[30:0], _divr >= divb};

        // Сдвиг влево делимого
        diva   <= {diva[30:0], 1'b0};

        // Уменьшение счетчика
        divcnt <= divcnt - 1'b1;

    end
    else t <= t_next;

end

// portin: begin end
// portout: begin end

// Вызов прерывания wb
interrupt: case (fn)

    // Запись в стек eflags|cs|ip
    0: begin

        fn          <= 1;
        t           <= push;
        t_next      <= interrupt;
        wb          <= flags;
        flags[IF]   <= 1'b0;
        flags[TF]   <= 1'b0;
        op1         <= wb;

    end
    1: begin fn <= 2; t <= push; wb <=  cs[15:0]; end
    2: begin fn <= 3; t <= push; wb <= ip[15:0]; end
    // Загрузка данных из IDTR
    3: begin fn <= 4; ea <= {op1[7:0], 2'b00}; src <= 1'b1; segment[15:0] <= 16'h0000; end
    4: begin fn <= 5; ip[ 7:0] <= in; ea <= ea + 1; end
    5: begin fn <= 6; ip[15:8] <= in; ea <= ea + 1; end
    6: begin fn <= 7; wb [ 7:0] <= in; ea <= ea + 1; end
    7: begin

        t           <= loadseg;
        t_next      <= fetch;
        fn          <= 0;
        fn2         <= 0;
        wb[15:8]    <= in;
        regn        <= 1;

    end

endcase

