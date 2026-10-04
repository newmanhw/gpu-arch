/* registerfile_tb.sv
 * Author: Newman Waters
 * Date: October 3, 2026
 */

`timescale 1ns / 1ps

module registerfile_tb;

    localparam int WIDTH = 32;
    localparam int DEPTH = 32;
    localparam time CLK_PERIOD = 10ns;

    logic             clk;
    logic             rst_n;
    logic [$clog2(DEPTH)-1:0] rd_addr_1;
    logic [WIDTH-1:0] rd_data_1;
    logic [$clog2(DEPTH)-1:0] rd_addr_2;
    logic [WIDTH-1:0] rd_data_2;
    logic [WIDTH-1:0] wr_port_data;
    logic [$clog2(DEPTH)-1:0] wr_addr;
    logic             wr_en;
    
    // Instantiate Device Under Test (DUT)
    registerfile #(.WIDTH(WIDTH), .DEPTH(DEPTH)) dut (
        .clk          (clk),
        .rst_n        (rst_n),
        .rd_addr_1    (rd_addr_1),
        .rd_data_1    (rd_data_1),
        .rd_addr_2    (rd_addr_2),
        .rd_data_2    (rd_data_2),
        .wr_port_data (wr_port_data),
        .wr_addr      (wr_addr),
        .wr_en        (wr_en)
    );

    // 100 MHz Clock Generation (5ns high / 5ns low)
    initial clk = 0;
    always #(CLK_PERIOD / 2) clk = ~clk;

    // Stimulus and VCD generation
    initial begin
        // Enable VCD wave dumping
        $dumpfile("waveform.vcd");
        $dumpvars(0, registerfile_tb);

        // Initialize inputs
        rst_n = 0;
        wr_en = 0;
        wr_port_data = '0;

        // Hold reset for 20 ns
        #20;
        rst_n = 1;
        #10;

        @(negedge clk);
        wr_en = 1;
        wr_port_data = 32'hDEADBEEF;
        wr_addr = 5'd10;
        @(negedge clk);
        wr_en = 0;

        @(negedge clk);
        rd_addr_1 = 5'd10;
        rd_addr_2 = 5'd10;
        @(negedge clk);
        assert (rd_data_1 == 32'hDEADBEEF) else $error("Test Failed: rd_data_1 = 0x%0h, expected 0xDEADBEEF", rd_data_1);
        assert (rd_data_2 == 32'hDEADBEEF) else $error("Test Failed: rd_data_2 = 0x%0h, expected 0xDEADBEEF", rd_data_2);

        #20;
        $display("All tests completed successfully.");
        $finish;
    end

endmodule