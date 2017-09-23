`timescale 1ns/100ps
module lvds_top();
reg clk;
reg rstn;
reg [3:0] data;
wire [7:0] data_w;
assign data_w = 8'b1011_1000;
wire [7:0] data_d;
initial
begin
clk = 0;
//rstn = 1'b0;
forever #5 clk = ~clk;
//rstn = 1'b0;
//#27 rstn = 1'b1;
end

initial
begin
rstn = 0;
#23 rstn = 1'b1;
end
reg [3:0] i;
/*
always @(clk or rstn)
	if(!rstn)
		data <= 0;
	else begin
 	for(i = 0; i < 4'd8; i = i + 1'b1)
		begin
		data <= {4{data_w[i]}};
		end
		end
*/
always @(clk or rstn)
	if(!rstn)
		i <= 0;
	else i <= i + 1;
always @(clk or rstn)
	if(!rstn)
		data <= 0;
	else case(i)
		0: data <= 4'b1111;
		1: data <= 4'b0000;
		2: data <= 4'b1111;
		3: data <= 4'b1111;
		4: data <= 4'b1111;
		5: data <= 4'b0000;

		6: data <= 4'b0000;
		7: data <= 4'b0000;	
		default:;
		endcase


lvds lvds_inst(
		.rx_inclock(clk),  //  rx_inclock.rx_inclock
		.rx_in(data),       //       rx_in.rx_in
		.rx_out(data_d),      //      rx_out.rx_out
		.rx_outclock(), // rx_outclock.rx_outclock
		.rx_locked()    //   rx_locked.rx_locked
	);	
reg [7:0] lane0,lane1,lane2,lane3;
always @(posedge clk or negedge rstn)
	if(!rstn)
		begin
		lane0 <= 0;
		lane1 <= 0;
		lane2 <= 0;
		lane3 <= 0;
		end
	else  begin
			lane0[7:6] <= {data_d[0],data_d[4]};
			lane0[5:4] <= lane0[7:6];
			lane0[3:2] <= lane0[5:4];
			lane0[1:0] <= lane0[3:2];
	
			lane1[7:6] <= {data_d[1],data_d[5]};
			lane1[5:4] <= lane1[7:6];
			lane1[3:2] <= lane1[5:4];
			lane1[1:0] <= lane1[3:2];

			lane2[7:6] <= {data_d[2],data_d[6]};
			lane2[5:4] <= lane2[7:6];
			lane2[3:2] <= lane2[5:4];
			lane2[1:0] <= lane2[3:2];

			lane3[7:6] <= {data_d[3],data_d[7]};
			lane3[5:4] <= lane3[7:6];
			lane3[3:2] <= lane3[5:4];
			lane3[1:0] <= lane3[3:2];
			end	
endmodule

