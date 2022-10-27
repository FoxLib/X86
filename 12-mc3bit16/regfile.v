// Регистры общего назначения
reg [15:0] ax   = 16'hAABB; // =0
reg [15:0] bx   = 16'h1234; // =3
reg [15:0] cx   = 16'h5678; // =1
reg [15:0] dx   = 16'h9ABC; // =2
reg [15:0] sp   = 16'h1234; // =4
reg [15:0] bp   = 16'h4232; // =5
reg [15:0] si   = 16'h2347; // =6
reg [15:0] di   = 16'hAB23; // =7

// Сегментные регистры
reg [15:0] es   = 16'h5211; // =0
reg [15:0] cs   = 16'h0000; // =1
reg [15:0] ss   = 16'h7723; // =2
reg [15:0] ds   = 16'h1422; // =3

reg [15:0] ip = 0; // Instruction Pointer
reg [11:0] flags = 12'b0000_0000_0010;
//                     ODIT SZ A  P C
