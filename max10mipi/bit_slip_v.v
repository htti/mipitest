module bit_slip_v(input clk,
						input rstn,
						input   byte_gate,
						input [7:0]  curr_byte,
						input [7:0]	 last_byte,
						input        frame_start,
						output reg		 found_sot,
						output reg [2:0] data_offs,
						output reg [7:0] actual_byte);

reg found_hdr;
reg [2:0] hdr_offs;
always @(curr_byte or last_byte)
	begin
/*	if({last_byte[7:0]} == 8'hb8)
		begin
		found_hdr = 1'b1;
		hdr_offs = 0;
		end
	else */if(({curr_byte[0],last_byte[7:1]} == 8'hb8)&&(last_byte[0] == 0))
				begin
				found_hdr = 1'b1;
				hdr_offs = 1;
				end
	else if(({curr_byte[1:0],last_byte[7:2]} == 8'hb8)&&(last_byte[1:0] == 0))
				begin
				found_hdr = 1'b1;
				hdr_offs = 3'd2;
				end
	else if(({curr_byte[2:0],last_byte[7:3]} == 8'hb8)&&(last_byte[2:0] == 0))
				begin
				found_hdr = 1'b1;
				hdr_offs = 3'd3;
				end
	else if(({curr_byte[3:0],last_byte[7:4]} == 8'hb8)&&(last_byte[3:0] == 0))
				begin
				found_hdr = 1'b1;
				hdr_offs = 3'd4;
				end
	else if(({curr_byte[4:0],last_byte[7:5]} == 8'hb8)&&(last_byte[4:0] == 0))
				begin
				found_hdr = 1'b1;
				hdr_offs = 3'd5;
				end
	else if(({curr_byte[5:0],last_byte[7:6]} == 8'hb8)&&(last_byte[5:0] == 0))
				begin
				found_hdr = 1'b1;
				hdr_offs = 3'd6;
				end
	else if(({curr_byte[6:0],last_byte[7]} == 8'hb8)&&(last_byte[6:0] == 0))
				begin
				found_hdr = 1'b1;
				hdr_offs = 3'd7;
				end
	else if((curr_byte[7:0] == 8'hb8)&&(last_byte == 0))
				begin
				found_hdr = 1'b1;
				hdr_offs = 0;				
				end
	else begin
			found_hdr = 0;
			hdr_offs = 0;
			end
	end
////////////////////////////////////////////////
//reg [2:0] data_offs;
//reg found_sot;
always @(posedge clk or negedge rstn)
	if(!rstn)
		begin
		data_offs <= 0;
//		found_sot <= 0;
		end
	else if(frame_start)
			begin
			if(found_hdr)
				begin
				data_offs <= hdr_offs;
//				found_sot <= found_hdr;
				end
			else begin
				  data_offs <= data_offs;
//				  found_sot <= found_sot;
				  end
			end
	else begin
		  data_offs <= 0;
//		  found_sot <= 0;
		  end
/////////////////////////////////////////////
always @(posedge clk or negedge rstn)
	if(!rstn)
		begin
		actual_byte <= 0;
		end
	else if(byte_gate)
			begin
			actual_byte <= shifted_byte;
			end
always @(posedge clk or negedge rstn)
	if(!rstn)
		begin
		found_sot <= 0;
		end
	else if(byte_gate)
			begin
			found_sot <= found_hdr;
			end
///////////////////////////////////			
reg [7:0] shifted_byte;
always @(curr_byte or last_byte)
	begin
	case(data_offs)
		3'd0: shifted_byte = {curr_byte};
		3'd1: shifted_byte = {curr_byte[0],last_byte[7:1]};
		3'd2: shifted_byte = {curr_byte[1:0],last_byte[7:2]};
		3'd3: shifted_byte = {curr_byte[2:0],last_byte[7:3]};
		3'd4: shifted_byte = {curr_byte[3:0],last_byte[7:4]};
		3'd5: shifted_byte = {curr_byte[4:0],last_byte[7:5]};
		3'd6: shifted_byte = {curr_byte[5:0],last_byte[7:6]};
		3'd7: shifted_byte = {curr_byte[6:0],last_byte[7]};
		default:;
		endcase
	end
endmodule