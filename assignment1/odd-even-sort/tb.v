module tb;

parameter datawidth = 8;
parameter arraylength = 128;

reg clk;
reg rst;
reg start;

wire done;
wire idle;

reg [datawidth*arraylength - 1 :0] inputarray;

wire [datawidth*arraylength - 1 :0] outputarray;


main #(
	.datawidth(datawidth),
	.arraylength(arraylength)
)
ins(
	.clk(clk),    // Clock
	.rst(rst),  // Asynchronous reset active low
	.start(start),
	.inputarray(inputarray),
	.outputarray(outputarray),
	.done(done),
	.idle(idle)
);


integer i;

initial begin 
	forever begin
    clk = 0;
    #10 clk = ~clk;
    #10;
    end
end


initial begin 
	rst = 0;
	#10 rst = 1;
	start <= 1'b1;

    begin
        for (i = 0; i < arraylength; i = i + 1) begin
            inputarray[(i + 1)*8 - 1 -: 8] <= arraylength - i;
        end   
	end

	#3000;

	$finish;

end

endmodule