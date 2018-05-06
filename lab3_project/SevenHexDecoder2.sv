module SevenHexDecoder2(
	input [4:0] i_hex,
	output logic [6:0] o_seven_ten,
	output logic [6:0] o_seven_one
);
	/* The layout of seven segment display, 1: dark
	 *    00
	 *   5  1
	 *    66
	 *   4  2
	 *    33
	 */
	parameter D0 = 7'b1000000;
	parameter D1 = 7'b1111001;
	parameter D2 = 7'b0100100;
	parameter D3 = 7'b0110000;
	parameter D4 = 7'b0011001;
	parameter D5 = 7'b0010010;
	parameter D6 = 7'b0000010;
	parameter D7 = 7'b1011000;
	parameter D8 = 7'b0000000;
	parameter D9 = 7'b0010000;
	parameter D10 = 7'b0111111;
	parameter NULL = 7'b1111111;

	always_comb begin
		case(i_hex)
			5'b00000: begin o_seven_ten = NULL; o_seven_one = NULL; end
			5'b00001: begin o_seven_ten = D0; o_seven_one = D1; end
			5'b00010: begin o_seven_ten = D0; o_seven_one = D2; end
			5'b00011: begin o_seven_ten = D0; o_seven_one = D3; end
			5'b00100: begin o_seven_ten = D0; o_seven_one = D4; end
			5'b00101: begin o_seven_ten = D0; o_seven_one = D5; end
			5'b00110: begin o_seven_ten = D0; o_seven_one = D6; end
			5'b00111: begin o_seven_ten = D0; o_seven_one = D7; end
			5'b01000: begin o_seven_ten = D0; o_seven_one = D8; end
			//
			5'b11000: begin o_seven_ten = D10; o_seven_one = D8; end
			5'b11001: begin o_seven_ten = D10; o_seven_one = D7; end
			5'b11010: begin o_seven_ten = D10; o_seven_one = D6; end
			5'b11011: begin o_seven_ten = D10; o_seven_one = D5; end
			5'b11100: begin o_seven_ten = D10; o_seven_one = D4; end
			5'b11101: begin o_seven_ten = D10; o_seven_one = D3; end
			5'b11110: begin o_seven_ten = D10; o_seven_one = D2; end
			5'b11111: begin o_seven_ten = D0; o_seven_one = D1; end
			default: begin o_seven_ten = NULL; o_seven_one = NULL; end
		endcase
	end
endmodule
