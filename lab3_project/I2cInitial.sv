module I2cInitial (
	input in_start,
	input in_clk,
	input in_rst,
	input in_finished,
	output out_rst,
	output out_start,
	output [23:0] out_data,
	output out_finished,
	output [3:0] debug
	
	
);

// debug ////////////////////////////////////////////////////////////////////////////////
	assign debug = state_r;

/////////////////////////////////////////////////////////////////////////////////////////


	localparam IDLE = 0;
	localparam BEGIN = 1;
	localparam WORK = 2;
	localparam END = 3;
	
	logic [23:0] data [0:9] = '{24'h340097,24'h340297,24'h340479,
	24'h340679,24'h340815,24'h340a00,24'h340c00,24'h340e42,24'h341019,24'h341201};
	/*
	data [0] = 24'h1a0097;
	data [1] = 24'h1a0297;
	data [2] = 24'h1a0479;
	data [3] = 24'h1a0679;
	data [4] = 24'h1a0815;
	data [5] = 24'h1a0a00;
	data [6] = 24'h1a0c00;
	data [7] = 24'h1a0e42;
	data [8] = 24'h1a1019;
	data [9] = 24'h1a1201;
	
	logic [23:0] data1 = 24'h1a0097;
	logic [23:0] data2 = 24'h1a0297;
	logic [23:0] data3 = 24'h1a0497;
	logic [23:0] data4 = 24'h1a0679;
	logic [23:0] data5 = 24'h1a0815;
	logic [23:0] data6 = 24'h1a0a00;
	logic [23:0] data7 = 24'h1a0c00;
	logic [23:0] data8 = 24'h1a0e42;
	logic [23:0] data9 = 24'h1a1019;
	logic [23:0] data10 = 24'h1a1201;
	*/
	
	logic [3:0] state_r, state_w;
	logic [3:0] dataCounter_r, dataCounter_w;
	logic sta_r, sta_w;
	logic rst_r, rst_w;	
	//logic fin_r, fin_w;
	logic finish_r, finish_w;
	logic [23:0] data_r, data_w;	
	
	assign out_rst = rst_r;
	assign out_start = sta_r;
	assign out_data = data_r;
	assign out_finished = finish_r;
	
	/*
	I2cSender #(.BYTE(3))Sender(
		.i_clk(in_clk),
		.i_rst(rst_r),
		.i_dat(data_r), 
		.i_start(sta_r),
		.o_finished(fin_w),
		.o_sclk(out_sclk),
		.o_sdat(inout_sdat)
	);	
	*/
	always_comb begin
		case(state_r)
			IDLE: begin
				if(in_start)begin
					state_w = BEGIN;
					dataCounter_w = 1;
					sta_w = 0;
					rst_w = 0;
					//fin_w = 1'bz;
					finish_w = 0;
					data_w = data[0];
				end else begin
					state_w = IDLE;
					dataCounter_w = 0;
					sta_w = 0;
					rst_w = 1;
					//fin_w = 1'bz;
					finish_w = finish_r;
					data_w = 0;
				end
			end
			
			BEGIN: begin
				state_w = WORK;
				dataCounter_w = dataCounter_r;
				sta_w = 1;
				rst_w = 1;
				//fin_w = 1'bz;
				finish_w = 0;
				data_w = data_r;
			end
			
			WORK: begin
				if(!in_finished)begin
					state_w = WORK;
					dataCounter_w = dataCounter_r;
					sta_w = 0;
					rst_w = 1;
					//fin_w = 1'bz;
					finish_w = 0;
					data_w = data_r;
				end else begin
					state_w = END;
					dataCounter_w = dataCounter_r + 1;
					sta_w = 0;
					rst_w = 1;
					//fin_w = 1'bz;
					finish_w = 0;
					data_w = data_r;
				end				
			end
			
			END: begin
				if(dataCounter_r == 11)begin
					state_w = END;
					dataCounter_w = dataCounter_r;
					sta_w = 0;
					rst_w = 1;
					//fin_w = 1'bz;
					finish_w = 1;
					data_w = 0;
				end	else begin
					state_w = BEGIN;
					dataCounter_w = dataCounter_r;
					sta_w = 0;
					rst_w = 0;
					//fin_w = 1'bz;
					finish_w = 0;
					data_w = data[dataCounter_r - 1];				
				end
			end			
		endcase
	end
	
	always_ff @(posedge in_clk or negedge in_rst)begin
		if(!in_rst)begin
			state_r <= IDLE;
			dataCounter_r <= 0;
			sta_r <= 0;
			rst_r <= 1;
			//fin_r <= 1'bz;
			finish_r <= 0;
			data_r <= 0;
		end else begin
			state_r <= state_w;
			dataCounter_r <= dataCounter_w;
			sta_r <= sta_w;
			rst_r <= rst_w;
			//fin_r <= 1'bz;
			finish_r <= finish_w;
			data_r <= data_w;
		end
	end

endmodule