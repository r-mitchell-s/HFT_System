`timescale 1ns / 1ps

module eth_mac_tx_tb;

    // Parameters
    localparam PAYLOAD_WIDTH = 368; // Example payload width

    // Signals
    logic i_clk;
    logic i_rst;
    logic i_tx_valid;
    logic [PAYLOAD_WIDTH - 1:0] i_payload_data;
    logic [47:0] i_dest_mac;
    logic [47:0] i_src_mac;
    logic [15:0] i_ether_type;
    
    logic [7:0] o_gmii_txd;
    logic o_gmii_tx_en;

    // Instantiate the Ethernet MAC TX module
    eth_mac_tx #(.PAYLOAD_WIDTH(PAYLOAD_WIDTH)) mac_tx (
        .i_clk(i_clk),
        .i_rst(i_rst),
        .i_tx_valid(i_tx_valid),
        .i_payload_data(i_payload_data),
        .i_dest_mac(i_dest_mac),
        .i_src_mac(i_src_mac),
        .i_ether_type(i_ether_type),
        .o_gmii_txd(o_gmii_txd),
        .o_gmii_tx_en(o_gmii_tx_en)
    );

    // Clock generation
    initial begin
        i_clk = 0;
        forever #5 i_clk = ~i_clk; // 100 MHz clock
    end

    // Test sequence
    initial begin
        // Initialize inputs
        i_rst = 1;
        i_tx_valid = 0;
        i_payload_data = 0;
        i_dest_mac = 48'hDEADBEEFDEAD; // Example MAC address
        i_src_mac = 48'hCAFECAFECAFE;  // Example MAC address
        i_ether_type = 16'h0800;        // IPv4 EtherType
        
        // Wait for some time
        #10;

        // Release reset
        i_rst = 0;
        #10;

        // Prepare a sample payload data
        i_payload_data = {(PAYLOAD_WIDTH / 8){8'hFF}}; // Example payload filled with 0xFF
        i_tx_valid = 1; // Indicate valid data to transmit

        // Wait for transmission to complete
        #2000;

        // Stop transmission
        i_tx_valid = 0;

        // Wait and then finish the simulation
        #50;
        $finish;
    end

    // Monitor outputs
    initial begin
        $monitor("Time: %0t | o_gmii_txd: %h | o_gmii_tx_en: %b", $time, o_gmii_txd, o_gmii_tx_en);
    end

endmodule