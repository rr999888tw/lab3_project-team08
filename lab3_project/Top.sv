module Top(
	input clk, //bclk input
	input key1, //reset top module
	input key2, //start top module
	input key3,
	
	input [17:0] switch,
	input ADCLRC,
	input DACLRC,
	input ADCDAT,
	output DACDAT,
	output SRAM_CE_N,
	output SRAM_LB_N,
	output SRAM_OE_N,
	output SRAM_UB_N,
	output SRAM_WE_N,
	output [19:0]SRAM_ADDR,
	inout [15:0]SRAM_DAT,
	output PLAY_FINISH,
	output REC_FINISH,
	output [2:0] o_state,
	output playdatais0,
	output recdatais0,
	output [15:0] o_dispdata
);
	localparam IDLE = 0;
	localparam HOLD = 1;
	localparam RECORD = 2;
	localparam PLAY = 3;
	localparam PAUSE = 4;
	logic [2:0] state_r, state_w;	
	wire RECORD_CE;
	wire RECORD_LB;
	wire RECORD_OE;
	wire RECORD_UB;
	wire RECORD_WE;
	wire PLAY_CE;
	wire PLAY_LB;
	wire PLAY_OE;
	wire PLAY_UB;
	wire PLAY_WE;
	logic [19:0] RECORD_addr;
	logic [15:0] RECORD_data;
	logic [19:0] PLAY_addr;
	logic [15:0] PLAY_data;	
	logic record_rst_r, record_rst_w;
	logic record_start_r, record_start_w;
	logic play_pause_r, play_pause_w;
	logic play_rst_r, play_rst_w;
	logic play_start_r, play_start_w;
	
	logic rec_finish, play_finish;
	assign REC_FINISH = rec_finish;
	assign PLAY_FINISH = play_finish;
	
	assign o_state = state_r;
	
	Record r1(
		.i_start(record_start_r),
		.i_adclrc(ADCLRC),
		.i_bclk(clk),
		.i_dat(ADCDAT),
		.i_rst(record_rst_r),
		.o_we(RECORD_WE),
		.o_ce(RECORD_CE),
		.o_oe(RECORD_OE),
		.o_lb(RECORD_LB),
		.o_ub(RECORD_UB),
		.o_dat(RECORD_data),
		.o_addr(RECORD_addr),
		.o_finish(rec_finish),
		.recdatais0(recdatais0)
	);
	
	PLAY p1(
		.i_start(play_start_r),
		.i_pause(play_pause_r),
		.i_switch(switch),
		.o_SRAM_ADDR(PLAY_addr),
		.i_SRAM_DAT(PLAY_data),
		.SRAM_CE_N(PLAY_CE),
		.SRAM_LB_N(PLAY_LB),
		.SRAM_OE_N(PLAY_OE),
		.SRAM_UB_N(PLAY_UB),
		.SRAM_WE_N(PLAY_WE),
		.i_BCLK(clk),
		.AUD_DACDAT(DACDAT),
		.AUD_DACLRCK(DACLRC),
		.i_rst(play_rst_r),
		.o_finish(play_finish),
		.datais0(playdatais0)
	);
	
	assign SRAM_DAT = SRAM_OE_N ? RECORD_data : 1'bz;
	assign PLAY_data = (!SRAM_OE_N)? SRAM_DAT : 1'bz;
	//assign o_dispdata = SRAM_OE_N ? RECORD_data : SRAM_DAT;
	
	
	always_comb begin
		
		case(state_r)
			IDLE: begin
				if(key2)begin
					state_w = HOLD;
					record_start_w = 0;
					record_rst_w = 0;
					play_start_w = 0;
					play_rst_w = 0;
					play_pause_w = 0;
					SRAM_CE_N = 1;   ////Unable the sram
					SRAM_LB_N = 0;
					SRAM_OE_N = 0;
					SRAM_UB_N = 0;
					SRAM_WE_N = 0;
					SRAM_ADDR = 0;
					//SRAM_DAT = 0;
				end else begin
					state_w =IDLE;
					record_start_w = 0;
					record_rst_w = 1;
					play_start_w = 0;
					play_rst_w = 1;
					play_pause_w = 0;
					SRAM_CE_N = 1;      ////Unable the sram
					SRAM_LB_N = 0;
					SRAM_OE_N = 0;
					SRAM_UB_N = 0;
					SRAM_WE_N = 0;
					SRAM_ADDR = 0;
					//SRAM_DAT = 0;
				end				
			end			
			HOLD: begin
				if(key2)begin
					state_w = RECORD; //start record			
					record_start_w = 1;
					record_rst_w = 1;
					play_start_w = 0;
					play_rst_w = 1;
					play_pause_w = 0;
					SRAM_CE_N = RECORD_CE;
					SRAM_LB_N = RECORD_LB;
					SRAM_OE_N = RECORD_OE;
					SRAM_UB_N = RECORD_UB;
					SRAM_WE_N = RECORD_WE;
					SRAM_ADDR = RECORD_addr;
					//SRAM_DAT = RECORD_data;
				end else if(key3)begin //start play
					state_w = PLAY;					
					record_start_w = 0;
					record_rst_w = 1;
					play_start_w = 1;
					play_rst_w = 1;
					play_pause_w = 0;
					SRAM_CE_N = PLAY_CE;
					SRAM_LB_N = PLAY_LB;
					SRAM_OE_N = PLAY_OE;
					SRAM_UB_N = PLAY_UB;
					SRAM_WE_N = PLAY_WE;
					SRAM_ADDR = PLAY_addr;
					//SRAM_DAT = PLAY_data;
				end else begin
					state_w = HOLD;					
					record_start_w = 0;
					record_rst_w = 1;
					play_start_w = 0;
					play_rst_w = 1;
					play_pause_w = 0;
					SRAM_CE_N = 0;
					SRAM_LB_N = 0;
					SRAM_OE_N = 0;
					SRAM_UB_N = 0;
					SRAM_WE_N = 0;
					SRAM_ADDR = 0;
					//SRAM_DAT = 0;
				end			
			end
			RECORD: begin
				if(key2)begin //stop record
					state_w = HOLD;					
					record_start_w = 0;
					record_rst_w = 0;
					play_start_w = 0;
					play_rst_w = 1;
					play_pause_w = 0;
					SRAM_CE_N = 0;
					SRAM_LB_N = 0;
					SRAM_OE_N = 0;
					SRAM_UB_N = 0;
					SRAM_WE_N = 0;
					SRAM_ADDR = 0;
					//SRAM_DAT = 0;
				end else if(rec_finish)begin
					state_w = HOLD;					
					record_start_w = 0;
					record_rst_w = 0;
					play_start_w = 0;
					play_rst_w = 1;
					play_pause_w = 0;
					SRAM_CE_N = 0;
					SRAM_LB_N = 0;
					SRAM_OE_N = 0;
					SRAM_UB_N = 0;
					SRAM_WE_N = 0;
					SRAM_ADDR = 0;
					//SRAM_DAT = 0;
				end else begin
					state_w = RECORD;					
					record_start_w = 0;
					record_rst_w = 1;
					play_start_w = 0;
					play_rst_w = 1;
					play_pause_w = 0;
					SRAM_CE_N = RECORD_CE;
					SRAM_LB_N = RECORD_LB;
					SRAM_OE_N = RECORD_OE;
					SRAM_UB_N = RECORD_UB;
					SRAM_WE_N = RECORD_WE;
					SRAM_ADDR = RECORD_addr;
					//SRAM_DAT = RECORD_data;
				end
			end
			PLAY: begin				
				if(key3 || play_finish)begin //go to hold
					state_w = HOLD;					
					record_start_w = 0;
					record_rst_w = 1;
					play_start_w = 0;
					play_rst_w = 0;
					play_pause_w = 0;
					SRAM_CE_N = 0;
					SRAM_LB_N = 0;
					SRAM_OE_N = 0;
					SRAM_UB_N = 0;
					SRAM_WE_N = 0;
					SRAM_ADDR = 0;
					//PLAY_data = SRAM_DAT;
				end else if(key2) begin
					state_w = PAUSE;					
					record_start_w = 0;
					record_rst_w = 1;
					play_start_w = 0;
					play_rst_w = 1;
					play_pause_w = 1;
					SRAM_CE_N = PLAY_CE;
					SRAM_LB_N = PLAY_LB;
					SRAM_OE_N = PLAY_OE;
					SRAM_UB_N = PLAY_UB;
					SRAM_WE_N = PLAY_WE;
					SRAM_ADDR = PLAY_addr;
					//PLAY_data = SRAM_DAT;
				end else begin
					state_w = PLAY;					
					record_start_w = 0;
					record_rst_w = 1;
					play_start_w = 0;
					play_rst_w = 1;
					play_pause_w = 0;
					SRAM_CE_N = PLAY_CE;
					SRAM_LB_N = PLAY_LB;
					SRAM_OE_N = PLAY_OE;
					SRAM_UB_N = PLAY_UB;
					SRAM_WE_N = PLAY_WE;
					SRAM_ADDR = PLAY_addr;
					//PLAY_data = SRAM_DAT;
				end
			end
			PAUSE: begin
					if(key2) begin
						state_w = PLAY;	
						play_pause_w = 1;
					end else begin
						state_w = PAUSE;	
						play_pause_w = 0;					
					end
					record_start_w = 0;
					record_rst_w = 1;
					play_start_w = 0;
					play_rst_w = 1;
					SRAM_CE_N = PLAY_CE;
					SRAM_LB_N = PLAY_LB;
					SRAM_OE_N = PLAY_OE;
					SRAM_UB_N = PLAY_UB;
					SRAM_WE_N = PLAY_WE;
					SRAM_ADDR = PLAY_addr;
			end
		endcase
	end
	always_ff @(posedge clk or negedge key1) begin
		if(!key1)begin
			state_r <= IDLE;			
			record_start_r <= 0;
			record_rst_r <= 0;
			play_start_r <= 0;
			play_rst_r <= 0;
			play_pause_r <= 0;
			
		end else begin
			state_r <= state_w;			
			record_start_r <= record_start_w;
			record_rst_r <= record_rst_w;
			play_start_r <= play_start_w;
			play_rst_r <= play_rst_w;
			play_pause_r <= play_pause_w;			
		
		end
	end
endmodule
	
	