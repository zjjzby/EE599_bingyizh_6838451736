module mux #(
	parameter datawidth = 8
	)

(
	x,
	y,
	select,
	out
);

input wire [datawidth - 1:0] x;
input wire [datawidth - 1:0] y;

input wire select;

output wire [datawidth - 1:0] out;

assign out = select? y : x;

endmodule