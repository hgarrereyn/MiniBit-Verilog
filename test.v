module test;

	reg [7:0] a,b,bus;
	reg fl_carry;

  wire [7:0] o;
  wire pre_carry, pre_lt, pre_z;

  wire a_pass, a_lt, a_rt,
	b_en, b_inv,
	o_add, o_nand,
	carry_add, carry_bit;

	alu_decoder q1 (bus, fl_carry, a_pass, a_lt, a_rt, b_en, b_inv, o_add, o_nand, carry_add, carry_bit);
  alu q2 (o, pre_carry, pre_lt, pre_z, a, b, carry_bit, a_pass, a_lt, a_rt, carry_add, b_en, b_inv, o_add, o_nand);

  initial begin
    $dumpfile("dump.vcd");
    $dumpvars(1, test);

    a = 8'h4;
    b = 8'h4;
		fl_carry = 1'b1;
		bus = 8'b00100000;

		#5 bus = 8'b10100000;

		#5 bus = 8'b01100000;
		a = 8'h9;
		b = 8'h2;

		#5 bus = 8'b01100000;
		a = 8'h9;
		b = 8'hf;

		while (b > 0) begin
			#2 b = b - 1;
		end

    #12 $finish;
  end

endmodule
