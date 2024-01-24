module top #(
    parameter DIVISOR = 50000000,
    parameter FILE_NAME = "mem_init.mif",
    parameter ADDR_WIDTH = 6,
    parameter DATA_WIDTH = 16
) (
    input clk,
    input rst_n,
    input [2:0] btn,
    input [9:0] sw,
    output [9:0] led,
    output [27:0] hex
);
    
    wire clk_div_out;
    wire we;
    wire [ADDR_WIDTH - 1:0] mem_addr;
    wire [DATA_WIDTH - 1:0] mem_data;
    wire [DATA_WIDTH - 1:0] mem_out;
    wire [ADDR_WIDTH - 1:0] pc;
    wire [ADDR_WIDTH - 1:0] sp;

    //wire [DATA_WIDTH - 1:0] cpu_out;
    //assign led[4:0] = cpu_out[4:0];

    clk_div #(DIVISOR) clk_div_dut(clk, sw[9], clk_div_out);
    memory #(FILE_NAME, ADDR_WIDTH, DATA_WIDTH) memory_dut(clk_div_out, we, mem_addr, mem_data, mem_out);
    cpu #(ADDR_WIDTH, DATA_WIDTH) cpu_dut(clk_div_out, sw[9], mem_out, {{(DATA_WIDTH - 3){1'b0}}, sw[4:0]}, we, mem_addr, mem_data, led[4:0], pc, sp);

    wire [3:0] tens_sp;
    wire [3:0] ones_sp;
    wire [3:0] tens_pc;
    wire [3:0] ones_pc;

    bcd bcd_dut_sp(sp, ones_sp, tens_sp);
    ssd ssd_sp_ones(ones_sp, hex[20:14]);
    ssd ssd_sp_tens(tens_sp, hex[27:21]);

    bcd bcd_dut_pc(pc, ones_pc, tens_pc);
    ssd ssd_pc_ones(ones_pc, hex[6:0]);
    ssd ssd_pc_tens(tens_pc, hex[13:7]);

endmodule