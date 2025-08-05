module all_instruction (
    input 					sys_clk		 ,
	input 					sys_rst_n	 ,

    //location1~5
    input    [15:0]     location1,
    input    [15:0]     location2,
    input    [15:0]     location3,
    input    [15:0]     location4,
    input    [15:0]     location5,

    
    //function
    input               Uart_en,

    output              tx,
    output       reg    Send_finish
);

// register 寄存器
reg                Uart_en_1;
reg                Uart_en_2;
reg                Delay_en_r;

//Delay
reg      [15:0]    div_cnt;  //分频系数 50_000-1 为1ms
reg      [13:0]    Delay_ms; //计数器  最大可计16384ms
reg                Delay_en;


//Seed
wire               finish;

reg      [3:0]     step;
reg                Send_en;
reg      [7:0]     ID;
reg      [15:0]    location;

//register
always@(posedge sys_clk or negedge sys_rst_n)begin
    if(!sys_rst_n)begin
        Uart_en_1<=0;
        Uart_en_2<=0;
        Delay_en_r<=0;
    end
    else begin
        Uart_en_1<=Uart_en;
        Uart_en_2<=Uart_en_1;
        Delay_en_r<=Delay_en;
        end
end

//分频
always@(posedge sys_clk or negedge sys_rst_n)begin
    if(!sys_rst_n)begin
        div_cnt<=0;   
    end
    else if(div_cnt==4_999)begin
        div_cnt<=0;
    end
    else if(Delay_en)begin
        div_cnt<=div_cnt+1;
    end
    else if ({Delay_en_r,Delay_en}==2'b10)begin
        div_cnt<=0;
    end
    else
        div_cnt<=div_cnt;

end

//计数
always@(posedge sys_clk or negedge sys_rst_n)begin
    if(!sys_rst_n)begin
        Delay_ms<=0;
    end
    else if (div_cnt==4_999)begin
        Delay_ms<=Delay_ms+1;
    end
    else if ({Delay_en_r,Delay_en}==2'b10)begin
        Delay_ms<=0;
    end          
    else
        Delay_ms<=Delay_ms;

end

//Seed
always@(posedge sys_clk or negedge sys_rst_n)begin
    if(!sys_rst_n)begin
        step<=0;
        ID<=0;
        location<=0;
        Send_en<=0;
        Delay_en<=0;
    end

    else begin
        case(step)

            0:begin
                 Send_finish<=0;

                 if({Uart_en_2,Uart_en_1}==2'b10)begin
                    step<=step+1;
                 end
            end

            1:begin
                            ID<=8'H05;
                          location<=location5;
                           Send_en<=1;
                           step<=step+1;
                    end

            2:begin
                            Send_en<=0;
                if(finish)begin
                    Delay_en<=1;
                    ID<=8'H04;
                    location<=location4;
                      end

                if(Delay_ms>500)begin
                    Send_en<=1;
                    Delay_en<=0;
                    step<=step+1; 
                end
                      
                else
                    step<=step;                                             
                    end
                    
            3:begin
                    step<=step+1;  //打一拍，避免Delay_ms没被清除就进入状态机的>500条件                   
                    end
                    
            4:begin
                            Send_en<=0;
                if(finish)begin
                    Delay_en<=1;						  
                    ID<=8'H03;
                    location<=location3;
                      end	

                if(Delay_ms>500)begin
                        Send_en<=1;
                       Delay_en<=0;
                       step<=step+1; 
                    end
                    else
                        step<=step;                                               
                    end
                    
            5:begin
                    step<=step+1;  //打一拍，避免Delay_ms没被清除就进入状态机的>500条件                   
                    end

            6:begin
                            Send_en<=0;
                if(finish)begin
                            Delay_en<=1;
                    ID<=8'H02;
                    location<=location2;
                        end
                    
                 if(Delay_ms>500)begin
                        Send_en<=1;
                       Delay_en<=0;
                       step<=step+1; 
                    end
                    else
                        step<=step;                                               
            end
                 
            7:begin
                    step<=step+1;  //打一拍，避免Delay_ms没被清除就进入状态机的>500条件                   
                    end


            8:begin
                Send_en<=0;
                if(finish)begin
                    Delay_en<=1;
                    ID<=8'H01;
                    location<=location1;
                                         
                end
                if(Delay_ms>500)begin
                        Send_en<=1;
                       Delay_en<=0;
                       step<=step+1; 
                    end
                    else
                        step<=step;                                               
            end						  

            9:begin
                Send_en<=0;
                if(finish)begin

                    Send_finish<=1;                       
                    step<=0;                                             
                end
            end
        endcase 
    end

end


single_instruction single_instruction_inst(
    .sys_clk(sys_clk),
    .sys_rst_n(sys_rst_n),
    .n2c_en(Send_en),
    .ID(ID),
    .location(location),
    .finish(finish),
    .tx(tx)
);

    
endmodule