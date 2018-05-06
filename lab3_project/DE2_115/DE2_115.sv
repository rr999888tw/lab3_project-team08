module DE2_115(
	input CLOCK_50,
	input CLOCK2_50,
	input CLOCK3_50,
	input ENETCLK_25,
	input SMA_CLKIN,
	output SMA_CLKOUT,
	output [8:0] LEDG,
	output [17:0] LEDR,
	input [3:0] KEY,
	input [17:0] SW,
	output [6:0] HEX0,
	output [6:0] HEX1,
	output [6:0] HEX2,
	output [6:0] HEX3,
	output [6:0] HEX4,
	output [6:0] HEX5,
	output [6:0] HEX6,
	output [6:0] HEX7,
	output LCD_BLON,
	inout [7:0] LCD_DATA,
	output LCD_EN,
	output LCD_ON,
	output LCD_RS,
	output LCD_RW,
	output UART_CTS,
	input UART_RTS,
	input UART_RXD,
	output UART_TXD,
	inout PS2_CLK,
	inout PS2_DAT,
	inout PS2_CLK2,
	inout PS2_DAT2,
	output SD_CLK,
	inout SD_CMD,
	inout [3:0] SD_DAT,
	input SD_WP_N,
	output [7:0] VGA_B,
	output VGA_BLANK_N,
	output VGA_CLK,
	output [7:0] VGA_G,
	output VGA_HS,
	output [7:0] VGA_R,
	output VGA_SYNC_N,
	output VGA_VS,
	input AUD_ADCDAT,
	inout AUD_ADCLRCK,
	inout AUD_BCLK,
	output AUD_DACDAT,
	inout AUD_DACLRCK,
	output AUD_XCK,
	output EEP_I2C_SCLK,
	inout EEP_I2C_SDAT,
	output I2C_SCLK,
	inout I2C_SDAT,
	output ENET0_GTX_CLK,
	input ENET0_INT_N,
	output ENET0_MDC,
	input ENET0_MDIO,
	output ENET0_RST_N,
	input ENET0_RX_CLK,
	input ENET0_RX_COL,
	input ENET0_RX_CRS,
	input [3:0] ENET0_RX_DATA,
	input ENET0_RX_DV,
	input ENET0_RX_ER,
	input ENET0_TX_CLK,
	output [3:0] ENET0_TX_DATA,
	output ENET0_TX_EN,
	output ENET0_TX_ER,
	input ENET0_LINK100,
	output ENET1_GTX_CLK,
	input ENET1_INT_N,
	output ENET1_MDC,
	input ENET1_MDIO,
	output ENET1_RST_N,
	input ENET1_RX_CLK,
	input ENET1_RX_COL,
	input ENET1_RX_CRS,
	input [3:0] ENET1_RX_DATA,
	input ENET1_RX_DV,
	input ENET1_RX_ER,
	input ENET1_TX_CLK,
	output [3:0] ENET1_TX_DATA,
	output ENET1_TX_EN,
	output ENET1_TX_ER,
	input ENET1_LINK100,
	input TD_CLK27,
	input [7:0] TD_DATA,
	input TD_HS,
	output TD_RESET_N,
	input TD_VS,
	inout [15:0] OTG_DATA,
	output [1:0] OTG_ADDR,
	output OTG_CS_N,
	output OTG_WR_N,
	output OTG_RD_N,
	input OTG_INT,
	output OTG_RST_N,
	input IRDA_RXD,
	output [12:0] DRAM_ADDR,
	output [1:0] DRAM_BA,
	output DRAM_CAS_N,
	output DRAM_CKE,
	output DRAM_CLK,
	output DRAM_CS_N,
	inout [31:0] DRAM_DQ,
	output [3:0] DRAM_DQM,
	output DRAM_RAS_N,
	output DRAM_WE_N,
	output [19:0] SRAM_ADDR,
	output SRAM_CE_N,
	inout [15:0] SRAM_DQ,
	output SRAM_LB_N,
	output SRAM_OE_N,
	output SRAM_UB_N,
	output SRAM_WE_N,
	output [22:0] FL_ADDR,
	output FL_CE_N,
	inout [7:0] FL_DQ,
	output FL_OE_N,
	output FL_RST_N,
	input FL_RY,
	output FL_WE_N,
	output FL_WP_N,
	inout [35:0] GPIO,
	input HSMC_CLKIN_P1,
	input HSMC_CLKIN_P2,
	input HSMC_CLKIN0,
	output HSMC_CLKOUT_P1,
	output HSMC_CLKOUT_P2,
	output HSMC_CLKOUT0,
	inout [3:0] HSMC_D,
	input [16:0] HSMC_RX_D_P,
	output [16:0] HSMC_TX_D_P,
	inout [6:0] EX_IO
);
	logic keydown_start, reset, debounce, CLK12, CLK50, CLK100k;
	logic keydown_rst;
	logic [3:0] random_value;
	logic [3:0] DEV;
	logic I2Cfinish, I2Crst, I2Cstart;
	logic [23:0] data;
	logic [2:0] TOP_state;
	logic [19:0] sram_addr;	
	logic [15:0] TOP_data;
	
	assign SRAM_ADDR = sram_addr;
	assign AUD_XCK = CLK12M;

diplay disp0(
	.i_rst_N(~keydown_rst), // may be ~keydown_rst, I2Crst
	.i_addr(sram_addr),  ///彭要幫我處理成5bit yeah  assume that is i_sec
	.i_sw(SW),
	.i_state(TOP_state),
	.i_data(TOP_data),
	.clock_50(CLOCK_50),
	.sec7(HEX7),
	.sec6(HEX6),
	.sec5(HEX5),
	.sec4(HEX4),
	.o3(HEX3),
	.o2(HEX2),
	.o1(HEX1),
	.o0(HEX0),
	//.LEDR(LEDR[15:0])
	.lcd_blon(LCD_BLON),
	.lcd_data(LCD_DATA),
	.lcd_en(LCD_EN),
	.lcd_on(LCD_ON),
	.lcd_rs(LCD_RS),
	.lcd_rw(LCD_RW),

);

assign LEDG[1] = SRAM_UB_N;
assign LEDG[2] = SRAM_LB_N;
assign LEDG[3] = SRAM_OE_N;
assign LEDG[4] = SRAM_CE_N;
assign LEDG[5] = SRAM_WE_N;




Top t0(
	.clk(AUD_BCLK), //bclk input
	.key1(~key1_down), //reset top module
	.key2(key2_down), //start top module
	.key3(key3_down),
	
	.switch(SW),
	.ADCLRC(AUD_ADCLRCK),
	.DACLRC(AUD_DACLRCK),
	.ADCDAT(AUD_ADCDAT),	
	.DACDAT(AUD_DACDAT),
	.SRAM_CE_N(SRAM_CE_N),
	.SRAM_LB_N(SRAM_LB_N),
	.SRAM_OE_N(SRAM_OE_N),
	.SRAM_UB_N(SRAM_UB_N),
	.SRAM_WE_N(SRAM_WE_N),
	.SRAM_ADDR(sram_addr),
	.SRAM_DAT(SRAM_DQ),
	//.PLAY_FINISH(LEDR[1]),
	//.REC_FINISH(LEDR[2]),
	.o_state(TOP_state),
	.playdatais0(~LEDG[6]),
	.recdatais0(~LEDG[7]),
	.o_dispdata(TOP_data)
);
	
	clk clk1(
		.clk_clk(CLOCK_50),       //   clk.clk
		.reset_reset_n(reset),  // reset.reset_n
		.clk_12M(CLK12M),
		.clk_100k(CLK100k)
	);

Debounce d0(
	.i_in(KEY[0]),
	.i_clk(CLK100k),
	.o_neg(keydown_rst),
	.o_pos(keyup_start)
	
);
Debounce d1(
	.i_in(KEY[1]),
	.i_clk(CLK12M),
	.o_neg(key1_down)
//	.o_pos()
);
Debounce d2(
	.i_in(KEY[2]),
	.i_clk(CLK12M),
	.o_neg(key2_down)
//	.o_pos()
);
Debounce d3(
	.i_in(KEY[3]),
	.i_clk(CLK12M),
	.o_neg(key3_down)
//	.o_pos()
);

I2cInitial I2cI(
	.in_start(keyup_start),
	.in_clk(CLK100k),
	.in_rst(~keydown_rst),
	.in_finished(I2Cfinish),
	.out_rst(I2Crst),
	.out_start(I2Cstart),
	.out_data(data),
	.out_finished(LEDG[0]),
	.debug(debug)
		
);
I2cSender I2cS(
	.i_start(I2Cstart),
	.i_dat(data),
	.i_clk(CLK100k),
	.i_rst(I2Crst),
	.o_finished(I2Cfinish),
	.o_sclk(I2C_SCLK),
	.o_sdat(I2C_SDAT)
);	


endmodule