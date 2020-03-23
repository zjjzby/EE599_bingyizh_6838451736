module tb ;

parameter size = 64;
parameter datawidth = 8;
parameter stages = $clog2(size);

reg [datawidth - 1:0] inarray [size - 1:0];
wire [datawidth*size - 1:0] inarrayWire;
wire [datawidth*size - 1:0] outarrayWire;
wire [datawidth - 1:0] outarray [size - 1:0];

reg clk;
reg rst;
reg [stages - 1 : 0] select;

genvar i;

generate
	for (i = 0; i < size; i = i + 1) begin
		assign inarrayWire[(i + 1)*datawidth - 1 : i*datawidth] = inarray[i];
		assign outarray[i] = outarrayWire[(i + 1)*datawidth - 1 : i*datawidth];
	end
endgenerate


barrelshifer #(
.size(size),
.datawidth(datawidth)
)
ins 
(
	.clk(clk),   
	.rst(rst), 
	.inarray(inarrayWire),
	.select(select),
	.outarray(outarrayWire)
);

integer j;

initial begin 
	forever begin
	clk = 0;
	#10 clk = ~clk;
	#10;
	end
end

initial begin 
	rst = 0;
	#5 rst = 1;

	for (j = 0; j < size; j = j + 1) begin
		inarray[j] = j;
	end

	for (j = 0; j < size; j = j + 1) begin
		select = j ;
		#20;
	end

	#200;
	$finish;

end



endmodule