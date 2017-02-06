module test();


	wire [7:0] bus;
	reg [7:0] bus_driver;
	reg pb, clk_en;

	octal_buffer b (bus, bus_driver, pb);

	reg clk, rx, timer_clear, reg_clear, jam_f;
	wire tx, hlt;

	mini_bit mini_bit (bus, clk, rx, tx, hlt, timer_clear, reg_clear, jam_f);

	initial begin
		$dumpfile("dump.vcd");
		$dumpvars(0, test);

		$readmemb("../prog/demo.txt", mini_bit.ram.ram_chip.mem);

		clk = 1'b0;
		clk_en = 1'b0;
		timer_clear = 1'b0;
		pb = 1'b1;
		reg_clear = 1'b0;

		jam_f = 1'b1;
		#1 jam_f = 1'b0;

		#4
		clk_en = 1'b1;

		//#2000

		//$finish;
	end

	always #2 begin
		if (clk_en) begin
			clk = ~clk;
		end
	end

	always @ (tx) begin
		if (tx) begin
			$display(bus);
		end
	end

	always @ (hlt) begin
		if (hlt) begin
			$finish;
		end
	end

endmodule
