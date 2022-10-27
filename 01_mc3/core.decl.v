// Адрес пока что будет указывать на IP
assign address = bus ? ea : ip;

// Необходимо больше для Icarus Verilog
initial begin we = 1'b0; out = 8'h00; end

// Фазы работы инструкции
localparam

    FETCH       = 5'h0,
    MODRM       = 5'h1,
    MODRM_8     = 5'h2,
    MODRM_16    = 5'h3,
    MODRM_16H   = 5'h4,
    MODRM_OP    = 5'h5,
    MODRM_OPH   = 5'h6,
    EXEC        = 5'h7;

// Регистры общего назначения 8 шт x 16 бит
reg [15:0] ax = 16'h0000; reg[15:0] sp = 16'h0000;
reg [15:0] cx = 16'h0000; reg[15:0] bp = 16'h0000;
reg [15:0] dx = 16'h1256; reg[15:0] si = 16'h0000;
reg [15:0] bx = 16'h0000; reg[15:0] di = 16'h0000;

//                            odit sz a  p c
reg [11:0]  flags       = 12'b0000_0000_0010;
reg [15:0]  ip          = 16'h0000;

// Управляющие регистры и статусы
reg         bus         = 1'b0;             // Указатель на EA вместо PC
reg [15:0]  ea          = 16'h0000;
reg [ 7:0]  opcode      = 8'h00;
reg [ 7:0]  modrm       = 8'h00;
reg [ 4:0]  fn          = 1'b0;             // Текущая выполняемая функция (0..31)
reg [ 2:0]  t           = 1'b0;             // Фаза исполнения функции
reg [ 2:0]  alu         = 3'b000;
reg         dir         = 1'b0;
reg         size        = 1'b0;
reg [15:0]  op1         = 16'h0000;
reg [15:0]  op2         = 16'h0000;

