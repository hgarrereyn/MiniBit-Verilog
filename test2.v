module test();

reg [7:0] j;

wire [7:0] q;

reg PE, CLK, UD, BD, Cin;

wire c, Cout;

quad_counter q1 (q[3:0],j[3:0],PE,CLK,UD,BD,Cin,c);
quad_counter q2 (q[7:4],j[7:4],PE,CLK,UD,BD,c,Cout);

initial begin
	$dumpfile("dump.vcd");
	$dumpvars(1, test);

	j = 8'h0;
	PE = 1'b0;
	CLK = 1'b0;
	UD = 1'b1;
	BD = 1'b1;
	Cin = 1'b0;

	#1 PE = 1'b1;
	#1 PE = 1'b0;

	#40
	j = 8'h7;
	#1 PE = 1'b1;
	#1 PE = 1'b0;

	UD = 1'b0;
	BD = 1'b0;

	#40
	j = 8'h7;
	#1 PE = 1'b1;
	#1 PE = 1'b0;

	UD = 1'b0;
	BD = 1'b1;

	#160 $finish;
end

always #2 CLK = ~CLK;

endmodule
