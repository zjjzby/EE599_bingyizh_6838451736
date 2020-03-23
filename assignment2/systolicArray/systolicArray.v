module systolicArray #(
	parameter size = 16,
	parameter datawidth = 8
) 
(
	clk,    // Clock
	rst,  // Asynchronous reset active low
	AarrayIn,
	BarrayIn,
	OutputArray
);


input wire clk;
input wire rst;

input wire [size*datawidth - 1: 0] AarrayIn;
input wire [size*datawidth - 1: 0] BarrayIn;

wire [datawidth - 1: 0] Aarray [size - 1:0];
wire [datawidth - 1: 0] Barray [size - 1:0];

output wire [size*size*datawidth - 1 : 0] OutputArray;

 

genvar i,j;
generate
	for (i = 0; i < size; i = i + 1) begin
		assign Aarray[i] = AarrayIn[(i + 1)*datawidth - 1: i*datawidth];
		assign Barray[i] = BarrayIn[(i + 1)*datawidth - 1: i*datawidth];
	end
endgenerate


generate
	for (i = 0; i < size; i = i + 1) begin : outerLoop

		for (j = 0; j < size; j = j + 1) begin : innerLoop
			wire [datawidth - 1: 0] IaIn;
			wire [datawidth - 1: 0] IbIn;
			wire [datawidth - 1: 0] IaOut;
			wire [datawidth - 1: 0] IbOut;
			wire [datawidth - 1: 0] ICout;

			if (i == 0) begin 
				assign IaIn = Aarray[j];
			end
			else begin 
				assign IaIn = outerLoop[i - 1].innerLoop[j].IaOut;
			end

			if (j == 0) begin 
				assign IbIn = Barray[i];
			end
			else begin 
				assign IbIn = outerLoop[i].innerLoop[j - 1].IbOut;
			end

			sysUnit #(
				.datawidth(datawidth),
				.size(size)
			) ins (
				.clk(clk),    // Clock
				.rst(rst),  // Asynchronous reset active low
				.aIn(IaIn),
				.bIn(IbIn),
				.aOut(IaOut),
				.bOut(IbOut),
				.Cout(ICout) 
			);

			assign OutputArray[ (i * size + j + 1)*datawidth - 1:  (i * size + j )*datawidth] = ICout;
		end
	end
endgenerate



endmodule