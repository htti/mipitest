module mipi_decode(
						input rx_inclk,
						input [3:0] rx_in,
						
						input rstn,
						
						input lp_mc_p,
						input lp_mc_n,
						input [3:0] lp_md_p,
						input [3:0] lp_md_n,
						
						//test
						output reg [7:0] lane0,
						output reg [7:0] lane1,
						output reg [7:0] lane2,
						output reg [7:0] lane3,
						output data_clk
						);
wire [7:0] data8;
lvds lvds_inst(
		.rx_inclock(rx_inclk),  	
		.rx_in(rx_in),       	 
		.rx_out(data8),     		  
		.rx_outclock(data_clk), 	 
		.rx_locked()    				 
	);
//reg [7:0] lane0,lane1,lane2,lane3;
always @(posedge data_clk or negedge rstn)
	if(!rstn)
		begin
		lane0 <= 0;
		lane1 <= 0;
		lane2 <= 0;
		lane3 <= 0;
		end
	else  begin
			lane0[7:6] <= {data8[1],data8[0]};
			lane0[5:4] <= lane0[7:6];
			lane0[3:2] <= lane0[5:4];
			lane0[1:0] <= lane0[3:2];
	
			lane1[7:6] <= {data8[3],data8[2]};
			lane1[5:4] <= lane1[7:6];
			lane1[3:2] <= lane1[5:4];
			lane1[1:0] <= lane1[3:2];

			lane2[7:6] <= {data8[5],data8[4]};
			lane2[5:4] <= lane2[7:6];
			lane2[3:2] <= lane2[5:4];
			lane2[1:0] <= lane2[3:2];

			lane3[7:6] <= {data8[7],data8[6]};
			lane3[5:4] <= lane3[7:6];
			lane3[3:2] <= lane3[5:4];
			lane3[1:0] <= lane3[3:2];
			end
wire [7:0] lane0_byte,lane1_byte,lane2_byte,lane3_byte;
wire       lane0_byte_gate,lane1_byte_gate,lane2_byte_gate,lane3_byte_gate;
wire       lane0_found_sot,lane1_found_sot,lane2_found_sot,lane3_found_sot;
wire       lane0_hs_mode,lane1_hs_mode,lane2_hs_mode,lane3_hs_mode;	
wire [2:0] lane0_data_offs,lane1_data_offs,lane2_data_offs,lane3_data_offs;		
lane_byte_align lane0_byte_align(.clk(data_clk),
											.rstn(rstn),
							  
											.lp_md_p(lp_md_p[0]),
											.lp_md_n(lp_md_n[0]),
											.ddr_data(data8[1:0]),
							  
											.byte_gate(lane0_byte_gate),
											.mipi_byte(lane0_byte),
											.found_sot(lane0_found_sot),
											.data_offs(lane0_data_offs),
											.hs_mode(lane0_hs_mode));
											
lane_byte_align lane1_byte_align(.clk(data_clk),
											.rstn(rstn),
							  
											.lp_md_p(lp_md_p[1]),
											.lp_md_n(lp_md_n[1]),
											.ddr_data(data8[3:2]),
							  
											.byte_gate(lane1_byte_gate),
											.mipi_byte(lane1_byte),
											.found_sot(lane1_found_sot),
											.data_offs(lane1_data_offs),
											.hs_mode(lane1_hs_mode));
											
lane_byte_align lane2_byte_align(.clk(data_clk),
											.rstn(rstn),
							  
											.lp_md_p(lp_md_p[2]),
											.lp_md_n(lp_md_n[2]),
											.ddr_data(data8[5:4]),
							  
											.byte_gate(lane2_byte_gate),
											.mipi_byte(lane2_byte),
											.found_sot(lane2_found_sot),
											.data_offs(lane2_data_offs),
											.hs_mode(lane2_hs_mode));
											
lane_byte_align lane3_byte_align(.clk(data_clk),
											.rstn(rstn),
							  
											.lp_md_p(lp_md_p[3]),
											.lp_md_n(lp_md_n[3]),
											.ddr_data(data8[7:6]),
							  
											.byte_gate(lane3_byte_gate),
											.mipi_byte(lane3_byte),
											.found_sot(lane3_found_sot),
											.data_offs(lane3_data_offs),
											.hs_mode(lane3_hs_mode));

data_resolve data_resolve_inst( 	.clk(data_clk),
											.rstn(rstn),
											.byte_gate({lane3_byte_gate,lane2_byte_gate,lane1_byte_gate,lane0_byte_gate}),
											.found_sot({lane3_found_sot,lane2_found_sot,lane1_found_sot,lane0_found_sot}),
											.hs_mode({lane3_hs_mode,lane2_hs_mode,lane1_hs_mode,lane0_hs_mode}),
											.data_offs({lane3_data_offs,lane2_data_offs,lane1_data_offs,lane0_data_offs}),
											.data({lane3_byte,lane2_byte,lane1_byte,lane0_byte}),
							
											.byte_read(),
											.package_valid());			


endmodule 