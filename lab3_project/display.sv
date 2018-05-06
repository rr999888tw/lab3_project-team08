module diplay(
	input i_rst_N,
	input [19:0] i_addr,  ///彭要幫我處理成5bit yeah  assume that is i_sec
	input [17:0] i_sw,
	input [2:0] i_state,
	input [15:0] i_data,
	input clock_50
	//
	output [6:0] sec5,
	output [6:0] sec7,
	output [6:0] sec6,

	output [6:0] sec4,
	//
	output [6:0] o3,
	output [6:0] o2,
	output [6:0] o1,
	output [6:0] o0,
	//
	// output [15:0] LEDR

	output lcd_blon,
	output [7:0] lcd_data,
	output lcd_en,
	output lcd_on,
	output lcd_rs,
	output lcd_rw
	
);

parameter H = 7'b0001001;
parameter I = 7'b1111001;
parameter D = 7'b1000000;
parameter L = 7'b1000111;
parameter E = 7'b0000110;
parameter R = 7'b0001000;
parameter C = 7'b1000110;
parameter O = 7'b1000000;
parameter P = 7'b0001100;
parameter A = 7'b0001000;
parameter Y = 7'b0011001;
parameter U = 7'b1000001;
parameter S = 7'b0010010;
parameter T = 7'b0000111;
parameter NULL = 7'b1111111;

logic [4:0] i_sec;
logic [4:0] sw;	
logic [6:0] o_state_4;
logic [6:0] o_state_5;
logic [6:0] o_state_6;
logic [6:0] o_state_7;

Addr2Time ad(
	.i_SRAM_ADDR(i_addr),
	.o_used_time(i_sec)
);

SevenHexDecoder1 s1(
	.i_hex(i_sec),
	.o_seven_ten(o_state_7),
	.o_seven_one(o_state_6)
);
SevenHexDecoder2 s2(
	.i_hex(sw),
	.o_seven_ten(o_state_5),
	.o_seven_one(o_state_4)
);


LCDdisplay ld(
	.i_rst_N(i_rst_N),
	.i_state(i_state),
	.clock_50(clock_50),
	.i_sec(i_sec),
    .sw(sw),
	.lcd_blon(lcd_blon),
	.lcd_data(lcd_data),
	.lcd_en(lcd_en),
	.lcd_on(lcd_on),
	.lcd_rs(lcd_rs),
	.lcd_rw(lcd_rw)
);


	always_comb begin
		
	
	
		if(i_state == 0) begin
			o3 = I;
			o2 = D;
			o1 = L;
			o0 = E;
			sw = 5'b00000;
			sec4 = NULL;
			sec5 = NULL;
			sec6 = NULL;
			sec7 = NULL;
		end else if(i_state == 1) begin
			o3 = H;
			o2 = O;
			o1 = L;
			o0 = D;
			sw = 5'b00000;
			sec4 = NULL;
			sec5 = NULL;
			sec6 = NULL;
			sec7 = NULL;
		end else if(i_state ==3) begin

			sec7 = o_state_7;
			sec6 = o_state_6;

			if(i_sw[17]) begin   
				if(i_sw[8])      begin sw = 5'b01000;  end
				else if(i_sw[7]) begin sw = 5'b00111;  end
				else if(i_sw[6]) begin sw = 5'b00110;  end
				else if(i_sw[5]) begin sw = 5'b00101;  end
				else if(i_sw[4]) begin sw = 5'b00100;  end
				else if(i_sw[3]) begin sw = 5'b00011;  end
				else if(i_sw[2]) begin sw = 5'b00010;  end
				else             begin sw = 5'b00001;  end
			end else begin
				if(i_sw[8])      begin sw = 5'b11000;  end
				else if(i_sw[7]) begin sw = 5'b11001;  end
				else if(i_sw[6]) begin sw = 5'b11010;  end
				else if(i_sw[5]) begin sw = 5'b11011;  end
				else if(i_sw[4]) begin sw = 5'b11100;  end
				else if(i_sw[3]) begin sw = 5'b11101;  end
				else if(i_sw[2]) begin sw = 5'b11110;  end
				else             begin sw = 5'b11111;  end
			end

			sec4 = o_state_4;
			sec5 = o_state_5;

			o3 = P;
			o2 = L;
			o1 = A;
			o0 = Y;
		end else if(i_state == 2) begin
			sec7 = o_state_7;
			sec6 = o_state_6;
			sec4 = NULL;
			sec5 = NULL;
			sw = 5'b00000;
			o3 = NULL;
			o2 = R;
			o1 = E;
			o0 = C;
		end else if(i_state == 4) begin

			sec7 = o_state_7;
			sec6 = o_state_6;

			if(i_sw[17]) begin   
				if(i_sw[8])      begin sw = 5'b01000;  end
				else if(i_sw[7]) begin sw = 5'b00111;  end
				else if(i_sw[6]) begin sw = 5'b00110;  end
				else if(i_sw[5]) begin sw = 5'b00101;  end
				else if(i_sw[4]) begin sw = 5'b00100;  end
				else if(i_sw[3]) begin sw = 5'b00011;  end
				else if(i_sw[2]) begin sw = 5'b00010;  end
				else             begin sw = 5'b00001;  end
			end else begin
				if(i_sw[8])      begin sw = 5'b11000;  end
				else if(i_sw[7]) begin sw = 5'b11001;  end
				else if(i_sw[6]) begin sw = 5'b11010;  end
				else if(i_sw[5]) begin sw = 5'b11011;  end
				else if(i_sw[4]) begin sw = 5'b11100;  end
				else if(i_sw[3]) begin sw = 5'b11101;  end
				else if(i_sw[2]) begin sw = 5'b11110;  end
				else             begin sw = 5'b11111;  end
			end

			sec4 = o_state_4;
			sec5 = o_state_5;

			o3 = P;
			o2 = A;
			o1 = U;
			o0 = S;
		end else begin
			sec7 = NULL;
			sec6 = NULL;
			sec4 = NULL;
			sec5 = NULL;
			sw = 5'b00000;
			o3 = NULL;
			o2 = NULL;
			o1 = NULL;
			o0 = NULL;
		end



	end
endmodule



/*
if(i_data[15]) begin
			LEDR[15:0] = '0;
		end else if(i_data[14]) begin
			LEDR[14:0] = '0;
			LEDR[15:14] = '1;
		end else if(i_data[13]) begin
			LEDR[13:0] = '0;
			LEDR[15:13] = '1;
		end else if(i_data[12]) begin
			LEDR[12:0] = '0;
			LEDR[15:12] = '1;
		end else if(i_data[11]) begin
			LEDR[11:0] = '0;
			LEDR[15:11] = '1;
		end else if(i_data[10]) begin
			LEDR[10:0] = '0;
			LEDR[15:10] = '1;
		end else if(i_data[9]) begin
			LEDR[9:0] = '0;
			LEDR[15:9] = '1;
		end else if(i_data[8]) begin
			LEDR[8:0] = '0;
			LEDR[15:8] = '1;
		end else if(i_data[7]) begin
			LEDR[7:0] = '0;
			LEDR[15:7] = '1;
		end else if(i_data[6]) begin
			LEDR[6:0] = '0;
			LEDR[15:6] = '1;
		end else if(i_data[5]) begin
			LEDR[5:0] = '0;
			LEDR[15:5] = '1;
		end else if(i_data[4]) begin
			LEDR[4:0] = '0;
			LEDR[15:4] = '1;
		end else if(i_data[3]) begin
			LEDR[3:0] = '0;
			LEDR[15:3] = '1;
		end else if(i_data[2]) begin
			LEDR[2:0] = '0;
			LEDR[15:2] = '1;
		end else if(i_data[1]) begin
			LEDR[1:0] = '0;
			LEDR[15:1] = '1;
		end else begin
			LEDR = '1;
		end
*/