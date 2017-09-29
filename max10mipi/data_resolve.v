module data_resolve( input clk,
							input rstn,
							input [3:0] byte_gate,
							input [3:0] found_sot,
							input [3:0] hs_mode,
							input [8:0] data_offs,
							input [31:0] data,
							
							output  reg [15:0] byte_read,
							output  reg      package_valid);
							
wire [7:0] ecc_result;							
csi_rx_hdr_ecc csi_rx_hdr_ecc_inst(.data(data[23:0]),
											  .ecc(ecc_result));
//reg package_valid;
always @(posedge clk or negedge rstn)
	if(!rstn)
		begin
		package_valid <= 0;
		end
	else if(resolve_state == 3'd1)
			begin
			package_valid <= (ecc_result == hdr_ecc);
			end
	else package_valid <= package_valid;

reg [15:0] package_len;
//reg [15:0] byte_read;
reg [7:0]  hdr_ecc;
reg [2:0] resolve_state;											
always @(posedge clk or negedge rstn)
	if(!rstn)
		begin
		resolve_state <= 0;
		end
	else case(resolve_state)
					3'd0:	begin
							if((found_sot == 4'b1111)&&(byte_gate[0]))
								resolve_state <= 3'd1;
							else resolve_state <= 3'd0;
								
							end
					3'd1:	begin
							byte_read <= 0;
							if(byte_gate[0])
								begin
								package_len <= data[23:8];
								hdr_ecc <= data[31:24];
								if(({2'b00,data[5:0]} > 8'h0f))
									resolve_state <= 3'd2; //long package
								else resolve_state <= 3'd3;
								end
								
							end
					3'd2:	begin
							if(byte_gate[0])
								begin
								if(byte_read <= package_len - 4)
									begin
									resolve_state <= 3'd2;
									byte_read <= byte_read + 4;
									end
								else begin
									  resolve_state <= 3'd3;
									  byte_read <= byte_read;
									  end
								end
								
							end
					3'd3:	begin
							resolve_state <= 3'd0;
							end
					default:;
					endcase
					
always @(posedge clk or negedge rstn)
	if(!rstn)
		begin
		
		end
	else begin
			end
			
always @(posedge clk or negedge rstn)
	if(!rstn)
		begin
		end
	else begin
			end
			
always @(posedge clk or negedge rstn)
	if(!rstn)
		begin
		end
	else begin
			end
			
always @(posedge clk or negedge rstn)
	if(!rstn)
		begin
		end
	else begin
			end
			
always @(posedge clk or negedge rstn)
	if(!rstn)
		begin
		end
	else begin
			end
endmodule