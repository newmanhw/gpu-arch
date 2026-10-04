/* fma_tb.sv
 * Author: Newman Waters
 * Date: October 3, 2026
 * Description: Testbench for the pipelined fused-multiply-add unit that computes f = a * b + c.
 */

`timescale 1ns / 1ps

module fma_tb;

    localparam int WIDTH = 8;
    localparam time CLK_PERIOD = 10ns;

    // Signal declarations to attach to DUT
    logic clk;
    logic rst_n;
    logic valid_in;
    logic [WIDTH-1:0] a;
    logic [WIDTH-1:0] b;
    logic [WIDTH-1:0] c;
    logic valid_out;
    logic [WIDTH-1:0] result;

    // DUT instantiation
    fma #(.WIDTH(WIDTH)) dut (
        .clk       (clk),
        .rst_n     (rst_n),
        .valid_in  (valid_in),
        .a         (a),
        .b         (b),
        .c         (c),
        .valid_out (valid_out),
        .result    (result)
    );

    // Clk gen (100 MHz)
    initial clk = 0;
    always #(CLK_PERIOD / 2) clk = ~clk;

    initial begin
        // Enable VCD wave dumping
        $dumpfile("waveform.vcd");
        $dumpvars(0, fma_tb);

        // Initialize inputs
        rst_n = 0;
        valid_in = 0;
        a = '0;
        b = '0;
        c = '0;

        // Hold reset for 20 ns
        #20;
        rst_n = 1;
        #10;

        // Test 1: Basic operation with valid input
        @(negedge clk);
        valid_in = 1;
        a = 8'h02; // 2
        b = 8'h03; // 3
        c = 8'h04; // 4

        @(negedge clk);
        a = 8'h05; // 
        b = 8'h05; // 
        c = 8'h05; // 

        // Wait for the pipeline to process the inputs
        @(negedge clk);
        a = 8'h05; // 
        b = 8'h05; // 
        c = 8'h00; // 

        @(negedge clk);
        a = 8'h10; // 
        b = 8'h00; // 
        c = 8'h01; // 

        // Check the output
        assert (valid_out == 1) else $error("Test 1 Failed: valid_out is not asserted");
        assert (result == (8'h02 * 8'h03 + 8'h04)) else $error("Test 1 Failed: result is incorrect, got %0h", result);

        @(negedge clk);
        a = 8'h01; // 
        b = 8'h01; // 
        c = 8'h01; // 
        
        // Check the output
        assert (valid_out == 1) else $error("Test 2 Failed: valid_out is not asserted");
        assert (result == (8'h05 * 8'h05 + 8'h05)) else $error("Test 2 Failed: result is incorrect, got %0h", result);

        @(negedge clk);
        assert (valid_out == 1) else $error("Test 3 Failed: valid_out is not asserted");
        assert (result == (8'h05 * 8'h05 + 8'h00)) else $error("Test 3 Failed: result is incorrect, got %0h", result);
        valid_in = 0; // Stop sending valid inputs for now

        @(negedge clk);
        assert (valid_out == 1) else $error("Test 4 Failed: valid_out is not asserted");
        assert (result == (8'h10 * 8'h00 + 8'h01)) else $error("Test 4 Failed: result is incorrect, got %0h", result);

        @(negedge clk);
        assert (valid_out == 1) else $error("Test 5 Failed: valid_out is not asserted");
        assert (result == (8'h01 * 8'h01 + 8'h01)) else $error("Test 5 Failed: result is incorrect, got %0h", result);

        #60;
        $display("All tests completed successfully.");
        $finish;
    end

endmodule