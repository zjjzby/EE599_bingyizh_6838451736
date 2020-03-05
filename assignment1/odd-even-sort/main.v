module main #(
	parameter datawidth = 8,
	parameter arraylength = 128)
(
	clk,    // Clock
	rst,  // Asynchronous reset active low
	start,
	inputarray,
	outputarray,
	done,
	idle
);

input wire clk;    // Clock
input wire rst;  // Asynchronous reset active low
input wire start;
input wire [datawidth*arraylength - 1: 0] inputarray;
output wire [datawidth*arraylength - 1: 0] outputarray;

wire [datawidth - 1 :0] input_array[arraylength - 1: 0];
reg [datawidth - 1 :0] output_array[arraylength - 1: 0];


genvar j;
generate
	for (j = 0; j < arraylength;j = j + 1) begin 
		assign input_array[j] = inputarray[(j + 1)*datawidth - 1 : j*datawidth];
		assign outputarray[(j + 1)*datawidth - 1 : j*datawidth] = output_array[j];
	end
endgenerate



output reg done;
output wire idle;



parameter IDLE = 1'b0;
parameter BUSY = 1'b1;

reg state;
reg[$clog2(arraylength) - 1 : 0] counter;

assign idle = state;

always @(posedge clk or negedge rst) begin : proc_state
	if(~rst) begin
		state <= IDLE;
	end else begin
		if (start == 1'b1 && state == IDLE)
			state <= BUSY;
		else if (counter == arraylength - 1)
			state <= IDLE;
		else
			state <= state;
	end
end

always @(posedge clk or negedge rst) begin : proc_counter
	if(~rst) begin
		counter <= 0;
	end else begin
		if (state == BUSY)
			counter <= counter + 1;
		else
			counter <= counter;
	end
end

always @(posedge clk or negedge rst) begin : proc_done
	if(~rst) begin
		done <= 0;
	end else begin
		if (counter == arraylength - 1)
			done <= 1'b1;
		else
			done <= 1'b0;
	end
end


wire [datawidth - 1 :0] input_intermediate[arraylength - 1: 0]; 
wire [datawidth - 1 :0] output_intermediate[arraylength - 1: 0];
wire [datawidth - 1 :0] outputFromCSUnit[arraylength - 1: 0];




genvar i;

generate
	for (i = 0; i < arraylength; i = i + 2) begin: compare_switchUnit
		compareSwitchunit #(.datawidth(datawidth)) ins
		(
			.inA(output_intermediate[i]),
			.inB(output_intermediate[i + 1]),
			.outA(outputFromCSUnit[i]),
			.outB(outputFromCSUnit[i+1])
		);
	end
endgenerate



generate
	for (i = 0; i < arraylength; i = i + 1) begin : output_intermediate_assignment
		assign output_intermediate[i] = counter[0] ?  output_array[(i + 1)%arraylength]:  output_array[i]; 
		if (i > 0 && i < arraylength - 1)
			assign input_intermediate[i] = counter[0] ? outputFromCSUnit[i - 1]: outputFromCSUnit[i];
		if (i == 0)
			assign input_intermediate[i] = counter[0] ? output_array[i]: outputFromCSUnit[i];
		if (i == arraylength - 1)
			assign input_intermediate[i] = counter[0] ? output_array[i]: outputFromCSUnit[i];
	end
endgenerate



generate
	for(i = 0; i < arraylength; i = i + 1) begin : compare_switch
		always @(posedge clk or negedge rst) begin : proc_output_array
			if(~rst) begin
				output_array[i] <= 0;
			end else begin
				if (start == 1'b1 && state == IDLE)
					output_array[i] <= input_array[i];
				else if (state <= BUSY)
					output_array[i] <= input_intermediate[i]; 
				else 
					output_array[i] <= output_array[i];
			end
		end
	end
endgenerate


endmodule



module compareSwitchunit #(
	parameter datawidth = 8
	) 
(
	inA,    // Clock
	inB, // Clock Enable
	outA,
	outB	
);

input wire [datawidth - 1 : 0] inA;
input wire [datawidth - 1 : 0] inB;

output wire [datawidth - 1 : 0] outA; 
output wire [datawidth - 1 : 0] outB; 

wire compareResult;

assign compareResult = (inA > inB);

assign outA = compareResult ? inB: inA;
assign outB = compareResult ? inA: inB;

endmodule