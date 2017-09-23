module config_camera(
							input clk,
							input rstn,
							output scl,
							inout  sda,
							
							output config_done,
							output reg [7:0] chip_version_h,
							output reg [7:0] chip_version_l,
							output reg [7:0] revision_number,
							output reg [7:0] manufacturer_id,
							output reg [7:0] smia_version,
							output reg [7:0] frame_count,
							output reg [7:0] pixel_order,
							output reg [7:0] data_pedestal_h,
							output reg [7:0] data_pedestal_l,
							output reg [7:0] pixel_order_h,
							output reg [7:0] pixel_order_l,
							output reg [7:0] ccp_data_format_h,
							output reg [7:0] ccp_data_format_l);

wire [9:0] lut_index;
wire [9:0] lut_size;
wire [41:0] lut_data;	
Mipi_Config1 Mipi_Config_inst
(
	.LUT_INDEX(lut_index),
	.LUT_DATA(lut_data),
	.LUT_SIZE(lut_size)
);
wire i2c_rdata_en;
wire [7:0] i2c_rdata;
i2c_timing_ctrl i2c_timing_ctrl_inst
(
	//global clock
	.clk(clk),		//100MHz
	.rst_n(rstn),		//system reset
	
	//i2c interface
	.i2c_sclk(scl),	//i2c clock
	.i2c_sdat(sda),	//i2c data for bidirection

	//user interface
	.i2c_config_size(lut_size),	//i2c config data counte
	.i2c_config_index(lut_index),	//i2c config reg index, read 2 reg and write xx reg
	.i2c_config_data(lut_data),	//i2c config data = {device_addr[7:0],addr_type,data_type,addr[15:0],data[15:0]}
	.i2c_config_done(config_done),	//i2c config timing complete
	.i2c_rdata(i2c_rdata),			//i2c register data while read i2c slave
	.i2c_rdata_en(i2c_rdata_en)
);
always @(posedge clk or negedge rstn)
	if(!rstn)
		begin
		chip_version_h <= 0;
		chip_version_l <= 0;
		revision_number <= 0;
		manufacturer_id <= 0;
		smia_version <= 0;
		frame_count <= 0;
		pixel_order <= 0;
		data_pedestal_h <= 0;
		data_pedestal_l <= 0;
		pixel_order_h <= 0;
		pixel_order_l <= 0;
		ccp_data_format_h <= 0;
		ccp_data_format_l <= 0;		
		end
	else if(i2c_rdata_en)
			case(lut_index)
				10'd570: chip_version_h <= i2c_rdata;
				10'd571: chip_version_l <= i2c_rdata;
				10'd572: revision_number <= i2c_rdata;
				10'd573: manufacturer_id <= i2c_rdata;
				10'd574: smia_version <= i2c_rdata;
				
				10'd575:		frame_count <= i2c_rdata;
				10'd576:		pixel_order <= i2c_rdata;
				10'd577:		data_pedestal_h <= i2c_rdata;
				10'd578:		data_pedestal_l <= i2c_rdata;
				10'd579:		pixel_order_h <= i2c_rdata;
				10'd580:		pixel_order_l <= i2c_rdata;
				10'd581:		ccp_data_format_h <= i2c_rdata;
				10'd582:		ccp_data_format_l <= i2c_rdata;	
				default:;
				endcase
	else begin
		chip_version_h <= chip_version_h;
		chip_version_l <= chip_version_l;
		revision_number <= revision_number;
		manufacturer_id <= manufacturer_id;
		smia_version <= smia_version;	

		frame_count <= frame_count;
		pixel_order <= pixel_order;
		data_pedestal_h <= data_pedestal_h;
		data_pedestal_l <= data_pedestal_l;
		pixel_order_h <= pixel_order_h;
		pixel_order_l <= pixel_order_l;
		ccp_data_format_h <= ccp_data_format_h;
		ccp_data_format_l <= ccp_data_format_l;
		  end

endmodule