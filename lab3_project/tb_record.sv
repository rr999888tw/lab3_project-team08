`timescale 1ns/100ps
//`define CYCLE = 10;

module tb_Record();

	localparam CYCLE = 24;
	localparam CYCLE1 = 960;

	logic i_start, i_adclrc, i_bclk, i_dat, i_rst;

	wire o_we, o_ce, o_oe, o_ib, o_ub;
	logic [15:0] o_dat;
	logic [19:0] o_addr; 

	always begin 
		#(CYCLE/2) i_bclk = ~i_bclk; 
	end

	always begin
		#(CYCLE1/2) i_adclrc = ~i_adclrc;
	end

		
	Record Rec(
		.i_start(i_start),
		.i_adclrc(i_adclrc),
		.i_bclk(i_bclk),
		.i_dat(i_dat),
		.i_rst(i_rst),
		.o_we(o_we),
		.o_ce(o_ce),
		.o_oe(o_oe),
		.o_lb(o_lb),
		.o_ub(o_ub),
		.o_dat(o_dat),
		.o_addr(o_addr)
	);
	initial begin
		$fsdbDumpfile("lab3_Record.fsdb");
		$fsdbDumpvars;

		i_start = 1'b0;
		i_rst = 1'b1;
		i_adclrc = 1'b0;
		i_bclk = 1'b0;


		#2 i_rst = 1'b0;
		#3 i_rst = 1'b1;
		#3 i_start = 1'b1;

		#4 i_dat = 1'b0;
		#5 i_dat = 1'b1;
		#6 i_dat = 1'b0;
		#7 i_dat = 1'b0;
		#8 i_dat = 1'b1;
		#9 i_dat = 1'b0;
		#10 i_dat = 1'b1;
		#11 i_dat = 1'b0;
		#12 i_dat = 1'b1;
		#13 i_dat = 1'b0;
		#14 i_dat = 1'b1;
		#15 i_dat = 1'b0;
		#16 i_dat = 1'b1;
		#17 i_dat = 1'b0;
		#18 i_dat = 1'b1;
		#19 i_dat = 1'b0;
		#20 i_dat = 1'b1;
		#21 i_dat = 1'b1;
		#22 i_dat = 1'b0;
		#23 i_dat = 1'b1;
		#24 i_dat = 1'b0;
		#25 i_dat = 1'b1;
		#26 i_dat = 1'b1;
		#27 i_dat = 1'b0;
		#28 i_dat = 1'b1;
		#29 i_dat = 1'b1;

		for (int j = 30; j < 70; j++) begin
			#(j) i_dat = 1'b1;
		end

		#1000 $finish;
	end
	

endmodule
