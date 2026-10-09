module parklot(
    input pout,  
    input pin,        
    input CLK,       
    input RST,
    output reg [4:0] CarCount,
    output reg FULL,
    output ERROR       
);


reg [2:0] next_state, present_state;

parameter idle = 3'd0,
          wait_pin = 3'd1,
          wait_pout =3'd2,
          entry =3'd3,
          exit= 3'd4,
          invalid = 3'd5;


reg err_flag;     
reg [5:0] blink_cnt;    

always @(*) begin
    next_state = idle;
    case (present_state)
        idle: begin
            if (pout && pin)
             next_state = invalid;
            else if (pout)
           next_state = wait_pin;
          else if (pin)
          next_state = wait_pout;
          else
         next_state = idle;
        end
        wait_pin: begin
            if (pin)
            next_state = entry;
            else
            next_state = wait_pin;
        end

        wait_pout: begin
            if (pout)
            next_state = exit;
            else
           next_state = wait_pout;
        end

     entry: next_state = idle;
    exit: next_state = idle;
       invalid:next_state = idle;
    default:next_state = idle;

    endcase
end




always @(posedge CLK or posedge RST) begin
    if (RST)
      present_state <= idle;
    else
  present_state <= next_state;
end

always @(posedge CLK or posedge RST) begin
    if (RST) begin
        CarCount <= 5'd0;
        err_flag <= 1'b0;
    end
    else begin
        case (present_state)

            entry: begin
                if (CarCount < 5'd25) begin
           CarCount <= CarCount + 1'b1;
                err_flag <= 1'b0;   
                end
                else
                    err_flag <= 1'b1;       
            end

            exit: begin
                if (CarCount > 5'd0) begin
                    CarCount <= CarCount - 1'b1;
                    err_flag <= 1'b0;          
                end
                else
                    err_flag <= 1'b1;    
            end
            invalid: begin
         err_flag <= 1'b1;      
            end
            default: ;      

        endcase
    end
end
always @(posedge CLK or posedge RST) begin
    if (RST)
    blink_cnt <= 6'd0;
    else
    blink_cnt <= blink_cnt + 1'b1;
end

assign ERROR = err_flag & blink_cnt[5];   
always @(*) begin
    if (CarCount == 5'd25)
  FULL = 1'b1;
    else
  FULL = 1'b0;
end

endmodule