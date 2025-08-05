module uart_camera(
	input 				Clk,
	input 				rst_n,
	input 				Uart_rx,
	
	output  reg [11:0] angle_adjust,
	output  reg [8:0] X_data,
	output  reg [7:0] Y_data,
	output  reg [3:0] Shape,
	output  reg [3:0] color,
	output  reg       valid
	
);
	reg  [1:0]   		Rx_Done_r;
	wire [7:0] data_packet;
	reg [7:0] x_data_low;
	reg [7:0] x_data_high;
	reg [7:0] angle_adjust_low;
	reg [7:0] angle_adjust_high;
	
	reg [11:0] angle_adjust_reg;
	reg [8:0] X_data_reg;
	reg [7:0] Y_data_reg;
	reg [3:0] Shape_reg;
	reg [3:0] color_reg;
	
	wire           Rx_Done;
	
	reg  [5:0] state;
	wire	posedge_Done;

always@(posedge Clk or negedge rst_n)begin
	if(!rst_n)
		Rx_Done_r<=0;
	else begin
		Rx_Done_r[0]<=Rx_Done;
		Rx_Done_r[1]<=Rx_Done_r[0];
	end
end

assign posedge_Done=(Rx_Done_r==2'b01)?1:0;	
	
//FF X高 X低 Y 形状 颜色 转角高 转角低 F1
always@(posedge Clk or negedge rst_n)begin
	if(!rst_n)begin
		state<=0;
		x_data_low<=0;
		x_data_high<=0;
		angle_adjust_low<=0;
		angle_adjust_high<=0;
		valid<=0;
		
		angle_adjust_reg <= 0;
		X_data_reg <= 0;
		Y_data_reg <= 0;
		Shape_reg <= 0;
		color_reg <= 0;
		
		angle_adjust <= 0;
		X_data <= 0;
		Y_data <= 0;
		Shape <= 0;
		color <= 0;
	end
	else begin
	case(state)
		0 : begin		
					valid<=0;
					if(posedge_Done&&data_packet==8'hFF)begin//帧头
							state<=state + 1;
					end
					 else begin
							state<=state;
							end
					 end
		1: begin
					if(posedge_Done)begin//X高
							x_data_high<=data_packet;
							state<=state + 1;
					end
					 else begin
							state<=state;								
							end
					end
		2: begin
					if(posedge_Done)begin//X低
							x_data_low<=data_packet[7:0];
							state<=state + 1;
					end
					 else begin
							state<=state;								
							end
					end
		3: begin
					if(posedge_Done)begin//Y
							X_data_reg<={x_data_high[0],x_data_low}; // 修正X_data位宽匹配
							Y_data_reg<=data_packet[7:0];
							state<=state + 1;
					end
					 else begin
							state<=state;								
							end
					end
		4: begin
					 if(posedge_Done)begin//形状信息
							Shape_reg<=data_packet[3:0];
							state<=state + 1;
					end
					 else begin
							state<=state;								
							end
					end
		5: begin
					 if(posedge_Done)begin//颜色
							color_reg<=data_packet[3:0];
							state<=state + 1;
					end
					 else begin
							state<=state;								
							end
					end		
		6: begin
					 if(posedge_Done)begin//转角高
							angle_adjust_high<=data_packet[7:0];
							state<=state + 1;
					end
					 else begin
							state<=state;								
							end
					end
		7: begin
					 if(posedge_Done)begin//转角低
							angle_adjust_low<=data_packet[7:0];
							state<=state + 1;
					end
					 else begin
							state<=state;								
							end
					end
		8: begin
		         if(posedge_Done)begin//帧尾
						if(data_packet==8'hF1)begin
							angle_adjust_reg<={angle_adjust_high,angle_adjust_low};
							state<=state + 1;
							end
						else begin
							state<=0; // 帧尾错误，重置状态机
							end
					end
					 else begin
							state<=state;								
							end
					 end
		9: begin
			angle_adjust_reg <= angle_adjust_reg * 11; // 转角调整计算
			state<=state + 1;
		end
		10: begin
					// 同时更新所有输出寄存器
					angle_adjust <= angle_adjust_reg;
					X_data <= X_data_reg;
					Y_data <= Y_data_reg;
					Shape <= Shape_reg;
					color <= color_reg;
					valid <= 1; // 输出数据有效
					state <= 0; // 返回初始状态
		end
		default : state<=0;
		endcase
	end
end
		
 UART_RX UART_RX_inst(
/*input*/ 				.sys_clk(Clk),
/*input*/ 				.sys_rst_n(rst_n),
/*input*/ 				.rx(Uart_rx),
/*output reg[7:0]*/	.po_data(data_packet),
/*output reg*/ 		.po_flag(Rx_Done)  
);

endmodule