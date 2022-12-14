module marsohod2
(
    input   wire        clk,
    output  wire [3:0]  led,
    input   wire [1:0]  keys,
    output  wire        adc_clock_20mhz,
    input   wire [7:0]  adc_input,
    output  wire        sdram_clock,
    output  wire [11:0] sdram_addr,
    output  wire [1:0]  sdram_bank,
    inout   wire [15:0] sdram_dq,
    output  wire        sdram_ldqm,
    output  wire        sdram_udqm,
    output  wire        sdram_ras,
    output  wire        sdram_cas,
    output  wire        sdram_we,
    output  wire [4:0]  vga_r,
    output  wire [5:0]  vga_g,
    output  wire [4:0]  vga_b,
    output  wire        vga_hs,
    output  wire        vga_vs,
    input   wire        ftdi_rx,
    output  wire        ftdi_tx,
    inout   wire [1:0]  usb0,
    inout   wire [1:0]  usb1,
    output  wire        sound_left,
    output  wire        sound_right,
    inout   wire        ps2_keyb_clk,
    inout   wire        ps2_keyb_dat,
    inout   wire        ps2_mouse_clk,
    inout   wire        ps2_mouse_dat
);

// Генерация частот
wire locked;
wire clock_25;

pll unit_pll
(
    .clk       (clk),
    .m25       (clock_25),
    .locked    (locked)
);

endmodule
