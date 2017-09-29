module lane_byte_align(input clk,
							  input rstn,
							  
							  input lp_md_p,
							  input lp_md_n,
							  input [1:0] ddr_data,
							  
							  output reg       byte_gate,
							  output 	 [7:0] mipi_byte,
							  output 	       found_sot,
							  output     [2:0] data_offs,
							  
							  output reg hs_mode);

localparam SYNC = 8'hB8;	
localparam IDLE = 3'd0,LP11 = 3'd1,LP01 = 3'd2,LP00 = 3'd3;						  
/////////////////////////////////////
reg [1:0] lp_md_r;
reg lp_md_change;
always @(posedge clk or negedge rstn)
	if(!rstn)
		begin
		lp_md_r <= 0;
		end
	else begin
		  lp_md_r <= lp_md;
		  if(lp_md_r != lp_md)
				lp_md_change <= 1'b1;
		  else lp_md_change <= 1'b0;
		  end
//////////////////////////////////////////////////////////
reg [2:0] cstate;		
wire [1:0] lp_md;
assign lp_md = {lp_md_p,lp_md_n};
always @(posedge clk or negedge rstn)
	if(!rstn)
		cstate <= IDLE;
	else 
	begin
	case(cstate)
		IDLE: begin                //IDLE
				if((lp_md == 2'b11)&& lp_md_change)
					cstate = LP11;
				else cstate = IDLE;
				end
		LP11: begin                 //11
				if(lp_md_change)
					begin
					if(lp_md == 2'b01)
						cstate = LP01;
					else cstate = LP11;
					end
				else cstate <= LP11;
				end
		LP01: begin                //01
				if(lp_md_change)
					begin
					if(lp_md == 2'b00)
						cstate = LP00;
					else cstate = IDLE;
					end
				else cstate <= LP01;
				end
		
		LP00: begin               //00
				if(lp_md_change)
					begin
					if(lp_md == 2'b11)
						cstate = LP11;
					else cstate = IDLE;
					end
				else cstate <= LP00;
				end
		
		default: cstate = IDLE;
		endcase	
	end
//reg hs_mode;	
always @(posedge clk or negedge rstn)
		if(!rstn)
			hs_mode <= 0;
		else if(cstate == LP00)
				hs_mode <= 1'b1;
		else hs_mode <= 0;
reg [1:0] cnt;
//reg byte_gate;
always @(posedge clk or negedge rstn)
	if(!rstn)
		begin
		cnt <= 0;
		byte_gate <= 0;
		end
	else if(hs_mode)
		begin
		if(cnt == 2'd3)
			begin
			cnt <= 0;
			byte_gate <= 1'b1;
			end
		else begin
			  cnt <= cnt + 1'b1;
			  byte_gate <= 0;
			  end
		end
	else cnt <= 0;
//wire byte_gate;
//assign byte_gate = (cnt == 2'd3);

reg [7:0] lane_byte;
always @(posedge clk or negedge rstn)
	if(!rstn)
		begin
		lane_byte <= 0;
		end
	else begin
			lane_byte[7:6] <= ddr_data;
			lane_byte[5:4] <= lane_byte[7:6];
			lane_byte[3:2] <= lane_byte[5:4];
			lane_byte[1:0] <= lane_byte[3:2];
			end
reg [7:0] lane_curr_byte,lane_last_byte;
always @(posedge clk or negedge rstn)
	if(!rstn)
		begin
		lane_curr_byte <= 0;
		lane_last_byte <= 0;
		end
	else if(byte_gate)
			begin
			lane_curr_byte <= lane_byte;
			lane_last_byte <= lane_curr_byte;
			end
bit_slip_v bit_slip_v_inst(.clk(clk),
									.rstn(rstn),
									.byte_gate(byte_gate),
									.curr_byte(lane_curr_byte),
									.last_byte(lane_last_byte),
									.frame_start(hs_mode),
									.found_sot(found_sot),
									.data_offs(data_offs),
									.actual_byte(mipi_byte));
/*
bit_slip bit_slip_inst( .curr_byte(lane_curr_byte),
								.last_byte(lane_last_byte),
								.found_hdr(hdr_found),
								.hdr_offs(hdr_offset));
*/
endmodule
		