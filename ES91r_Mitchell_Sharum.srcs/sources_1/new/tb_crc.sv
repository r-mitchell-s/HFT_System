//`timescale 1ps / 1ps

///*

//*/

//module tb_crc();

//    // Declare testbench variables
//    reg i_clk;
//    reg i_rst;
//    reg i_crc_en;
//    reg [1:0] i_data;
//    wire [31:0] o_crc;

//    // Instantiate the DUT (Device Under Test)
//    crc dut (
//        .i_clk(i_clk),
//        .i_rst(i_rst),
//        .i_crc_en(i_crc_en),
//        .i_data(i_data),
//        .o_crc(o_crc)
//    );

//    // Clock generation
//    always begin
//        #5 i_clk = ~i_clk;  // 100 MHz clock (period of 10ps)
//    end

//    // Test sequence
//    initial begin
//        // Initialize signals
//        i_clk = 0;
//        i_rst = 1;
//        i_crc_en = 0;
//        i_data = 2'b00;

//        // Apply reset
//        #10 i_rst = 0;
        
//        // Enable CRC generation and provide data inputs
//        #10 i_crc_en = 1;
//        i_data = 2'b01;
        
//        #10 i_data = 2'b10;
        
//        #10 i_data = 2'b11;
        
//        #10 i_data = 2'b00;
        
//        // Disable CRC after a few cycles
//        #10 i_crc_en = 0;
        
//        // Observe the result
//        #50;

//        // End the simulation
//        $finish;
//    end

//    // Monitor signals
//    initial begin
//        $monitor("Time: %t | i_data: %b | o_crc: %h", $time, i_data, o_crc);
//    end

//endmodule