module single_instruction(
    input                   sys_clk,
    input                   sys_rst_n,
    input             n2c_en,
    input  [7:0]      ID,
    input  [15:0]     location,
    output  wire          finish,
    output  wire          tx
);
reg [112-1:0] c_out = 'h0;
// 串口发送完成信号
wire              Tx_Done;
// 串口工作状态
wire              uart_state;

// 同步Send_en信号
reg               Send_en_r;
// Send_en信号的下降沿检测
wire              Send_en_p;

// 累加和
reg  [7:0]        sum;
// 校验和
reg  [7:0]        Calibration = 'h0;


// 同步Send_en信号
always@(posedge sys_clk or negedge sys_rst_n)begin
    if(!sys_rst_n)begin
        Send_en_r <= 0;
    end
    else
        Send_en_r <= n2c_en;
end

// 检测Send_en信号的下降沿
assign Send_en_p = {Send_en_r, n2c_en} == 2'b10 ? 1 : 0;

reg time_finshed = 0;
reg  outfinish = 0;

always @(posedge sys_clk or negedge sys_rst_n) begin
    if(!sys_rst_n) begin
        time_finshed <= 0;
    end
    else if(Send_en_p && !outfinish) begin
        sum <= ID + 8'h0A + 8'h03 + 8'h29 + 8'h1E + location[15:8] + location[7:0] + 8'hDC + 8'h05;//速度5DC 1500
        time_finshed <= 1;
    end else begin
        time_finshed <= 0;
    end
end

reg [3:0] outstep = 'd0; 

// 编码输出
always @(posedge sys_clk or negedge sys_rst_n) begin
    if (!sys_rst_n) begin
        c_out <= 'h0;
        outfinish <= 'b0;
    end else begin
        case (outstep)
            'd0: begin
                outfinish <= 1'b0;
                Calibration <= ~sum;
                if(finish)c_out <= 'h0;
                if(time_finshed)begin
                    outstep <= outstep + 1;
                end
            end
            'd1: begin
                outstep <= outstep + 1;

            end
            'd2: begin
                c_out <= {
                    Calibration, // 校验码，8位
                    8'h05,       // 速度低字节，8位
                    8'hDC,
                    8'h00,       // 时间低字节，8位
                    8'h00,       // 时间高字节，8位
                    location[15:8],   // 位置低字节，8位
                    location[7:0],  // 位置高字节，8位
                    8'h1E,       
                    8'h29,       // 写入舵机功能命令，8位
                    8'h03,       // 指令包功能命令，8位
                    8'h0A,       // 指令包数据长度，8位
                    ID,          // ID，8位
                    8'hFF,       // 字头，8位
                    8'hFF        // 字头，8位
                };
                if(c_out)outstep <= outstep + 1;
                else outstep <= outstep;
            end
            'd3: begin
                outfinish <= 1'b1;
                outstep <= 'd0;
            end
        endcase
        
    end
end

uart_Robot_tx u_uart_Robot_tx 
( 
    .sys_clk    (sys_clk    ),  // input             sys_clk 
    .sys_rst_n  (sys_rst_n  ),  // input             sys_rst_n 
    .pi_data    (c_out    ),  // input     [7:0]   pi_data 
    .pi_flag    (outfinish    ),  // input             pi_flag 
 
    .tx         (tx         ),   // output            tx 
    .tx_done    (finish)            // output            tx_done 
); 

endmodule