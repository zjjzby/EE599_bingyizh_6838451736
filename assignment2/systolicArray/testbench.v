module testbench ;

parameter size = 16;
parameter datawidth = 8;
parameter outwidth = datawidth*2 + $clog2(size);

reg clk;
reg rst;
reg [datawidth - 1 : 0] Aarray [size - 1 : 0];
reg [datawidth - 1 : 0] Barray [size - 1 : 0];

wire [outwidth - 1:0] Carry[size - 1 : 0][size - 1 : 0];

wire [size*datawidth - 1: 0] AarrayIn;
wire [size*datawidth - 1: 0] BarrayIn;

wire [size*size*outwidth - 1 : 0] OutputArray;

genvar i,j;
generate
	for (i = 0; i < size; i = i + 1) begin 
		assign AarrayIn[(i + 1)*datawidth - 1 : i*datawidth ] = Aarray[i];
		assign BarrayIn[(i + 1)*datawidth - 1 : i*datawidth ] = Barray[i];
		for (j = 0; j < size; j = j + 1) begin
			assign Carry[i][j] = OutputArray[(i * size + j + 1)*outwidth  - 1:  (i * size + j )*outwidth];
		end
	end
endgenerate

systolicArray #(
	.size(size),
	.datawidth(datawidth)
) ins
(
	.clk(clk),    // Clock
	.rst(rst),  // Asynchronous reset active low
	.AarrayIn(AarrayIn),
	.BarrayIn(BarrayIn),
	.OutputArray(OutputArray)
);

integer k,m;

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

	for (k = 0; k < 2*size; k = k + 1) begin
		if (k < size) begin 
			for (m = 0; m <= size; m = m + 1) begin
				 if (m <= k) begin 
				 	 Aarray[m] <= $random%10;
				 	 Barray[m] <= $random%10;
				 end
				 else begin
				 	 Aarray[m] <= 0; 
				 	 Barray[m] <= 0;
				 end
			end
		end
		else begin
			for (m = 0; m <= size; m = m + 1) begin
				if ( m <= k - size) begin 
					Aarray[m] <= 0; 
					Barray[m] <= 0;
				end
				else begin 
					Aarray[m] <= $random%10; 
					Barray[m] <= $random%10;
				end
			end
		end
		#20;
	end
	#2000;
	$finish;
end

endmodule