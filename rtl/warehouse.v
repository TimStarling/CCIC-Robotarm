module warehouse (
    input sys_clk,
    input sys_rst_n,
    input [5:0] warehouse_nob,//输入仓库编号
    input wire en_flag,
    input wire uart_rx,

    output reg [8:0] x_warehouse,
    output reg [7:0] y_warehouse,
    output reg [11:0] direction, // 方向
    output reg ready_flag,
    output reg system_start
);
wire write_down;
//--------------------------物品仓库--------------------------
reg [11:0] ware_house1 [0:2];//0-x 1-y 2-仓库编号
initial begin //一号
    ware_house1[0] = 'd255;
    ware_house1[1] = 'd145;
    ware_house1[2] = 'h01;
end
reg [11:0] ware_house2 [0:2];
initial begin //二号
    ware_house2[0] = 12'd255;
    ware_house2[1] = 12'd105;
    ware_house2[2] = 'h02;
end
reg [11:0] ware_house3 [0:2];
initial begin //三号
    ware_house3[0] = 12'd253;
    ware_house3[1] = 12'd60;
    ware_house3[2] = 'h03;
end
reg [11:0] ware_house4 [0:2];
initial begin //四号
    ware_house4[0] = 12'd255;
    ware_house4[1] = 12'd15;
    ware_house4[2] = 'h04;
end
reg [11:0] ware_house5 [0:2];
initial begin //五号
    ware_house5[0] = 12'd210;
    ware_house5[1] = 12'd150;
    ware_house5[2] = 'h05;
end
reg [11:0] ware_house6 [0:2];
initial begin //六号
    ware_house6[0] = 12'd210;
    ware_house6[1] = 12'd105;
    ware_house6[2] = 'h06;
end
reg [11:0] ware_house7 [0:2];
initial begin //七号
    ware_house7[0] = 12'd210;
    ware_house7[1] = 12'd68;
    ware_house7[2] = 'h07;
end
reg [11:0] ware_house8 [0:2];
initial begin //八号
    ware_house8[0] = 12'd210;
    ware_house8[1] = 12'd15;
    ware_house8[2] = 'h08;
end
reg [11:0] ware_house9 [0:2];
initial begin //九号
    ware_house9[0] = 12'd165;
    ware_house9[1] = 12'd155;
    ware_house9[2] = 'h09;
end
reg [11:0] ware_house10 [0:2];
initial begin //十号
    ware_house10[0] = 12'd165;
    ware_house10[1] = 12'd110;
    ware_house10[2] = 'h0A;
end
reg [11:0] ware_house11 [0:2];
initial begin //十一号
    ware_house11[0] = 12'd165;
    ware_house11[1] = 12'd73;
    ware_house11[2] = 'h0B;
end
reg [11:0] ware_house12 [0:2];
initial begin //十二号
    ware_house12[0] = 12'd160;
    ware_house12[1] = 12'd25;
    ware_house12[2] = 'h0C;
end
reg [11:0] ware_house13 [0:2];
initial begin //十三号
    ware_house13[0] = 12'd120;
    ware_house13[1] = 12'd160;
    ware_house13[2] = 'h0D;
end
reg [11:0] ware_house14 [0:2];
initial begin //十四号
    ware_house14[0] = 12'd120;
    ware_house14[1] = 12'd115;
    ware_house14[2] = 'h0E;
end
reg [11:0] ware_house15 [0:2];
initial begin //十五号
    ware_house15[0] = 12'd120;
    ware_house15[1] = 12'd70;
    ware_house15[2] = 'h0F;
end
reg [11:0] ware_house16 [0:2];
initial begin //十六号
    ware_house16[0] = 12'd120;
    ware_house16[1] = 12'd32;
    ware_house16[2] = 'h10;
end
reg [11:0] ware_house17 [0:2];
initial begin //十七号
    ware_house17[0] = 12'd75;
    ware_house17[1] = 12'd160;
    ware_house17[2] = 'h11;
end
reg [11:0] ware_house18 [0:2];
initial begin //十八号
    ware_house18[0] = 12'd75;
    ware_house18[1] = 12'd118;
    ware_house18[2] = 'h12;
end
reg [11:0] ware_house19 [0:2];
initial begin //十九号
    ware_house19[0] = 12'd75;
    ware_house19[1] = 12'd72;
    ware_house19[2] = 'h13;
end
reg [11:0] ware_house20 [0:2];
initial begin //二十号
    ware_house20[0] = 12'd75;
    ware_house20[1] = 12'd30;
    ware_house20[2] = 'h14;
end
reg [11:0] ware_house21 [0:2];
initial begin //二十一号
    ware_house21[0] = 12'd32;
    ware_house21[1] = 12'd164;
    ware_house21[2] = 'h15;
end
reg [11:0] ware_house22 [0:2];
initial begin //二十二号
    ware_house22[0] = 12'd32;
    ware_house22[1] = 12'd119;
    ware_house22[2] = 'h16;
end
reg [11:0] ware_house23 [0:2];
initial begin //二十三号
    ware_house23[0] = 12'd32;
    ware_house23[1] = 12'd74;
    ware_house23[2] = 'h17;
end
reg [11:0] ware_house24 [0:2];
initial begin //二十四号
    ware_house24[0] = 12'd28;
    ware_house24[1] = 12'd31;
    ware_house24[2] = 'h18;
end


//----------------------仓库内容读取部分--------------------
reg [5:0]warehouse_input;
reg [5:0] state = 'd0;
always @(posedge sys_clk or negedge sys_rst_n) begin
    if (!sys_rst_n) begin
        ready_flag <= 1'b0;
    end else begin
        case(state)
            'd0: begin
                ready_flag <= 1'b0;
                x_warehouse <= 'd0;
                y_warehouse <= 'd0;
                if (en_flag) begin
                    warehouse_input <= warehouse_nob;
                    state <= 'd1;
                end
            end
            'd1: begin
                if(ware_house1[2] == warehouse_input) begin
                    x_warehouse <= ware_house1[0];
                    y_warehouse <= ware_house1[1];
                    state <= 'd25;
                end
                else state <= state + 'd1;
            end
            'd2: begin
                if(ware_house2[2] == warehouse_input) begin
                    x_warehouse <= ware_house2[0];
                    y_warehouse <= ware_house2[1];
                    state <= 'd25;
                end
                else state <= state + 'd1;
            end
            'd3: begin
                if(ware_house3[2] == warehouse_input) begin
                    x_warehouse <= ware_house3[0];
                    y_warehouse <= ware_house3[1];
                    state <= 'd25;
                end
                else state <= state + 'd1;
            end
            'd4: begin
                if(ware_house4[2] == warehouse_input) begin
                    x_warehouse <= ware_house4[0];
                    y_warehouse <= ware_house4[1];
                    state <= 'd25;
                    end
                else state <= state + 'd1;
            end
            'd5: begin
                if(ware_house5[2] == warehouse_input) begin
                    x_warehouse <= ware_house5[0];
                    y_warehouse <= ware_house5[1];
                    state <= 'd25;
                    end
                    else state <= state + 'd1;
            end
            'd6: begin
                if(ware_house6[2] == warehouse_input) begin
                    x_warehouse <= ware_house6[0];
                    y_warehouse <= ware_house6[1];
                    state <= 'd25;
                    end
                else state <= state + 'd1;
            end
            'd7: begin
                if(ware_house7[2] == warehouse_input) begin
                    x_warehouse <= ware_house7[0];
                    y_warehouse <= ware_house7[1];
                    state <= 'd25;
                    end
                    else state <= state + 'd1;
            end
            'd8: begin
                if(ware_house8[2] == warehouse_input) begin
                    x_warehouse <= ware_house8[0];
                    y_warehouse <= ware_house8[1];
                    state <= 'd25;
                end
                else state <= state + 'd1;
            end
            'd9: begin
                if(ware_house9[2] == warehouse_input) begin
                    x_warehouse <= ware_house9[0];
                    y_warehouse <= ware_house9[1];
                    state <= 'd25;
                end
                else state <= state + 'd1;
            end
            'd10: begin
                if(ware_house10[2] == warehouse_input) begin
                    x_warehouse <= ware_house10[0];
                    y_warehouse <= ware_house10[1];
                    state <= 'd25;
                    end
                else state <= state + 'd1;
            end
            'd11: begin
                if(ware_house11[2] == warehouse_input) begin
                    x_warehouse <= ware_house11[0];
                    y_warehouse <= ware_house11[1];
                    state <= 'd25;
                    end
                else state <= state + 'd1;
            end
            'd12: begin
                if(ware_house12[2] == warehouse_input) begin
                    x_warehouse <= ware_house12[0];
                    y_warehouse <= ware_house12[1];
                    state <= 'd25;
                    end
                else state <= state + 'd1;
            end
            'd13: begin
                if(ware_house13[2] == warehouse_input) begin
                    x_warehouse <= ware_house13[0];
                    y_warehouse <= ware_house13[1];
                    state <= 'd25;
                    end
                else state <= state + 'd1;
                    end
            'd14: begin
                if(ware_house14[2] == warehouse_input) begin
                    x_warehouse <= ware_house14[0];
                    y_warehouse <= ware_house14[1];
                    state <= 'd25;
                    end
                else state <= state + 'd1;
            end
            'd15: begin
                if(ware_house15[2] == warehouse_input) begin
                    x_warehouse <= ware_house15[0];
                    y_warehouse <= ware_house15[1];
                    state <= 'd25;
                    end
                else state <= state + 'd1;
            end
            'd16: begin
                if(ware_house16[2] == warehouse_input) begin
                    x_warehouse <= ware_house16[0];
                    y_warehouse <= ware_house16[1];
                    state <= 'd25;
                    end
                    else state <= state + 'd1;
            end
            'd17: begin
                if(ware_house17[2] == warehouse_input) begin
                    x_warehouse <= ware_house17[0];
                    y_warehouse <= ware_house17[1];
                    state <= 'd25;
                    end
                    else state <= state + 'd1;
            end
            'd18: begin
                if(ware_house18[2] == warehouse_input) begin
                    x_warehouse <= ware_house18[0];
                    y_warehouse <= ware_house18[1];
                    state <= 'd25;
                    end
                else state <= state + 'd1;
                    end
            'd19: begin
                if(ware_house19[2] == warehouse_input) begin
                    x_warehouse <= ware_house19[0];
                    y_warehouse <= ware_house19[1];
                    state <= 'd25;
                    end
                else state <= state + 'd1;
                    end
            'd20: begin
                if(ware_house20[2] == warehouse_input) begin
                    x_warehouse <= ware_house20[0];
                    y_warehouse <= ware_house20[1];
                    state <= 'd25;
                    end
                else state <= state + 'd1;
                    end
            'd21: begin
                if(ware_house21[2] == warehouse_input) begin
                    x_warehouse <= ware_house21[0];
                    y_warehouse <= ware_house21[1];
                    state <= 'd25;
                    end
                else state <= state + 'd1;
                    end
                    'd22: begin
                if(ware_house22[2] == warehouse_input) begin
                    x_warehouse <= ware_house22[0];
                    y_warehouse <= ware_house22[1];
                    state <= 'd25;
                    end
                else state <= state + 'd1;
                    end
            'd23: begin
                if(ware_house23[2] == warehouse_input) begin
                    x_warehouse <= ware_house23[0];
                    y_warehouse <= ware_house23[1];
                    state <= 'd25;
                    end
                else state <= state + 'd1;
                    end
            'd24: begin
                if(ware_house24[2] == warehouse_input) begin
                    x_warehouse <= ware_house24[0];
                    y_warehouse <= ware_house24[1];
                    state <= 'd25;
                    end
                else state <= state + 'd1;
                    end
            'd25:begin
                state <= state + 'd1;
            end
            'd26: begin
                state <= state + 'd1;
            end
            'd27: begin
                ready_flag <= 1'b1;
                state <= state + 'd1;
            end
            'd28: begin
                state <= state + 'd1;
            end
            'd29: begin
                ready_flag <= 1'b0;
                state <= state + 'd1;
            end
            'd30: begin
                state <= 'd0;
            end
            default:state <= 'd0;
            endcase 
    end  
end

endmodule