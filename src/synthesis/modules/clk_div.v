module clk_div #(
    parameter DIVISOR =  50000000
) (
    input clk,
    input rst_n,
    output out
);

    integer coutner_reg, counter_next;
    reg out_reg, out_next;
    assign out = out_reg;

    always @(posedge clk, negedge rst_n) begin
        if(!rst_n) begin
            out_reg <= 1'b0;
            coutner_reg <= 0;
        end
        else begin
            out_reg <= out_next;
            coutner_reg <= counter_next;
        end
    end

    always @(posedge clk) begin
        out_next = out_reg;
        counter_next = coutner_reg;
        if(coutner_reg == DIVISOR) begin
            counter_next = 0;
            out_next = 1'b1;
        end
        else begin
            counter_next = coutner_reg + 1;
            out_next = 1'b0;
        end
    end
    
endmodule