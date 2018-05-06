
module DSP (
	input  i_rst,
	input  i_start,
	input  i_pause,
	input  [17:0] i_switch,
	output [19:0] o_SRAM_ADDR,
	input  signed [15:0] i_SRAM_DAT,
	output o_SRAM_CE_N,	// 0
	output o_SRAM_LB_N,	// 0
	output o_SRAM_OE_N,	// 0
	output o_SRAM_UB_N,	// 0
	output o_SRAM_WE_N,	// 1
	input  i_BCLK,
	input  i_load,
	input  i_pop,
	output [15:0] o_outdata,
	output o_full
	

);

localparam SLOW = 0;
localparam FAST = 1;
//localparam MAXCOUNT = maxcount - 1;
localparam ZEROINTER = 0;
localparam ONEINTER  = 1;
localparam FREQUP = 0;
localparam SPEEDUP = 1;

logic [9:0] speedupcount_r, speedupcount_w;
logic signed [5:0] speed_r, speed_w, count_r, count_w, maxcount;
logic signed [15:0] data_r, data_w, nextdata_r, nextdata_w, add_data_r, add_data_w;
logic [19:0] addr_r, addr_w;
logic full_r, full_w;


assign o_SRAM_CE_N = 0; // 0
assign o_SRAM_LB_N = 0;	// 0
assign o_SRAM_OE_N = 0;	// 0
assign o_SRAM_UB_N = 0;	// 0
assign o_SRAM_WE_N = 1;	// 1
//assign fastslow = i_switch[0];
assign o_outdata = data_r;
assign o_SRAM_ADDR = addr_r+1;
assign o_full = full_r;




always_comb begin

if(i_switch[8]) begin speed_w = 8; maxcount = 7; end
else if(i_switch[7]) begin speed_w = 7; maxcount = 6; end
else if(i_switch[6]) begin speed_w = 6; maxcount = 5; end
else if(i_switch[5]) begin speed_w = 5; maxcount = 4; end
else if(i_switch[4]) begin speed_w = 4; maxcount = 3; end
else if(i_switch[3]) begin speed_w = 3; maxcount = 2; end
else if(i_switch[2]) begin speed_w = 2; maxcount = 1; end
else begin speed_w = 1; maxcount = 0; end



data_w = data_r;
nextdata_w = nextdata_r;
addr_w = addr_r;
count_w = count_r;
add_data_w = add_data_r;
speedupcount_w = speedupcount_r;

	if(i_start) begin
		data_w = 1;
		nextdata_w = i_SRAM_DAT;
		addr_w = 0;
		count_w = 0;
		add_data_w = 0;
		full_w = 0;
		speedupcount_w = 0;
	end else if(addr_r > 32000*32+1000) begin
		data_w = data_r;
		nextdata_w = nextdata_r;
		addr_w = addr_r;
		count_w = count_r;
		add_data_w = add_data_r;
		full_w = 1;
		speedupcount_w = speedupcount_r;
	end else begin
		case(i_switch[17])
			SLOW: begin
				case(i_switch[0]) 
					ZEROINTER: begin
						if(i_load | i_pop) begin
							if(count_r == maxcount) begin
								if(i_pop) addr_w = addr_r + 1;
								else addr_w = addr_r;
								count_w = 0;
								data_w = nextdata_r;
								nextdata_w = i_SRAM_DAT;
								add_data_w = add_data_r;
								full_w = 0;
								speedupcount_w = 0;
							end else begin
								data_w = data_r;
								nextdata_w = nextdata_r;
								addr_w = addr_r;
								count_w = count_r + 1;
								add_data_w = add_data_r;
								full_w = 0;
								speedupcount_w = 0;
							end
						end else begin
							data_w = data_r;
							nextdata_w = nextdata_r;
							addr_w = addr_r;
							count_w = count_r;
							add_data_w = add_data_r;
							full_w = 0;
							speedupcount_w = 0;
						end
					end
					ONEINTER: begin
						if(i_load | i_pop) begin
							
							if(count_r == maxcount) begin
								if(i_pop) addr_w = addr_r + 1;
								else addr_w = addr_r;
								count_w = 0;
								data_w = nextdata_r;
								nextdata_w = i_SRAM_DAT;
								add_data_w = (i_SRAM_DAT - nextdata_r)/speed_r;
								full_w = 0;
								speedupcount_w = 0;
							end else begin
								if(i_pop) data_w = data_r + add_data_r;
								else data_w = data_r;
								count_w = count_r + 1;
								addr_w = addr_r;
								nextdata_w = nextdata_r;
								add_data_w = add_data_r;
								full_w = 0;
								speedupcount_w = 0;
							end
						
						end
						else begin
							data_w = data_r;
							nextdata_w = nextdata_r;
							addr_w = addr_r;
							count_w = count_r;
							add_data_w = add_data_r;
							full_w = 0;
							speedupcount_w = 0;
						end
					end
				endcase
			end
			FAST: begin
				case(i_switch[0]) 
					FREQUP: begin
						if(i_load | i_pop) begin
							if(i_pop) addr_w = addr_r + speed_r - 1;
							else addr_w = addr_r;
							data_w = nextdata_r;
							nextdata_w = i_SRAM_DAT;
							count_w = 0;
							add_data_w = add_data_r;
							full_w = 0;
							speedupcount_w = speedupcount_r;
						end
						else begin
							data_w = data_r;
							nextdata_w = i_SRAM_DAT;
							addr_w = addr_r;
							count_w = 0;
							add_data_w = add_data_r;
							full_w = 0;
							speedupcount_w = speedupcount_r;
						end
					end
					SPEEDUP: begin
						if(i_load | i_pop) begin
							if(i_pop) begin 
								if(speedupcount_r == 1023) begin 
									speedupcount_w = 0;
									addr_w = addr_r + 1024*maxcount;
								end else begin
									speedupcount_w = speedupcount_r + 1;
									addr_w = addr_r + 1;
								end
							end else begin 
								addr_w = addr_r;
								speedupcount_w = speedupcount_r;
							end
							data_w = nextdata_r;
							nextdata_w = i_SRAM_DAT;
							count_w = 0;
							add_data_w = add_data_r;
							full_w = 0;
						end
						else begin
							data_w = data_r;
							nextdata_w = i_SRAM_DAT;
							addr_w = addr_r;
							count_w = 0;
							add_data_w = add_data_r;
							full_w = 0;
							speedupcount_w = speedupcount_r;
						end
					end
				endcase
			end
		endcase
	end
	
	
	
end




	always_ff @(posedge i_BCLK or negedge i_rst) begin
		if(!i_rst)begin
			data_r <= 0;
			nextdata_r <= 0;
			addr_r <= 1;
			count_r <= 0;
			speed_r <= 1;
			add_data_r <= 0;
			full_r <= 0;
			speedupcount_r <= 0;
		end else begin
			data_r <= data_w;
			nextdata_r <= nextdata_w;
			addr_r <= addr_w;
			count_r <= count_w;
			speed_r <= speed_w;
			add_data_r <= add_data_w;
			full_r <= full_w;
			speedupcount_r <= speedupcount_w;
		end
	end

endmodule

