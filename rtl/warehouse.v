module warehouse (
    input sys_clk,
    input sys_rst_n,
    input [3:0] color,// 红 1 黄 2 蓝 4 黑 8
    input [3:0] shape,// 方 1 六边 2 圆 4 三角 8 
    input wire en_flag,
    input wire uart_rx,

    output reg [8:0] x_warehouse,
    output reg [7:0] y_warehouse,
    output reg [11:0] direction, // 方向
    output reg ready_flag,
    output reg system_start
);
wire[4:0]location_input;
wire[3:0]Shape_input;
wire[3:0]color_input;
wire[3:0]angle_input;
wire write_down;
//--------------------------物品仓库--------------------------
reg [11:0] ware_house1 [0:6];//0-x 1-y 2-color_in 3-shape_in 4方向 5- 1为已有物品 0为空闲 6 -仓库编号
initial begin //一号
    ware_house1[0] = 'd255;
    ware_house1[1] = 'd145;
    ware_house1[2] = 12'd0;
    ware_house1[3] = 12'd0;
    ware_house1[4] = 12'd0;
    ware_house1[5] = 12'd0;
    ware_house1[6] = 'h01;
end
reg [11:0] ware_house2 [0:6];
initial begin //二号
    ware_house2[0] = 12'd255;
    ware_house2[1] = 12'd105;
    ware_house2[2] = 12'd0;
    ware_house2[3] = 12'd0;
    ware_house2[4] = 12'd0;
    ware_house2[5] = 12'd0;
    ware_house2[6] = 'h02;
end
reg [11:0] ware_house3 [0:6];
initial begin //三号
    ware_house3[0] = 12'd253;
    ware_house3[1] = 12'd60;
    ware_house3[2] = 12'd0;
    ware_house3[3] = 12'd0;
    ware_house3[4] = 12'd0;
    ware_house3[5] = 12'd0;
    ware_house3[6] = 'h03;
end
reg [11:0] ware_house4 [0:6];
initial begin //四号
    ware_house4[0] = 12'd255;
    ware_house4[1] = 12'd15;
    ware_house4[2] = 12'd0;
    ware_house4[3] = 12'd0;
    ware_house4[4] = 12'd0;
    ware_house4[5] = 12'd0;
    ware_house4[6] = 'h04;
end
reg [11:0] ware_house5 [0:6];
initial begin //五号
    ware_house5[0] = 12'd210;
    ware_house5[1] = 12'd150;
    ware_house5[2] = 12'd0;
    ware_house5[3] = 12'd0;
    ware_house5[4] = 12'd0;
    ware_house5[5] = 12'd0;
    ware_house5[6] = 'h05;
end
reg [11:0] ware_house6 [0:6];
initial begin //六号
    ware_house6[0] = 12'd210;
    ware_house6[1] = 12'd105;
    ware_house6[2] = 12'd0;
    ware_house6[3] = 12'd0;
    ware_house6[4] = 12'd0;
    ware_house6[5] = 12'd0;
    ware_house6[6] = 'h06;
end
reg [11:0] ware_house7 [0:6];
initial begin //七号
    ware_house7[0] = 12'd210;
    ware_house7[1] = 12'd68;
    ware_house7[2] = 12'd0;
    ware_house7[3] = 12'd0;
    ware_house7[4] = 12'd0;
    ware_house7[5] = 12'd0;
    ware_house7[6] = 'h07;
end
reg [11:0] ware_house8 [0:6];
initial begin //八号
    ware_house8[0] = 12'd210;
    ware_house8[1] = 12'd15;
    ware_house8[2] = 12'd0;
    ware_house8[3] = 12'd0;
    ware_house8[4] = 12'd0;
    ware_house8[5] = 12'd0;
    ware_house8[6] = 'h08;
end
reg [11:0] ware_house9 [0:6];
initial begin //九号
    ware_house9[0] = 12'd165;
    ware_house9[1] = 12'd155;
    ware_house9[2] = 12'd0;
    ware_house9[3] = 12'd0;
    ware_house9[4] = 12'd0;
    ware_house9[5] = 12'd0;
    ware_house9[6] = 'h09;
end
reg [11:0] ware_house10 [0:6];
initial begin //十号
    ware_house10[0] = 12'd165;
    ware_house10[1] = 12'd110;
    ware_house10[2] = 12'd0;
    ware_house10[3] = 12'd0;
    ware_house10[4] = 12'd0;
    ware_house10[5] = 12'd0;
    ware_house10[6] = 'h0A;
end
reg [11:0] ware_house11 [0:6];
initial begin //十一号
    ware_house11[0] = 12'd165;
    ware_house11[1] = 12'd73;
    ware_house11[2] = 12'd0;
    ware_house11[3] = 12'd0;
    ware_house11[4] = 12'd0;
    ware_house11[5] = 12'd0;
    ware_house11[6] = 'h0B;
end
reg [11:0] ware_house12 [0:6];
initial begin //十二号
    ware_house12[0] = 12'd160;
    ware_house12[1] = 12'd25;
    ware_house12[2] = 12'd0;
    ware_house12[3] = 12'd0;
    ware_house12[4] = 12'd0;
    ware_house12[5] = 12'd0;
    ware_house12[6] = 'h0C;
end
reg [11:0] ware_house13 [0:6];
initial begin //十三号
    ware_house13[0] = 12'd120;
    ware_house13[1] = 12'd160;
    ware_house13[2] = 12'd0;
    ware_house13[3] = 12'd0;
    ware_house13[4] = 12'd0;
    ware_house13[5] = 12'd0;
    ware_house13[6] = 'h0D;
end
reg [11:0] ware_house14 [0:6];
initial begin //十四号
    ware_house14[0] = 12'd120;
    ware_house14[1] = 12'd115;
    ware_house14[2] = 12'd0;
    ware_house14[3] = 12'd0;
    ware_house14[4] = 12'd0;
    ware_house14[5] = 12'd0;
    ware_house14[6] = 'h0E;
end
reg [11:0] ware_house15 [0:6];
initial begin //十五号
    ware_house15[0] = 12'd120;
    ware_house15[1] = 12'd70;
    ware_house15[2] = 12'd0;
    ware_house15[3] = 12'd0;
    ware_house15[4] = 12'd0;
    ware_house15[5] = 12'd0;
    ware_house15[6] = 'h0F;
end
reg [11:0] ware_house16 [0:6];
initial begin //十六号
    ware_house16[0] = 12'd120;
    ware_house16[1] = 12'd32;
    ware_house16[2] = 12'd0;
    ware_house16[3] = 12'd0;
    ware_house16[4] = 12'd0;
    ware_house16[5] = 12'd0;
    ware_house16[6] = 'h10;
end
reg [11:0] ware_house17 [0:6];
initial begin //十七号
    ware_house17[0] = 12'd75;
    ware_house17[1] = 12'd160;
    ware_house17[2] = 12'd0;
    ware_house17[3] = 12'd0;
    ware_house17[4] = 12'd0;
    ware_house17[5] = 12'd0;
    ware_house17[6] = 'h11;
end
reg [11:0] ware_house18 [0:6];
initial begin //十八号
    ware_house18[0] = 12'd75;
    ware_house18[1] = 12'd118;
    ware_house18[2] = 12'd0;
    ware_house18[3] = 12'd0;
    ware_house18[4] = 12'd0;
    ware_house18[5] = 12'd0;
    ware_house18[6] = 'h12;
end
reg [11:0] ware_house19 [0:6];
initial begin //十九号
    ware_house19[0] = 12'd75;
    ware_house19[1] = 12'd72;
    ware_house19[2] = 12'd0;
    ware_house19[3] = 12'd0;
    ware_house19[4] = 12'd0;
    ware_house19[5] = 12'd0;
    ware_house19[6] = 'h13;
end
reg [11:0] ware_house20 [0:6];
initial begin //二十号
    ware_house20[0] = 12'd75;
    ware_house20[1] = 12'd30;
    ware_house20[2] = 12'd0;
    ware_house20[3] = 12'd0;
    ware_house20[4] = 12'd0;
    ware_house20[5] = 12'd0;
    ware_house20[6] = 'h14;
end
reg [11:0] ware_house21 [0:6];
initial begin //二十一号
    ware_house21[0] = 12'd32;
    ware_house21[1] = 12'd164;
    ware_house21[2] = 12'd0;
    ware_house21[3] = 12'd0;
    ware_house21[4] = 12'd0;
    ware_house21[5] = 12'd0;
    ware_house21[6] = 'h15;
end
reg [11:0] ware_house22 [0:6];
initial begin //二十二号
    ware_house22[0] = 12'd32;
    ware_house22[1] = 12'd119;
    ware_house22[2] = 12'd0;
    ware_house22[3] = 12'd0;
    ware_house22[4] = 12'd0;
    ware_house22[5] = 12'd0;
    ware_house22[6] = 'h16;
end
reg [11:0] ware_house23 [0:6];
initial begin //二十三号
    ware_house23[0] = 12'd32;
    ware_house23[1] = 12'd74;
    ware_house23[2] = 12'd0;
    ware_house23[3] = 12'd0;
    ware_house23[4] = 12'd0;
    ware_house23[5] = 12'd0;
    ware_house23[6] = 'h17;
end
reg [11:0] ware_house24 [0:6];
initial begin //二十四号
    ware_house24[0] = 12'd28;
    ware_house24[1] = 12'd31;
    ware_house24[2] = 12'd0;
    ware_house24[3] = 12'd0;
    ware_house24[4] = 12'd0;
    ware_house24[5] = 12'd0;
    ware_house24[6] = 'h18;
end


//----------------------仓库内容读取部分--------------------
reg [3:0]color_in;
reg [3:0]shape_in;
reg [5:0] state = 'd0;
always @(posedge sys_clk or negedge sys_rst_n) begin
    if (!sys_rst_n) begin
        ready_flag <= 1'b0;
        ware_house1[5] <= 0;
        ware_house2[5] <= 0;
        ware_house3[5] <= 0;
        ware_house4[5] <= 0;
        ware_house5[5] <= 0;
        ware_house6[5] <= 0;
        ware_house7[5] <= 0;
        ware_house8[5] <= 0;
        ware_house9[5] <= 0;
        ware_house10[5] <= 0;
        ware_house11[5] <= 0;
        ware_house12[5] <= 0;
        ware_house13[5] <= 0;
        ware_house14[5] <= 0;
        ware_house15[5] <= 0;
        ware_house16[5] <= 0;
        ware_house17[5] <= 0;
        ware_house18[5] <= 0;
        ware_house19[5] <= 0;
        ware_house20[5] <= 0;
        ware_house21[5] <= 0;
        ware_house22[5] <= 0;
        ware_house23[5] <= 0;
        ware_house24[5] <= 0;
    end else begin
        case(state)
            'd0: begin
                ready_flag <= 1'b0;
                x_warehouse <= 'd0;
                y_warehouse <= 'd0;
                if (en_flag) begin
                    color_in <= color;
                    shape_in <= shape;
                    state <= 'd1;
                end
            end
            'd1: begin
                if(ware_house1[2] == color_in && ware_house1[3] == shape_in && ware_house1[5] == 0) begin
                    x_warehouse <= ware_house1[0];
                    y_warehouse <= ware_house1[1];
                    direction <= ware_house1[4];
                    ware_house1[5] <= 1;
                    state <= 'd25;
                end
                else state <= state + 'd1;
            end
            'd2: begin
                if(ware_house2[2] == color_in && ware_house2[3] == shape_in && ware_house2[5] == 0) begin
                    x_warehouse <= ware_house2[0];
                    y_warehouse <= ware_house2[1];
                    direction <= ware_house2[4];
                    ware_house2[5] <= 1;
                    state <= 'd25;
                end
                else state <= state + 'd1;
            end
            'd3: begin
                if(ware_house3[2] == color_in && ware_house3[3] == shape_in && ware_house3[5] == 0) begin
                    x_warehouse <= ware_house3[0];
                    y_warehouse <= ware_house3[1];
                    direction <= ware_house3[4];
                    ware_house3[5] <= 1;
                    state <= 'd25;
                end
                else state <= state + 'd1;
            end
            'd4: begin
                if(ware_house4[2] == color_in && ware_house4[3] == shape_in && ware_house4[5] == 0) begin
                    x_warehouse <= ware_house4[0];
                    y_warehouse <= ware_house4[1];
                    direction <= ware_house4[4];
                    ware_house4[5] <= 1;
                    state <= 'd25;
                    end
                else state <= state + 'd1;
            end
            'd5: begin
                if(ware_house5[2] == color_in && ware_house5[3] == shape_in && ware_house5[5] == 0) begin
                    x_warehouse <= ware_house5[0];
                    y_warehouse <= ware_house5[1];
                    direction <= ware_house5[4];
                    ware_house5[5] <= 1;
                    state <= 'd25;
                    end
                    else state <= state + 'd1;
            end
            'd6: begin
                if(ware_house6[2] == color_in && ware_house6[3] == shape_in && ware_house6[5] == 0) begin
                    x_warehouse <= ware_house6[0];
                    y_warehouse <= ware_house6[1];
                    direction <= ware_house6[4];
                    ware_house6[5] <= 1;
                    state <= 'd25;
                    end
                else state <= state + 'd1;
            end
            'd7: begin
                if(ware_house7[2] == color_in && ware_house7[3] == shape_in && ware_house7[5] == 0) begin
                    x_warehouse <= ware_house7[0];
                    y_warehouse <= ware_house7[1];
                    direction <= ware_house7[4];
                    ware_house7[5] <= 1;
                    state <= 'd25;
                    end
                    else state <= state + 'd1;
            end
            'd8: begin
                if(ware_house8[2] == color_in && ware_house8[3] == shape_in && ware_house8[5] == 0) begin
                    x_warehouse <= ware_house8[0];
                    y_warehouse <= ware_house8[1];
                    direction <= ware_house8[4];
                    ware_house8[5] <= 1;
                    state <= 'd25;
                end
                else state <= state + 'd1;
            end
            'd9: begin
                if(ware_house9[2] == color_in && ware_house9[3] == shape_in && ware_house9[5] == 0) begin
                    x_warehouse <= ware_house9[0];
                    y_warehouse <= ware_house9[1];
                    direction <= ware_house9[4];
                    ware_house9[5] <= 1;
                    state <= 'd25;
                end
                else state <= state + 'd1;
            end
            'd10: begin
                if(ware_house10[2] == color_in && ware_house10[3] == shape_in && ware_house10[5] == 0) begin
                    x_warehouse <= ware_house10[0];
                    y_warehouse <= ware_house10[1];
                    direction <= ware_house10[4];
                    ware_house10[5] <= 1;
                    state <= 'd25;
                    end
                else state <= state + 'd1;
            end
            'd11: begin
                if(ware_house11[2] == color_in && ware_house11[3] == shape_in && ware_house11[5] == 0) begin
                    x_warehouse <= ware_house11[0];
                    y_warehouse <= ware_house11[1];
                    direction <= ware_house11[4];
                    ware_house11[5] <= 1;
                    state <= 'd25;
                    end
                else state <= state + 'd1;
            end
            'd12: begin
                if(ware_house12[2] == color_in && ware_house12[3] == shape_in && ware_house12[5] == 0) begin
                    x_warehouse <= ware_house12[0];
                    y_warehouse <= ware_house12[1];
                    direction <= ware_house12[4];
                    ware_house12[5] <= 1;
                    state <= 'd25;
                    end
                else state <= state + 'd1;
            end
            'd13: begin
                if(ware_house13[2] == color_in && ware_house13[3] == shape_in && ware_house13[5] == 0) begin
                    x_warehouse <= ware_house13[0];
                    y_warehouse <= ware_house13[1];
                    direction <= ware_house13[4];
                    ware_house13[5] <= 1;
                    state <= 'd25;
                    end
                else state <= state + 'd1;
                    end
            'd14: begin
                if(ware_house14[2] == color_in && ware_house14[3] == shape_in && ware_house14[5] == 0) begin
                    x_warehouse <= ware_house14[0];
                    y_warehouse <= ware_house14[1];
                    direction <= ware_house14[4];
                    ware_house14[5] <= 1;
                    state <= 'd25;
                    end
                else state <= state + 'd1;
            end
            'd15: begin
                if(ware_house15[2] == color_in && ware_house15[3] == shape_in && ware_house15[5] == 0) begin
                    x_warehouse <= ware_house15[0];
                    y_warehouse <= ware_house15[1];
                    direction <= ware_house15[4];
                    ware_house15[5] <= 1;
                    state <= 'd25;
                    end
                else state <= state + 'd1;
            end
            'd16: begin
                if(ware_house16[2] == color_in && ware_house16[3] == shape_in && ware_house16[5] == 0) begin
                    x_warehouse <= ware_house16[0];
                    y_warehouse <= ware_house16[1];
                    direction <= ware_house16[4];
                    ware_house16[5] <= 1;
                    state <= 'd25;
                    end
                    else state <= state + 'd1;
            end
            'd17: begin
                if(ware_house17[2] == color_in && ware_house17[3] == shape_in && ware_house17[5] == 0) begin
                    x_warehouse <= ware_house17[0];
                    y_warehouse <= ware_house17[1];
                    direction <= ware_house17[4];
                    ware_house17[5] <= 1;
                    state <= 'd25;
                    end
                    else state <= state + 'd1;
            end
            'd18: begin
                if(ware_house18[2] == color_in && ware_house18[3] == shape_in && ware_house18[5] == 0) begin
                    x_warehouse <= ware_house18[0];
                    y_warehouse <= ware_house18[1];
                    direction <= ware_house18[4];
                    ware_house18[5] <= 1;
                    state <= 'd25;
                    end
                else state <= state + 'd1;
                    end
            'd19: begin
                if(ware_house19[2] == color_in && ware_house19[3] == shape_in && ware_house19[5] == 0) begin
                    x_warehouse <= ware_house19[0];
                    y_warehouse <= ware_house19[1];
                    direction <= ware_house19[4];
                    ware_house19[5] <= 1;
                    state <= 'd25;
                    end
                else state <= state + 'd1;
                    end
            'd20: begin
                if(ware_house20[2] == color_in && ware_house20[3] == shape_in && ware_house20[5] == 0) begin
                    x_warehouse <= ware_house20[0];
                    y_warehouse <= ware_house20[1];
                    direction <= ware_house20[4];
                    ware_house20[5] <= 1;
                    state <= 'd25;
                    end
                else state <= state + 'd1;
                    end
            'd21: begin
                if(ware_house21[2] == color_in && ware_house21[3] == shape_in && ware_house21[5] == 0) begin
                    x_warehouse <= ware_house21[0];
                    y_warehouse <= ware_house21[1];
                    direction <= ware_house21[4];
                    ware_house21[5] <= 1;
                    state <= 'd25;
                    end
                else state <= state + 'd1;
                    end
                    'd22: begin
                if(ware_house22[2] == color_in && ware_house22[3] == shape_in && ware_house22[5] == 0) begin
                    x_warehouse <= ware_house22[0];
                    y_warehouse <= ware_house22[1];
                    direction <= ware_house22[4];
                    ware_house22[5] <= 1;
                    state <= 'd25;
                    end
                else state <= state + 'd1;
                    end
            'd23: begin
                if(ware_house23[2] == color_in && ware_house23[3] == shape_in && ware_house23[5] == 0) begin
                    x_warehouse <= ware_house23[0];
                    y_warehouse <= ware_house23[1];
                    direction <= ware_house23[4];
                    ware_house23[5] <= 1;
                    state <= 'd25;
                    end
                else state <= state + 'd1;
                    end
            'd24: begin
                if(ware_house24[2] == color_in && ware_house24[3] == shape_in && ware_house24[5] == 0) begin
                    x_warehouse <= ware_house24[0];
                    y_warehouse <= ware_house24[1];
                    direction <= ware_house24[4];
                    ware_house24[5] <= 1;
                    state <= 'd25;
                    end
                else state <= state + 'd1;
                    end
            'd25:begin
                state <= state + 'd1;
            end
            'd26: begin
                if(direction == 12'd1) begin
                    direction <= 12'd0; // 设置方向
                end
                else if(direction == 12'd2) begin
                    direction <= 12'd2048; // 设置方向
                end
                else if(direction == 12'd4) begin
                    direction <= 12'd1024; // 设置方向
                end
                else if(direction == 12'd8) begin
                    direction <= 12'd3072; // 设置方向
                end
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


//----------------------UART写入部分--------------------
reg [6:0] uart_state = 'd0;
always @(posedge sys_clk or negedge sys_rst_n) begin
    if(!sys_rst_n)begin
        uart_state <= 'd0;
    end
    else begin
        case (uart_state)
            'd0: begin
                if(write_down)uart_state <= uart_state + 'd1;
                else uart_state <= 'd0;
            end
            'd1:begin
                if(location_input == 'h1F)begin
                    system_start <= 1'b1; // 开始工作
                end
                else if(location_input == 'h01) begin
                    ware_house1[2] <= color_input;
                    ware_house1[3] <= Shape_input;
                    ware_house1[4] <= angle_input;
                end
                else if(location_input == 'h02) begin
                    ware_house2[2] <= color_input;
                    ware_house2[3] <= Shape_input;
                    ware_house2[4] <= angle_input;
                end
                else if(location_input == 'h03) begin
                    ware_house3[2] <= color_input;
                    ware_house3[3] <= Shape_input;
                    ware_house3[4] <= angle_input;
                end
                else if(location_input == 'h04) begin
                    ware_house4[2] <= color_input;
                    ware_house4[3] <= Shape_input;
                    ware_house4[4] <= angle_input;
                end
                else if(location_input == 'h05) begin
                    ware_house5[2] <= color_input;
                    ware_house5[3] <= Shape_input;
                    ware_house5[4] <= angle_input;
                end
                else if(location_input == 'h06) begin
                    ware_house6[2] <= color_input;
                    ware_house6[3] <= Shape_input;
                    ware_house6[4] <= angle_input;
                end
                else if(location_input == 'h07) begin
                    ware_house7[2] <= color_input;
                    ware_house7[3] <= Shape_input;
                    ware_house7[4] <= angle_input;
                end
                else if(location_input == 'h08) begin
                    ware_house8[2] <= color_input;
                    ware_house8[3] <= Shape_input;
                    ware_house8[4] <= angle_input;
                end
                else if(location_input == 'h09) begin
                    ware_house9[2] <= color_input;
                    ware_house9[3] <= Shape_input;
                    ware_house9[4] <= angle_input;
                end
                else if(location_input == 'h0A) begin
                    ware_house10[2] <= color_input;
                    ware_house10[3] <= Shape_input;
                    ware_house10[4] <= angle_input;
                end
                else if(location_input == 'h0B) begin
                    ware_house11[2] <= color_input;
                    ware_house11[3] <= Shape_input;
                    ware_house11[4] <= angle_input;
                end
                else if(location_input == 'h0C) begin
                    ware_house12[2] <= color_input;
                    ware_house12[3] <= Shape_input;
                    ware_house12[4] <= angle_input;
                end
                else if(location_input == 'h0D) begin
                    ware_house13[2] <= color_input;
                    ware_house13[3] <= Shape_input;
                    ware_house13[4] <= angle_input;
                end
                else if(location_input == 'h0E) begin
                    ware_house14[2] <= color_input;
                    ware_house14[3] <= Shape_input;
                    ware_house14[4] <= angle_input;
                end
                else if(location_input == 'h0F) begin
                    ware_house15[2] <= color_input;
                    ware_house15[3] <= Shape_input;
                    ware_house15[4] <= angle_input;
                end
                else if(location_input == 'h10) begin
                    ware_house16[2] <= color_input;
                    ware_house16[3] <= Shape_input;
                    ware_house16[4] <= angle_input;
                end
                else if(location_input == 'h11) begin
                    ware_house17[2] <= color_input;
                    ware_house17[3] <= Shape_input;
                    ware_house17[4] <= angle_input;
                end
                else if(location_input == 'h12) begin
                    ware_house18[2] <= color_input;
                    ware_house18[3] <= Shape_input;
                    ware_house18[4] <= angle_input;
                end
                else if(location_input == 'h13) begin
                    ware_house19[2] <= color_input;
                    ware_house19[3] <= Shape_input;
                    ware_house19[4] <= angle_input;
                end
                else if(location_input == 'h14) begin
                    ware_house20[2] <= color_input;
                    ware_house20[3] <= Shape_input;
                    ware_house20[4] <= angle_input;
                end
                else if(location_input == 'h15) begin
                    ware_house21[2] <= color_input;
                    ware_house21[3] <= Shape_input;
                    ware_house21[4] <= angle_input;
                end
                else if(location_input == 'h16) begin
                    ware_house22[2] <= color_input;
                    ware_house22[3] <= Shape_input;
                    ware_house22[4] <= angle_input;
                end
                else if(location_input == 'h17) begin
                    ware_house23[2] <= color_input;
                    ware_house23[3] <= Shape_input;
                    ware_house23[4] <= angle_input;
                end
                else if(location_input == 'h18) begin
                    ware_house24[2] <= color_input;
                    ware_house24[3] <= Shape_input;
                    ware_house24[4] <= angle_input;
                end
                else begin
                    // 未知位置，忽略
                end
                uart_state <= 'd0;
            end
            default: uart_state <= 'd0;
        endcase
    end
end

uart_packet uart_packet_inst(
	.sys_clk(sys_clk),
	.sys_rst_n(sys_rst_n),
	.uart_rx(uart_rx),
	.location(location_input),
	.Shape(Shape_input),
	.color(color_input),
	.angle(angle_input),
	.valid(write_down)
);

endmodule