module matrixmultiplication #(
	parameter inputdataWdith = 8,
	parameter size = 32
)
(
	clk,    // Clock
	rst,  // Asynchronous reset active low
	arrayA,
	arrayB,
	out
);

input wire clk;
input wire rst;
input wire [inputdataWdith*size - 1:0] arrayA;
input wire [inputdataWdith*size - 1:0] arrayB;

parameter widthAfterMul = inputdataWdith * 2;
parameter widthOut = widthAfterMul + $clog2(size);

output wire [widthOut - 1:0] out;

reg [widthAfterMul-1: 0] RMul [size - 1: 0];

genvar i, j;
generate
	for (i = 0 ; i < size; i = i + 1) begin : first_mul
		always @(posedge clk or negedge rst) begin : proc_RMul
			if(~rst) begin
				RMul[i] <= 0;
			end else begin
				RMul[i] <= arrayA[(i + 1)*inputdataWdith - 1 : i*inputdataWdith] * arrayB[(i + 1)*inputdataWdith - 1 : i*inputdataWdith];
			end
		end
	end
endgenerate


generate
	for (i = 0; i < $clog2(size); i = i + 1) begin : stage_define
		  reg [widthAfterMul + i: 0] out[2**($clog2(size) - i - 1) - 1:0];
		
		for (j = 0; j < 2**($clog2(size) - i - 1); j = j + 1) begin : each_stage
			if (i == 0) begin
				always @(posedge clk or negedge rst) begin : proc_firststage
					if(~rst) begin
						stage_define[i].out[j] <= 0;
					end else begin
						stage_define[i].out[j] <= RMul[2*j] + RMul[2*j + 1];
					end
				end
			end
			else begin
				always @(posedge clk or negedge rst) begin : proc_afterstage
					if(~rst) begin
						stage_define[i].out[j] <= 0;
					end else begin
						stage_define[i].out[j] <= stage_define[i - 1].out[2*j] + stage_define[i - 1].out[2*j + 1] ;
					end
				end

			end
		end
	end
endgenerate


assign out = stage_define[$clog2(size) - 1].out[0];



endmodule