module de0(

    // Reset
    input              RESET_N,

    // Clocks
    input              CLOCK_50,
    input              CLOCK2_50,
    input              CLOCK3_50,
    inout              CLOCK4_50,

    // DRAM
    output             DRAM_CKE,
    output             DRAM_CLK,
    output      [1:0]  DRAM_BA,
    output      [12:0] DRAM_ADDR,
    inout       [15:0] DRAM_DQ,
    output             DRAM_CAS_N,
    output             DRAM_RAS_N,
    output             DRAM_WE_N,
    output             DRAM_CS_N,
    output             DRAM_LDQM,
    output             DRAM_UDQM,

    // GPIO
    inout       [35:0] GPIO_0,
    inout       [35:0] GPIO_1,

    // 7-Segment LED
    output      [6:0]  HEX0,
    output      [6:0]  HEX1,
    output      [6:0]  HEX2,
    output      [6:0]  HEX3,
    output      [6:0]  HEX4,
    output      [6:0]  HEX5,

    // Keys
    input       [3:0]  KEY,

    // LED
    output      [9:0]  LEDR,

    // PS/2
    inout              PS2_CLK,
    inout              PS2_DAT,
    inout              PS2_CLK2,
    inout              PS2_DAT2,

    // SD-Card
    output             SD_CLK,
    inout              SD_CMD,
    inout       [3:0]  SD_DATA,

    // Switch
    input       [9:0]  SW,

    // VGA
    output      [3:0]  VGA_R,
    output      [3:0]  VGA_G,
    output      [3:0]  VGA_B,
    output             VGA_HS,
    output             VGA_VS
);

// Z-state
assign DRAM_DQ = 16'hzzzz;
assign GPIO_0  = 36'hzzzzzzzz;
assign GPIO_1  = 36'hzzzzzzzz;

// LED OFF
assign HEX0 = 7'b1111111;
assign HEX1 = 7'b1111111;
assign HEX2 = 7'b1111111;
assign HEX3 = 7'b1111111;
assign HEX4 = 7'b1111111;
assign HEX5 = 7'b1111111;

// Генерация частот
// ---------------------------------------------------------------------

wire        locked;
wire        clock_25;
wire        clock_100;

de0pll unit_pll
(
    .clkin     (CLOCK_50),
    .m25       (clock_25),
    .m100      (clock_100),
    .locked    (locked)
);

// Блоки памяти
// ---------------------------------------------------------------------

reg  [17:0] m_address;
reg  [7:0]  i_data;

wire [7:0]  q_memory;
wire [7:0]  q_bios;
wire [7:0]  q_vmem;

reg         we_vga    = 0;
reg         we_memory = 0;
reg         we_bios   = 0;

// 256kb
membase membase_inst
(
    .clock      (clock_100),
    // Общая память
    .address_a  (m_address),
    .data_a     (o_data),
    .wren_a     (we_memory),
    .q_a        (q_memory),
    // Совмещенная видеопамять (последние страницы памяти)
    .address_b  (vga_address),
    .q_b        (vga_data),
);

// 32K: BIOS
bios bios_inst
(
    .clock      (clock_100),
    .address_a  (address[14:0]),
    .q_a        (q_bios),
    .data_a     (o_data),
    .wren_a     (we_bios)
);

// Маршрутизация
always @* begin

    i_data      = 8'hFF;
    m_address   = address[17:0];
    we_vga      = 0;
    we_memory   = 0;
    we_bios     = 0;

    casex (address)

        // 00000-3ffff 256k Общая память
        20'b00xx_xxxx_xxxx_xxxx_xxxx:
        begin i_data = q_memory; we_memory = we; end

        // a0000-affff 16/64k CGA/VGA
        20'b1010_xxxx_xxxx_xxxx_xxxx: case (videomode)

            1: begin i_data = q_memory; we_memory = we; m_address = {4'b1111, address[13:0]}; end
            2: begin i_data = q_memory; we_memory = we; m_address = {2'b11,   address[15:0]}; end

        endcase

        // b8000-b9fff 8k TEXTMODE
        20'b1011_100x_xxxx_xxxx_xxxx:
        begin i_data = q_vmem; we_vga  = we; end

        // f8000-fffff 8k BIOS
        20'b1111_1xxx_xxxx_xxxx_xxxx:
        begin i_data = q_bios; we_bios = we; end

    endcase

end

// ---------------------------------------------------------------------
// Ядро процессора
// ---------------------------------------------------------------------

wire [12:0] address_vga;
wire [ 7:0] data;
wire [19:0] address;
wire [ 7:0] o_data;
wire        we;

core88 UnitCore88
(
    .clock      (clock_25),
    .reset_n    (locked & RESET_N),
    .locked     (locked),

    // Данные
    .address    (address),
    .bus        (i_data),
    .data       (o_data),
    .wreq       (we),

    // Порты
    .port_clk   (port_clk),
    .port       (port),
    .port_i     (port_i),
    .port_o     (port_o),
    .port_w     (port_w),

    // Прерывания
    .intr       (intr),
    .irq        (irq),
    .intr_latch (intr_latch)
);

// ---------------------------------------------------------------------
// Управление портами
// ---------------------------------------------------------------------

wire        port_clk;
wire [15:0] port;
wire [ 7:0] port_i;
wire [ 7:0] port_o;
wire        port_w;

wire        intr;
wire        intr_latch;
wire [ 7:0] irq;

pctl pctl_inst
(
    .reset_n        (locked & RESET_N),
    .clock          (clock_25),

    // Интерфейс
    .port_clk       (port_clk),
    .port           (port),
    .port_i         (port_i),
    .port_o         (port_o),
    .port_w         (port_w),

    // Видео
    .videomode       (videomode),
    .vga_cursor      (cursor),
    .cursor_shape_lo (cursor_shape_lo),
    .cursor_shape_hi (cursor_shape_hi),
    .dac_out         (dac_out),
    .dac_address     (dac_address),
    .dac_we          (dac_we),

    // Клавиатура
    .ps2_data       (ps2_data),
    .ps2_hit        (ps2_hit),

    // SD-карта
    .sd_signal      (sd_signal),   // In   =1 Сообщение отослано на spi
    .sd_cmd         (sd_cmd),      // In      Команда
    .sd_din         (sd_din),      // Out     Принятое сообщение от карты
    .sd_out         (sd_out),      // In      Сообщение на отправку к карте
    .sd_busy        (sd_busy),     // Out  =1 Занято
    .sd_timeout     (sd_timeout),  // Out  =1 Таймаут

    // Прерывания
    .intr           (intr),
    .irq            (irq),
    .intr_latch     (intr_latch)
);

// ---------------------------------------------------------------------
// Модуль SD
// ---------------------------------------------------------------------

assign SD_DATA[0] = 1'bZ;

wire [1:0]  sd_cmd;
wire [7:0]  sd_din;
wire [7:0]  sd_out;
wire        sd_signal;
wire        sd_busy;
wire        sd_timeout;

sd UnitSD
(
    // 25 Mhz
    .clock      (clock_25),

    // Физический интерфейс
    .SPI_CS     (SD_DATA[3]),   // Выбор чипа
    .SPI_SCLK   (SD_CLK),       // Тактовая частота
    .SPI_MISO   (SD_DATA[0]),   // Входящие данные
    .SPI_MOSI   (SD_CMD),       // Исходящие

    // Интерфейс
    .sd_signal  (sd_signal),   // In   =1 Сообщение отослано на spi
    .sd_cmd     (sd_cmd),      // In      Команда
    .sd_din     (sd_din),      // Out     Принятое сообщение от карты
    .sd_out     (sd_out),      // In      Сообщение на отправку к карте
    .sd_busy    (sd_busy),     // Out  =1 Занято
    .sd_timeout (sd_timeout)   // Out  =1 Таймаут
);

// ---------------------------------------------------------------------
// Видеоадаптер
// ---------------------------------------------------------------------

wire [ 1:0] videomode;
wire [10:0] cursor;
wire [ 5:0] cursor_shape_lo;
wire [ 4:0] cursor_shape_hi;
wire [31:0] dac_out;
wire [ 7:0] dac_address;
wire        dac_we;
wire [17:0] vga_address;
wire [ 7:0] vga_data;
wire [ 7:0] vga_dac_address;
wire [31:0] vga_dac_data;

vga vga_inst
(
    .clock              (clock_25),
    .r                  (VGA_R),
    .g                  (VGA_G),
    .b                  (VGA_B),
    .hs                 (VGA_HS),
    .vs                 (VGA_VS),
    .address            (address_vga),
    .data               (data),
    .cursor             (cursor),
    .vga_address        (vga_address),
    .vga_data           (vga_data),
    .vga_dac_address    (vga_dac_address),
    .vga_dac_data       (vga_dac_data),
    .cursor_shape_lo    (cursor_shape_lo),
    .cursor_shape_hi    (cursor_shape_hi),
    .videomode          (videomode)
);

// 1kb
dac dac_inst
(
    .clock      (clock_100),
    .address_a  (vga_dac_address),
    .q_a        (vga_dac_data),
    .address_b  (dac_address),
    .data_b     (dac_out),
    .wren_b     (dac_we),
);

// 8k: Видеопамять и знакогенератор
font font_inst
(
    .clock      (clock_100),
    .address_a  (address_vga),
    .q_a        (data),
    .address_b  (address[12:0]),
    .q_b        (q_vmem),
    .data_b     (o_data),
    .wren_b     (we_vga),
);

// ---------------------------------------------------------------------
// Клавиатура
// ---------------------------------------------------------------------

wire [7:0]  ps2_data;
wire        ps2_hit;

ps2 ps2_inst
(
    .clock      (clock_25),
    .ps_clock   (PS2_CLK),
    .ps_data    (PS2_DAT),
    .done       (ps2_hit),
    .data       (ps2_data)
);

// ---------------------------------------------------------------------

endmodule

`include "../ps2.v"
`include "../vga.v"
`include "../core88.v"
`include "../pctl.v"
`include "../sd.v"
