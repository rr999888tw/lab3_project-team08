module Record(
	input i_start,     //綜p撠
	input i_adclrc, ////???????????????????????????/
	input i_bclk,   ////12MHz
	input i_dat,    ////f is 12MHz from top
	input i_rst,
	//input i_finish, ///雓函膩謖/////////////////////泅et橫
	//////////sram part////////////
	output o_we,
	output o_ce,
	output o_oe,
	output o_lb,
	output o_ub,
	output o_finish, /////鉉it e謍圈    
	output [15:0]o_dat,  ///output to sram
	output [19:0]o_addr,
	output recdatais0
);

	localparam IDLE = 0;
	localparam WAIT = 1;
	localparam RECEIVE = 2;
	localparam RECORD = 3;

	logic [1:0] state_r, state_w;
	logic [4:0] counter_r, counter_w;  //count to 16
	logic [19:0] tcount_r, tcount_w;   //count to stop
	//logic finish_r, finish_w;
	logic [15:0] buffer_r, buffer_w;
	logic half_cycle_r, half_cycle_w;
	logic we_r, we_w;
	logic ce_r, ce_w;      ////new
	logic [15:0] sramdat_r, sramdat_w;
	logic [19:0] addr_r, addr_w;
	logic finish_r, finish_w;
	
	//assign o_finish = finish_r;
	assign o_dat = sramdat_r;
	assign o_ce = 0;
	assign o_ib = 0;
	assign o_ub = 0;
	assign o_oe = 1;    ///in fact this is "don't care" in write mode
	assign o_we = we_r;
	assign o_addr = addr_r;
	assign o_finish = finish_r;
 

	always_comb begin
	
	if(o_dat == 0) recdatais0 = 1;
	else recdatais0 = 0;
	
		case(state_r)
			IDLE: begin
				if(i_start) begin
					if(!i_adclrc) begin
						state_w = WAIT;
						counter_w = 0;
					//	finish_w = 0;
						buffer_w = buffer_r;
						half_cycle_w = 0;
						we_w = we_r;	
						sramdat_w = sramdat_r;
						addr_w = addr_r; 
						tcount_w = tcount_r;
						finish_w = 0;
						ce_w = ce_r;////////////////////////
					end else begin
						state_w = WAIT;
						counter_w = 0;
					//	finish_w = 0;
						buffer_w = buffer_r;
						half_cycle_w = 1;
						we_w = we_r;
						sramdat_w = sramdat_r;
						addr_w = addr_r;
						tcount_w = tcount_r; 
						finish_w = 0;
						ce_w = ce_r;
					end
				end else begin
					state_w = IDLE;
					counter_w = counter_r;
				//	finish_w = finish_r;
					buffer_w = buffer_r;
					half_cycle_w = half_cycle_r;
					we_w = we_r;
					sramdat_w = sramdat_r;
					addr_w = addr_r; 
					tcount_w = tcount_r; 
					finish_w = 0;
					ce_w = ce_r;
				end
			end
			WAIT: begin                                 /////蝘剝璁dclrc嚚伐蹎喇肅怎鞊舀迫朣CD
				if(half_cycle_r) begin
					if(!i_adclrc) begin
						state_w = RECEIVE;
						counter_w = counter_r;
						//finish_w = 0;
						buffer_w = buffer_r;
						half_cycle_w = 0;
						we_w = we_r;
						sramdat_w = sramdat_r;
						addr_w = addr_r;
						tcount_w = tcount_r; 
						finish_w = 0;
						ce_w = ce_r;
					end else begin
						state_w = WAIT;
						counter_w = counter_r;
						//finish_w = 0;
						buffer_w = buffer_r;
						half_cycle_w = half_cycle_r;
						we_w = we_r;
						sramdat_w = sramdat_r;	
						addr_w = addr_r;
						tcount_w = tcount_r; 
						finish_w = 0;
						ce_w = ce_r;
					end
				end else begin
					if(i_adclrc) begin
						state_w = RECEIVE;
						counter_w = counter_r;
						//finish_w = 0;
						buffer_w = buffer_r;
						half_cycle_w = 1;
						we_w = we_r;
						sramdat_w = sramdat_r;
						addr_w = addr_r;
						tcount_w = tcount_r; 
						finish_w = 0;
						ce_w = ce_r;
					end else begin
						state_w = WAIT;
						counter_w = counter_r;
						//finish_w = 0;
						buffer_w = buffer_r;
						half_cycle_w = half_cycle_r;
						we_w = we_r;
						sramdat_w = sramdat_r;
						addr_w = addr_r;
						tcount_w = tcount_r; 
						finish_w = 0;
						ce_w = ce_r;
					end
				end	

			end
			RECEIVE: begin
				if(counter_r && (counter_r)%16 == 0) begin  ////銵制頩adclrc豲航曈湔//// 蝘雿的
					state_w = RECORD;
					counter_w = counter_r;
					//finish_w = 1;
					buffer_w = (buffer_r<<1) + i_dat;
					half_cycle_w = half_cycle_r;
					we_w = 0;
					sramdat_w = sramdat_r;	
					addr_w = addr_r;
					tcount_w = tcount_r; 
					finish_w = 0;
					ce_w = 0;
				end else begin
					state_w = RECEIVE;
					counter_w = counter_r + 1;
					//finish_w = 0;
					buffer_w = (buffer_r<<1) + i_dat;////////////MSB first
					half_cycle_w = half_cycle_r;
					we_w  = we_r;
					sramdat_w = sramdat_r;
					addr_w = addr_r;
					tcount_w = tcount_r; 
					finish_w = 0;
					ce_w = ce_r;
				end
				
			end
			RECORD: begin	
				if(!i_adclrc) begin
					if(tcount_r == 20'b11111111111111111111) begin
						state_w = IDLE;
						counter_w = 0;
						//finish_w = 1;
						buffer_w = 0;
						half_cycle_w = half_cycle_r;
						we_w = 1;
						sramdat_w = buffer_r;
						addr_w = 0;
						tcount_w = 0;    /////嗅2^20甈⊥敺飛0
						finish_w = 1;
						ce_w = 1;
					end else begin
						state_w = WAIT;
						counter_w = 0;
						//finish_w = 1;
						buffer_w = 0;
						half_cycle_w = half_cycle_r;
						we_w = 1;
						sramdat_w = buffer_r;
						addr_w = addr_r + 1;
						tcount_w = tcount_r+1;
						finish_w = 0;
						ce_w = 1;
					end 
				end else begin
					state_w = WAIT;
					counter_w = 0;
					//finish_w = 1;
					buffer_w = 0;
					half_cycle_w = half_cycle_r;
					we_w = 1;
					sramdat_w = sramdat_r;
					addr_w = addr_r;
					tcount_w = tcount_r; 
					finish_w = 0;
					ce_w = 1;
				end  
			end
				
		endcase
	end
	
	always_ff @(negedge i_bclk or negedge i_rst)begin
		if(!i_rst)begin
			state_r <= IDLE;
			counter_r <= 0;
			//finish_r <= 0;
			buffer_r <= 0;
			half_cycle_r <= 0;
			we_r <= 1;
			sramdat_r <= 0;
			addr_r <= 0;
			tcount_r <= 0;
			finish_r <= 0;
			ce_r <= 1;
		end else begin
			state_r <= state_w;
			counter_r <= counter_w;
			//finish_r <= finish_w;
			buffer_r <= buffer_w;
			half_cycle_r <= half_cycle_w;
			we_r <= we_w;
			sramdat_r <= sramdat_w;
			addr_r <= addr_w;
			tcount_r <= tcount_w;
			finish_r <= finish_w;
			ce_r <= ce_w;
		end
	end
endmodule





