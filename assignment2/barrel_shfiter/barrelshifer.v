module barrelshifer #(
	parameter size = 64,
	parameter datawidth = 8
	) (
	clk,    // Clock
	rst,  // Asynchronous reset active low
	inarray,
	select,
	outarray
);

input wire clk;
input wire rst;
parameter stages = $clog2(size);
input wire [stages - 1:0] select;

input wire [datawidth*size - 1 : 0] inarray;
output wire [datawidth*size - 1 : 0] outarray;


wire [datawidth - 1: 0] inDarray [size - 1:0];

genvar i,j;
generate
	for (i = 0; i < size; i = i + 1) begin
		assign inDarray[i] = inarray[(i + 1)*datawidth - 1: i*datawidth];
	end
endgenerate

generate
	for (i = 0; i < stages; i = i + 1) begin : stages_loop
		reg [stages - 1:0] stage_select;
		reg [datawidth - 1: 0] temp [size - 1:0]; 
		wire [datawidth - 1: 0] upperIn [size - 1:0];
		wire [datawidth - 1: 0] lowerIn [size - 1:0];
		wire [datawidth - 1: 0] selectOut [size - 1:0];


		for (j = 0; j < size; j = j + 1) begin : mux_loop
 		 	if (i == 0) begin
 		 		assign stages_loop[i].upperIn[j] = inDarray[j];
 		 		if ( j - 1 >= 0) begin 
 		 			assign stages_loop[i].lowerIn[j] = inDarray[(j - 1)];
 		 		end
 		 		else begin 
 		 			assign stages_loop[i].lowerIn[j] = inDarray[(j - 1) + size];
 		 		end
 		 	end
 		 	else begin 
 		 		assign stages_loop[i].upperIn[j] = stages_loop[i - 1].temp[j]; 
 		 		if ( j - 2**i >= 0) begin
 		 			assign stages_loop[i].lowerIn[j] = stages_loop[i - 1].temp[j - 2**i]; 
 		 		end
 		 		else begin
 		 			assign stages_loop[i].lowerIn[j] = stages_loop[i - 1].temp[j - 2**i + size]; 
 		 		end
 		 	end

 		 	

 		 	if (i == 0) begin 
 		 		always @(posedge clk or negedge rst) begin : proc_stage_select
	 		 		if(~rst) begin
	 		 			stages_loop[i].stage_select <= 0;
	 		 		end else begin
	 		 			stages_loop[i].stage_select <= select;
	 		 		end
 		 		end

 		 		mux #(.datawidth(datawidth)) ins(
	 			.x(stages_loop[i].upperIn[j]),
				.y(stages_loop[i].lowerIn[j]),
				.select(select[i]),
				.out(stages_loop[i].selectOut[j])
	 		);
 		 	end
 		 	else begin 
 		 		always @(posedge clk or negedge rst) begin : proc_stage_select
	 		 		if(~rst) begin
	 		 			stages_loop[i].stage_select <= 0;
	 		 		end else begin
	 		 			stages_loop[i].stage_select <= stages_loop[i - 1].stage_select;
	 		 		end
 		 		end
 		 		mux #(.datawidth(datawidth)) ins(
	 			.x(stages_loop[i].upperIn[j]),
				.y(stages_loop[i].lowerIn[j]),
				.select(stages_loop[i - 1].stage_select[i]),
				.out(stages_loop[i].selectOut[j])
	 		);
 		 	end


	 		always @(posedge clk or negedge rst) begin : proc_temp
	 			if(~rst) begin
	 				stages_loop[i].temp[j] <= 0;
	 			end else begin
	 				stages_loop[i].temp[j] <= stages_loop[i].selectOut[j];
	 			end
	 		end

	 		if (i == stages - 1) begin 
	 			assign outarray[(j + 1)*datawidth - 1 : j * datawidth]  = stages_loop[i].temp[j];
	 		end
		 end 
	end
endgenerate



endmodule