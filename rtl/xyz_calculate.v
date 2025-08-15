module xyz_calculate(
    input                    sys_clk,
    input                    sys_rst_n,

    input [8:0] X, // 输入值 单位mm 0-265 9位
    input [7:0] Y,// 输入值 单位mm 0-175 8位
    input get_flag,// 抓取标志位 0-低 1-高
    input calculate_flag,

    output reg [11:0] pwm_out0,
    output reg [11:0] pwm_out1, // 输出值 500-2500 整数
    output reg [11:0] pwm_out2,
    output reg [11:0] pwm_out3,
    output reg ready_flag
);

reg [15:0]denom_in;
reg [23:0]numer_in;
wire [15:0]quotient_out;
reg [9:0]address;
wire [35:0] q_out;
reg [8:0] x_data;
reg [7:0] y_data;
reg [8:0] l_data;
reg start_flag = 1'b0;
reg get_flag_data;
//---------------------------------初始变量导入
always @(posedge sys_clk or negedge sys_rst_n) begin
    if(!sys_rst_n)begin
        start_flag <= 1'b0;
    end
    else begin
        if(calculate_flag) begin
            x_data <= X;
            y_data <= Y;
            get_flag_data <= get_flag;
            start_flag <= 1'b1;
        end
        else start_flag <= 1'b0;
    end    
end


// ----------角度计算
reg [11:0] address_atan = 12'd0; // 12位 6位x 6位y
wire [20:0] atan_q;//21位 9位l 12位pwm0
reg [4:0] first_step = 4'd0;
reg signed [31:0] temp2 = 32'd0; 
reg signed [31:0] temp3 = 32'd0; 
reg [5:0] x_data_in,y_data_in;
always @(posedge sys_clk or negedge sys_rst_n) begin
    if (!sys_rst_n) begin
        first_step <= 4'd0;
        ready_flag <= 1'b0;
    end else begin
        case (first_step)
            5'd0:begin 
                ready_flag <= 1'b0;
                if(start_flag) begin//address_atan <= {x/5 , y/5};
                        denom_in <= 'd5;
                        numer_in <= x_data;
                        first_step <= first_step + 1;
                end else begin
                    address_atan <= 12'd0;
                    first_step <= 5'd0;
                end
            end
            5'd1:begin
                x_data_in <= quotient_out;
                //if(x_data_in > 'd53)x_data_in <= 'd53;
                //else x_data_in <= x_data_in;
                first_step <= first_step + 1;
            end
            5'd2:begin
                denom_in <= 'd5;
                numer_in <= y_data;
                first_step <= first_step + 1;
            end
            5'd3:begin
                y_data_in <= quotient_out;
                //if(y_data_in > 'd35)y_data_in <= 'd35;
                //else y_data_in <= y_data_in;
                first_step <= first_step + 1;
            end
            5'd4:begin
                address_atan <= {x_data_in,y_data_in};
                first_step <= first_step + 1;
            end
            5'd5:begin
                first_step <= first_step + 1;
            end
            5'd6:begin
                first_step <= first_step + 1;
            end
            5'd7:begin
                l_data <= atan_q[20:12];
                pwm_out0 <= atan_q[11:0];
                first_step <= first_step + 1;
            end
            5'd8: begin
                first_step <= first_step + 1;
            end 
            5'd9: begin//根据l_data 选择位置输出
                address <= {get_flag_data,l_data};
                first_step <= first_step + 1;
            end
            5'd10:begin
                first_step <= first_step + 1;
            end
            5'd11:begin
                first_step <= first_step + 1;
            end
            5'd12:begin
                pwm_out1 <= q_out[35:24];
                first_step <= first_step + 1;
            end
            5'd13:begin
                pwm_out2 <= q_out[23:12];
                first_step <= first_step + 1;
            end
            5'd14: begin
                pwm_out3 <= q_out[11:0];
                first_step <= first_step + 1;
            end
            5'd15: begin
                first_step <= first_step + 1;
            end
            5'd16: begin
                ready_flag <= 1'b1;
                first_step <= 5'd0;
            end
        endcase
    end
end

bottom_rom bottom_inst(
    .address(address_atan),
    .clock(sys_clk),
    .q(atan_q)
);

arm_rom arm_rom_inst (
	.address(address),
	.clock(sys_clk),
	.q(q_out)
);

DIV_xyz	DIV_inst1 (
    .denom ( denom_in ),
    .numer ( numer_in ),
    .quotient ( quotient_out )
);
endmodule