module sysUnit #(
	parameter datawidth = 8,
	parameter size = 16
) (
	clk,    // Clock
	rst,  // Asynchronous reset active low
	aIn,
	bIn,
	aOut,
	bOut,
	Cout 
);

input wire clk;
input wire rst;
input wire [datawidth - 1 : 0] aIn;
input wire [datawidth - 1 : 0] bIn;

output [datawidth - 1 : 0] aOut;
output [datawidth - 1 : 0] bOut;

reg [datawidth - 1 : 0] aOut;
reg [datawidth - 1 : 0] bOut;


output [datawidth*2 + $clog2(size) - 1 : 0] Cout;

reg [datawidth*2 + $clog2(size) - 1 : 0] Cout;
reg [datawidth*2 - 1 : 0] mulresult;

always @(posedge clk or negedge rst) begin : proc_mulresult
	if(~rst) begin
		mulresult <= 0;
	end else begin
		mulresult <= aIn*bIn;
	end
end

always @(posedge clk or negedge rst) begin : proc_Cout
	if(~rst) begin
		Cout <= 0;
	end else begin
		Cout <= Cout + mulresult;
	end
end

always @(posedge clk or negedge rst) begin : proc_aOut
	if(~rst) begin
		aOut <= 0;
	end else begin
		aOut <= aIn;
	end
end

always @(posedge clk or negedge rst) begin : proc_bOut
	if(~rst) begin
		bOut <= 0;
	end else begin
		bOut <= bIn;
	end
end


endmodule