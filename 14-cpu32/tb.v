`timescale 10ns / 1ns
module tb;

reg clock;
reg clock25;

always  #0.5  clock   = ~clock;
always  #2.0  clock25 = ~clock25;

initial begin clock = 0; clock25 = 0; #2000 $finish; end
initial begin $dumpfile("tb.vcd"); $dumpvars(0, tb); end
initial begin $readmemh("bios/bios.hex", memory, 20'hF8000); end

// 1Мб памяти. Простой контроллер памяти
// -----------------------------------------
reg  [ 7:0] memory[1024*1024];
reg  [ 7:0] i_data;
wire [ 7:0] o_data;
wire        we;

always @(posedge clock) begin

    i_data <= memory[address];
    if (we) memory[address] <= o_data;

end
// ---------------------------------------------------------------------
// Процессор
// ---------------------------------------------------------------------

wire [19:0] address;
wire        locked;

wire        port_clk;
wire [15:0] port;
wire [ 7:0] port_i;
wire [ 7:0] port_o;
wire        port_w;

wire        intr;
wire        intr_latch;
wire [ 7:0] irq;

reg  [ 7:0] ps2_data = 8'h01;
reg         ps2_hit  = 0;

wire [10:0] vga_cursor;
wire [31:0] dac_out;
wire [ 7:0] dac_address;
wire        dac_we;

core88 core88_inst
(
    .clock      (clock25),
    .reset_n    (1'b1),
    .locked     (1'b1),

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

wire [3:0]  SD_DATA;
wire        SD_CMD;
wire [1:0]  sd_cmd;
wire [7:0]  sd_din;
wire [7:0]  sd_out;
wire        sd_signal;
wire        sd_busy;
wire        sd_timeout;

sd sd_inst
(
    // 25 Mhz
    .clock      (clock25),

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

pctl pctl_inst
(
    .clock      (clock25),
    .reset_n    (1'b1),
    .port_clk   (port_clk),
    .port       (port),
    .port_i     (port_i),
    .port_o     (port_o),
    .port_w     (port_w),

    // Устройства
    .vga_cursor (vga_cursor),
    .ps2_data   (ps2_data),
    .ps2_hit    (ps2_hit),
    .dac_out    (dac_out),
    .dac_address(dac_address),
    .dac_we     (dac_we),

    // SD-карта
    .sd_signal  (sd_signal),   // In   =1 Сообщение отослано на spi
    .sd_cmd     (sd_cmd),      // In      Команда
    .sd_din     (sd_din),      // Out     Принятое сообщение от карты
    .sd_out     (sd_out),      // In      Сообщение на отправку к карте
    .sd_busy    (sd_busy),     // Out  =1 Занято
    .sd_timeout (sd_timeout),  // Out  =1 Таймаут

    // Прерывания
    .intr       (intr),
    .irq        (irq),
    .intr_latch (intr_latch)
);

endmodule
