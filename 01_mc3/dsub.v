module dsub
(
    input               CLOCK,
    output  reg  [3:0]  VGA_R,
    output  reg  [3:0]  VGA_G,
    output  reg  [3:0]  VGA_B,
    output              VGA_HS,
    output              VGA_VS
);
       
// ---------------------------------------------------------------------
// Тайминги для горизонтальной и вертикальной развертки
//        Visible    Front     Sync      Back      Whole
parameter hzv = 640, hzf = 16, hzs = 96, hzb = 48, hzw = 800,
          vtv = 400, vtf = 12, vts = 2,  vtb = 35, vtw = 449;
// ---------------------------------------------------------------------
assign VGA_HS = X  < (hzb + hzv + hzf); // NEG
assign VGA_VS = Y >= (vtb + vtv + vtf); // POS
// ---------------------------------------------------------------------
// Позиция луча в кадре и максимальные позиции (x,y)
reg  [ 9:0] X = 0; wire xmax = (X == hzw - 1);
reg  [ 9:0] Y = 0; wire ymax = (Y == vtw - 1);
wire [ 9:0] x = (X - hzb); // x=[0..639]
wire [ 9:0] y = (Y - vtb); // y=[0..399]
// ---------------------------------------------------------------------

always @(posedge CLOCK) begin

    // Черный цвет по краям
    {VGA_R, VGA_G, VGA_B} <= 12'h000;

    // Кадровая развертка
    X <= xmax ?         0 : X + 1;
    Y <= xmax ? (ymax ? 0 : Y + 1) : Y;

    // Вывод окна видеоадаптера
    if (X >= hzb && X < hzb + hzv && Y >= vtb && Y < vtb + vtv)
    begin
         {VGA_R, VGA_G, VGA_B} <= 12'h111;
    end

end

endmodule