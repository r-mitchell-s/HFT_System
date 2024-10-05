`timescale 1ps / 1ps

/*

- This module imlements a cyclic redundacy check generator for use in the ethernet MAC Tx
- Ethernet frames include PREABMLE-SFD-HEADER-PAYLOAD-CRC. This module generates the last 
  section of the ethernet frame. 

*/

module crc(
    input           i_clk, i_rst, i_crc_en,     // clock, reset, and enable signals
    input [1:0]     i_data,                     // data bits used for crc calculation (come from payload)
    output [31:0]   o_crc                       // 32-bit frame check sequence
    );
    
    // linear feedback shift registers for crc computation
    logic [31:0] lfsr_next, lfsr_curr;
    
    // sequential logic for reset and output update
    always @(posedge i_clk, posedge i_rst) begin
        if (i_rst) begin
            lfsr_next <= {32{1'b1}};
        end else if (i_crc_en) begin
            lfsr_next <= lfsr_curr;
        end
    end
    
    // bit assignment logic according to CRC32 polynomial 0xEDB88320
    assign lfsr_curr[0]  = lfsr_next[2];
    assign lfsr_curr[1]  = lfsr_next[3];
    assign lfsr_curr[2]  = lfsr_next[4];
    assign lfsr_curr[3]  = lfsr_next[5];
    assign lfsr_curr[4]  = (i_data[0] ^ lfsr_next[0] ^ lfsr_next[6]);
    assign lfsr_curr[5]  = (i_data[1] ^ lfsr_next[1] ^ lfsr_next[7]);
    assign lfsr_curr[6]  = lfsr_next[8];
    assign lfsr_curr[7]  = (i_data[0] ^ lfsr_next[0] ^ lfsr_next[9]);
    assign lfsr_curr[8]  = (i_data[0] ^ i_data[1] ^ lfsr_next[0] ^ lfsr_next[1] ^ lfsr_next[10]);
    assign lfsr_curr[9]  = (i_data[1] ^ lfsr_next[1] ^ lfsr_next[11]);
    assign lfsr_curr[10] = lfsr_next[12];
    assign lfsr_curr[11] = lfsr_next[13];
    assign lfsr_curr[12] = lfsr_next[14];
    assign lfsr_curr[13] = lfsr_next[15];
    assign lfsr_curr[14] = (i_data[0] ^ lfsr_next[0] ^ lfsr_next[16]);
    assign lfsr_curr[15] = (i_data[1] ^ lfsr_next[1] ^ lfsr_next[17]);
    assign lfsr_curr[16] = lfsr_next[18];
    assign lfsr_curr[17] = lfsr_next[19];
    assign lfsr_curr[18] = (i_data[0] ^ lfsr_next[0] ^ lfsr_next[20]);
    assign lfsr_curr[19] = (i_data[0] ^ i_data[1] ^ lfsr_next[0] ^ lfsr_next[1] ^ lfsr_next[21]);
    assign lfsr_curr[20] = (i_data[0] ^ i_data[1] ^ lfsr_next[0] ^ lfsr_next[1] ^ lfsr_next[22]);
    assign lfsr_curr[21] = (i_data[1] ^ lfsr_next[1] ^ lfsr_next[23]);
    assign lfsr_curr[22] = (i_data[0] ^ lfsr_next[0] ^ lfsr_next[24]);
    assign lfsr_curr[23] = (i_data[0] ^ i_data[1] ^ lfsr_next[0] ^ lfsr_next[1] ^ lfsr_next[25]);
    assign lfsr_curr[24] = (i_data[1] ^ lfsr_next[1] ^ lfsr_next[26]);
    assign lfsr_curr[25] = (i_data[0] ^ lfsr_next[0] ^ lfsr_next[27]);
    assign lfsr_curr[26] = (i_data[0] ^ i_data[1] ^ lfsr_next[0] ^ lfsr_next[1] ^ lfsr_next[28]);
    assign lfsr_curr[27] = (i_data[1] ^ lfsr_next[1] ^ lfsr_next[29]);
    assign lfsr_curr[28] = (i_data[0] ^ lfsr_next[0] ^ lfsr_next[30]);
    assign lfsr_curr[29] = (i_data[0] ^ i_data[1] ^ lfsr_next[0] ^ lfsr_next[1] ^ lfsr_next[31]);
    assign lfsr_curr[30] = (i_data[0] ^ i_data[1] ^ lfsr_next[0] ^ lfsr_next[1]);
    assign lfsr_curr[31] = (i_data[1] ^ lfsr_next[1]);

    // output assignment updates according to the sequential block
    assign o_crc = lfsr_curr ^ 32'hffffffff;
    
endmodule