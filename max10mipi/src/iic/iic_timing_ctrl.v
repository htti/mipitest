
//	CrazyBingo	1.1				add i2c_wdata for avoid bit width warming


`timescale 1ns/1ns
module	i2c_timing_ctrl
#(
	parameter	CLK_FREQ	=	10_000_000,	//10 MHz
	parameter	I2C_FREQ	=	200_000,		//100 KHz(< 400KHz)
	parameter   DEVICE_ADDR = 8'h6C
)
(
	//global clock
	input				clk,		//100MHz
	input				rst_n,		//system reset
	
	//i2c interface
	output				i2c_sclk,	//i2c clock
	inout				i2c_sdat,	//i2c data for bidirection

	//user interface
	input		[9:0]	i2c_config_size,	//i2c config data counte
	output	reg	[9:0]	i2c_config_index,	//i2c config reg index, read 2 reg and write xx reg
	input		[41:0]	i2c_config_data,	//i2c config data = {device_addr[7:0],addr_type,data_type,addr[15:0],data[15:0]}
	output				i2c_config_done,	//i2c config timing complete
	output	reg	[7:0]	i2c_rdata,			//i2c register data while read i2c slave
	output  reg         i2c_rdata_en
);

wire [7:0] delay_ms;
wire addr_type,data_type;
wire [15:0] addr;
wire [15:0] data;
assign delay_ms  = i2c_config_data[41:34];
assign addr_type = i2c_config_data[33];
assign data_type = i2c_config_data[32];
assign addr = i2c_config_data[31:16];
assign data = i2c_config_data[15:0];
//----------------------------------------
//Delay xxus until i2c slave is steady
reg	[16:0]	delay_cnt;
localparam	DELAY_TOP = CLK_FREQ/1000;	//1ms Setting time after software/hardware reset
//localparam	DELAY_TOP = 17'hff;			//Just for test
always@(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		delay_cnt <= 0;
	else if(delay_cnt < DELAY_TOP - 1'b1)
		delay_cnt <= delay_cnt + 1'b1;
	else
		delay_cnt <= delay_cnt;
end
wire	delay_done = (delay_cnt == DELAY_TOP - 1'b1) ? 1'b1 : 1'b0;	//81us delay


//----------------------------------------
//I2C Control Clock generate
reg	[15:0]	clk_cnt;	//divide for i2c clock
/******************************************
			 _______		  _______
SCLK	____|		|________|		 |
		 ________________ ______________
SDAT	|________________|______________
		 _	              _
CLK_EN	| |______________| |____________
			    _			  	 _
CAP_EN	_______| |______________| |_____
*******************************************/
reg	i2c_ctrl_clk;		//i2c control clock, H: valid; L: valid
reg	i2c_transfer_en;	//send i2c data	before, make sure that sdat is steady when i2c_sclk is valid
reg	i2c_capture_en;		//capture i2c data	while sdat is steady from cmos 				
always@(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		begin
		clk_cnt <= 0;
		i2c_ctrl_clk <= 0;
		i2c_transfer_en <= 0;
		i2c_capture_en <= 0;
		end
	else if(delay_done)
		begin
		if(clk_cnt < (CLK_FREQ/I2C_FREQ) - 1'b1)
			clk_cnt <= clk_cnt + 1'd1;
		else
			clk_cnt <= 0;
		//i2c control clock, H: valid; L: valid
		i2c_ctrl_clk <= ((clk_cnt >= (CLK_FREQ/I2C_FREQ)/4 + 1'b1) &&
						(clk_cnt < (3*CLK_FREQ/I2C_FREQ)/4 + 1'b1)) ? 1'b1 : 1'b0;
		//send i2c data	before, make sure that sdat is steady when i2c_sclk is valid
		i2c_transfer_en <= (clk_cnt == 16'd0) ? 1'b1 : 1'b0;
		//capture i2c data	while sdat is steady from cmos 					
		i2c_capture_en <= (clk_cnt == (2*CLK_FREQ/I2C_FREQ)/4 - 1'b1) ? 1'b1 : 1'b0;
		end
	else
		begin
		clk_cnt <= 0;
		i2c_ctrl_clk <= 0;
		i2c_transfer_en <= 0;
		i2c_capture_en <= 0;
		end
end

//-----------------------------------------
//I2C Timing state Parameter
localparam	I2C_IDLE			=	5'd0;
//Write I2C: {ID_Address, REG_Address, W_REG_Data}
localparam	I2C_WR_START		=	5'd1;
localparam	I2C_WR_IDADDR		=	5'd2;
localparam	I2C_WR_ACK1			=	5'd3;
localparam	I2C_WR_REGADDR_H	=	5'd4;
localparam	I2C_WR_ACK2	   	    =	5'd5;
localparam	I2C_WR_REGADDR_L	=	5'd6;
localparam	I2C_WR_ACK3	    	=	5'd7;

localparam	I2C_WR_REGDATA_H	=	5'd8;
localparam	I2C_WR_ACK4			=	5'd9;

localparam	I2C_WR_REGDATA_L	=	5'd10;
localparam	I2C_WR_ACK5			=	5'd11;

localparam	I2C_WR_STOP			=	5'd12;
//I2C Read: {ID_Address + REG_Address} + {ID_Address + R_REG_Data}
localparam	I2C_RD_START1		=	5'd13;		
localparam	I2C_RD_IDADDR1		=	5'd14;
localparam	I2C_RD_ACK1			=	5'd15;
localparam	I2C_RD_REGADDR_H	=	5'd16;
localparam	I2C_RD_ACK2			=	5'd17;

localparam	I2C_RD_REGADDR_L	=	5'd18;
localparam	I2C_RD_ACK3			=	5'd19;

localparam	I2C_RD_STOP1		=	5'd20;
localparam	I2C_RD_IDLE			=	5'd21;
localparam	I2C_RD_START2		=	5'd22;
localparam	I2C_RD_IDADDR2		=	5'd23;
localparam	I2C_RD_ACK4			=	5'd24;
localparam	I2C_RD_REGDATA		=	5'd25;
localparam	I2C_RD_NACK			=	5'd26;
localparam	I2C_RD_STOP2		=	5'd27;
localparam  I2C_WAIT			=   5'd28;


//-----------------------------------------
// FSM: always1
(*keep*)reg	[4:0]	current_state, next_state; //i2c write and read state  
always@(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		current_state <= I2C_IDLE;
	else if(i2c_transfer_en)
		current_state <= next_state;
end

//-----------------------------------------
always@(posedge clk or negedge rst_n)
	if(!rst_n)
		begin
		i2c_rdata_en <= 0;
		end
	else if(current_state == I2C_RD_STOP2)
		i2c_rdata_en <= 1'b1;
	else i2c_rdata_en <= 0;
(*keep*)wire	i2c_transfer_end = (current_state == I2C_WR_STOP || current_state == I2C_RD_STOP2) ? 1'b1 : 1'b0;
reg		i2c_ack;	//i2c slave renpose successed
always@(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		i2c_config_index <= 0;
	else if(i2c_transfer_en)
		begin
		if(i2c_transfer_end & ~i2c_ack)
//		if(i2c_transfer_end /*& ~i2c_ack*/)											//Just for test
			begin
			if(i2c_config_index < i2c_config_size)	
				i2c_config_index <= i2c_config_index + 1'b1;
//				i2c_config_index <= {i2c_config_index[7:1], ~i2c_config_index[0]};	//Just for test
			else
				i2c_config_index <= i2c_config_size;
			end
		else
			i2c_config_index <= i2c_config_index;
		end
	else
		i2c_config_index <= i2c_config_index;
end
assign	i2c_config_done = (i2c_config_index == i2c_config_size) ? 1'b1 : 1'b0;


//-----------------------------------------
// FSM: always2
reg	[3:0]	i2c_stream_cnt;	//i2c data bit stream count
always@(*)
begin
	next_state = I2C_IDLE; 	//state initialization
	case(current_state)
	I2C_IDLE:		//5'd0
		begin
		if(delay_done)	//1ms Setting time after software/hardware reset	
			begin
			if(i2c_transfer_en)
				begin
				/*if(i2c_config_index <= 10'd4)
					next_state = I2C_RD_START1;	
				else */if(i2c_config_index <= 10'd569)
					next_state = I2C_WR_START;
				else if(i2c_config_index < i2c_config_size)
					next_state = I2C_RD_START1;	

				else
					next_state = I2C_IDLE;		//Config I2C Complete
				end
			else
				next_state = next_state;
			end
		else
				next_state = I2C_IDLE;		//Wait I2C Bus is steady
		end
	//Write I2C: {ID_Address, REG_Address, W_REG_Data}
	I2C_WR_START:	//5'd1
		begin
		if(i2c_transfer_en)	next_state = I2C_WR_IDADDR;
		else				next_state = I2C_WR_START;
		end
	I2C_WR_IDADDR:	//5'd2
		if(i2c_transfer_en == 1'b1 && i2c_stream_cnt == 4'd8)	
							next_state = I2C_WR_ACK1;
		else				next_state = I2C_WR_IDADDR;
	I2C_WR_ACK1:	//5'd3
		if(i2c_transfer_en)	next_state = I2C_WR_REGADDR_H;
		else				next_state = I2C_WR_ACK1;
	I2C_WR_REGADDR_H:	//5'd4
		if(i2c_transfer_en == 1'b1 && i2c_stream_cnt == 4'd8)	
							next_state = I2C_WR_ACK2;
		else				next_state = I2C_WR_REGADDR_H;
	I2C_WR_ACK2:	//5'd5
		if(i2c_transfer_en)	//1 means 16bit
			begin
			if(addr_type)
							next_state = I2C_WR_REGADDR_L;
			else 			next_state = I2C_WR_REGDATA_H;
			end
		else				next_state = I2C_WR_ACK2;
		
	I2C_WR_REGADDR_L: //5'd6
		if(i2c_transfer_en == 1'b1 && i2c_stream_cnt == 4'd8)
							next_state = I2C_WR_ACK3;
		else 				next_state = I2C_WR_REGADDR_L;
	I2C_WR_ACK3:      //5'd7
		if(i2c_transfer_en)
							next_state = I2C_WR_REGDATA_H;
		else 				next_state = I2C_WR_ACK3;
//write data		
	I2C_WR_REGDATA_H:	//5'd8
		if(i2c_transfer_en == 1'b1 && i2c_stream_cnt == 4'd8)	
							next_state = I2C_WR_ACK4;
		else				next_state = I2C_WR_REGDATA_H;
	I2C_WR_ACK4:	//5'd9
		if(i2c_transfer_en)	
			begin
			if(data_type)               //1 means  16bits
				next_state = I2C_WR_REGDATA_L;
			else 
				next_state = I2C_WR_STOP;
			end
		else				next_state = I2C_WR_ACK4;
	I2C_WR_REGDATA_L: //5'd10
		if(i2c_transfer_en == 1'b1 && i2c_stream_cnt == 4'd8)
							next_state = I2C_WR_ACK5;
		else 				next_state = I2C_WR_REGDATA_L;
	I2C_WR_ACK5:      ////5'd11
		if(i2c_transfer_en)
							next_state = I2C_WR_STOP;
		else 				next_state = I2C_WR_ACK5;
	I2C_WR_STOP:	//5'd12
		if(i2c_transfer_en)	next_state = I2C_WAIT;
		else				next_state = I2C_WR_STOP;
	//I2C Read: {ID_Address + REG_Address} + {ID_Address + R_REG_Data}
	I2C_RD_START1:	//5'd13
		if(i2c_transfer_en)	next_state = I2C_RD_IDADDR1;
		else				next_state = I2C_RD_START1;
	I2C_RD_IDADDR1:	//5'd14
		if(i2c_transfer_en == 1'b1 && i2c_stream_cnt == 4'd8)	
							next_state = I2C_RD_ACK1;
		else				next_state = I2C_RD_IDADDR1;
	I2C_RD_ACK1:	//5'd15
		if(i2c_transfer_en)	
			next_state = I2C_RD_REGADDR_H;
		else				next_state = I2C_RD_ACK1;
	I2C_RD_REGADDR_H:	//5'd16
		if(i2c_transfer_en == 1'b1 && i2c_stream_cnt == 4'd8)	
							next_state = I2C_RD_ACK2;
		else				next_state = I2C_RD_REGADDR_H;
	I2C_RD_ACK2:	//5'd17
		if(i2c_transfer_en)	
			begin
			if(addr_type)
							next_state = I2C_RD_REGADDR_L; 
			else 			next_state = I2C_RD_STOP1;
			end
		else				next_state = I2C_RD_ACK2;
	I2C_RD_REGADDR_L: //5'd18
		if(i2c_transfer_en == 1'b1 && i2c_stream_cnt == 4'd8)
							next_state = I2C_RD_ACK3;
		else 				next_state = I2C_RD_REGADDR_L;
	I2C_RD_ACK3:      //5'd19
		if(i2c_transfer_en)
							next_state = I2C_RD_STOP1;
		else 				next_state = I2C_RD_ACK3;
	//////////////////////////////////////////////////////
	I2C_RD_STOP1:	//5'd20
		if(i2c_transfer_en)	next_state = I2C_RD_IDLE;
		else				next_state = I2C_RD_STOP1;
	I2C_RD_IDLE:	//5'd21
		if(i2c_transfer_en)	next_state = I2C_RD_START2;
		else				next_state = I2C_RD_IDLE;
	I2C_RD_START2:	//5'd22
		if(i2c_transfer_en)	next_state = I2C_RD_IDADDR2;
		else				next_state = I2C_RD_START2;
	I2C_RD_IDADDR2:	//5'd23
		if(i2c_transfer_en == 1'b1 && i2c_stream_cnt == 4'd8)	
							next_state = I2C_RD_ACK4;
		else				next_state = I2C_RD_IDADDR2;
	I2C_RD_ACK4:	//5'd24
		if(i2c_transfer_en)	next_state = I2C_RD_REGDATA;
		else				next_state = I2C_RD_ACK4;
	I2C_RD_REGDATA:	//5'd25
		if(i2c_transfer_en == 1'b1 && i2c_stream_cnt == 4'd8)	
							next_state = I2C_RD_NACK;
		else				next_state = I2C_RD_REGDATA;
	I2C_RD_NACK:	//5'd26
		if(i2c_transfer_en)	next_state = I2C_RD_STOP2;
		else				next_state = I2C_RD_NACK;
	I2C_RD_STOP2:	//5'd27
		if(i2c_transfer_en)	next_state = I2C_WAIT;
		else				next_state = I2C_RD_STOP2;
	I2C_WAIT:       //5'd28
		begin
		if(i2c_transfer_en & frame_delay)
			 next_state = I2C_IDLE;
		else next_state = I2C_WAIT;
		end
	default:;	//default vaule		
	endcase
end

//-----------------------------------------
// FSM: always3
//reg	i2c_write_flag, i2c_read_flag;
reg	i2c_sdat_out;		//i2c data output
//reg	[3:0]	i2c_stream_cnt;	//i2c data bit stream count
reg	[7:0]	i2c_wdata;	//i2c data prepared to transfer
always@(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		begin
		i2c_sdat_out <= 1'b1;
		i2c_stream_cnt <= 0;
		i2c_wdata <= 0;
		end
	else if(i2c_transfer_en)
		begin
		case(next_state)
		I2C_IDLE:	//5'd0
			begin
			i2c_sdat_out <= 1'b1;		//idle state
			i2c_stream_cnt <= 0;
			i2c_wdata <= 0;
			end
		//Write I2C: {ID_Address, REG_Address, W_REG_Data}
		I2C_WR_START:	//5'd1
			begin
			i2c_sdat_out <= 1'b0;
			i2c_stream_cnt <= 0;
			i2c_wdata <= DEVICE_ADDR;//i2c_config_data[23:16];	//ID_Address
			end
		I2C_WR_IDADDR:	//5'd2
			begin
			i2c_stream_cnt <= i2c_stream_cnt + 1'b1;
			i2c_sdat_out <= i2c_wdata[3'd7 - i2c_stream_cnt];
			end
		I2C_WR_ACK1:	//5'd3
			begin
			i2c_stream_cnt <= 0;
			i2c_wdata <= addr[15:8];//i2c_config_data[15:8];		//REG_Address
			end
		I2C_WR_REGADDR_H:	//5'd4
			begin
			i2c_stream_cnt <= i2c_stream_cnt + 1'b1;
			i2c_sdat_out <= i2c_wdata[3'd7 - i2c_stream_cnt];
			end
		I2C_WR_ACK2:	//5'd5
			begin
			i2c_stream_cnt <= 0;
			if(addr_type)
				i2c_wdata <= addr[7:0];
			else i2c_wdata <= data[15:8];//i2c_config_data[7:0];		//W_REG_Data
			end
		I2C_WR_REGADDR_L:
			begin
			i2c_stream_cnt <= i2c_stream_cnt + 1'b1;
			i2c_sdat_out <= i2c_wdata[3'd7 - i2c_stream_cnt];
			end
		I2C_WR_ACK3:
			begin
			i2c_stream_cnt <= 0;
			i2c_wdata    <= data[15:8];
			end
		
		I2C_WR_REGDATA_H:	//5'd6
			begin
			i2c_stream_cnt <= i2c_stream_cnt + 1'b1;
			i2c_sdat_out <= i2c_wdata[3'd7 - i2c_stream_cnt];
			end
		I2C_WR_ACK4:	//5'd7
			begin
			i2c_stream_cnt <= 0;
			if(data_type)
				i2c_wdata <= data[7:0];
			else i2c_wdata <= 0;
			end
		I2C_WR_REGDATA_L:
			begin
			i2c_stream_cnt <= i2c_stream_cnt + 1'b1;
			i2c_sdat_out <= i2c_wdata[3'd7 - i2c_stream_cnt];
			end
		I2C_WR_ACK5:
			begin
			i2c_stream_cnt <= 0;			
			end
		
		I2C_WR_STOP:	//5'd8
			i2c_sdat_out <= 1'b0;
		//I2C Read: {ID_Address + REG_Address} + {ID_Address + R_REG_Data}
		I2C_RD_START1:	//5'd10
			begin
			i2c_sdat_out <= 1'b0;
			i2c_stream_cnt <= 0;
			i2c_wdata <= DEVICE_ADDR;//i2c_config_data[23:16];
			end
		I2C_RD_IDADDR1:	//5'd11
			begin
			i2c_stream_cnt <= i2c_stream_cnt + 1'b1;
			i2c_sdat_out <= i2c_wdata[3'd7 - i2c_stream_cnt];
			end
		I2C_RD_ACK1:	//5'd11
			begin
			i2c_stream_cnt <= 0;
			i2c_wdata <= addr[15:8];//i2c_config_data[15:8];
			end
		I2C_RD_REGADDR_H:	//5'd12
			begin
			i2c_stream_cnt <= i2c_stream_cnt + 1'b1;
			i2c_sdat_out <= i2c_wdata[3'd7 - i2c_stream_cnt];	
			end
		I2C_RD_ACK2:	//5'd13
			begin
			i2c_stream_cnt <= 0;
			if(addr_type)
				i2c_wdata <= addr[7:0];
			else i2c_wdata <= 0;
			end
		I2C_RD_REGADDR_L:
			begin
			i2c_stream_cnt <= i2c_stream_cnt + 1'b1;
			i2c_sdat_out <= i2c_wdata[3'd7 - i2c_stream_cnt];			
			end
		I2C_RD_ACK3:
			begin
			i2c_stream_cnt <= 0;			
			end
			
		
		I2C_RD_STOP1:	//5'd14
			i2c_sdat_out <= 1'b0;
		I2C_RD_IDLE:	//5'd15
			i2c_sdat_out <= 1'b1;		//idle state
		//-------------------------
		I2C_RD_START2:	//5'd16
			begin
			i2c_sdat_out <= 1'b0;
			i2c_stream_cnt <= 0;
			i2c_wdata <= DEVICE_ADDR;//i2c_config_data[23:16];	
			end
		I2C_RD_IDADDR2:	//5'd17
			begin
			i2c_stream_cnt <= i2c_stream_cnt + 1'b1;
			if(i2c_stream_cnt < 5'd7)
				i2c_sdat_out <= i2c_wdata[3'd7 - i2c_stream_cnt];
			else
				i2c_sdat_out <= 1'b1;	//Read flag for I2C Timing
			end
		I2C_RD_ACK4:	//5'd18
			i2c_stream_cnt <= 0;
		I2C_RD_REGDATA:	//5'd19
			i2c_stream_cnt <= i2c_stream_cnt + 1'b1;
		I2C_RD_NACK:	//5'd20
			i2c_sdat_out <= 1'b1;	//NACK
		I2C_RD_STOP2:	//5'd21
			i2c_sdat_out <= 1'b0;
		I2C_WAIT: i2c_sdat_out <= 1'b1;
		endcase
		end
	else
		begin
		i2c_stream_cnt <= i2c_stream_cnt;
		i2c_sdat_out <= i2c_sdat_out;
		end
end

//---------------------------------------------
//respone from slave for i2c data transfer
reg	i2c_ack1, i2c_ack2, i2c_ack3,i2c_ack4,i2c_ack5;
//reg	i2c_ack;
//reg	[7:0]	i2c_rdata;
always@(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		begin
		{i2c_ack1, i2c_ack2, i2c_ack3,i2c_ack4,i2c_ack5} <= 5'b11111;
		i2c_ack <= 1'b1;
		i2c_rdata <= 0;
		end
	else if(i2c_capture_en)
		begin
		case(next_state)
		I2C_IDLE:
			begin
		{i2c_ack1, i2c_ack2, i2c_ack3,i2c_ack4,i2c_ack5} <= 5'b11111;
		i2c_ack <= 1'b1;
			end
		//Write I2C: {ID_Address, REG_Address, W_REG_Data}
		I2C_WR_ACK1:	i2c_ack1 <= i2c_sdat;
		I2C_WR_ACK2:	i2c_ack2 <= i2c_sdat;
		I2C_WR_ACK3:	i2c_ack3 <= i2c_sdat;
		I2C_WR_ACK4:	i2c_ack4 <= i2c_sdat;
		I2C_WR_ACK5:	i2c_ack5 <= i2c_sdat;
		
		I2C_WR_STOP:	i2c_ack <= data_type? (i2c_ack1 | i2c_ack2 | i2c_ack3|i2c_ack4|i2c_ack5): (i2c_ack1 | i2c_ack2 | i2c_ack3|i2c_ack4);
		//I2C Read: {ID_Address + REG_Address} + {ID_Address + R_REG_Data}
		I2C_RD_ACK1:	i2c_ack1 <= i2c_sdat;
		I2C_RD_ACK2:    i2c_ack2 <= i2c_sdat;
		I2C_RD_ACK3:    i2c_ack3 <= i2c_sdat;
		I2C_RD_ACK4:    i2c_ack4 <= i2c_sdat;
		I2C_RD_STOP2:	i2c_ack <= (i2c_ack1 | i2c_ack2 | i2c_ack3|i2c_ack4);
		I2C_RD_REGDATA:	i2c_rdata <= {i2c_rdata[6:0], i2c_sdat};
		endcase
		end
	else
		begin
		{i2c_ack1, i2c_ack2, i2c_ack3,i2c_ack4,i2c_ack5} <= {i2c_ack1, i2c_ack2, i2c_ack3,i2c_ack4,i2c_ack5};
		i2c_ack <= i2c_ack;
		end
end

//delay us
reg [16:0] cnt1ms;
always @(posedge clk or negedge rst_n)
	if(!rst_n)
		begin
		cnt1ms <= 0;
		end
	else if(current_state == I2C_WAIT)
			begin
			if(cnt1ms == 17'h186A0)
				begin
				cnt1ms <= 0;
				end
			else cnt1ms <= cnt1ms + 1'b1;
			end
	else begin
		 cnt1ms <= 0;
		 end
	
reg [7:0] cnttime;
(*keep*)wire       frame_delay;
assign frame_delay = (cnttime == delay_ms);

always @(posedge clk or negedge rst_n)
	if(!rst_n)
		begin
		cnttime <= 0;
		end
//	else if(frame_delay)
//			cnttime <= 0;
	else if(current_state != I2C_WAIT)
			cnttime <= 0;
	else if(cnt1ms == 17'h186A0)
			begin
			if(frame_delay)
				cnttime <= 0;
			else cnttime <= cnttime + 1'b1;
			end
	else begin
		  cnttime <= cnttime;
		  end

/*
wire frame_delay_pos;
reg frame_delay_r;
always @(posedge clk or negedge rst_n)
	if(!rst_n)
		begin
		frame_delay_r <= 0;
		end
	else frame_delay_r <= frame_delay;
assign frame_delay_pos = frame_delay & ~frame_delay_r;
*/
//---------------------------------------------------
wire	bir_en =   (current_state == I2C_WR_ACK1 || current_state == I2C_WR_ACK2 || current_state == I2C_WR_ACK3 ||
					current_state == I2C_WR_ACK4 || current_state == I2C_WR_ACK5 ||
					current_state == I2C_RD_ACK1 || current_state == I2C_RD_ACK2 || current_state == I2C_RD_ACK3 ||
					current_state == I2C_RD_ACK4 ||
					current_state == I2C_RD_REGDATA || current_state == I2C_WAIT) ? 1'b1 : 1'b0;
					
assign	i2c_sclk = (current_state >= I2C_WR_IDADDR  && current_state <= I2C_WR_ACK5 ||
					current_state >= I2C_RD_IDADDR1 && current_state <= I2C_RD_ACK3 ||
					current_state >= I2C_RD_IDADDR2 && current_state <= I2C_RD_NACK) ? 
					i2c_ctrl_clk : 1'b1;
assign	i2c_sdat = (~bir_en) ? i2c_sdat_out : 1'bz; //bir_en 1 means input ,0 means output 


endmodule
