module FSM (
    input wire clk,
    input wire rstn,
	input wire valid_in,
    input wire start,
    input wire shiftDone,
    input wire valid_out,
	output reg write_fifo,
	output reg read_fifo,
	output wire en_shift,
    output reg alu_en
);
    
parameter   P_ST_IDLE = 'd0 ,
            P_ST_FIFOIN = 'd1 ,
            P_ST_SHIFT = 'd2 ,
            P_ST_MAC = 'd3 ,
            P_ST_DONE = 'd4 ;

reg [4:0] r_st_current;
reg [4:0] r_st_next   ;
reg read_fifo_d, read_fifo_d2;

always @(posedge clk or negedge rstn) begin
    if (!rstn) begin
        r_st_current <= P_ST_IDLE;
    end
    else begin
        r_st_current <= r_st_next;
    end
end

always @(*) begin
    case (r_st_current)
        P_ST_IDLE: begin
            if(valid_in) begin
                r_st_next = P_ST_FIFOIN;
            end 
            else begin
                r_st_next = P_ST_IDLE;
            end
        end
        P_ST_FIFOIN: begin
            if(start) begin
                r_st_next = P_ST_SHIFT;
            end 
            else begin
                r_st_next = P_ST_FIFOIN;
            end
        end
        P_ST_SHIFT: begin
            if (shiftDone) begin
                r_st_next = P_ST_MAC;
            end
            else begin
                r_st_next = P_ST_SHIFT;
            end
        end
        P_ST_MAC : begin
            if (valid_out) begin
                r_st_next = P_ST_DONE;
            end
            else begin
                r_st_next = P_ST_MAC;
            end
        end
        P_ST_DONE:begin
            r_st_next = P_ST_IDLE;
        end
        default: r_st_next = P_ST_IDLE;
    endcase
end


// P_ST_FIFOIN
always @(posedge clk or negedge rstn) begin
    if (!rstn) begin
        write_fifo <= 0;
    end
    else if (r_st_current == P_ST_FIFOIN) begin
        write_fifo <= 1;
    end
    else begin
        write_fifo <= 0;
    end
end
// P_ST_SHIFT
reg en_shift_d0, en_shift_d1;
always @(posedge clk or negedge rstn) begin
    if (!rstn) begin
        read_fifo <= 0;
		en_shift_d0 <= 0;
		en_shift_d1 <= 0;
    end
    else if (r_st_current == P_ST_SHIFT) begin
        read_fifo <= 1;
		en_shift_d0 <= read_fifo;
		en_shift_d1 <= en_shift_d0;
    end
    else begin
        read_fifo <= 0;
		en_shift_d0 <= en_shift_d0;
		en_shift_d0 <= en_shift_d0;
    end
end
assign en_shift = en_shift_d0 & (~en_shift_d1);

// P_ST_MAC
always @(posedge clk or negedge rstn) begin
    if (!rstn) begin
       alu_en <= 0;
    end
    else if (r_st_current == P_ST_MAC) begin
       alu_en <= 1;
    end
    else begin
       alu_en <= 0;
    end
end

endmodule
