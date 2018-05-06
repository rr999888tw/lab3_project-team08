module LCDdisplay(
    input clock_50,
    input [4:0] i_sec,
    input [4:0] sw,
    input [2:0] i_state,
    input i_rst_N,

    output lcd_blon,
	output lcd_on,
	output lcd_rw,
    
	output lcd_en,
    
    output lcd_rs,
	output [7:0] lcd_data,
);

assign lcd_on = 1'b1;
assign lcd_rw = 1'b0;
assign lcd_en = clock_50;
// assign lcd_blon = 1'b0;

localparam INIT = 0;
localparam DISPLAY = 1;

logic [8:0] chars [40:0]; // 33+7  
logic [6:0] count_w, count_r;
logic state_w, state_r;

assign chars[34][8:0] = 9'h38;
assign chars[35][8:0] = 9'h38;
assign chars[36][8:0] = 9'h38;
assign chars[37][8:0] = 9'h08;
assign chars[38][8:0] = 9'h01;
assign chars[39][8:0] = 9'h0c;
assign chars[40][8:0] = 9'h06;

case (state_r)

    INIT: begin
        if (count_r == 33 + 7) begin
            count_w = 0;
            state_w = DISPLAY;
        end else begin
            count_w = count_r + 1;
            state_w = state_r;
        end
    end

    DISPLAY: begin
        
        state_w = DISPLAY
        if (count_r == 32) begin
            count_w = 0;
        end else begin
            count_w = count_r + 1;    
        end
    end

	default: begin 
		state_w = INIT; 
		count_w = 34; 
		lcd_data = chars[34][7:0];
		lcd_rs = chars[34][8];
	end


endcase


always@(posedge clock_50 or negedge i_rst_N) begin

    if(!i_rst_N) begin
        state_r <= INIT;
        count_r <= 34;
        //count_r <= 0;

    end else begin 

        state_r <= state_w;
        count_r <= count_w;
        //count_r <= count_w;
        lcd_data <= chars[count_w][7:0]
        lcd_rs <= chars[count_w][8]
        
        
            
    end

end

localparam IDLE = 0;
localparam HOLD = 1;
localparam PLAY = 3;
localparam REC = 2;

case (i_state)

    IDLE: begin

        chars[0][8:0] = I;
        chars[1][8:0] = D;
        chars[2][8:0] = L;
        chars[3][8:0] = E;
        
        for (int i = 4; i < 16; ++i) begin
            chars[i][8:0] = Space;
        end
        chars[16][8:0] = 9'hC0;
        for (int i = 17; i < 33; ++i) begin
            chars[i][8:0] = Space;
        end
        chars[33][8:0] = 9'h80;
        
    end
    HOLD: begin
    
        chars[0][8:0] = H;
        chars[1][8:0] = O;
        chars[2][8:0] = L;
        chars[3][8:0] = D;    

        for (int i = 4; i < 16; ++i) begin
            chars[i][8:0] = Space;
        end
        chars[16][8:0] = 9'hC0;
        for (int i = 17; i < 33; ++i) begin
            chars[i][8:0] = Space;
        end
        chars[33][8:0] = 9'h80;
    
    
    end
    REC: begin
        
        chars[0][8:0] = R;
        chars[1][8:0] = E;
        chars[2][8:0] = C;
        for (int i = 3; i < 16; ++i) begin
            chars[i][8:0] = Space;
        end
        chars[16][8:0] = 9'hC0;
        
		case(i_sec)
			5'h0: begin chars[17][8:0] = D0; chars[18][8:0] = D0; end
			5'h1: begin chars[17][8:0] = D0; chars[18][8:0] = D1; end
			5'h2: begin chars[17][8:0] = D0; chars[18][8:0] = D2; end
			5'h3: begin chars[17][8:0] = D0; chars[18][8:0] = D3; end
			5'h4: begin chars[17][8:0] = D0; chars[18][8:0] = D4; end
			5'h5: begin chars[17][8:0] = D0; chars[18][8:0] = D5; end
			5'h6: begin chars[17][8:0] = D0; chars[18][8:0] = D6; end
			5'h7: begin chars[17][8:0] = D0; chars[18][8:0] = D7; end
			5'h8: begin chars[17][8:0] = D0; chars[18][8:0] = D8; end
			5'h9: begin chars[17][8:0] = D0; chars[18][8:0] = D9; end
			5'ha: begin chars[17][8:0] = D1; chars[18][8:0] = D0; end
			5'hb: begin chars[17][8:0] = D1; chars[18][8:0] = D1; end
			5'hc: begin chars[17][8:0] = D1; chars[18][8:0] = D2; end
			5'hd: begin chars[17][8:0] = D1; chars[18][8:0] = D3; end
			5'he: begin chars[17][8:0] = D1; chars[18][8:0] = D4; end
			5'hf: begin chars[17][8:0] = D1; chars[18][8:0] = D5; end
			//
			5'h10: begin chars[17][8:0] = D1; chars[18][8:0] = D6; end
			5'h11: begin chars[17][8:0] = D1; chars[18][8:0] = D7; end
			5'h12: begin chars[17][8:0] = D1; chars[18][8:0] = D8; end
			5'h13: begin chars[17][8:0] = D1; chars[18][8:0] = D9; end
			5'h14: begin chars[17][8:0] = D2; chars[18][8:0] = D0; end
			5'h15: begin chars[17][8:0] = D2; chars[18][8:0] = D1; end
			5'h16: begin chars[17][8:0] = D2; chars[18][8:0] = D2; end
			5'h17: begin chars[17][8:0] = D2; chars[18][8:0] = D3; end
			5'h18: begin chars[17][8:0] = D2; chars[18][8:0] = D4; end
			5'h19: begin chars[17][8:0] = D2; chars[18][8:0] = D5; end
			5'h1a: begin chars[17][8:0] = D2; chars[18][8:0] = D6; end
			5'h1b: begin chars[17][8:0] = D2; chars[18][8:0] = D7; end
			5'h1c: begin chars[17][8:0] = D2; chars[18][8:0] = D8; end
			5'h1d: begin chars[17][8:0] = D2; chars[18][8:0] = D9; end
			5'h1e: begin chars[17][8:0] = D3; chars[18][8:0] = D0; end
			5'h1f: begin chars[17][8:0] = D3; chars[18][8:0] = D1; end
			default: begin chars[17][8:0] = Space; chars[18][8:0] = Space; end
		endcase
        
        for (i = 19 ; i < 33; ++i) begin
            chars[i][8:0] = Space;
        end
        chars[33][8:0] = 9'h80;
        
        
    end
    PLAY: begin
        
        chars[0][8:0] = P;
        chars[1][8:0] = L;
        chars[2][8:0] = A;
        chars[3][8:0] = Y;      
        for (int i = 4 ; i < 16; ++i) begin
            chars[i][8:0] = Space;
        end
        chars[16][8:0] = 9'hC0;
		case(i_sec)
			5'h0: begin chars[17][8:0] = D0; chars[18][8:0] = D0; end
			5'h1: begin chars[17][8:0] = D0; chars[18][8:0] = D1; end
			5'h2: begin chars[17][8:0] = D0; chars[18][8:0] = D2; end
			5'h3: begin chars[17][8:0] = D0; chars[18][8:0] = D3; end
			5'h4: begin chars[17][8:0] = D0; chars[18][8:0] = D4; end
			5'h5: begin chars[17][8:0] = D0; chars[18][8:0] = D5; end
			5'h6: begin chars[17][8:0] = D0; chars[18][8:0] = D6; end
			5'h7: begin chars[17][8:0] = D0; chars[18][8:0] = D7; end
			5'h8: begin chars[17][8:0] = D0; chars[18][8:0] = D8; end
			5'h9: begin chars[17][8:0] = D0; chars[18][8:0] = D9; end
			5'ha: begin chars[17][8:0] = D1; chars[18][8:0] = D0; end
			5'hb: begin chars[17][8:0] = D1; chars[18][8:0] = D1; end
			5'hc: begin chars[17][8:0] = D1; chars[18][8:0] = D2; end
			5'hd: begin chars[17][8:0] = D1; chars[18][8:0] = D3; end
			5'he: begin chars[17][8:0] = D1; chars[18][8:0] = D4; end
			5'hf: begin chars[17][8:0] = D1; chars[18][8:0] = D5; end
			//
			5'h10: begin chars[17][8:0] = D1; chars[18][8:0] = D6; end
			5'h11: begin chars[17][8:0] = D1; chars[18][8:0] = D7; end
			5'h12: begin chars[17][8:0] = D1; chars[18][8:0] = D8; end
			5'h13: begin chars[17][8:0] = D1; chars[18][8:0] = D9; end
			5'h14: begin chars[17][8:0] = D2; chars[18][8:0] = D0; end
			5'h15: begin chars[17][8:0] = D2; chars[18][8:0] = D1; end
			5'h16: begin chars[17][8:0] = D2; chars[18][8:0] = D2; end
			5'h17: begin chars[17][8:0] = D2; chars[18][8:0] = D3; end
			5'h18: begin chars[17][8:0] = D2; chars[18][8:0] = D4; end
			5'h19: begin chars[17][8:0] = D2; chars[18][8:0] = D5; end
			5'h1a: begin chars[17][8:0] = D2; chars[18][8:0] = D6; end
			5'h1b: begin chars[17][8:0] = D2; chars[18][8:0] = D7; end
			5'h1c: begin chars[17][8:0] = D2; chars[18][8:0] = D8; end
			5'h1d: begin chars[17][8:0] = D2; chars[18][8:0] = D9; end
			5'h1e: begin chars[17][8:0] = D3; chars[18][8:0] = D0; end
			5'h1f: begin chars[17][8:0] = D3; chars[18][8:0] = D1; end
			default: begin chars[17][8:0] = Space; chars[18][8:0] = Space; end
        endcase
        
        for (int i = 19; i < 31) begin
            chars[i][8:0] = Space;
        end
        
        case(sw)
			5'b00000: begin chars[31][8:0] = NULL; chars[32][8:0] = NULL; end
			5'b00001: begin chars[31][8:0] = D0; chars[32][8:0] = D1; end
			5'b00010: begin chars[31][8:0] = D0; chars[32][8:0] = D2; end
			5'b00011: begin chars[31][8:0] = D0; chars[32][8:0] = D3; end
			5'b00100: begin chars[31][8:0] = D0; chars[32][8:0] = D4; end
			5'b00101: begin chars[31][8:0] = D0; chars[32][8:0] = D5; end
			5'b00110: begin chars[31][8:0] = D0; chars[32][8:0] = D6; end
			5'b00111: begin chars[31][8:0] = D0; chars[32][8:0] = D7; end
			5'b01000: begin chars[31][8:0] = D0; chars[32][8:0] = D8; end
			//
			5'b11000: begin chars[31][8:0] = D10; chars[32][8:0] = D8; end
			5'b11001: begin chars[31][8:0] = D10; chars[32][8:0] = D7; end
			5'b11010: begin chars[31][8:0] = D10; chars[32][8:0] = D6; end
			5'b11011: begin chars[31][8:0] = D10; chars[32][8:0] = D5; end
			5'b11100: begin chars[31][8:0] = D10; chars[32][8:0] = D4; end
			5'b11101: begin chars[31][8:0] = D10; chars[32][8:0] = D3; end
			5'b11110: begin chars[31][8:0] = D10; chars[32][8:0] = D2; end
			5'b11111: begin chars[31][8:0] = D0; chars[32][8:0] = D1; end
			default: begin chars[31][8:0] = NULL; chars[32][8:0] = NULL; end
		endcase
        
        chars[33][8:0] = 9'h80;
        
    end

	default: begin: 

		for (int i = 0; i < 16; ++i) begin
            chars[i][8:0] = Space;
        end
        chars[16][8:0] = 9'hC0;
        for (int i = 17; i < 33; ++i) begin
            chars[i][8:0] = Space;
        end
        chars[33][8:0] = 9'h80;
		
	end
endcase

localparam I = 9'b101001001;
localparam D = 9'b101000100;
localparam L = 9'b101001100;
localparam E = 9'b101000101;
localparam H = 9'b101001000;
localparam O = 9'b101001111;
localparam D = 9'b101000100;
localparam P = 9'b101010000;
localparam A = 9'b101000001;
localparam Y = 9'b101011001;
localparam R = 9'b101010010;
localparam C = 9'b101000011;
localparam Space = 9'b100100000;

localparam D0 = 9'b100110000;
localparam D1 = 9'b100110001;
localparam D2 = 9'b100110010;
localparam D3 = 9'b100110011;
localparam D4 = 9'b100110100;
localparam D5 = 9'b100110101;
localparam D6 = 9'b100110110;
localparam D7 = 9'b100110111;
localparam D8 = 9'b100111000;
localparam D9 = 9'b100111001;
localparam D10 = 9'b110110000;