/* registerfile.sv
 * Author: Newman Waters
 * Date: October 3, 2026
*/
`timescale 1ns / 1ps

module registerfile #(
    parameter int WIDTH = 32,
    parameter int DEPTH = 32
) (
    input logic clk,
    input logic rst_n,
    
    // Dual port read
    input logic [$clog2(DEPTH)-1:0] rd_addr_1,
    output logic [WIDTH-1:0] rd_data_1,
    input logic [$clog2(DEPTH)-1:0] rd_addr_2,
    output logic [WIDTH-1:0] rd_data_2,

    // Write port
    input logic [WIDTH-1:0] wr_port_data,
    input logic [$clog2(DEPTH)-1:0] wr_addr,
    input logic wr_en
);
    logic [WIDTH-1:0] regs [DEPTH-1:0];

    always_ff @(posedge clk) begin
        if (!rst_n) begin
            for (int i = 0; i < DEPTH; i++) begin
                regs[i] <= '0;
            end
        end else if (wr_en) begin
            regs[wr_addr] <= wr_port_data;
        end

        rd_data_1 <= regs[rd_addr_1];
        rd_data_2 <= regs[rd_addr_2];
    end

endmodule