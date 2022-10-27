exec: casex (opcode)

// 00 <ALU> modrm
8'b00xx_x0xx: begin

    t       <= modrm_wb;
    wb      <= alu_r;
    flags   <= alu_f;

    if (alu == alu_cmp) begin t <= fetch; src <= 1'b0; end

end

// 04 <ALU> a, imm
8'b00xx_x10x: case (fn)

    // Выставить операнды на вычисление
    0: begin

        op1 <= size ? ax : ax[7:0];
        op2 <= size ? wb : in;
        fn  <= 1;
        if (size == 0) ip <= ip_next;

    end

    // Записать результаты в AL|AX|EAX
    1: begin

        t       <= fetch;
        flags   <= alu_f;

        if (alu != alu_cmp) begin

            if (size) ax[15:0] <= alu_r[15:0];
            else      ax[7:0]  <= alu_r[7:0];

        end

    end

endcase

// 07 POP sreg
8'b000x_x111: begin

    t       <= loadseg;
    t_next  <= fetch;
    regn    <= opcode[4:3];

end

// 40 INC|DEC r16
8'b0100_xxxx: case (fn)

    // Загрузка
    0: begin

        fn  <= 1;
        op1 <= reg16;
        op2 <= 1;
        alu <= opcode[3] ? alu_sub : alu_add;

    end

    // Вычисление
    1: begin

        t           <= modrm_wb;
        wb          <= alu_r;
        flags       <= {alu_f[11:1], flags[CF]};
        dir         <= 1'b1;
        modrm[5:3]  <= opcode[2:0];

    end

endcase

// 50 PUSH r16
8'b0101_0xxx: begin

    t  <= push;
    wb <= reg16;

end

// 58 POP r16
8'b0101_1xxx: begin

    t           <= modrm_wb;
    t_next      <= fetch;
    size        <= 1'b1;
    dir         <= 1'b1;
    modrm[5:3]  <= opcode[2:0];

end

// 60 PUSHA
8'b0110_0000: begin

    if (regn == 7) t_next <= fetch;

    wb   <= regn == 4 ? frametemp : reg16;
    t    <= push;
    regn <= regn + 1;

end

// 60 POPA
8'b0110_0001: begin

    t    <= regn == 0 ? fetch : pop;
    regn <= regn - 1;

    case (regn)

        0: ax <= wb;
        1: cx <= wb;
        2: dx <= wb;
        3: bx <= wb;
        // esp skip
        5: bp <= wb;
        6: si <= wb;
        7: di <= wb;

    endcase

end

// 68 PUSH i16
8'b0110_10x0: begin

    t       <= push;
    t_next  <= fetch;

    if (opcode[1]) begin wb <= {{24{in[7]}}, in}; ip <= ip_next; end

end

// 69 IMUL r16, rm, i16/i8
8'b0110_10x1: case (fn)

    0: begin

        fn      <= 1;
        t       <= opcode[1] ? exec : fetch_imm16;
        t_next  <= exec;
        op1     <= op2;
        wb      <= in;

        if (opcode[1]) ip <= ip_next;

    end

    1: begin

        fn      <= 2;
        op1     <= {{16{op2[15]}}, op2[15:0]};
        op2     <= opcode[1] ? {{24{wb[7]}}, wb[7:0]} : ({{16{wb[15]}}, wb[15:0]});

    end

    2: begin


        wb          <= mult[15:0];
        flags[CF]   <= mult[31:16] ? 1 : 0;
        flags[OF]   <= mult[31:16] ? 1 : 0;
        t           <= modrm_wb;
        t_next      <= fetch;

    end

endcase

// 80 <ALU> rm, i8/16
8'b1000_00xx: case (fn)

    // Считывние 8 бит или дочитывание 16/32
    0: begin

        fn  <= 2;
        alu <= modrm[5:3];

        case (opcode[1:0])
        /*I8 */ 0, 2: begin ip <= ip_next;     op2 <= in; end
        /*I16*/ 1:    begin t  <= fetch_imm16; fn <= 1; end
        /*S8 */ 3:    begin ip <= ip_next;     op2 <= {{8{in[7]}}, in}; end
        endcase

    end

    // Данные из Imm16/32
    1: begin fn <= 2; op2 <= wb; end

    // Запись результата
    2: begin

        t       <= modrm_wb;
        wb      <= alu_r;
        flags   <= alu_f;
        src     <= 1'b1;

        if (alu == alu_cmp) begin t <= fetch; src <= 1'b0; end

    end

endcase

// 84 TEST modrm
8'b1000_010x: begin

    flags   <= alu_f;
    fn      <= 1'b0;
    t       <= fetch;
    src     <= 1'b0;

end

// 86 XCHG rm,r
8'b1000_011x: case (fn)

    0: begin t <= modrm_wb; wb <= op2; t_next <= exec;  fn  <= 1; end
    1: begin t <= modrm_wb; wb <= op1; t_next <= fetch; dir <= 0; end

endcase

// 88 MOV modrm
// 8D LEA
8'b1000_10xx,
8'b1000_1101: begin

    t   <= modrm_wb;
    wb  <= opcode[2] ? ea : op2;

end

// 8C MOV r, sreg
8'b1000_110x: begin

    t <= modrm_wb;

    case (modrm[5:3])
    3'h0: wb <= es[15:0];
    3'h1: wb <= cs[15:0];
    3'h2: wb <= ss[15:0];
    3'h3: wb <= ds[15:0];
    default: t <= exception;
    endcase

end

// 8E MOV sreg, rm
8'b1000_1110: begin

    wb   <= op2;
    t    <= modrm[5:3] == 3'b001 ? exception : loadseg;
    regn <= modrm[5:3];

end

// 8F POP rm
8'b1000_1111: case (fn)

    1: begin t <= fetch_modrm; fn <= 2; {dir, ignoreo} <= 2'b01; end
    2: begin t <= modrm_wb; t_next <= fetch; end

endcase

// 90 XCHG ax, r16
8'b1001_0xxx: begin

    t           <= modrm_wb;
    wb          <= ax;
    dir         <= 1'b1;
    modrm[5:3]  <= regn;

    ax <= reg16;

end

// 9A JMP|CALL FAR
8'b1001_1010,
8'b1110_1010: case (fn)

    0: begin fn <= 1; op1 <= wb; t <= fetch_imm16; end
    1: begin

        fn      <= 2;
        t       <= loadseg;
        t_next  <= opcode[4] ? exec : fetch; // CALL | JMP
        regn    <= 3'h1; // CS:
        ip      <= op1;

        // Для CALL
        op1 <= ip;
        op2 <= cs[15:0];

    end

    2: begin fn <= 3; t <= push; wb <= op2; end
    3: begin fn <= 0; t <= push; wb <= op1; t_next <= fetch; end

endcase

// 9D POPF
8'b1001_1101: begin

    t <= fetch;
    flags[15:0] <= {wb[11:6], 1'b0, wb[4], 1'b0, wb[2], 1'b1, wb[0]};

end

// A0 MOV a,[m] || mov [m],a
8'b1010_00xx: case (fn)

    // Либо запись в память, либо чтение
    0: begin

        fn      <= 1;
        src     <= 1'b1;
        ea      <= wb;
        size    <= opcode[0];

        if (opcode[1]) begin

            t       <= modrm_wb;
            wb      <= ax;
            dir     <= 1'b0;
            modrm   <= 1'b0;

        end

    end

    // AL, [mem]
    1: begin

        fn <= 2;
        ea <= ea + 1;
        ax[7:0] <= in;
        if (opcode[0] == 1'b0) begin fn <= 0; src <= 1'b0; t <= fetch; end

    end

    2: begin

        fn <= 3;
        ea <= ea + 1;
        ax[15:8] <= in;
        fn  <= 0;
        src <= 1'b0;
        t   <= fetch;

    end

endcase

// A4 MOVSx
8'b1010_010x: begin

    t       <= modrm_wb;
    t_next  <= fetch;
    segment <= es;
    ea      <= di;
    wb      <= op1;
    modrm   <= 1'b0;
    si      <= str_si;
    di      <= str_di;

    if (rep[1]) begin cx <= str_cx; ip <= ip_rep; end

end

// A6 CMPSx
8'b1010_011x: case (fn)

    0: begin // Читать ES:eDI

        fn      <= 1;
        fn2     <= 4;
        dir     <= 1'b1;
        segment <= es;
        ea      <= di;
        t       <= fetch_modrm;

    end
    1: begin // Инкременты, запись в eflags

        t       <= fetch;
        src     <= 1'b0;
        flags   <= alu_f;
        si      <= str_si;
        di      <= str_di;

        if (rep[1]) cx <= str_cx;
        if (rep[1] && rep[0] == alu_f[ZF]) ip <= ip_rep;

    end

endcase

// A8 TEST a,imm
8'b1010_100x: case (fn)

    0: begin

        fn  <= 1;
        op1 <= ax;
        op2 <= opcode[0] ? wb : in;
        alu <= alu_and;

        if (opcode[0] == 1'b0) ip <= ip_next;

    end

    1: begin flags <= alu_f; fn <= 1'b0; t <= fetch; end

endcase

// AC LODSx
8'b1010_110x: begin

    t   <= fetch;
    src <= 1'b0;
    si  <= str_si;

    // Загрузка в Acc
    if (size) ax[15:0] <= op1[15:0];
    else      ax[7:0]  <= op1[ 7:0];

    if (rep[1]) begin cx <= str_cx; ip <= ip_rep; end

end

// AE SCASx
8'b1010_111x: begin

    src     <= 1'b0;
    t       <= fetch;
    flags   <= alu_f;
    di      <= str_di;

    if (rep[1]) cx <= str_cx;
    if (rep[1] && rep[0] == alu_f[ZF]) ip <= ip_rep;

end

// B0 MOV r, imm
8'b1011_xxxx: begin

    t           <= modrm_wb;
    dir         <= 1'b1;
    size        <= opcode[3];
    modrm[5:3]  <= opcode[2:0];

    // 8 битное значение
    if (!opcode[3]) begin ip <= ip_next; wb <= in; end

end

// C6 MOV modrm, imm
8'b1100_011x: case (fn)

    // Запросить считывание immediate
    0: begin

        fn  <= size ? 2 : 1;
        src <= 1'b0;

        if (size) t <= fetch_imm16;

    end

    1: begin fn  <= 2; wb <= in; ip <= ip_next; end
    2: begin src <= 1'b1; t <= modrm_wb; t_next <= fetch; end

endcase

// C0 SHIFT
8'b1100_000x,
8'b1101_00xx: begin

    t       <= shift;
    t_next  <= fetch;
    alu     <= modrm[5:3];
    src     <= 1'b1;

    if (opcode[4]) begin
        op2 <= opcode[1] ? cx[5:0] : 1'b1;
    end
    else begin
        ip  <= ip_next;
        op2 <= in;
    end


end

// C4 LES|LDS r,[m]
8'b1100_010x: case (fn)

    0: begin fn <= 1; t <= modrm_wb; t_next <= exec; wb <= op2; end
    1: begin fn <= 2; src <= 1'b1; ea <= ea + 2; end
    2: begin wb[7:0] <= in; fn <= 3; ea <= ea + 1; end
    3: begin

        t           <= loadseg;
        t_next      <= fetch;
        regn        <= opcode[0] ? 3 : 0;
        wb[15:8]    <= in;

    end

endcase

// C2 RET; RET imm
8'b1100_001x: case (fn)

    0: begin fn <= 1; t <= pop; op1 <= wb; end
    1: begin

        t <= fetch;

        ip <= wb;
        sp <= sp + op1;

    end

endcase

// C8 ENTER imm,i8
8'b1100_1000: case (fn)

    0: begin

        fn  <= in ? 1 : 2;
        op1 <= wb;
        op2 <= in;
        ip <= ip_next;
        t   <= push;
        wb  <= bp;
        frametemp <= sp_dec;

    end

    1: begin

        t   <= push;
        wb  <= op2 >  1 ? bp-2 : frametemp;
        bp  <= op2 >  1 ? bp-2 : bp;
        fn  <= op2 == 1 ? 2 : 1;
        op2 <= op2 - 1;

    end

    2: begin

        t  <= fetch;
        bp <= frametemp;
        sp <= bp - op1;

    end

endcase

// LEAVE
8'b1100_1001: begin bp <= wb; t <= fetch; end

// CA RETF; RETF imm
8'b1100_101x: case (fn)

    0: begin fn <= 1; t <= pop; op1 <= wb; end

    1: begin

        fn <= 2;
        t  <= pop;
        ip <= wb;

    end

    2: begin

        t       <= loadseg;
        t_next  <= fetch;
        regn    <= 3'h1; // CS:
        sp      <= sp + op1;

    end

endcase

// CD INT i8
8'b1100_1101: begin t <= interrupt; ip <= ip_next; wb <= in; end

// CF IRET
8'b1100_1111: case (fn)

    1: begin fn <= 2; t <= pop; op1 <= wb; end
    2: begin fn <= 3; t <= pop; op2 <= wb; end
    3: begin

        t       <= loadseg;
        t_next  <= fetch;
        regn    <= 1;
        flags   <= wb;
        wb      <= op2;
        ip      <= op1;

    end

endcase

// E4 IN eAX, dx/i8
8'b1110_x10x: case (fn)

    0: begin

        fn       <= 1;
        ip       <= ip_next;
        port     <= in;
        port_clk <= 1'b0;

    end
    1: begin fn <= 2; port_clk <= 1; end
    2: begin fn <= 3; port_clk <= 0; end
    3: begin fn <= 1;

        case (op2[0])

            0: ax[7:0]   <= port_i; // 8  bit
            1: ax[15:8]  <= port_i; // 16 bit

        endcase

        port     <= port     + 1'b1;
        op2[1:0] <= op2[1:0] + 1'b1;

        if (op1[1:0] == op2[1:0]) t <= fetch;

    end

endcase

// E8 CALL a16
8'b1110_1000: begin

    t       <= push;
    t_next  <= fetch;
    wb      <= ip;
    ip      <= ip + wb;

end

// D4 AAM
8'b1101_0100: case (fn)

    0: begin

        fn      <= 1;
        t       <= in ? divide : interrupt;
        t_next  <= exec;
        diva    <= {ax[7:0], 24'b0};
        divb    <= in;
        divcnt  <= 8;
        wb      <= 0;
        ip     <= ip_next;

    end

    1: begin

        src <= 1'b0;
        t   <= fetch;

        if (divb) begin

            ax <= {divres[7:0], divrem[7:0]};
            flags[ZF] <= ax[15:0] == 0;
            flags[SF] <= ax[15];
            flags[PF] <= ~^ax[15];

        end

    end

endcase

// D5 AAD
8'b1101_0101: begin

    t           <= fetch;
    ip         <= ip_next;
    ax[15:0]   <= aam;
    flags[ZF]  <= aam[15:0] == 0;
    flags[SF]  <= aam[15];
    flags[PF]  <= ~^aam[15];

end

// D7 XLATB
8'b1101_0111: begin

    ax[7:0] <= in;
    src     <= 1'b0;
    t       <= fetch;

end

// E0 LOOP | JMP | J<ccc> short b8
8'b1110_00xx,
8'b1110_1011,
8'b0111_xxxx: begin

    t   <= fetch;
    ip <= ip + 1'b1 + {{24{in[7]}}, in};

end

// E6 OUT dx/i8, eAX
8'b1110_x11x: case (fn)

    0: begin

        fn       <= 1;
        ip      <= ip_next;
        port     <= in;
        port_clk <= 1'b0;

    end

    1: begin

        fn       <= 2;
        port_w   <= 1;
        port_clk <= 1;

        case (op2[0])

            0: port_o <= ax[  7:0];
            1: port_o <= ax[ 15:8];

        endcase

    end
    2: begin fn <= 3; port_w <= 0; port_clk <= 0; end
    3: begin fn <= 1;

        port     <= port     + 1'b1;
        op2[1:0] <= op2[1:0] + 1'b1;

        if (op1[1:0] == op2[1:0]) t <= fetch;

    end

endcase

// E9 JMP near
9'b0_1110_1001,
9'b1_1000_xxxx: begin

    t  <= fetch;
    ip <= ip + wb;

end

// Групповые инструкции F6/F7
8'b1111_011x: casex (modrm[5:3])

    // TEST rm, imm
    3'b00x: case (fn)

        // Сброс src, если был для imm8
        0: if (src) src <= 1'b0;
        else begin

            fn  <= opcode[0] ? 1 : 2;
            t   <= opcode[0] ? fetch_imm16 : exec;
            op2 <= in;
            alu <= alu_and;
            src <= 1'b0;

            if (opcode[0] == 1'b0) ip <= ip_next;

        end

        1: begin fn <= 2; op2 <= wb; end
        2: begin flags <= alu_f; t <= fetch; end

    endcase

    // NOT rm
    3'b010: begin

        wb      <= ~op1;
        t       <= modrm_wb;
        t_next  <= fetch;

    end

    // NEG rm
    3'b011: case (fn)

        0: begin fn <= 1; op1 <= 0; op2 <= op1; alu <= alu_sub; end
        1: begin wb <= alu_r; flags <= alu_f; t <= modrm_wb; t_next <= fetch; end

    endcase

    // MUL | IMUL
    3'b10x: case (fn)

        // Запрос
        0: begin

            fn <= 1;

            if (modrm[3]) begin
                op1 <= size ? op1 : {{8{op1[7]}}, op1[7:0]};
                op2 <= size ? ax :  {{8{ax[7]}},  ax[7:0]};
            end else begin
                op2 <= size ? ax : ax[7:0];
            end

        end

        // Запись результата
        1: begin

            src <= 1'b0;
            t   <= fetch;

            // CF,OF устанавливаются при переполнении
            // ZF при нулевом результате
            if (size) begin // 16 bit

                ax[15:0]   <= mult[15:0];
                dx[15:0]   <= mult[31:16];
                flags[ZF]  <= mult[31:0] == 32'b0;
                flags[CF]  <= dx[15:0]  != 16'b0;
                flags[OF]  <= dx[15:0]  != 16'b0;

            end else begin // 8 bit

                ax[15:0]   <= mult[15:0];
                flags[ZF]  <= mult[15:0] == 16'b0;
                flags[CF]  <= ax[15:8]  != 8'b0;
                flags[OF]  <= ax[15:8]  != 8'b0;

            end

        end

    endcase

    // DIV, IDIV
    3'b11x: case (fn)

        // Запрос
        0: begin

            fn      <= 1;
            t       <= divide;
            diva    <= _diva;
            divb    <= _divb;
            divcnt  <= size ? 32 : 16;
            divrem  <= 1'b0;
            divres  <= 1'b0;
            signa   <= 1'b0;
            signb   <= 1'b0;

            // IDIV
            if (modrm[3]) begin

                // Расстановка знаков
                signa <= _diva[31];
                signb <= _divb[alu_top];

                // diva = |diva|
                if (_diva[31]) begin

                    if (size) diva[31:16] <= -_diva[31:16];
                    else      diva[31:24] <= -_diva[31:24];

                end

                // divb = |divb|
                if (size && _divb[15])  divb[15:0] <= -_divb[15:0];
                else if (_divb[7])      divb[ 7:0] <= -_divb[ 7:0];

            end

        end

        // Запись результата
        1: begin

            t    <= fetch;
            src  <= 1'b0;
            wb   <= 1'b0;   // INT 0

            if (size) begin

                ax[15:0] <= signd ? -divres[15:0] : divres[15:0];
                dx[15:0] <= divrem[15:0];

                if (|divres[31:16] || divb[15:0] == 0) t <= interrupt;

            end else begin

                ax[ 7:0] <= signd ? -divres[7:0] : divres[7:0];
                ax[15:8] <= divrem[7:0];

                if (|divres[15:8] || divb[7:0] == 0) t <= interrupt;

            end

        end

    endcase

endcase

// Групповые инструкции FE/FF
8'b1111_111x: case (modrm[5:3])

    // INC|DEC rm
    3'b000,
    3'b001: case (fn)

        0: begin fn <= 1; op2 <= 1; alu <= modrm[3] ? 5 : 0; end
        1: begin wb <= alu_r; t <= modrm_wb; t_next <= fetch; flags <= {alu_f[11:1], flags[CF]}; end

    endcase

    // CALL | JMP rm
    3'b010,
    3'b100: if (size) begin

        t       <= modrm[4] ? push : fetch;
        t_next  <= fetch;
        src     <= modrm[4];
        wb      <= ip;
        ip      <= op1;

    end else t <= exception;

    // CALL | JMP far
    3'b011,
    3'b101: if (size) case (fn)

        0: begin

            // Для PUSH (CALL)
            op1 <= cs[15:0];
            op2 <= ip;

            // Переход по заданному адресу
            ip  <= op1;
            fn  <= 1;
            ea  <= ea + 2;

        end

        // Загрузка CS:
        1: begin fn <= 2; wb[7:0] <= in; ea <= ea + 1; end

        // Загрузка сегмента и либо выход к fetch, либо call far
        2: begin

            t           <= loadseg;
            t_next      <= modrm[5] ? fetch : exec;
            fn          <= 3;
            regn        <= 1;
            wb[15:8]    <= in;

        end

        // PUSH для CALL FAR
        3: begin fn <= 4; t <= push; wb <= op1; end
        4: begin fn <= 5; t <= push; wb <= op2; t_next <= fetch; end

    endcase else t <= exception;

    // PUSH rm
    3'b110: if (size) begin

        t       <= push;
        t_next  <= fetch;
        wb      <= op1;

    end else t <= exception;

    // Undefined instruction
    3'b111: t <= exception;

endcase

// UNEXPECTED INSTRUCTION
default: begin end

endcase
