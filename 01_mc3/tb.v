`timescale 10ns / 1ns

module tb;
// ---------------------------------------------------------------------
reg clock;     always #0.5 clock    = ~clock;
reg clock_25;  always #1.0 clock_50 = ~clock_50;
reg clock_50;  always #2.0 clock_25 = ~clock_25;
// ---------------------------------------------------------------------
initial begin clock = 0; clock_25 = 0; clock_50 = 0; #2000 $finish; end
initial begin $dumpfile("tb.vcd"); $dumpvars(0, tb); end
initial begin $readmemh("tb.hex", mem, 0); end
// ---------------------------------------------------------------------

reg  [ 7:0] mem[65536];
wire [15:0] address;
wire [ 7:0] in = mem[address];
wire [ 7:0] out;
wire        we;

always @(posedge clock) if (we) mem[address] <= out;

// ---------------------------------------------------------------------

core Core8
(
    .clock          (clock_25),
    .reset_n        (1'b1),
    .hold           (1'b0),
    .address        (address),
    .in             (in),
    .out            (out),
    .we             (we)
);

endmodule
