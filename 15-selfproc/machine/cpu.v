module cpu
(
    input   wire            clock,
    input   wire            locked,
    input   wire            resetn,
    
    // Память
    output  reg     [31:0]  address,
    input   wire    [ 7:0]  i_data,
    output  reg     [ 7:0]  o_data,
    output  reg             we,
    
    // Регистры
    output  reg     [7:0]   ra,
    output  reg     [7:0]   rb,
    input   wire    [31:0]  rav,
    input   wire    [31:0]  rbv,
    output  reg     [31:0]  rdata,
    output  reg             rw,
    
    // Стек
    output  reg     [ 9:0]  sp,
    input   wire    [31:0]  spi,
    output  reg     [31:0]  spo,
    output  reg             spw
);

`include "decl.v"

assign address = cp ? ea : ip;

always @(posedge clock) 
if (locked == 0 || resetn == 0) begin ip <= 0; t <= 0; end
else if (locked) begin

    we <= 0;
    rw <= 0;
    ip <= ip + 1;

    // Считывание опкода
    if (t == 0) begin
        
        t  <= 1;
        ir <= i_data;
    
    end

    // Исполнение операции
    casex (t ? ir : i_data)

        // 3T MOV ra, rb
        8'b00000000: case (t)

            1: begin t <= 2; rb <= i_data; end           
            2: begin t <= 0; ra <= i_data; rdata <= rbv; rw <= 1; end
        
        endcase        
        
        // 6T MOV ra, i32
        8'b00000001: case (t)
        
            1: begin t <= 2; ra <= i_data; end                            
            2: begin t <= 3; rdata <= i_data; end
            3: begin t <= 4; rdata[ 15:8] <= i_data; end
            4: begin t <= 5; rdata[23:16] <= i_data; end
            5: begin t <= 0; rdata[31:24] <= i_data; rw <= 1; end
        
        endcase
        
        // 3T MOV ra, i8|s8
        8'b0000001x: case (t)
        
            1: begin t <= 2; ra <= i_data; end            
            2: begin t <= 0; rdata <= ir[0] ? {{24{i_data[7]}}, i_data[7:0]} : i_data; rw <= 1; end

        endcase
        
        // 4T/7T MOV[B,D] ra, [rb]
        8'b0000010x: case (t)
            
            // Прочесть операнды
            1: begin t <= 2; rb <= i_data; end
            2: begin t <= 3; ra <= i_data; cp <= 1; ea <= rbv; end
            // Запись результата, если 8 бит
            3: begin 

                //                 32  8
                t       <= ir[0] ? 4 : 0; 
                rw      <= ir[0] ? 0 : 1;
                cp      <= ir[0];
                ip      <= ir[0] ? ip-3 : ip;
                ea      <= ea + 1;
                rdata   <= i_data; 
                
            end
            // Дочитать 24 бита и записать результат
            4: begin t <= 5; rdata[ 15:8] <= i_data; ea <= ea + 1; end
            5: begin t <= 6; rdata[23:16] <= i_data; ea <= ea + 1; end
            6: begin t <= 0; rdata[31:24] <= i_data; rw <= 1; cp <= 0; end

        endcase
        
        // 8T/5T MOV[B|D] [rb], ra
        8'b0000011x: case (t)
        
            1: begin t <= 2; rb <= i_data; end
            2: begin t <= 3; ra <= i_data; end
            3: begin

                t       <= 4;
                ea      <= rbv; 
                we      <= 1; 
                cp      <= 1; 
                o_data  <= rav[7:0];
                
            end
            // Запись 8 бит
            4: begin 
            
                t       <= ir[0] ? 5 : 0;
                ip      <= ir[0] ? ip-4 : ip-1;
                cp      <= ir[0];
                we      <= ir[0];
                ea      <= ea + 1;
                o_data  <= rav[15:8];
            
            end
            // Запись 32 бит
            5: begin t <= 6; we <= 1; ea <= ea + 1; o_data <= rav[23:16]; end
            6: begin t <= 7; we <= 1; ea <= ea + 1; o_data <= rav[31:24]; end
            7: begin t <= 0; cp <= 0; end
        
        endcase

    endcase

end

endmodule