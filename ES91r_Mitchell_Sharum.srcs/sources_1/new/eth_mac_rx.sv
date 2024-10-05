/*

- ethernet Tx takes data payload (in our case an OUCH formatted trade message) and src/dst MAC addresses as its inputs 
  construct an ethernet frame around that payload for transmission, structured as follows
    - 7 byte preamble
    - 1 byte start frame delimiter (SFD)
    - 6 byte destination MAC address
    - 6 byte source MAC address
    - 2 byte ethertype (for this project only IPv4 will be used, so no need to parameterize ethertype)
    - 46-1500 byte data payload (the module input i_payload)
    - 4 byte frame check sequence via CRC-32 checksum (provided by the crc.sv module)  
- the payload width and source and destination MAC addresses will be parameterized so that they may be determined at a higher level in the trading system
- transmission of the ethernet frame occurs serially, so we cannot simply output the whole frame all at once.
  On-the-fly assembly will be used due to the fact that, even though it is more complex to implement, it reduces
  both latency and memory overhead when compared with parallelized frame assembly methods, as frame transmission can start as sooon as the first few bytes are constructed
- transmission will occur to the PHY layer via gmii protocol (Gigabit Media Inependent Interface)

*/

`timescale 1ns / 1ps

module eth_mac_tx #(PAYLOAD_WIDTH = 368)(
    
    // basic inputs
    input  logic        i_clk,         // input clock
    input  logic        i_rst,         // reset signal
    
    // interface to higher layers
    input  logic        i_tx_valid,    // Data valid signal
    input  logic [7:0]  i_tx_data,     // Data to transmit (payload)
    input  logic [47:0] i_dest_mac,    // Destination MAC address
    input  logic [47:0] i_src_mac,     // Source MAC address
    input  logic [15:0] i_ether_type,  // EtherType/Length field
    
    // interface to PHY
    output logic [7:0]  o_gmii_txd,    // Data sent to PHY
    output logic        o_gmii_tx_en   // Transmit enable signal
    );
    
    // state definition (transmission will occur as frame onstruction progresses through states)
    enum logic [2:0] {IDLE, PREAMBLE, HEADER, PAYLOAD, CRC, DONE} state, next_state;
    
    // shift register to transmit the frame as it is being constructed (1 byte at a time), and a countrer to track how many bytes we've tramsmit
    reg [7:0] tx_sr;
    reg [15:0] byt_counter;
    
    // ethernet MAC state machine
    always @(posedge i_clk) begin
        if (i_rst) begin
            state <= IDLE;
            o_gmii_tx_en = 1'b0;
        end else begin
            
            // MAC state transition logic
            case (state) 
                
                // in IDLE state, wait for transmission bit to assert before beginning frame construction
                IDLE: 
                    
        
    
endmodule

module mac_tx (
    input  logic        i_clk,
    input  logic        i_reset,
    
    // Interface to higher layers
    input  logic [7:0]  i_tx_data,     // Data to transmit (payload)
    input  logic        i_tx_valid,    // Data valid signal
    input  logic [47:0] i_dest_mac,    // Destination MAC address
    input  logic [47:0] i_src_mac,     // Source MAC address
    input  logic [15:0] i_ether_type,  // EtherType/Length field
    
    // Interface to PHY
    output logic [7:0]  o_gmii_txd,    // Data sent to PHY
    output logic        o_gmii_tx_en   // Transmit enable signal
);
    // State machine states for TX
    enum logic [2:0] {IDLE, PREAMBLE, HEADER, PAYLOAD, CRC, DONE} state, next_state;

    // Frame construction signals
    logic [7:0] tx_shift_reg;
    logic [15:0] byte_counter;

    // Internal signals for CRC
    logic [31:0] crc_out;

    // MAC TX logic
    always_ff @(posedge i_clk or posedge i_reset) begin
        if (i_reset) begin
            state <= IDLE;
            o_gmii_tx_en <= 1'b0;
        end else begin
            case (state)
                // Idle state, waiting for valid data
                IDLE: begin
                    if (i_tx_valid) begin
                        state <= PREAMBLE;
                        byte_counter <= 0;
                    end
                end

                // Send the preamble (7 bytes of 0xAA) and SFD (1 byte of 0xAB)
                PREAMBLE: begin
                    o_gmii_tx_en <= 1'b1;
                    if (byte_counter < 7) begin
                        o_gmii_txd <= 8'hAA;  // Preamble
                    end else if (byte_counter == 7) begin
                        o_gmii_txd <= 8'hAB;  // SFD
                        state <= HEADER;
                    end
                    byte_counter <= byte_counter + 1;
                end

                // Send the Ethernet header (destination MAC, source MAC, EtherType)
                HEADER: begin
                    case (byte_counter)
                        // Destination MAC (6 bytes)
                        0: o_gmii_txd <= i_dest_mac[47:40];
                        1: o_gmii_txd <= i_dest_mac[39:32];
                        2: o_gmii_txd <= i_dest_mac[31:24];
                        3: o_gmii_txd <= i_dest_mac[23:16];
                        4: o_gmii_txd <= i_dest_mac[15:8];
                        5: o_gmii_txd <= i_dest_mac[7:0];

                        // Source MAC (6 bytes)
                        6: o_gmii_txd <= i_src_mac[47:40];
                        7: o_gmii_txd <= i_src_mac[39:32];
                        8: o_gmii_txd <= i_src_mac[31:24];
                        9: o_gmii_txd <= i_src_mac[23:16];
                        10: o_gmii_txd <= i_src_mac[15:8];
                        11: o_gmii_txd <= i_src_mac[7:0];

                        // EtherType/Length (2 bytes)
                        12: o_gmii_txd <= i_ether_type[15:8];
                        13: o_gmii_txd <= i_ether_type[7:0];
                    endcase
                    byte_counter <= byte_counter + 1;

                    if (byte_counter == 13) begin
                        state <= PAYLOAD;
                        byte_counter <= 0;
                    end
                end

                // Send the payload data
                PAYLOAD: begin
                    if (i_tx_valid) begin
                        o_gmii_txd <= i_tx_data;
                        byte_counter <= byte_counter + 1;
                    end

                    // If payload is finished or meets the max Ethernet frame size, move to CRC
                    if (byte_counter == 1500 || !i_tx_valid) begin
                        state <= CRC;
                    end
                end

                // Send the CRC (4 bytes) for the Ethernet frame
                CRC: begin
                    // Compute CRC over the frame (excluding preamble and SFD)
                    // Example of CRC-32 logic omitted for simplicity.
                    o_gmii_txd <= crc_out[31:24];  // Send CRC MSB first
                    state <= DONE;
                end

                DONE: begin
                    o_gmii_tx_en <= 1'b0;
                    state <= IDLE;
                end

            endcase
        end
    end

    // CRC generation logic (to be added)
    // ...

endmodule

