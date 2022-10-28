`timescale 10ns / 1ns
module tb;
// -----------------------------------------------------------------------------
reg clock;
reg clock_25;
reg clock_50;

always #0.5 clock    = ~clock;
always #1.0 clock_50 = ~clock_50;
always #2.0 clock_25 = ~clock_25;

initial begin clock = 0; clock_25 = 0; clock_50 = 0; #2000 $finish; end
initial begin $dumpfile("tb.vcd"); $dumpvars(0, tb); end
// -----------------------------------------------------------------------------
initial begin $readmemh("tb.hex", memory, 0); end
// -----------------------------------------------------------------------------

// Память
reg [ 7:0] memory[1024*1024];
reg [31:0] address;
reg [ 7:0] i_data;
reg [ 7:0] o_data;

// Регистры
reg  [31:0] regs[256];
wire [ 7:0] ra;
wire [ 7:0] rb;
wire [31:0] rdata;
wire        rw;
wire [31:0] rav = ra ? regs[ra] : 0;
wire [31:0] rbv = rb ? regs[rb] : 0;

// Стек
reg  [31:0] stack[1024];        // 4kb стек
wire [ 9:0] sp;

always @(posedge clock) begin
    
    i_data <= memory[address[19:0]];
    if (we) memory[address[19:0]] <= o_data;
    
    // Запись в регистры
    if (rw) regs[ra] <= rdata;

end
// -----------------------------------------------------------------------------

cpu FoxlisicProcessor
(
    .clock      (clock_25),
    .locked     (1'b1),
    .resetn     (1'b1),
    
    // Память
    .address    (address),
    .i_data     (i_data),
    .o_data     (o_data),
    .we         (we),
    // Регистры
    .ra         (ra),
    .rb         (rb),
    .rav        (rav),
    .rbv        (rbv),
    .rdata      (rdata),
    .rw         (rw)
);

endmodule
