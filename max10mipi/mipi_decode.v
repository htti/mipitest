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
		.rx_inclock(rx_inclk),  	//  rx_inclock.rx_inclock
		.rx_in(rx_in),       		//  rx_in.rx_in
		.rx_out(data8),     		 	//  rx_out.rx_out
		.rx_outclock(data_clk), 	//  rx_outclock.rx_outclock
		.rx_locked()    				//  x_locked.rx_locked
	);
	
//word align
//reg [1:0] lane0_r0,lane0_r1,lane0_r2,lane0_r3;
//reg [1:0] lane1_r0,lane1_r1,lane1_r2,lane1_r3;
//reg [1:0] lane2_r0,lane2_r1,lane2_r2,lane2_r3;
//reg [1:0] lane3_r0,lane3_r1,lane3_r2,lane3_r3;

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
			
lane_byte_align lane0_byte_align(.clk(data_clk),
											.rstn(rstn),
							  
											.lp_md_p(lp_md_p[0]),
											.lp_md_n(lp_md_n[0]),
											.ddr_data(data8[1:0]),
							  
											.byte_en(),
											.byte(),
											.hs_mode());
											
lane_byte_align lane1_byte_align(.clk(data_clk),
											.rstn(rstn),
							  
											.lp_md_p(lp_md_p[1]),
											.lp_md_n(lp_md_n[1]),
											.ddr_data(data8[3:2]),
							  
											.byte_en(),
											.byte(),
											.hs_mode());
											
lane_byte_align lane2_byte_align(.clk(data_clk),
											.rstn(rstn),
							  
											.lp_md_p(lp_md_p[2]),
											.lp_md_n(lp_md_n[2]),
											.ddr_data(data8[5:4]),
							  
											.byte_en(),
											.byte(),
											.hs_mode());
											
lane_byte_align lane3_byte_align(.clk(data_clk),
											.rstn(rstn),
							  
											.lp_md_p(lp_md_p[3]),
											.lp_md_n(lp_md_n[3]),
											.ddr_data(data8[7:6]),
							  
											.byte_en(),
											.byte(),
											.hs_mode());

/*
reg [2:0] cnt;
always @(posedge data_clk or negedge rstn)
	if(!rstn)
		begin
		cnt <= 0;
		end
	else if(cnt == 3'd3)
			cnt <= 0;
	else cnt <= cnt + 1'b1;
	
reg [7:0] lane0_curr_byte,lane0_last_byte;
reg [7:0] lane1_curr_byte,lane1_last_byte;
reg [7:0] lane2_curr_byte,lane2_last_byte;
reg [7:0] lane3_curr_byte,lane3_last_byte;

always @(posedge data_clk or negedge rstn)
	if(!rstn)
		begin
		lane0_curr_byte
		end
*/
reg [1:0] LP_state;
always @(posedge lp_mc_p or negedge rstn)
	if(!rstn)
		begin
		LP_state <= 0;
		end
	else case(LP_state)
			2'd0: begin
					if(lp_md_p & lp_md_n) //11
						LP_state <= 2'd1;
					else LP_state <= 2'd0;
					end
			2'd1: begin
					if(!lp_md_p & lp_md_n) //01
						LP_state <= 2'd2;
					else LP_state <= 2'd1;
					end
			2'd2: begin
					if(!lp_md_p & !lp_md_n)
						LP_state <= 2'd3;
					else LP_state <= 2'd2;
					end
			2'd3: begin
					
					end
			default:;
			endcase

//always @(posedge data_clk or negedge rstn)
//	if()
	

//always @(posedge data_clk)
/*
wire [7:0] data0,data1,data2,dat3;
wire data_clk0,data_clk1,data_clk2,data_clk3;
lvds lvds_inst0(
		.rx_inclock(rx_inclk),  //  rx_inclock.rx_inclock
		.rx_in(rx_in),       //       rx_in.rx_in
		.rx_out(data0),      //      rx_out.rx_out
		.rx_outclock(data_clk0), // rx_outclock.rx_outclock
		.rx_locked()    //   rx_locked.rx_locked
	);

lvds lvds_inst1(
		.rx_inclock(rx_inclk),  //  rx_inclock.rx_inclock
		.rx_in(rx_in[1]),       //       rx_in.rx_in
		.rx_out(data1),      //      rx_out.rx_out
		.rx_outclock(data_clk1), // rx_outclock.rx_outclock
		.rx_locked()    //   rx_locked.rx_locked
	);
	
lvds lvds_inst2(
		.rx_inclock(rx_inclk),  //  rx_inclock.rx_inclock
		.rx_in(rx_in[2]),       //       rx_in.rx_in
		.rx_out(data2),      //      rx_out.rx_out
		.rx_outclock(data_clk2), // rx_outclock.rx_outclock
		.rx_locked()    //   rx_locked.rx_locked
	);

lvds lvds_inst3(
		.rx_inclock(rx_inclk),  //  rx_inclock.rx_inclock
		.rx_in(rx_in[3]),       //       rx_in.rx_in
		.rx_out(data3),      //      rx_out.rx_out
		.rx_outclock(data_clk3), // rx_outclock.rx_outclock
		.rx_locked()    //   rx_locked.rx_locked
	);
*/	
	
endmodule 