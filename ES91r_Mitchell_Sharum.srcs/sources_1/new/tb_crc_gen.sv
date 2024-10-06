//`timescale 1ns / 1ps

//module tb_crc_gen;

//    // Inputs
//    logic i_clk;             // Clock signal
//    logic i_rst;             // Reset signal
//    logic i_crc_en;          // Enable signal for CRC calculation
//    logic [7:0] i_data;      // Input data for CRC calculation

//    // Outputs
//    logic [31:0] o_crc;      // Output CRC value

//    // Instantiate the CRC generator
//    crc_gen uut (
//        .i_clk(i_clk),
//        .i_rst(i_rst),
//        .i_crc_en(i_crc_en),
//        .i_data(i_data),
//        .o_crc(o_crc)
//    );

//    // Clock generation
//    initial begin
//        i_clk = 0;
//        forever #5 i_clk = ~i_clk;  // Toggle clock every 5 ns
//    end

//    // Test sequence
//    initial begin
//        // Initialize inputs
//        i_rst = 1;
//        i_crc_en = 0;
//        i_data = 8'h00;  // Initial data
//        #10;

//        // Release reset
//        i_rst = 0;
//        #10;

//        // Enable CRC generation and send data bytes
//        i_crc_en = 1;
//        #10;
        
//        // Example data (Ethernet frame payload)
//        // Here, we're sending a few example bytes.
//        i_data = 8'hDE; #10;  // Send first byte
//        i_data = 8'hAD; #10;  // Send second byte
//        i_data = 8'hBE; #10;  // Send third byte
//        i_data = 8'hEF; #10;  // Send fourth byte

//        // Finish the CRC calculation
//        i_crc_en = 0;
//        #10;  // Wait a bit to stabilize

//        // Check output
//        // Replace with the expected CRC value for DEADBEEF
//        $display("Final CRC: %h", o_crc);
//        if (o_crc === 32'hCDB4D5B4) begin
//            $display("Test Passed! CRC matches expected value.");
//        end else begin
//            $display("Test Failed! Expected: %h, Got: %h", 32'hCDB4D5B4, o_crc);
//        end

//        // Finish simulation
//        $finish;
//    end

//endmodule
