module bit_slip_v(input [7:0]  curr_byte,
						input [7:0]	 last_byte,
						output 		 found_hdr,
						output [2:0] hdr_offs);

always @(curr_byte or last_byte)
	begin
	if({last_byte[7:0]} == 8'hb8)
		begin
		found_hdr = 1'b1;
		hdr_offs = 0;
		end
	else if(({curr_byte[0],last_byte[7:1]} == 8'hb8)&&(last_byte[0] == 0))
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
	else begin
			found_hdr = 0;
			hdr_offs = 0;
			end
	end
endmodule