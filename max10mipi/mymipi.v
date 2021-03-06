
//=======================================================
//  This code is generated by Terasic System Builder
//=======================================================

module mymipi(

	//////////// CLOCK //////////
	input 		          		ADC_CLK_10,
	input 		          		MAX10_CLK1_50,
	input 		          		MAX10_CLK2_50,

	//////////// LED //////////
	output		     [7:0]		LED,

	//////////// MIPI //////////
	output		          		MIPI_CORE_EN,
	output		          		MIPI_I2C_SCL,
	inout 		          		MIPI_I2C_SDA,
	
	input 		          		MIPI_LP_MC_n,
	input 		          		MIPI_LP_MC_p,
	input 		     [3:0]		MIPI_LP_MD_n,
	input 		     [3:0]		MIPI_LP_MD_p,
	input 		          		MIPI_MC_p,
	
	output		          		MIPI_MCLK,

	input 		     [3:0]		MIPI_MD_p,
	output		          		MIPI_RESET_n,
	output		          		MIPI_WP,

	//////////// SW //////////
	input 		     [1:0]		SW
);
assign MIPI_RESET_n = 1'b1;
assign MIPI_WP = 1'b0;
assign MIPI_CORE_EN = 1'b1;



wire clk100m;
wire rstn;
wire clk10m;
wire clk50m;
pll pll_inst(
	.inclk0(MAX10_CLK1_50),
	.c0(clk50m),
	.c1(clk100m),
	.c2(MIPI_MCLK),
	.c3(clk10m),
	.locked(rstn));

config_camera(
					.clk(clk10m),
					.rstn(rstn),
					.scl(MIPI_I2C_SCL),
					.sda(MIPI_I2C_SDA),
					.config_done(LED[0]),
					.chip_version_h(),
					.chip_version_l(),
					.revision_number(),
					.manufacturer_id(),
					.smia_version());

mipi_decode mipi_decode_inst(
						.rx_inclk(MIPI_MC_p),
						.rx_in(MIPI_MD_p),
						.rstn(1'b1),
						.lp_mc_p(MIPI_LP_MC_p),
						.lp_mc_n(MIPI_LP_MC_n),
						.lp_md_p(MIPI_LP_MD_p),
						.lp_md_n(MIPI_LP_MD_n),
						//test
						.lane0(),
						.lane1(),
						.lane2(),
						.lane3(),
						.data_clk(),
						);

//=======================================================
//  REG/WIRE declarations
//=======================================================




//=======================================================
//  Structural coding
//=======================================================



endmodule
