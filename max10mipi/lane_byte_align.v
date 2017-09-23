module lane_byte_align(input clk,
							  input rstn,
							  
							  input lp_md_p,
							  input lp_md_n,
							  input [1:0] ddr_data,
							  
							  output reg       byte_en,
							  output reg [7:0] byte,
							  
							  output reg hs_mode);

localparam SYNC = 8'hB8;	
localparam IDLE = 3'd0,LP11 = 3'd1,LP01 = 3'd2,LP00 = 3'd3;						  

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
reg [2:0] cstate;
/*	
reg [2:0] cstate,nstate;
always @(posedge clk or negedge rstn)
	if(!rstn)
		begin
		cstate <= 0;
		end
	else begin
			cstate <= nstate;
			end
*/			
wire [1:0] lp_md;
assign lp_md = {lp_md_p,lp_md_n};
always @(posedge clk or negedge rstn)
	if(!rstn)
		cstate <= IDLE;
	else 
	begin
	//nstate = 0;
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
		else if(cstate == 3'd3)
				hs_mode <= 1'b1;
		else hs_mode <= 0;
reg [2:0] cnt;
always @(posedge clk or negedge rstn)
	if(!rstn)
		begin
		cnt <= 0;
		end
	else if(hs_mode)
		begin
		if(cnt == 3'd3)
			cnt <= 0;
		else cnt <= cnt + 1'b1;
		end
	else cnt <= 0;

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
	else if(cnt == 3'd3)
			begin
			lane_curr_byte <= lane_byte;
			lane_last_byte <= lane_curr_byte;
			end

bit_slip bit_slip_inst( .curr_byte(lane_curr_byte),
								.last_byte(lane_last_byte),
								.found_hdr(hdr_found),
								.hdr_offs(hdr_offset));
/*			
reg [2:0] i;
reg offset_found;
reg [2:0] offset;	

reg hdr_found;
reg [2:0] hdr_offset;
always @(lane_curr_byte,lane_last_byte,rstn)
	begin
	if(!rstn)
		i = 0;
	else if(hs_mode)
			begin
			if(i <= 3'd7)
				i = i + 1;
			else i = 0;
			end
	else i = 0;
	end
	
always @(lane_curr_byte,lane_last_byte,rstn)
	begin
	if(!rstn)
		begin
		offset = 0;
		offset_found = 0;
		end
	else case(i)
			0: begin
				if(({lane_curr_byte[0],lane_last_byte[7:1]} == SYNC) & (lane_last_byte[0] ==  0))
					begin
					offset = 0;
					offset_found = 1'b1;
					end
				else begin
						
						end
				end
			1: begin
				if(({lane_curr_byte[1:0],lane_last_byte[7:2]} == SYNC) & (lane_last_byte[1:0] ==  0))
					begin
					offset = 1;
					offset_found = 1'b1;
					end
				else begin
						
						end
				end
			2: begin
				if(({lane_curr_byte[2:0],lane_last_byte[7:3]} == SYNC) & (lane_last_byte[2:0] ==  0))
					begin
					offset = 2;
					offset_found = 1'b1;
					end
				else begin
						
						end
				end
			3: begin
				if(({lane_curr_byte[3:0],lane_last_byte[7:4]} == SYNC) & (lane_last_byte[3:0] ==  0))
					begin
					offset = 3;
					offset_found = 1'b1;
					end
				else begin
						
						end
				end
			4: begin
				if(({lane_curr_byte[4:0],lane_last_byte[7:5]} == SYNC) & (lane_last_byte[4:0] ==  0))
					begin
					offset = 4;
					offset_found = 1'b1;
					end
				else begin
						
						end
				end
			5: begin
				if(({lane_curr_byte[5:0],lane_last_byte[7:6]} == SYNC) & (lane_last_byte[5:0] ==  0))
					begin
					offset = 5;
					offset_found = 1'b1;
					end
				else begin
						
						end
				end
			6: begin
				if(({lane_curr_byte[6:0],lane_last_byte[7]} == SYNC) & (lane_last_byte[6:0] ==  0))
					begin
					offset = 6;
					offset_found = 1'b1;
					end
				else begin
						
						end
				end
			7: begin
				if(({lane_curr_byte[7:0]} == SYNC) & (lane_last_byte[7:0] ==  0))
					begin
					offset = 7;
					offset_found = 1'b1;
					end
				else begin
						
						end
				end
			endcase
	if(offset_found)
		begin
		hdr_found = 1'b1;
		hdr_offset = offset;
		end
	else begin
			hdr_found = 0;
			hdr_offset = 0;
			end
	end
*/
	
/*
always @(lane_curr_byte,lane_last_byte)
	begin
	offset = 0;
	offset_found = 0;
	for(i = 0; i < 4'd8; i = i + 1)
		begin
		if( ({lane_curr_byte[i:0],lane_last_byte[7:i+1]} == SYNC)&(lane_last_byte[i:0] ==  0) )
			begin
			offset = i;
			offset_found = 1'b1;
			end
		else begin
				offset = offset;
				offset_found = offset_found;
				end
		end
	if(offset_found)
		begin
		hdr_found = 1'b1;
		hdr_offset = offset;
		end
	else begin
			hdr_found = 0;
			hdr_offset = 0;
			end
	 end
*/
reg [2:0] data_offs;
reg hdr_found_r;
always @(posedge clk or negedge rstn)
	if(!rstn)
		begin
		hdr_found_r <= 0;
		byte_en <= 0;
		data_offs <= 0;
		end
	else begin
			hdr_found_r <= hdr_found;
			if(hdr_found & !hdr_found_r)
				begin
				byte_en <= 1'b1;
				data_offs <= hdr_offset;
				end
		  end
reg [7:0] shifted_byte;
always @(data_offs,lane_curr_byte,lane_last_byte)
	begin
	case(data_offs)
		3'd0: shifted_byte = {lane_curr_byte[0]  ,lane_last_byte[7:1]};
		3'd1: shifted_byte = {lane_curr_byte[1:0],lane_last_byte[7:2]};
		3'd2: shifted_byte = {lane_curr_byte[2:0],lane_last_byte[7:3]};
		3'd3: shifted_byte = {lane_curr_byte[3:0],lane_last_byte[7:4]};
		3'd4: shifted_byte = {lane_curr_byte[4:0],lane_last_byte[7:5]};
		3'd5: shifted_byte = {lane_curr_byte[5:0],lane_last_byte[7:6]};
		3'd6: shifted_byte = {lane_curr_byte[6:0],lane_last_byte[7]};
		3'd7: shifted_byte = lane_curr_byte[7:0];
		default:;
		endcase
	end
always @(posedge clk or negedge rstn)
	if(!rstn)
		begin
		byte <= 0;
		end
	else byte <= shifted_byte;
endmodule
		