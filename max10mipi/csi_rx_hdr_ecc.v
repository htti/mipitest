module csi_rx_hdr_ecc(data,
							 ecc);
   input [23:0] data;
   output [7:0] ecc;
   
   
   assign ecc[7] = 1'b0;
   assign ecc[6] = 1'b0;
   assign ecc[5] = data[10] ^ data[11] ^ data[12] ^ data[13] ^ data[14] ^ data[15] ^ data[16] ^ data[17] ^ data[18] ^ data[19] ^ data[21] ^ data[22] ^ data[23];
   assign ecc[4] = data[4] ^ data[5] ^ data[6] ^ data[7] ^ data[8] ^ data[9] ^ data[16] ^ data[17] ^ data[18] ^ data[19] ^ data[20] ^ data[22] ^ data[23];
   assign ecc[3] = data[1] ^ data[2] ^ data[3] ^ data[7] ^ data[8] ^ data[9] ^ data[13] ^ data[14] ^ data[15] ^ data[19] ^ data[20] ^ data[21] ^ data[23];
   assign ecc[2] = data[0] ^ data[2] ^ data[3] ^ data[5] ^ data[6] ^ data[9] ^ data[11] ^ data[12] ^ data[15] ^ data[18] ^ data[20] ^ data[21] ^ data[22];
   assign ecc[1] = data[0] ^ data[1] ^ data[3] ^ data[4] ^ data[6] ^ data[8] ^ data[10] ^ data[12] ^ data[14] ^ data[17] ^ data[20] ^ data[21] ^ data[22] ^ data[23];
   assign ecc[0] = data[0] ^ data[1] ^ data[2] ^ data[4] ^ data[5] ^ data[7] ^ data[10] ^ data[11] ^ data[13] ^ data[16] ^ data[20] ^ data[21] ^ data[22] ^ data[23];
   
endmodule