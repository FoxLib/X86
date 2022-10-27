// ---------------------------------------------------------------------
// Условные переходы
// ---------------------------------------------------------------------

wire [7:0] branches = {

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
// Арифметико-логика, базовая
// ---------------------------------------------------------------------

wire [16:0] alu_r =

    alu == alu_add ? op1 + op2 :
    alu == alu_or  ? op1 | op2 :
    alu == alu_adc ? op1 + op2 + flags[CF] :
    alu == alu_sbb ? op1 - op2 - flags[CF] :
    alu == alu_and ? op1 & op2:
    alu == alu_xor ? op1 ^ op2:
                     op1 - op2; // sub, cmp

wire [ 3:0] alu_top = size ? 15 : 7;

wire is_add  = alu == alu_add || alu == alu_adc;
wire is_lgc  = alu == alu_xor || alu == alu_and || alu == alu_or;
wire alu_cf  = alu_r[alu_top + 1'b1];
wire alu_af  = op1[4] ^ op2[4] ^ alu_r[4];
wire alu_sf  = alu_r[alu_top];
wire alu_zf  = size ? ~|alu_r[15:0] : ~|alu_r[7:0];
wire alu_pf  = ~^alu_r[7:0];
wire alu_of  = (op1[alu_top] ^ op2[alu_top] ^ is_add) & (op1[alu_top] ^ alu_r[alu_top]);

wire [11:0] alu_f = {

    /* OF  */ alu_of & ~is_lgc,
    /* DIT */ flags[10:8],
    /* SF  */ alu_sf,
    /* ZF  */ alu_zf,
    /* 5   */ 1'b0,
    /* AF  */ alu_af & ~is_lgc,
    /* 3   */ 1'b0,
    /* PF  */ alu_pf,
    /* 1   */ 1'b1,
    /* CF  */ alu_cf & ~is_lgc
};

// ---------------------------------------------------------------------
// Десятичная коррекция DAA, DAS, AAA, AAS
// ---------------------------------------------------------------------

reg         daa_a;
reg         daa_c;
reg         daa_x;
reg [8:0]   daa_i;
reg [7:0]   daa_h;
reg [15:0]  daa_r;
reg [11:0]  flags_o;
reg [11:0]  flags_d;

always @* begin

    daa_r   = ax[15:0];
    flags_d = flags;

    case (in[4:3])

        // DAA, DAS
        0, 1: begin

            daa_c = flags[CF];
            daa_a = flags[AF];
            daa_i = ax[7:0];

            // Младший ниббл
            if (ax[3:0] > 9 || flags[AF]) begin
                daa_i = in[3] ? ax[7:0]-6 : ax[7:0]+6;
                daa_c = daa_i[8];
                daa_a = 1;
            end

            daa_r = daa_i[7:0];
            daa_x = daa_c;

            // Старший ниббл
            if (daa_c || daa_i[7:0] > 8'h9F) begin
                daa_r = in[3] ? daa_i[7:0]-8'h60 : daa_i[7:0]+8'h60;
                daa_x = 1;
            end

            flags_d[SF] =   daa_r[7];        // S
            flags_d[ZF] = ~|daa_r[7:0];      // Z
            flags_d[AF] =   daa_a;           // A
            flags_d[PF] = ~^daa_r[7:0];      // P
            flags_d[OF] =   daa_x;           // C

        end

        // AAA, AAS
        2, 3: begin

            daa_i = ax[ 7:0];
            daa_r = ax[15:0];

            if (flags[4] || ax[3:0] > 9) begin

                daa_i = alu[0] ? ax[ 7:0] - 6 : ax[ 7:0] + 6;
                daa_h = alu[0] ? ax[15:8] - 1 : ax[15:8] + 1;
                daa_r = {daa_h, 4'h0, daa_i[3:0]};

                flags_d[AF] = 1; // AF=1
                flags_d[CF] = 1; // CF=1

            end
            else begin

                flags_d[AF] = 0;
                flags_d[CF] = 0;

            end

        end

    endcase

end
