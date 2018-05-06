module TOP(
	input i_clk,
	input add,
	output signed [3:0] number,
	output [3:0]dev

);
logic [50:0] counter_r, counter_w;
logic signed [3:0] num_r, num_w, dev_r, dev_w;
logic signed [3:0] snum, snum_r, snum_w;
logic signed [3:0] devnum;

assign number = num_r;
assign dev = dev_r;
assign snum = snum_w - snum_r;
assign snum_r = 1;
assign snum_w = -1;
assign devnum = 2;

always_comb begin
	if(counter_r == (100000/dev)) begin 
		counter_w = 0;
		num_w = num_r +1;
	end else begin
		counter_w = counter_r+1;
		num_w = num_r;
	end
	if(add) begin
		dev_w = dev_r+ (snum/devnum);
	end else begin
		dev_w = dev_r;
	end
end

always_ff @(posedge i_clk) begin
	counter_r <= counter_w;
	num_r <= num_w;
	dev_r <= dev_w;

end



endmodule