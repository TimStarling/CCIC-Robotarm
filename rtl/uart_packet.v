`timescale 1ns / 1ps
module uart_packet(
	input 				sys_clk,
	input 				sys_rst_n,
	input 		wire		uart_rx,
	
	
	output  reg [3:0] led,
	output  reg [4:0] location,
	output  reg [3:0] Shape,
	output  reg [3:0] color,
	output  reg [3:0] angle,
	output  reg       valid
	
);
	reg  [1:0]   		Rx_Done_r;
	wire [7:0] data_packet;
	wire           Rx_Done;
	
			  
	reg  [2:0] state;
	wire	posedge_Done;

always@(posedge sys_clk or negedge sys_rst_n)begin
	if(!sys_rst_n)
		Rx_Done_r<=0;
	else begin
		Rx_Done_r[0]<=Rx_Done;
		Rx_Done_r[1]<=Rx_Done_r[0];
		  end

end

assign posedge_Done=(Rx_Done_r==2'b01)?1:0;	
	

always@(posedge sys_clk or negedge sys_rst_n)begin
	if(!sys_rst_n)begin
		state<=0;
		location<=0;
		Shape<=0;
		color<=0;
		angle<=0;
		valid<=0;

	end
	else begin
	case(state)
		0 : begin		
					valid<=0;
					if(posedge_Done&&data_packet==8'hFF)begin//帧头
							state<=1;
					end
					 else begin
							state<=0;
							end
					 end
		1: begin
					if(posedge_Done)begin//仓库编号信息
							location<=data_packet[4:0];
							state<=2;
					end
					 else begin
							state<=1;								
							end
					end
		2: begin
					if(posedge_Done)begin//形状信息
							Shape<=data_packet[3:0];
							state<=3;
					end
					 else begin
							state<=2;								
							end
					end
		3: begin
					if(posedge_Done)begin//颜色信息
							color<=data_packet[3:0];
							state<=4;
					end
					 else begin
							state<=3;								
							end
					end
		4: begin
					 if(posedge_Done)begin//角度信息
							angle<=data_packet[3:0];
							valid<=1;
							state<=5;
					end
					 else begin
							state<=4;								
							end
					end
		5: begin
		         if(posedge_Done)begin//帧尾
						if(data_packet==8'hFF)begin
							valid<=1;
							state<=0;
							end
						else begin
							state<=0;									
							end
					end
					 else begin
							state<=5;								
							end
					 end
		default : state<=0;
		endcase
		end
	end

	always@(posedge sys_clk or negedge sys_rst_n)begin
		if(!sys_rst_n)
			led<=4'b1111;
		else begin
				if(location==1)begin
					led[0]=0;
				end
				if(Shape==1)begin
					led[1]=0;
				end
				if(color==1)begin
					led[2]=0;
				end
				if(angle==1)begin
					led[3]=0;
				end			
	end
end		
		
 UART_RX u_UART_RX(
/*input*/ 				.sys_clk(sys_clk),
/*input*/ 				.sys_rst_n(sys_rst_n),
/*input*/ 				.rx(uart_rx),
/*output reg[7:0]*/	.po_data(data_packet),
/*output reg*/ 		.po_flag(Rx_Done)  
);

endmodule

