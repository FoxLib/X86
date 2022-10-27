module core
(
    input               clock,
    input               reset_n,
    input               locked,
    output      [15:0]  address,
    input       [7:0]   in,
    output  reg [7:0]   out,
    output  reg         we
);

initial begin out = 8'h00; we = 1'b0; end

assign address = sw ? ea : ip;

// ---------------------------------------------------------------------
localparam

    init        = 0,
    modrm_fetch = 1,
    modrm_d8    = 2,
    modrm_dl    = 3,
    modrm_dh    = 4,
    modrm_op1   = 5,
    modrm_op2   = 6,
    exec        = 7,
    wback       = 8,
    wback2      = 9,
    wbackn      = 10;

localparam

    CF = 0, PF = 2, AF =  4, ZF =  6, SF = 7,
    TF = 8, IF = 9, DF = 10, OF = 11;
    
// Регистры
// ---------------------------------------------------------------------
reg [15:0]  ax = 16'h0000; reg [15:0]  sp = 16'h0000;
reg [15:0]  cx = 16'h0000; reg [15:0]  bp = 16'h0000;
reg [15:0]  dx = 16'h0000; reg [15:0]  si = 16'h0000;
reg [15:0]  bx = 16'h0000; reg [15:0]  di = 16'h0000;
reg [15:0]  ip = 16'h0000;
reg [11:0]  flags = 12'b0000_0000_0010;
//                      ODIT SZ A  P C
// ---------------------------------------------------------------------

reg [ 3:0]  n       = 1'b0;             // Главная процедура
reg [ 2:0]  t       = 1'b0;             // Линия в процедуре
reg         regw    = 1'b0;             // =1 wb в regn (negedge)
reg [ 2:0]  regn    = 3'b000;           // Номер регистра 
reg         sw      = 1'b0;             // =1 ea; =0 ip
reg [15:0]  ea      = 16'h0000;         // Эффективный адрес
reg         size    = 1'b0;
reg         dir     = 1'b0;
reg [ 2:0]  alu     = 3'b000;
reg [ 7:0]  opcode  = 8'h00;
reg [ 7:0]  modrm   = 8'h00;
reg [15:0]  op1     = 16'h0000;         // Первый операнд
reg [15:0]  op2     = 16'h0000;         // Второй операнд
reg [15:0]  wb      = 16'h0000;         // Обратная запись

// ---------------------------------------------------------------------
// ВЫЧИСЛЕНИЯ
// ---------------------------------------------------------------------

wire        wbreg   = dir || modrm[7:6] == 2'b11;
wire [2:0]  wbnum   = dir ? modrm[5:3] : modrm[2:0];
wire [7:0]  branch  = {

    /*7*/ (flags[SF] ^ flags[OF]) | flags[ZF],
    /*6*/ (flags[SF] ^ flags[OF]),
    /*5*/  flags[PF],
    /*4*/  flags[SF],
    /*3*/  flags[CF] | flags[ZF],
    /*2*/  flags[ZF],
    /*1*/  flags[CF],
    /*0*/  flags[OF]
};

// ---------------------------------------------------------------------
// Считывание регистров
// ---------------------------------------------------------------------

wire [ 2:0] reg1n = dir ? in[5:3] : in[2:0];
wire [ 2:0] reg2n = dir ? in[2:0] : in[5:3];
reg  [15:0] reg1;
reg  [15:0] reg2;

always @* begin

    // Операнд 1
    // * Считывается из in, если modrm_fetch
    // * Или из regn, при других случаях
    case (n == modrm_fetch ? reg1n : regn)
    3'h0: reg1 = size ? ax : ax[ 7:0];
    3'h1: reg1 = size ? cx : cx[ 7:0];
    3'h2: reg1 = size ? dx : dx[ 7:0];
    3'h3: reg1 = size ? bx : bx[ 7:0];
    3'h4: reg1 = size ? sp : ax[15:8];
    3'h5: reg1 = size ? bp : cx[15:8];
    3'h6: reg1 = size ? si : dx[15:8];
    3'h7: reg1 = size ? di : bx[15:8];
    endcase

    // Операнд 2
    case (reg2n)
    3'h0: reg2 = size ? ax : ax[ 7:0];
    3'h1: reg2 = size ? cx : cx[ 7:0];
    3'h2: reg2 = size ? dx : dx[ 7:0];
    3'h3: reg2 = size ? bx : bx[ 7:0];
    3'h4: reg2 = size ? sp : ax[15:8];
    3'h5: reg2 = size ? bp : cx[15:8];
    3'h6: reg2 = size ? si : dx[15:8];
    3'h7: reg2 = size ? di : bx[15:8];
    endcase
    
end

// ---------------------------------------------------------------------
// ИСПОЛНЕНИЕ ИНСТРУКЦИИ
// ---------------------------------------------------------------------

always @(posedge clock)
if (locked)
if (reset_n == 1'b0) begin ip <= 16'h0000; n <= 1'b0; sw <= 1'b0; end
else begin

we   <= 1'b0;
regw <= 1'b0;

case (n)

    // -----------------------------------------------------------------
    // Считывание опкода
    // -----------------------------------------------------------------
    
    init: begin

        ip      <= ip + 1'b1;
        n       <= exec;
        t       <= 1'b0;
        size    <= in[0];
        dir     <= in[1];
        opcode  <= in;

        casex (in)
        // Никакие префиксы мы не используем
        8'h0F, 8'hF0,
        8'h26, 8'h2E, 8'h36, 8'h3E,
        8'h64, 8'h65, 8'h66, 8'h67: begin /* SKIP */ end
        // ALU:Basic
        8'b00xx_x0xx: begin alu <= in[5:3]; n <= modrm_fetch; end
        8'b00xx_x10x: begin alu <= in[5:3]; end
        // INC|DEC r16
        8'b0100_xxxx: begin

            size <= 1'b1;
            alu  <= in[3] ? 5 : 0; // 0=add, 5=sub
            regn <= in[2:0];
            op2  <= 1'b1;

        end
        // MOV rm|r
        8'b1000_10xx: begin n <= modrm_fetch; end
        // XCHG ax, r16
        8'b1001_0xxx: begin size <= 1'b1; regn <= in[2:0]; end
        // MOV r,i
        8'b1011_xxxx: begin {size, regn} <= in[3:0]; end
        // Jccc b8
        8'b0111_xxxx: if (branch[in[3:1]] == in[0]) begin

            n  <= init;
            ip <= ip + 2'h2;

        end        
        endcase

    end

    // -----------------------------------------------------------------
    // Считывание байта MODRM
    // -----------------------------------------------------------------

    modrm_fetch: begin

        modrm <= in;
        ip    <= ip + 1'b1;
        op1   <= reg1;
        op2   <= reg2;

        // Вычисление эффективного адреса
        case (in[2:0])
        3'h0: ea <= bx + si;
        3'h1: ea <= bx + di;
        3'h2: ea <= bp + si;
        3'h3: ea <= bp + di;
        3'h4: ea <= si;
        3'h5: ea <= di;
        3'h6: ea <= ^in[7:6] ? bp : 16'h0000;
        3'h7: ea <= bx;
        endcase

        // Дочитать DISP
        case (in[7:6])
        2'b00: // OP, +D16
            if (in[2:0] == 3'b110) n <= modrm_dl;
            else begin sw <= 1'b1; n <= modrm_op1; end
        2'b01: // +S8
            n <= modrm_dh;
        2'b10: // +D16
            n <= modrm_dl;
        2'b11: // REG
            n <= exec;
        endcase

    end

    // +D16 
    modrm_dl: begin

        n  <= modrm_dh;
        ea <= ea + in;
        ip <= ip + 1'b1;

    end

    // +D16, +S8
    modrm_dh: begin

        n  <= modrm_op1;
        ea <= ea + (modrm[6] ? {{8{in[7]}}, in} : {in, 8'h00});
        ip <= ip + 1'b1;
        sw <= 1'b1;

    end

    // Op8
    modrm_op1: begin

        n <= size ? modrm_op2 : exec;

        if (dir)  op2 <= in; else op1 <= in;
        if (size) ea  <= ea + 1'b1;

    end

    // Op16
    modrm_op2: begin

        n  <= exec;
        ea <= ea - 1'b1;

        if (dir) op2[15:8] <= in; else op1[15:8] <= in;

    end

    // -----------------------------------------------------------------
    // Исполнение инструкции
    // -----------------------------------------------------------------

    exec: casex (opcode)

        // Запись результатов от АЛУ
        8'b00xx_x0xx: begin

            n     <= (alu == 3'b111) || wbreg ? init : wback;
            regw  <= (alu != 3'b111) && wbreg;
            regn  <= wbnum;
            wb    <= result;
            flags <= flags_o;

        end

        // 3/4T: АЛУ с Imm
        8'b00xx_x10x: case (t)

            0: begin // Читать LO

                t   <= size ? 1 : 2;
                op1 <= ax;
                op2 <= in;
                ip  <= ip + 1'b1;

            end

            1: begin // Читать HI

                t  <= 2;
                ip <= ip + 1'b1;
                op2[15:8] <= in;

            end

            2: begin // Запись результата AL/AX

                n     <= init;
                regw  <= alu != 3'b111;
                regn  <= 3'h0;
                wb    <= result;
                flags <= flags_o;

            end

        endcase

        // 3T | INC|DEC r16
        8'b0100_xxxx: case (t)

            0: begin t <= 1; op1 <= reg1; end
            1: begin

                n       <= init;
                regw    <= 1'b1;
                wb      <= result;
                flags   <= {flags_o[11:1], flags[CF]};
                
            end

        endcase

        // 2T+ | MOV rm|r
        8'b1000_10xx: begin

            n     <= wbreg ? init : wback;
            regw  <= wbreg;
            regn  <= wbnum;
            wb    <= op2;
            
        end

        // 3T | XCHG ax, r16
        8'b1001_0xxx: case (t)

            0: begin

                t    <= 1;
                op1  <= ax;
                regw <= 1'b1;
                regn <= 0; 
                wb   <= reg1;

            end
            
            1: begin

                n    <= init;
                regw <= 1'b1;
                regn <= opcode[2:0];
                wb   <= op1;

            end

        endcase
        
        // MOV r,ib
        // MOV r,iw
        8'b1011_xxxx: case (t)

            0: begin // LOW

                t    <= 1;
                n    <= ~size ? init : exec;
                regw <= ~size;
                wb   <= in;
                ip   <= ip + 1'b1;

            end

            1: begin // HIGH

                n    <= init;
                regw <= 1'b1;
                ip   <= ip + 1'b1;
                wb[15:8] <= in;

            end

        endcase

        // JMP|Jcccc short
        8'b1110_1011,
        8'b0111_xxxx: begin

            n  <= init;
            ip <= ip + 1'b1 + {{8{in[7]}}, in};

        end

    endcase

    // Запись результата ModRM в память (wb,modrm,size)
    wback: begin
        
        we  <= 1'b1;
        sw  <= 1'b1;
        out <= wb[7:0];
        n   <= size ? wback2 : wbackn;

    end

    // Запись старшего байта
    wback2: begin

        n   <= wbackn;
        we  <= size;
        out <= wb[15:8];
        ea  <= ea + 1'b1;
        
    end

    // Остановка записи
    wbackn: begin n <= init; sw <= 1'b0; end

endcase

end

// ---------------------------------------------------------------------
// ЗАПИСЬ В РЕГИСТРЫ
// ---------------------------------------------------------------------

always @(negedge clock) begin

    if (regw)
    case (regn)
    0: if (size) ax <= wb; else ax[ 7:0] <= wb[7:0];
    1: if (size) cx <= wb; else cx[ 7:0] <= wb[7:0];
    2: if (size) dx <= wb; else dx[ 7:0] <= wb[7:0];
    3: if (size) bx <= wb; else bx[ 7:0] <= wb[7:0];
    4: if (size) sp <= wb; else ax[15:8] <= wb[7:0];
    5: if (size) bp <= wb; else cx[15:8] <= wb[7:0];
    6: if (size) si <= wb; else dx[15:8] <= wb[7:0];
    7: if (size) di <= wb; else bx[15:8] <= wb[7:0];
    endcase

end

// ---------------------------------------------------------------------
// АРИФМЕТИЧЕСКО-ЛОГИЧЕСКОЕ УСТРОЙСТВО
// ---------------------------------------------------------------------

reg  [16:0] res;
reg  [11:0] flags_o;
wire [15:0] result = size ? res[15:0] : res[7:0];
wire [3:0]  signx  = size ? 15 : 7;

wire add_o   = (op1[signx] ^ op2[signx] ^ 1) & (op1[signx] ^ res[signx]);
wire sub_o   = (op1[signx] ^ op2[signx] ^ 0) & (op1[signx] ^ res[signx]);
wire signf   = res[signx];
wire zerof   = size ? ~|res[15:0] : ~|res[7:0];
wire auxf    = op1[AF] ^ op2[AF] ^ res[AF];
wire parity  = ~^res[7:0];
wire carryf  = res[signx + 1];

// Общие АЛУ
always @* begin

    case (alu)
    /* ADD */ 0: res = op1 + op2;
    /* OR  */ 1: res = op1 | op2;
    /* ADC */ 2: res = op1 + op2 + flags[CF];
    /* SBB */ 3: res = op1 - op2 - flags[CF];
    /* AND */ 4: res = op1 & op2;
    /* SUB */ 5,
    /* CMP */ 7: res = op1 - op2;
    /* XOR */ 6: res = op1 ^ op2;
    endcase

    case (alu)
    // ADD | ADC
    0, 2:    flags_o = {

        /* O */ add_o,
        /* D */ flags[DF],
        /* I */ flags[IF],
        /* T */ flags[TF],
        /* S */ signf,
        /* Z */ zerof,
        /* 0 */ 1'b0,
        /* A */ auxf,
        /* 0 */ 1'b0,
        /* P */ parity,
        /* 1 */ 1'b1,
        /* C */ carryf
    };

    // SBB | SUB | CMP
    3, 5, 7: flags_o = {

        /* O */ sub_o,
        /* D */ flags[DF],
        /* I */ flags[IF],
        /* T */ flags[TF],
        /* S */ signf,
        /* Z */ zerof,
        /* 0 */ 1'b0,
        /* A */ auxf,
        /* 0 */ 1'b0,
        /* P */ parity,
        /* 1 */ 1'b1,
        /* C */ carryf
    };

    // OR, AND, XOR
    1, 4, 6: flags_o = {

        /* O */ 1'b0,
        /* D */ flags[DF],
        /* I */ flags[IF],
        /* T */ flags[TF],
        /* S */ signf,
        /* Z */ zerof,
        /* 0 */ 1'b0,
        /* A */ 1'b0,
        /* 0 */ 1'b0,
        /* P */ parity,
        /* 1 */ 1'b1,
        /* C */ 1'b0
    };
    endcase

end

endmodule
