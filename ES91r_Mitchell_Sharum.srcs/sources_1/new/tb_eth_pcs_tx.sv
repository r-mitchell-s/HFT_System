// module tb_eth_pcs_tx;

//     // Testbench clock and reset signals
//     reg tb_clk;
//     reg tb_rst;

//     // Inputs to the PCS module (simulated MAC signals)
//     reg tb_mac_data_valid;
//     reg [63:0] tb_mac_data;

//     // Outputs from the PCS module
//     wire tb_pcs_data_valid;
//     wire [65:0] tb_pcs_data;

//     // Instantiate the DUT (Design Under Test)
//     eth_pcs_tx dut (
//         .i_clk(tb_clk),
//         .i_rst(tb_rst),
//         .i_mac_data_valid(tb_mac_data_valid),
//         .i_mac_data(tb_mac_data),
//         .o_pcs_data_valid(tb_pcs_data_valid),
//         .o_pcs_data(tb_pcs_data)
//     );

//     // Clock generation (50 MHz clock)
//     always begin
//         #10 tb_clk = ~tb_clk;  // 20ns period -> 50 MHz clock
//     end

//     // Task to reset the design
//     task reset_dut();
//         begin
//             tb_rst = 1;
//             #50;
//             tb_rst = 0;
//         end
//     endtask

//     // Task to send data to the PCS
//     task send_mac_data(input [63:0] data);
//         begin
//             tb_mac_data_valid = 1;
//             tb_mac_data = data;
//             #20; // Wait for one clock cycle
//             tb_mac_data_valid = 0;
//             tb_mac_data = 64'b0;
//         end
//     endtask

//     // Initial block to apply stimulus
//     initial begin
//         // Initialize signals
//         tb_clk = 0;
//         tb_rst = 1;
//         tb_mac_data_valid = 0;
//         tb_mac_data = 64'b0;

//         // GTKWave dump setup
//         $dumpfile("dump.vcd");
//         $dumpvars(0, tb_eth_pcs_tx);

//         // Reset the DUT
//         reset_dut();

//         // Test case 1: Send some example MAC data (64-bit words)
//         send_mac_data(64'h1122334455667788);  // Example MAC data word 1
//         send_mac_data(64'h99AABBCCDDEEFF00);  // Example MAC data word 2
//         send_mac_data(64'h987654345678987);  // Example MAC data word 2
//         send_mac_data(64'h0987654321234567);  // Example MAC data word 2

//         // Wait for a few clock cycles to allow data to propagate through PCS
//         #100;

//         // End simulation
//         $finish;
//     end

//     // Monitor PCS outputs (optional, can be removed if not needed)
//     initial begin
//         $monitor("Time = %0t | MAC Data Valid = %b | MAC Data = %h | PCS Data Valid = %b | PCS Data = %h",
//                  $time, tb_mac_data_valid, tb_mac_data, tb_pcs_data_valid, tb_pcs_data);
//     end

// endmodule
