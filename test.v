module test;

	reg [7:0] bus;
	wire [7:0] bus_driver;
	reg write_bus;

	reg fl_carry, a_r, a_bus, b_r, b_bus;

  wire [7:0] a_direct, b_direct, o;
  wire pre_carry, pre_lt, pre_z;

  wire a_pass, a_lt, a_rt,
	b_en, b_inv,
	o_add, o_nand,
	carry_add, carry_bit;

	octal_buffer bus_buffer (bus_driver, bus, write_bus);

	main_reg q0 (a_direct, b_direct, bus_driver, a_r, a_bus, b_r, b_bus);
	alu_decoder q1 (bus_driver, fl_carry, a_pass, a_lt, a_rt, b_en, b_inv, o_add, o_nand, carry_add, carry_bit);
  alu q2 (o, pre_carry, pre_lt, pre_z, a_direct, b_direct, carry_bit, a_pass, a_lt, a_rt, carry_add, b_en, b_inv, o_add, o_nand);

  initial begin
    $dumpfile("dump.vcd");
    $dumpvars(1, test);

		write_bus = 1'b0;

    fl_carry = 1'b0;
		a_r = 1'b1;
		a_bus = 1'b1;
		b_r = 1'b1;
		b_bus = 1'b1;
		bus = 8'h0;

		//Add 5 and 7

		#2
		bus = 8'd5;
		a_r = 1'b0;
		#2
		a_r = 1'b1;

		#2
		bus = 8'd7;
		b_r = 1'b0;
		#2
		b_r = 1'b1;

		#2
		bus = 8'b00100000;

    #5 $finish;
  end

endmodule
