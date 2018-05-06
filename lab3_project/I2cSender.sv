module I2cSender (
	input i_start,
	input [23:0] i_dat,
	input i_clk,
	input i_rst,
	output o_finished,
	output o_sclk,
	inout o_sdat
);	
	localparam IDLE = 0;
	localparam BEGIN = 1;
	localparam  TRANSMIT = 2;
	localparam	END = 3;
	
	logic sdat_r, sdat_w;
	logic finish_r, finish_w;
	
	assign o_sdat = sdat_r;
	
	assign o_finished = finish_r;
				
	logic [1:0] state_r, state_w;	// 4 states
	logic beginCounter_r, beginCounter_w;
	logic [1:0] transmitCounter_r, transmitCounter_w; 
	logic [3:0] eightCounter_r, eightCounter_w;
	logic [1:0] ackCounter_r, ackCounter_w;
	logic endCounter_r, endCounter_w;
	logic [23:0] data_r, data_w;
	
	sclkGenerate sclk(
		.i_start(i_start),
		.i_clk(i_clk),
		.i_rst(i_rst),
		.i_end(state_r),
		.o_sclk(o_sclk)
	);	
	
			
	always_comb begin
	state_w = state_r;
	sdat_w = sdat_r;
	data_w = data_r;
	eightCounter_w = eightCounter_r;
	ackCounter_w = ackCounter_r;
	finish_w = finish_r;
	beginCounter_w = beginCounter_r;
	transmitCounter_w = transmitCounter_r;
	endCounter_w = endCounter_r;
		case(state_r)
			IDLE: begin			
				if(i_start)begin
					state_w = BEGIN;
					sdat_w = 0;
					data_w = i_dat;
					eightCounter_w = 0;
					ackCounter_w = 0;
					finish_w = 0;
					beginCounter_w = 0;
					transmitCounter_w = 0;
					endCounter_w = 0;					
					
				end else begin
					state_w = IDLE;
					sdat_w = 1;
					data_w = 0;
					eightCounter_w = 0;
					ackCounter_w = 0;
					finish_w = 0;					
					beginCounter_w = 0;
					transmitCounter_w = 0;
					endCounter_w = 0;					
				end		
			end
			
			BEGIN: begin
				if(beginCounter_r == 0)begin
					state_w = BEGIN;
					sdat_w = 0;
					data_w = data_r;
					eightCounter_w = 0;
					ackCounter_w = 0;
					finish_w = 0;
					beginCounter_w = 1;
					transmitCounter_w = 0;
					endCounter_w = 0;
					
					
				end else if(beginCounter_r == 1)begin
					state_w = TRANSMIT;
					sdat_w = data_r[23];
					data_w = data_r << 1;
					eightCounter_w = 1;
					ackCounter_w = 0;
					finish_w = 0;
					beginCounter_w = 0;
					transmitCounter_w = 1;
					endCounter_w = 0;					
				end 
			end
			
			TRANSMIT: begin
				if( transmitCounter_r != 3 )begin				
					state_w = TRANSMIT;
					sdat_w = sdat_r;
					data_w = data_r;
					eightCounter_w = eightCounter_r;
					ackCounter_w = ackCounter_r;
					finish_w = 0;
					beginCounter_w = 0;
					transmitCounter_w = transmitCounter_r + 1;
					endCounter_w = 0;
				end else if((eightCounter_r != 8) && (ackCounter_r != 3) )begin //next bit
					state_w = TRANSMIT;
					sdat_w = data_r[23];
					data_w = data_r << 1;
					eightCounter_w = eightCounter_r + 1;
					ackCounter_w = ackCounter_r;
					finish_w = 0;
					beginCounter_w = 0;
					transmitCounter_w = 1;
					endCounter_w = 0;
				end else if((eightCounter_r == 8) && (ackCounter_r != 3) )begin //enter ack
					state_w = TRANSMIT;
					sdat_w = 1'bz;
					data_w = data_r;
					eightCounter_w = 0;
					ackCounter_w = ackCounter_r + 1;
					finish_w = 0;
					beginCounter_w = 0;
					transmitCounter_w = 1;
					endCounter_w = 0;
				end else if((eightCounter_r == 0) && (ackCounter_r != 3) )begin
					state_w = TRANSMIT;
					sdat_w = data_r[23];
					data_w = data_r << 1;
					eightCounter_w = 1;
					ackCounter_w = ackCounter_r;
					finish_w = 0;
					beginCounter_w = 0;
					transmitCounter_w = 1;
					endCounter_w = 0;
				end else if((eightCounter_r == 0) && (ackCounter_r == 3) )begin
					state_w = END;
					sdat_w = 0;
					data_w = 0;
					eightCounter_w = 0;
					ackCounter_w = 0;
					finish_w = 0;
					beginCounter_w = 0;
					transmitCounter_w = 0;
					endCounter_w = 0;
				end 
			end
			
			END: begin
				if(endCounter_r == 0)begin
					state_w = END;
					sdat_w = 0;
					data_w = 0;
					eightCounter_w = 0;
					ackCounter_w = 0;
					finish_w = 0;
					beginCounter_w = 0;
					transmitCounter_w = 0;
					endCounter_w = 1;
				end else if(endCounter_r == 1)begin
					state_w = IDLE;
					sdat_w = 1;
					data_w = 0;
					eightCounter_w = 0;
					ackCounter_w = 0;
					finish_w = 1;
					beginCounter_w = 0;
					transmitCounter_w = 0;
					endCounter_w = 0;
				end
			end			
			
		endcase
	end
	
	always_ff @(posedge i_clk or negedge i_rst) begin
		if(!i_rst) begin
			state_r <= IDLE;
			sdat_r <= 1;
			data_r <= 0;
			eightCounter_r <= 0;
			ackCounter_r <= 0;
			finish_r <= 0;
			beginCounter_r <= 0;
			transmitCounter_r <= 0;
			endCounter_r <= 0;
		end else begin
			state_r <= state_w;
			sdat_r <= sdat_w;
			data_r <= data_w;
			eightCounter_r <= eightCounter_w;
			ackCounter_r <= ackCounter_w;
			finish_r <= finish_w;
			beginCounter_r <= beginCounter_w;
			transmitCounter_r <= transmitCounter_w;
			endCounter_r <= endCounter_w;
		end
	end
					
endmodule



module sclkGenerate(
	input i_start,
	input i_clk,
	input i_rst,
	input [1:0] i_end,
	output o_sclk
);	

	logic sclk_r, sclk_w;
	assign o_sclk = sclk_r;
	logic [1:0] sclk_counter_r, sclk_counter_w;
	
	always_comb begin
	sclk_w = sclk_r;
	sclk_counter_w = sclk_counter_r;
		if(i_start)begin
			sclk_w = 1;
			sclk_counter_w = 1;	
		end else if(i_end == 3)begin
			sclk_w = 1;
			sclk_counter_w = 0;			
		end else if(i_end != 3)begin
			if(sclk_counter_r == 1)begin
				sclk_w = 0;
				sclk_counter_w = 2;
			end else if(sclk_counter_r == 2)begin
				sclk_w = 0;
				sclk_counter_w = 3;
			end else if(sclk_counter_r == 3)begin
				sclk_w = 1;
				sclk_counter_w = 1;
			end else if(sclk_counter_r == 0)begin
				sclk_w = 1;
				sclk_counter_w = 0;	
			end
		end	
	end
	
	always_ff @(posedge i_clk or negedge i_rst) begin
		if(!i_rst) begin
			sclk_r <= 1;
			sclk_counter_r <= 0;
		end else begin
			sclk_r <= sclk_w;
			sclk_counter_r <= sclk_counter_w;
		end
	end
	
endmodule
