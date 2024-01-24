module ssd (
    input [3:0] in,
    output reg [6:0] out
);
    
    always @(*) begin
		case (in)
			4'b0000: out = ~7'h3F;
			4'b0001: out = ~7'h06;// 000 0110
			4'b0010: out = ~7'h5B;// 101 1011
			4'b0011: out = ~7'h4F;
			4'b0100: out = ~7'h66;
			4'b0101: out = ~7'h6D;
			4'b0110: out = ~7'h7D;
			4'b0111: out = ~7'h07;
			4'b1000: out = ~7'h7F;
			4'b1001: out = ~7'h6F;
			4'b1010: out = ~7'h77;// 111 0111
			4'b1011: out = ~7'h7C;// 111 1100
			4'b1100: out = ~7'h39;// 011 1001
			4'b1101: out = ~7'h5E;// 101 1110
			4'b1110: out = ~7'h79;// 111 1001
			4'b1111: out = ~7'h71;// 111 0001
		endcase
	end

endmodule