/* 
    - The PCS module takes 8 bytes from the ethernet MAC (T) as its input
    and produces a 64b/66b encoded and scrambled output ready to be transmit
    over physical media
    - Other inputs (enables etc) operate on the same clock nd reset as the rest of the system

*/

module eth_pcs_tx (

    // basic inputs
    input logic          i_clk,  
    input logic          i_rst,

    // inputs takeen directly from eth_mac_tx (or the buffer after MAC)
    input logic i_mac_data_valid,
    input logic [63:0]  i_mac_data,
    
    // outputs (run directly into the PMD for transmission)
    output logic o_pcs_data_valid,
    output logic [65:0] o_pcs_data
);

    // Scrambler state (based on x^58 polynomial)
    logic [57:0] scrambler_state;

    // registers to store the current scrambled data and the 2 encoding bits to be appended
    logic [63:0] scrambled_data;  
    logic [1:0] encoding_header;  

    // sequential block to define reset behavior
    always @(posedge i_clk) begin
        if (i_rst) begin
            scrambler_state <= 58'h0AAAAAAAAAAAAAA;

        // if the MAC is transmitting data
        end else if (i_mac_data_valid) begin

            // scramble the data
            scrambled_data <= i_mac_data ^ {scrambler_state[38:0], 25'b0}; 

            // Update the scrambler state with feedback (x^58 + x^39 + 1)
            scrambler_state <= {scrambler_state[56:0], scrambler_state[57] ^ scrambler_state[38] ^ i_mac_data[63]};
        end
    end

    // combinatorial block for determining what header to add for 64b/66b encoding (MAC data or control bits??)
    always @* begin
        if (i_mac_data_valid) begin
            encoding_header = 2'b01;
        end else begin
            encoding_header = 2'b10;
        end
    end

    // sequential block for output generation
    always @(posedge i_clk) begin
        if (i_rst) begin
            o_pcs_data_valid <= 1'b0;
            o_pcs_data <= 64'b0;
        end else if (i_mac_data_valid) begin
            o_pcs_data_valid <= 1'b1;
            o_pcs_data <= {encoding_header, scrambled_data};
        end else begin
            o_pcs_data_valid <= 1'b0;
        end
    end

endmodule