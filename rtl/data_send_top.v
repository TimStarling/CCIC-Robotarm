module data_send_top(
    input 				sys_clk		 ,
    input 				sys_rst_n	 ,
    input       wire    uart_rx,
    input       wire    rx_camera,

    output				tx_armcontrol,
    output				tx_pump,
    output				tx_done,
	 output wire tx_test,
    output      reg     control_finish,

    input               key1

//    input            [11:0] angle_bias, // 角度偏移
//    input					control_flag,
//    input            [8:0] x_data,
//    input            [7:0] y_data,

);
assign tx_test = rx_camera;
reg control_flag;
wire  [8:0] x_data; 
wire  [7:0] y_data;
wire  [3:0] color;
reg  [5:0] warehouse_input;
(*keep*) wire  [11:0] angle_bias;// 角度偏移
/*
输入 xy en信号 短信号 finish短信号
*/
// 端口定义
reg get_flag = 'd1;// 抓取标志位 0-低 1-高
reg [8:0] x_input = 'd132;
reg [7:0] y_input = 'd80;
reg xyz_calculate_start = 1'b0;
wire xyz_calculate_ready;

parameter COUNT_MAX = 160_000_000 - 1;  // 计数值，50MHz 时钟下 4 秒的脉冲数 old 175
reg [31:0] count;         // 计数器，用于计时
reg cnt_finish = 1'b0;    // 计数结束标志位
reg cnt_begin = 1'b0;     // 计数开始标志位

always @(posedge sys_clk or negedge sys_rst_n) begin
    if (!sys_rst_n) begin
        count <= 0;
        cnt_finish <= 0;
    end
    else begin
        if (count == COUNT_MAX) begin
            count <= 0;
            cnt_finish <= 1;  // 定时时间到，置 1
        end
        else begin
            if(cnt_begin)begin
                count <= count + 1;
                cnt_finish <= 0;  // 其他时间保持 0
            end
            else count <= 'd0;
        end
    end
end

parameter COUNT_MAX2 = 65_000_000 - 1;  // 计数值，50MHz 时钟下 2 秒的脉冲数 old 75
reg [31:0] count2;         // 计数器，用于计时
reg cnt_finish2 = 1'b0;    // 计数结束标志位
reg cnt_begin2 = 1'b0;     // 计数开始标志位

always @(posedge sys_clk or negedge sys_rst_n) begin
    if (!sys_rst_n) begin
        count2 <= 0;
        cnt_finish2 <= 0;
    end
    else begin
        if (count2 == COUNT_MAX2) begin
            count2 <= 0;
            cnt_finish2 <= 1;  // 定时时间到，置 1
        end
        else begin
            if(cnt_begin2)begin
                count2 <= count2 + 1;
                cnt_finish2 <= 0;  // 其他时间保持 0
            end
            else count2 <= 'd0;
        end
    end
end
// -----------------------------------------------------------按键检测部分
wire key_down1,key_down2,key_down3,key_down4,key_down5;
always @(posedge sys_clk or negedge sys_rst_n) begin
    if(!sys_rst_n)begin
        control_flag <= 1'b0;
    end
    else begin
        if(key_down1) begin
            control_flag <= 1'b1;
            warehouse_input <= 'd1; // 仓库编号
        end
        else control_flag <= 1'b0;
    end
end
key_detect key_detect_inst (
 . clk(sys_clk),
 . rstn(sys_rst_n),
 . key_in(!key1),
 . key_down(key_down1)
);
//key_detect key_detect_inst1 (
// . clk(sys_clk),
// . rstn(sys_rst_n),
// . key_in(key2),
// . key_down(key_down2)
//);
//key_detect key_detect_inst2 (
// . clk(sys_clk),
// . rstn(sys_rst_n),
// . key_in(key3),
// . key_down(key_down3)
//);
//key_detect key_detect_inst3 (
// . clk(sys_clk),
// . rstn(sys_rst_n),
// . key_in(key4),
// . key_down(key_down4)
//);
//key_detect key_detect_inst4 (
// . clk(sys_clk),
// . rstn(sys_rst_n),
// . key_in(key5),
// . key_down(key_down5)
//);

reg start_flag = 1'b0; // 开始标志位
wire system_start; // 系统启动标志位
always @(posedge sys_clk or negedge sys_rst_n) begin
    if(!sys_rst_n)start_flag <= 1'b0;
    else
    if(!key1)start_flag <= 1'b1;
end

assign system_start = start_flag && control_flag; // 控制标志位

reg [11:0] angle_bias_reg; // 偏移后的角度寄存器
/*
    核心模块：发送控制 
    输入：x y 坐标，控制指令，颜色，形状 自动完成抓取存入仓库流程
    流程：
    1. 计算角度
    2. 运动到物料区指定物块高处
    3. 抓取
    4. 运动到物料区指定物块高处
    5. 运动到仓库的高处
    6. 放置
    7. 运动到仓库的高处
    8. 回到物料区指定物块高处
    9. 结束动作
*/
reg [5:0] state = 'd0;
reg write_start =1'b0;
wire [11:0] angle0,angle1,angle2,angle3,angle4;
reg warehouse_start = 1'b0;
wire warehouse_ready;
wire [11:0]pwm_out1,pwm_out2,pwm_out3,pwm_out0;
reg [15 * 8 - 1:0] pump_data;// #005P1500T1500 #005P2500T1500 气泵控制
wire [8:0] x_warehouse;
wire [7:0] y_warehouse;
wire [11:0] direction; // 方向
reg [5:0] warehouse = 'd0;
reg [3:0] color_input = 'd0;
(*keep = "true"*) reg [11:0] pwm_value0,pwm_value1,pwm_value2,pwm_value3,pwm_value4;
always @(posedge sys_clk or negedge sys_rst_n) begin
    if(!sys_rst_n) begin
        state <= 'd0;
    end
    else begin
        case(state)
            'd0: begin
                control_finish <= 1'b1;
                if(system_start) begin
                    angle_bias_reg <= angle_bias; // 保存偏移角度
                    control_finish <= 1'b0;
                    x_input <= x_data;
                    y_input <= y_data;
                    warehouse <= warehouse_input;
                    state <= state + 1;
                    xyz_calculate_start <= 1'b1;
                end
                else state <= state;
            end
            'd1: begin
                if(xyz_calculate_ready)begin //  运动到高处
                    pwm_value0 <= pwm_out0;
                    pwm_value1 <= pwm_out1;
                    pwm_value2 <= pwm_out2;
                    pwm_value3 <= pwm_out3;
                    pwm_value4 <= pwm_out0 + angle_bias_reg;
                    get_flag <= 1;
                    write_start <= 1'b1;
                    xyz_calculate_start <= 1'b0;
                    state <= state + 1;
                end
                else state <= state;
            end
            'd2: begin
                write_start <= 1'b0;// 等待2秒
                cnt_begin2 <= 1'b1;
                state <= state + 1;
            end
            'd3: begin
                if(cnt_finish2) begin 
                    xyz_calculate_start <= 1'b1;
                    cnt_begin2 <= 1'b0;
                    get_flag <= 0;
                    state <= state + 1;
                end
                else state <= state;
            end
            'd4:begin
                if(xyz_calculate_ready)begin // 运动到低处 抓取
                    pwm_value0 <= pwm_out0;
                    pwm_value1 <= pwm_out1;
                    pwm_value2 <= pwm_out2;
                    pwm_value3 <= pwm_out3;
                    pwm_value4 <= pwm_out0 + angle_bias_reg;
                    write_start <= 1'b1;
                    xyz_calculate_start <= 1'b0;
                    pump_data <= "!0051T0052P500#";
                    state <= state + 1;
                end
                else state <= state;
            end
            'd5: begin
                    write_start <= 1'b0;// 等待1.5秒
                    cnt_begin2 <= 1'b1;
                    state <= state + 1;
            end
            'd6: begin
                if(cnt_finish2) begin 
                    xyz_calculate_start <= 1'b1;
                    cnt_begin2 <= 1'b0;
                    get_flag <= 1;
                    state <= state + 1;
                end
                else state <= state;
            end
            'd7: begin
                if(xyz_calculate_ready)begin // 运动到高处
                    pwm_value0 <= pwm_out0;
                    pwm_value1 <= pwm_out1;
                    pwm_value2 <= pwm_out2;
                    pwm_value3 <= pwm_out3;
                    pwm_value4 <= pwm_out0;
                    write_start <= 1'b1;
                    xyz_calculate_start <= 1'b0;
                    state <= state + 1;
                end
                else state <= state;
            end
            'd8: begin
                write_start <= 1'b0;// 等待1.5秒
                cnt_begin2 <= 1'b1;
                state <= state + 1;
            end
            'd9: begin
                if(cnt_finish2) begin //寻找仓库地址
                    cnt_begin2 <= 1'b0;
                    warehouse_start <= 1'b1;
                    state <= state + 1;
                end
                else state <= state;
            end
            'd10:begin
                if(warehouse_ready) begin // 计算仓库位置
                    x_input <= x_warehouse;
                    y_input <= y_warehouse;
                    warehouse_start <= 1'b0;
                    get_flag <= 1;
                    xyz_calculate_start <= 1'b1;
                    state <= state + 1;
                end
                else state <= state;
            end
            'd11: begin
                if(xyz_calculate_ready)begin // 运动到仓库 高处
                    pwm_value0 <= pwm_out0 + 'd2048; // 高处
                    pwm_value1 <= pwm_out1;
                    pwm_value2 <= pwm_out2;
                    pwm_value3 <= pwm_out3;
                    pwm_value4 <= pwm_out0 + 'd2048 + direction;
                    xyz_calculate_start <= 1'b0;
                    write_start <= 1'b1;
                    state <= state + 1;
                end
                else state <= state;
            end
            'd12: begin
                write_start <= 1'b0;// 等待4秒
                cnt_begin <= 1'b1;
                state <= state + 1;
            end
            'd13: begin
                if(cnt_finish) begin // 下降放置
                    xyz_calculate_start <= 1'b1;
                    cnt_begin <= 1'b0;
                    get_flag <= 0;
                    state <= state + 1;
                end
                else state <= state;
            end
            'd14: begin
                if(xyz_calculate_ready)begin // 运动到仓库 低处
                    pwm_value0 <= pwm_out0 + 'd2048; 
                    pwm_value1 <= pwm_out1;
                    pwm_value2 <= pwm_out2;
                    pwm_value3 <= pwm_out3;
                    pwm_value4 <= pwm_out0 + 'd2048+ direction;
                    xyz_calculate_start <= 1'b0;
                    write_start <= 1'b1;
                    state <= state + 1;
                end
                else state <= state;
            end
            'd15: begin
                write_start <= 1'b0;// 等待2秒
                cnt_begin2 <= 1'b1;
                state <= state + 1;
            end
            'd16: begin
                if(cnt_finish2)begin//放下物块
                    cnt_begin2 <= 1'b0;
                    pump_data <= "!0051T0051P500#";
                    state <= state + 1;
                    write_start <= 1'b1;
                end 
                else state <= state;
            end
            'd17: begin
                write_start <= 1'b0;// 等待2秒
                cnt_begin2 <= 1'b1;
                state <= state + 1;
            end
            'd18: begin
                if(cnt_finish2) begin // 回到仓库 高处
                    cnt_begin2 <= 1'b0;
                    xyz_calculate_start <= 1'b1;
                    get_flag <= 1;
                    state <= state + 1;
                end
                else state <= state;
            end
            'd19: begin
                if(xyz_calculate_ready)begin // 运动到仓库 高
                    pwm_value0 <= pwm_out0 + 'd2048; 
                    pwm_value1 <= pwm_out1;
                    pwm_value2 <= pwm_out2;
                    pwm_value3 <= pwm_out3;
                    pwm_value4 <= pwm_out0 + 'd2048 + direction;
                    xyz_calculate_start <= 1'b0;
                    write_start <= 1'b1;
                    state <= state + 1;
                end
                else state <= state;
            end
            'd20: begin
                write_start <= 1'b0;// 等待2秒
                cnt_begin2 <= 1'b1;
                state <= state + 1;
            end
            'd21: begin
                if(cnt_finish2)begin // 回到上次位置
                    cnt_begin2 <= 1'b0;
                    pwm_value0 <= 'd2048;
                    pwm_value1 <= 'd1850;
                    pwm_value2 <= 'd3227;
                    pwm_value3 <= 'd3000;
                    pwm_value4 <= 'd2048;
                    write_start <= 1'b1;
                    state <= state + 1;
                end
                else state <= state;
            end
            'd22: begin
                write_start <= 1'b0;// 等待4秒
                cnt_begin <= 1'b1;
                state <= state + 1;
            end
            'd23: begin
                if(cnt_finish)begin
                    control_finish <= 1'b1;
                    cnt_begin <= 1'b0;
                    state <= state + 1;
                end
            end
            'd24: begin
                state <= 'd0;
            end
            default: state <= 'd0;
        endcase
    end
end

xyz_calculate xyz_calculate_inst(
    .sys_clk(sys_clk),
    .sys_rst_n(sys_rst_n),
    .X(x_input),
    .Y(y_input),
    .get_flag(get_flag),
    .calculate_flag(xyz_calculate_start),
    .pwm_out1(pwm_out1),
    .pwm_out2(pwm_out2),
    .pwm_out3(pwm_out3),
    .pwm_out0(pwm_out0),
    .ready_flag(xyz_calculate_ready)
);

//机械臂控制与串口发送
all_instruction all_instruction_inst(
    .sys_clk(sys_clk),
    .sys_rst_n(sys_rst_n),
    .location1(pwm_value0),
    .location2(pwm_value1),
    .location3(pwm_value2),
    .location4(pwm_value3),
    .location5(pwm_value4),
    .Uart_en(write_start),
    .tx(tx_armcontrol),
    .Send_finish(tx_done)
);

warehouse warehouse_inst (
    .sys_clk(sys_clk),
    .sys_rst_n(sys_rst_n),
    .warehouse_nob(warehouse_input),
    .en_flag(warehouse_start),
    .uart_rx(uart_rx),
    .x_warehouse(x_warehouse),
    .y_warehouse(y_warehouse),
    .direction(direction),
    .ready_flag(warehouse_ready)
);

//气泵串口
uart_tx_pump uart_tx_pumpinst 
( 
    .sys_clk    (sys_clk    ), 
    .sys_rst_n  (sys_rst_n  ), 
    .pi_data    (pump_data    ), 
    .pi_flag    (write_start    ), 
 
    .tx         (tx_pump         )
); 

//uart_camera uart_camera_init (
//	.Clk(sys_clk),
//	.rst_n(sys_rst_n),
//	.Uart_rx(rx_camera),
//	.angle_adjust(angle_bias),
//	.X_data(x_data),
//	.Y_data(y_data),
//	.warehouse_nob(warehouse_input),
//	.color(color),
//	.valid(control_flag)
//);

endmodule