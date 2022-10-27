/*
 * Этот процессор предназначен для выполнения в 64Кб пространстве памяти
 * - Количество инструкции ограничено минимальным количеством
 * - Нет сегментных регистров
 * - Нет префиксов
 * Процессор сделан для быстрой разработки
 */

module core
(
    input               clock,
    input               hold,
    input               reset_n,
    output      [15:0]  address,
    input       [ 7:0]  in,
    output  reg [ 7:0]  out,
    output  reg         we
);

`include "core.decl.v"

// ---------------------------------------------------------------------
// Процессорное основное ядро
// ---------------------------------------------------------------------

always @(posedge clock)
// Получение сброса процессора или его первичной инициализации
if (reset_n == 1'b0) begin ip <= 16'hFFF0; fn <= FETCH; bus <= 1'b0; end
// При наличии HOLD=1, ничего не делать в процессоре
else if (hold == 1'b0)
case (fn)

    // СЧИТЫВАНИЕ ОПКОДА
    // =================================================================

    FETCH: begin

        opcode  <= in;
        ip      <= ip + 1'b1;
        fn      <= EXEC;
        t       <= 1'b0;

        casex (in)

        // Базовый АЛУ с двумя операндами
        8'b00xxx0xx: begin

            alu  <= in[5:3];     // Номер инструкции АЛУ
            size <= in[0];       // 8/16 бит
            dir  <= in[1];       // 0=rm,r; 1=r,rm
            fn   <= MODRM;

        end

        endcase

    end

    // ДЕКОДИРОВАНИЕ БАЙТА MODRM И ЧТЕНИЕ ОПЕРАНДОВ
    // =================================================================

    // Считывание байта ModRM
    MODRM: begin

        modrm <= in;
        ip    <= ip + 1'b1;

        // Левый операнд (dst)
        case (dir ? in[5:3] : in[2:0])
        3'h0: op1 <= size ? ax : ax[ 7:0];
        3'h1: op1 <= size ? cx : cx[ 7:0];
        3'h2: op1 <= size ? dx : dx[ 7:0];
        3'h3: op1 <= size ? bx : bx[ 7:0];
        3'h4: op1 <= size ? sp : ax[15:8];
        3'h5: op1 <= size ? bp : cx[15:8];
        3'h6: op1 <= size ? si : dx[15:8];
        3'h7: op1 <= size ? di : bx[15:8];
        endcase

        // Правый операнд (src)
        case (dir ? in[2:0] : in[5:3])
        3'h0: op2 <= size ? ax : ax[ 7:0];
        3'h1: op2 <= size ? cx : cx[ 7:0];
        3'h2: op2 <= size ? dx : dx[ 7:0];
        3'h3: op2 <= size ? bx : bx[ 7:0];
        3'h4: op2 <= size ? sp : ax[15:8];
        3'h5: op2 <= size ? bp : cx[15:8];
        3'h6: op2 <= size ? si : dx[15:8];
        3'h7: op2 <= size ? di : bx[15:8];
        endcase

        // Эффективный адрес
        case (in[2:0])
        3'h0: ea <= bx + si;
        3'h1: ea <= bx + di;
        3'h2: ea <= bp + si;
        3'h3: ea <= bp + di;
        3'h4: ea <= si;
        3'h5: ea <= di;
        3'h6: ea <= in[7:6] ? bp : 1'b0;
        3'h7: ea <= bx;
        endcase

        // Определить дальнейшие действия, зная MOD-часть
        case (in[7:6])
        2'b00:

            // Либо переходим к чтению операнда, либо +16 битное смещение
            if (in[2:0] == 3'h6)
                 begin fn <= MODRM_16; end
            else begin fn <= MODRM_OP; bus <= 1'b1; end

        2'b01: fn <= MODRM_8;
        2'b10: fn <= MODRM_16;

        // Читается из регистров
        2'b11: fn <= EXEC;
        endcase

    end

    // +DISP8
    MODRM_8: begin

        ip  <= ip + 1'b1;
        ea  <= ea + {{8{in[7]}}, in};
        bus <= 1'b1;
        fn  <= MODRM_OP;

    end

    // +DISP16 LOW
    MODRM_16: begin

        ip  <= ip + 1'b1;
        ea  <= ea + in;
        fn  <= MODRM_16H;

    end

    // +DISP16 HIGH
    MODRM_16H: begin

        ip  <= ip + 1'b1;
        ea  <= ea + {in, 8'h00};
        bus <= 1'b1;
        fn  <= MODRM_OP;

    end

    // Чтение операнда op1/op2 (LOW)
    MODRM_OP: begin

        if (size)
             begin fn <= MODRM_OPH; ea <= ea + 1'b1; end
        else begin fn <= EXEC; end

        if (dir) op2 <= in; else op1 <= in;

    end

    // Операнд HIGH
    MODRM_OPH: begin

        if (dir) op2[15:8] <= in; else op1[15:8] <= in;

        fn <= EXEC;
        ea <= ea - 1'b1;

    end

    // ИСПОЛНЕНИЕ ИНСТРУКЦИИ
    // =================================================================

endcase

endmodule
