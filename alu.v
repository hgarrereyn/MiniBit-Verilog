//Shifts a left or right with an optional carry
//Control signals are true when low
module shifter (o, pre_carry, a, a_pass, a_lt, a_rt, carry);

  output [7:0] o;
  output pre_carry;

  input [7:0] a;
  input a_pass, a_lt, a_rt, carry;

  octal_buffer pass (o, a, a_pass);
  octal_buffer rt (o, (a >> 1) + (carry << 7), a_rt);
  octal_buffer lt (o, (a << 1) + (carry), a_lt);

  assign pre_carry = (~a_lt & a[7]) | (~a_rt & a[0]);

endmodule

//Inverts or passes b
//Control signals are true when low
//output is zero when both control signals are high
module inverter(o, a, b_en, b_inv);

  output [7:0] o;
  pulldown (o[0],o[1],o[2],o[3],o[4],o[5],o[6],o[7]);

  input [7:0] a;
  input b_en, b_inv;

  octal_buffer en (o, a, b_en);
  octal_inv_buffer inv (o, a, b_inv);

endmodule

//output is a + b + carry
//pre_carry is the overflow bit
//pre_lt is true when o[7] is set
//pre_z is true when o == zero
module adder(o, a, b, carry, pre_carry, pre_lt, pre_z);

  output [7:0] o;
  output pre_carry, pre_lt, pre_z;

  input [7:0] a,b;
  input carry;

  wire c;

  quad_adder q1 (o[3:0], a[3:0], b[3:0], carry, c);
  quad_adder q2 (o[7:4], a[7:4], b[7:4], c, pre_carry);

  assign pre_lt = o[7];
  assign pre_z = ~(|o);

endmodule

module selector(o, a, b, o_add, o_nand);

  output [7:0] o;

  input [7:0] a,b;
  input o_add, o_nand;

  octal_buffer q1 (o, a, o_add);
  octal_buffer q2 (o, b, o_nand);

endmodule

//ALU Module
module alu(o,pre_carry,pre_lt,pre_z,
           a_direct,b_direct,
           carry_bit,a_pass,a_lt,a_rt,
           carry_add,
           b_en,b_inv,
           o_add,o_nand);

  output [7:0] o;
  output pre_carry, pre_lt, pre_z;

  input [7:0] a_direct, b_direct;
  input carry_bit, a_pass, a_lt, a_rt, carry_add, b_en, b_inv, o_add, o_nand;

  wire [7:0] w0, w1, w2, w3;
  wire w4, w5;

  shifter q1 (w0, w4, a_direct, a_pass, a_lt, a_rt, carry_bit);
  inverter q2 (w1, b_direct, b_en, b_inv);
  adder q3 (w2, w0, w1, carry_add, w5, pre_lt, pre_z);
  assign w3 = ~(w0 & w1); //nand module
  selector q4 (o, w2, w3, o_add, o_nand);
  assign pre_carry = w4 | w5;

endmodule

//Decoder module
module alu_decoder(d, fl_carry,
	a_pass, a_lt, a_rt,
	b_en, b_inv,
	o_add, o_nand,
	carry_add, carry_bit);

	input [7:0] d;
	input fl_carry;

	output a_pass, a_lt, a_rt, b_en, b_inv, o_add, o_nand, carry_add, carry_bit;

	assign a_pass = d[3];
	assign a_lt = ~(d[3] & ~d[4]);
	assign a_rt = ~(d[3] & d[4]);

	assign b_en = ~(d[5] & ~d[6]);
	assign b_inv = ~(d[5] & d[6]);

	assign o_add = (~d[3] & d[4]);
	assign o_nand = ~(~d[3] & d[4]);

	//logic, carry, and carry is set
	assign carry_bit = (d[3] & d[7] & fl_carry);

	assign carry_add =
		~d[3] & //we are adding
			(
				(d[5] & d[6] & !d[7]) //Subtraction (force C)
				| (d[7] & fl_carry) //carry is set
				| (~d[5] & d[6]) //invert command
			);

endmodule
