module uart_tx_pump
#( 
    parameter UART_BPS    = 'd115200,        // 串口波特率
    parameter CLK_FREQ    = 'd50_000_000,    // 时钟频率
    parameter DATA_WIDTH  = 120              // 输入数据位宽（可配置任意值）
) 
( 
    input  wire            sys_clk,
    input  wire            sys_rst_n,
    input  wire [DATA_WIDTH-1:0] pi_data,    // 模块输入的动态位宽数据
    input  wire            pi_flag,
    
    output reg             tx,
    output reg             tx_done
);

// 本地参数计算
localparam BAUD_CNT_MAX   = CLK_FREQ / UART_BPS;
localparam BYTE_COUNT     = (DATA_WIDTH + 7) / 8;    // 计算需要传输的字节数（向上取整）
localparam BYTE_CNT_WIDTH = $clog2(BYTE_COUNT);      // 字节计数器位宽

// 寄存器定义
reg [12:0]        baud_cnt;
reg               bit_flag;
reg [3:0]         bit_cnt;
reg [BYTE_CNT_WIDTH-1:0] byte_cnt;
reg               work_en;

// 数据扩展：将输入数据扩展到完整的字节边界（高位补0）
localparam EXT_WIDTH = BYTE_COUNT * 8;
wire [EXT_WIDTH-1:0] data_ext = {{(EXT_WIDTH-DATA_WIDTH){1'b0}}, pi_data};

// 工作使能控制
always @(posedge sys_clk or negedge sys_rst_n) begin
    if (!sys_rst_n)
        work_en <= 1'b0;
    else if (pi_flag)
        work_en <= 1'b1;
    else if (bit_flag && (bit_cnt == 4'd9) && (byte_cnt == BYTE_COUNT-1))
        work_en <= 1'b0;
end

// 波特率计数器
always @(posedge sys_clk or negedge sys_rst_n) begin
    if (!sys_rst_n)
        baud_cnt <= 0;
    else if (!work_en || (baud_cnt == BAUD_CNT_MAX-1))
        baud_cnt <= 0;
    else
        baud_cnt <= baud_cnt + 1;
end

// 比特标志生成
always @(posedge sys_clk or negedge sys_rst_n) begin
    if (!sys_rst_n)
        bit_flag <= 0;
    else
        bit_flag <= (baud_cnt == 1);
end

// 比特计数器和字节计数器
always @(posedge sys_clk or negedge sys_rst_n) begin
    if (!sys_rst_n) begin
        bit_cnt  <= 0;
        byte_cnt <= 0;
    end else if (bit_flag) begin
        if (bit_cnt == 9) begin
            bit_cnt <= 0;
            byte_cnt <= (byte_cnt == BYTE_COUNT-1) ? 0 : byte_cnt + 1;
        end else begin
            bit_cnt <= bit_cnt + 1;
        end
    end
end

// 数据发送逻辑
always @(posedge sys_clk or negedge sys_rst_n) begin
    if (!sys_rst_n) begin
        tx <= 1'b1;
    end else if (bit_flag) begin
        case (bit_cnt)
            0: tx <= 1'b0;  // 起始位
            1: tx <= data_ext[byte_cnt*8 + 0];
            2: tx <= data_ext[byte_cnt*8 + 1];
            3: tx <= data_ext[byte_cnt*8 + 2];
            4: tx <= data_ext[byte_cnt*8 + 3];
            5: tx <= data_ext[byte_cnt*8 + 4];
            6: tx <= data_ext[byte_cnt*8 + 5];
            7: tx <= data_ext[byte_cnt*8 + 6];
            8: tx <= data_ext[byte_cnt*8 + 7];
            9: tx <= 1'b1;  // 停止位
            default: tx <= 1'b1;
        endcase
    end
end

// 传输完成标志
always @(posedge sys_clk or negedge sys_rst_n) begin
    if (!sys_rst_n)
        tx_done <= 0;
    else
        tx_done <= (bit_flag && (bit_cnt == 9) && (byte_cnt == BYTE_COUNT-1));
end

endmodule