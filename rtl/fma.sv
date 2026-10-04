/* fma.sv
 * Author: Newman Waters
 * Date: October 3, 2026
 * Description: A pipelined fused-multiply-add unit that computes f = a * b + c.
*/
`timescale 1ns / 1ps

module fma #(
    parameter int WIDTH = 32
) (
    input logic clk,
    input logic rst_n,
    input logic valid_in,
    input logic [WIDTH-1:0] a,
    input logic [WIDTH-1:0] b,
    input logic [WIDTH-1:0] c,
    
    output logic valid_out,
    output logic [WIDTH-1:0] result
);

    // Internal pipeline registers
    logic [WIDTH-1:0] a_r, b_r, c_r;
    logic [WIDTH-1:0] mult_result;
    logic [WIDTH-1:0] delay_r;
    logic [WIDTH-1:0] final_result;
    logic [2:0] pipeline_valid_r;

    // Process for valid logic
    // we do not need to reset all registers since valid register indicates whether they have garbage in them
    always_ff @(posedge clk) begin
        if (!rst_n) begin
            pipeline_valid_r <= '0;
        end else begin
            pipeline_valid_r[0] <= valid_in;
            pipeline_valid_r[1] <= pipeline_valid_r[0];
            pipeline_valid_r[2] <= pipeline_valid_r[1];
        end
    end

    // Process for computation
    always_ff @(posedge clk) begin
        a_r <= a;
        b_r <= b;
        c_r <= c;
        mult_result <= a_r * b_r;
        delay_r <= c_r;
        final_result <= mult_result + delay_r;
    end

    assign valid_out = pipeline_valid_r[2];
    assign result = final_result;
endmodule