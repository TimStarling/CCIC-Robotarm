module key_detect (
    clk,
    rstn,
    key_in,
    key_down,
    key_up,
    led_out
  );

  input clk;
  input rstn;
  input key_in;
  output key_down;
  output key_up;
  output reg led_out;

  reg key_val;
  reg key_old;


  always @(posedge clk or negedge rstn)
  begin
    if(!rstn)
    begin
      key_old <= 0;
      key_val <= 0;
    end
    else
    begin
      key_val <= key_in;
      key_old <= key_val;
    end
  end

  assign POSEDGE = key_val &&!key_old;
  assign NEGEDGE =!key_val && key_old;

  parameter TIM_COUNT = 100_000 - 1;

  reg [3:0]state;
  reg [19:0]tim_count;
  reg key_state;

  always @(posedge clk or negedge rstn)
  begin
    if(!rstn)
    begin
      state <= 0;
      tim_count <= 0;
      key_state <= 0;
    end
    else if(state == 0&&NEGEDGE)
      state <= 1;
    else if(state == 1)
    begin
      if(POSEDGE)
        tim_count <= 0;
      else
      begin
        if(tim_count  == TIM_COUNT)
        begin
          tim_count <= 0;
          state <= 2;
          key_state <= 1;
        end
        else
          tim_count <= tim_count + 1;
      end
    end
    else if(state == 2)
    begin
      key_state <= 2;
      if(POSEDGE)
        state <= 3;
    end
    else if(state == 3)
    begin
      if(NEGEDGE)
        tim_count <= 0;
      else
      begin
        if(tim_count  == TIM_COUNT)
        begin
          tim_count <= 0;
          state <= 0;
          key_state <= 3;
        end
        else
          tim_count <= tim_count + 1;
      end
    end
  end

  assign key_down = key_state == 1 && state == 2;
  assign key_up = key_state == 3 && state == 0;

  always @(posedge clk or negedge rstn)
  begin
    if(!rstn)
      led_out <= 0;
    else if(key_down)
      led_out <= ~led_out;
  end

endmodule //key_detect
