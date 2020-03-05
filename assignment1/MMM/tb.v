module tb;

parameter inputdataWdith = 8;
parameter size = 32;

reg clk;
reg rst;

reg [inputdataWdith*size - 1: 0] arrayA;
reg [inputdataWdith*size - 1: 0] arrayB;

wire [inputdataWdith*2 + $clog2(size) - 1 :0] out;

matrixmultiplication #(
	.inputdataWdith(inputdataWdith),
	.size(size)
)
ins
(
	.clk(clk),    // Clock
	.rst(rst),  // Asynchronous reset active low
	.arrayA(arrayA),
	.arrayB(arrayB),
	.out(out)
);


integer i,j;

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
    
    for (j = 0; j < size*2; j=j+1)
        begin 
            for (i = 0; i < size; i=i+1) begin
                arrayA[(i + 1)*8 - 1 -: 8] <= j + 1;
                arrayB[(i + 1)*8 - 1 -: 8] <= j;
            end
            #20;
        end
	
	$finish;
end


endmodule