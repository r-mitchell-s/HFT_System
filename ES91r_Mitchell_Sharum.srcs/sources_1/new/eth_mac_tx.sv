/*

- Payload size will have to be somehow passed in from the NASDAQ_OUCH module, as OUCH messages are of variable size, and shoiuld fit PAYLOAD_WIDTH
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
    input  logic        i_clk,                              // input clock
    input  logic        i_rst,                              // reset signal
    
    // interface to higher layers
    input  logic        i_tx_valid,                         // data valid signal
    input  logic [PAYLOAD_WIDTH - 1:0]  i_payload_data,     // data to transmit (payload)
    input  logic [47:0] i_dest_mac,                         // destination MAC address
    input  logic [47:0] i_src_mac,                          // source MAC address
    input  logic [15:0] i_ether_type,                       // etherType/Length field
    
    // interface to PHY
    output logic [7:0]  o_gmii_txd,                         // data sent to PHY
    output logic        o_gmii_tx_en                        // transmit enable signal
    );
    
    // state definition (transmission will occur as frame onstruction progresses through states)
    enum logic [2:0] {IDLE, PREAMBLE, HEADER, PAYLOAD, CRC, DONE} state = IDLE, next_state;
    
    // shift register to transmit the frame as it is being constructed (1 byte at a time), and a countrer to track how many bytes we've tramsmit
    reg [7:0] tx_sr;
    reg [15:0] byte_counter;
    
    // internal signals that interface with the crc_gen module
    logic crc_en;
    logic [7:0] crc_out;
    
    
    // ethernet MAC state machine with synchronous reset
    always @(posedge i_clk) begin
        if (i_rst) begin
            state <= IDLE;
            o_gmii_tx_en <= 1'b0;
        end else begin
        
            state <= next_state;
            
            // MAC state transition logic
            case (state) 
                
                // wait for transmission bit to assert before beginning frame construction
                IDLE: begin
                    if (i_tx_valid) begin
                        byte_counter <= 0;
                        next_state <= PREAMBLE;
                        crc_en <= 1'b0;
                    end else begin
                        next_state <= IDLE;
                        o_gmii_tx_en <= 1'b1;
                    end
                end
                
                // construct and send preamble abnd start-frame delimeter
                PREAMBLE: begin

                    // start transmitting
                    
                    
                    // preamble consists of 7 bytes of 10101010 (0xAA)
                    if (byte_counter < 7) begin
                        o_gmii_txd <= 8'hAA;
                        byte_counter <= byte_counter + 1;
                        
                    // SFD consists of 1 byte of 10101011, and then begin transmitting header
                    end else if (byte_counter == 7) begin
                        o_gmii_txd <= 8'hAB;
                        byte_counter <= 0;
                        next_state <= HEADER;
                    end
                end
                
                // transmit ethernet header contents (src and dst MAC addr and ethertype
                HEADER: begin

                    // conditional to transmit correct bytes
                    case (byte_counter)
                        // destination MAC (6 bytes)
                        0: o_gmii_txd <= i_dest_mac[47:40];
                        1: o_gmii_txd <= i_dest_mac[39:32];
                        2: o_gmii_txd <= i_dest_mac[31:24];
                        3: o_gmii_txd <= i_dest_mac[23:16];
                        4: o_gmii_txd <= i_dest_mac[15:8];
                        5: o_gmii_txd <= i_dest_mac[7:0];

                        // source MAC (6 bytes)
                        6: o_gmii_txd <= i_src_mac[47:40];
                        7: o_gmii_txd <= i_src_mac[39:32];
                        8: o_gmii_txd <= i_src_mac[31:24];
                        9: o_gmii_txd <= i_src_mac[23:16];
                        10: o_gmii_txd <= i_src_mac[15:8];
                        11: o_gmii_txd <= i_src_mac[7:0];

                        // etherType/Length (2 bytes)
                        12: o_gmii_txd <= i_ether_type[15:8];
                        13: o_gmii_txd <= i_ether_type[7:0];
                    endcase
                    
                    // switch states when complete
                    if (byte_counter == 13) begin
                        byte_counter <= 0;
                        next_state <= PAYLOAD;
                    
                    // increment byte counter
                    end else begin
                        byte_counter <= byte_counter + 1;
                    end
                end
                
                
                // payload transmission
                PAYLOAD: begin

                    // only transmit bytes so long as we have no transmit the whole payload
                    if (byte_counter < PAYLOAD_WIDTH / 8) begin
                        
                        // payload shift register takes in the byte strting at byte_counter * 8 (byte 0 them 1 then 2...)
                        tx_sr <= i_payload_data[(byte_counter) * 8 +: 8];
                        o_gmii_txd <= tx_sr;                    
                        
                        // increment byte counter
                        byte_counter <= byte_counter + 1;
                        
                    end else if (byte_counter >= PAYLOAD_WIDTH / 8) begin
                        crc_en <= 1'b1; // Start CRC generation
                        next_state <= CRC;
                        byte_counter <= 0;
                    end 
                end 

 
                // CRC transmission 
                CRC: begin

                    case (byte_counter)
                        0: o_gmii_txd <= crc_out[31:24];
                        1: o_gmii_txd <= crc_out[23:16];
                        2: o_gmii_txd <= crc_out[15:8];
                        3: o_gmii_txd <= crc_out[7:0];
                    endcase                                
                    
                    // end transmission once crc finished
                    if (byte_counter == 3) begin
                        next_state <= DONE;
                        byte_counter <= 0;
                    
                    // increment byte counter and check to see if you are done
                    end else begin
                        byte_counter <= byte_counter + 1; 
                    end
                end 
                
                // once we finish frame construction, resume IDLE state
                DONE: begin
                    o_gmii_tx_en <= 1'b0;
                    next_state <= IDLE;
                end
            endcase                      
        end  
    end
    
        // instantiate CRC generation module to generate the last 4 bytes of the ethernet frame based on header and payload bits
        crc_gen crc(.i_clk(i_clk), .i_rst(i_rst), .i_crc_en(crc_en), .i_data(o_gmii_txd), .o_crc(crc_out));      
endmodule