module PLAY (
	input  i_start,		// 
	input  i_pause,		// pulse input
	input  [17:0] i_switch,
	output [19:0] o_SRAM_ADDR,
	input  signed [15:0] i_SRAM_DAT,
	output SRAM_CE_N,
	output SRAM_LB_N,
	output SRAM_OE_N,
	output SRAM_UB_N,
	output SRAM_WE_N,
	input  i_BCLK,
	output AUD_DACDAT,
	input  AUD_DACLRCK,
	input  i_rst,		// const 1, if 0 -> reset
	output o_finish,		// step output
	output datais0

);


//	logic [19:0] sraddr_r, sraddr_w;
	logic signed [15:0] data_r, data_w, DSP_data;
	logic [4:0]  bitctr_r, bitctr_w;
	logic dacdat_w, dacdat_r;
	logic [1:0] state_r, state_w;
	logic DSPload_r, DSPload_w, DSPpop_r, DSPpop_w;

DSP dsp1(
	.i_start(i_start),
	.i_switch(i_switch),
	.i_pause(i_pause),
	.o_SRAM_ADDR(o_SRAM_ADDR),
	.i_SRAM_DAT(i_SRAM_DAT),
	.o_SRAM_CE_N(SRAM_CE_N),	// 0
	.o_SRAM_LB_N(SRAM_LB_N),	// 0
	.o_SRAM_OE_N(SRAM_OE_N),	// 0
	.o_SRAM_UB_N(SRAM_UB_N),	// 0
	.o_SRAM_WE_N(SRAM_WE_N),	// 1
	.i_BCLK(i_BCLK),
	.i_load(DSPload_w),
	.i_pop(DSPpop_w),
	.o_outdata(DSP_data),
	.i_rst(i_rst),
	.o_full(o_finish)

);



	localparam TRANSFER_LEFT = 0;
	localparam TRANSFER_RIGHT = 1;
	localparam PAUSE = 2;
	
	

	//assign daclrck_w = AUD_DACLRCK;
	
	assign AUD_DACDAT = dacdat_w;	//srdat_r[15];
	
/*	
sraddr_r <= sraddr_w;
srdat_r <= srdat_w;
bitctr_r <= bitctr_w;
daclrck_r <= daclrck_w;
dacdat_r <= dacdat_w;
state_r <= state_w;
*/

	
	
always_comb begin

if(i_SRAM_DAT == 0) datais0 = 1;
else datais0 = 0;

	if(i_start) begin
		state_w = 0;
		bitctr_w = 0;
		dacdat_w = 0;
		data_w = 0;
		DSPpop_w = 0;
		DSPload_w = 0;
	end else if(o_finish) begin
		state_w = 0;
		bitctr_w = 0;
		dacdat_w = 0;
		data_w = 0;
		DSPpop_w = 0;
		DSPload_w = 0;
	end else begin
		case (state_r)
			TRANSFER_LEFT: begin
				if(AUD_DACLRCK) begin
					state_w = TRANSFER_RIGHT;
					bitctr_w = 0;
					dacdat_w = 0;
					data_w = DSP_data;//newdata;
					DSPpop_w = 1;
					DSPload_w = 0;
				end else if(i_pause) begin
					state_w = PAUSE;
					bitctr_w = 0;
					dacdat_w = 0;
					data_w = 0;//newdata;
					DSPpop_w = 1;
					DSPload_w = 0;
				end else begin
					state_w = TRANSFER_LEFT;
					data_w = data_r << 1;
					DSPpop_w = 0;
					DSPload_w = 0;
					if(bitctr_r[4]) begin 
						bitctr_w = bitctr_r;
						dacdat_w = 0;
					end else begin 
						bitctr_w = bitctr_r + 1;
						dacdat_w = data_r[15];
					end
				end
			end
			TRANSFER_RIGHT: begin
				if(!AUD_DACLRCK) begin
					state_w = TRANSFER_LEFT;
					bitctr_w = 0;
					dacdat_w = 0;
					data_w = DSP_data;//newdata;
					DSPpop_w = 0;
					DSPload_w = 0;
				end else if(i_pause) begin
					state_w = PAUSE;
					bitctr_w = 0;
					dacdat_w = 0;
					data_w = 0;//newdata;
					DSPpop_w = 1;
					DSPload_w = 0;
				end else begin
					state_w = TRANSFER_RIGHT;
					data_w = data_r << 1;
					DSPpop_w = 0;
					DSPload_w = 0;
					if(bitctr_r[4]) begin 
						bitctr_w = bitctr_r;
						dacdat_w = 0;
					end else begin 
						bitctr_w = bitctr_r + 1;
						dacdat_w = data_r[15];
					end
				end
			end
			PAUSE: begin
				if(i_pause) begin	
					state_w = AUD_DACLRCK;
					bitctr_w = 0;
					dacdat_w = 0;
					data_w = DSP_data;//newdata;
					DSPpop_w = 0;
					DSPload_w = 0;
				end else begin
					state_w = PAUSE;
					bitctr_w = 0;
					dacdat_w = 0;
					data_w = 0;//newdata;
					DSPpop_w = 0;
					DSPload_w = 0;
				end
			end
			default: begin
					state_w = 0;
					bitctr_w = 0;
					dacdat_w = 0;
					data_w = 0;//newdata;
					DSPpop_w = 0;
					DSPload_w = 0;
			end
		endcase
	end
end



	always_ff @(negedge i_BCLK or negedge i_rst) begin
		if(!i_rst)begin
			data_r <= 0;
			bitctr_r <= 0;
			dacdat_r <= 0;
			state_r <= 0;
			DSPpop_r <= 0;
			DSPload_r <= 0;
		end else begin
			data_r <= data_w;
			bitctr_r <= bitctr_w;
			dacdat_r <= dacdat_w;
			state_r <= state_w;
			DSPpop_r <= DSPpop_w;
			DSPload_r <= DSPload_r;			
		end
	end

endmodule
