//D type flip flop
module d_flip_flop (q,d,clk);

  output reg q;
  input d, clk;

  always @ (*) begin
		if (clk) begin
			q <= d;
		end
  end

endmodule

//Tri state buffer
//q = d when OE is low
module tri_buffer (q,d,OE);

  output q;
  input d, OE;

  assign q = (OE) ? 1'bZ : d;

endmodule

//Inverting tri state buffer
//q = ~d when OE is low
module inv_tri_buffer (q,d,OE);

  output q;
  input d, OE;

  assign q = (OE) ? 1'bZ : ~d;

endmodule


//Octal D-Type Flip Flop
//74LS574
//q = d when CP goes low to high
//output is q when OE is low (otherwise Z)
module octal_d_flip_flop (q,d,OE,CP);

  output wire [7:0] q;
  wire [7:0] q_mid;
  input [7:0] d;
  input OE, CP;

  d_flip_flop dff0 (q_mid[0], d[0], CP);
  d_flip_flop dff1 (q_mid[1], d[1], CP);
  d_flip_flop dff2 (q_mid[2], d[2], CP);
  d_flip_flop dff3 (q_mid[3], d[3], CP);
  d_flip_flop dff4 (q_mid[4], d[4], CP);
  d_flip_flop dff5 (q_mid[5], d[5], CP);
  d_flip_flop dff6 (q_mid[6], d[6], CP);
  d_flip_flop dff7 (q_mid[7], d[7], CP);

  tri_buffer tr0 (q[0], q_mid[0], OE);
  tri_buffer tr1 (q[1], q_mid[1], OE);
  tri_buffer tr2 (q[2], q_mid[2], OE);
  tri_buffer tr3 (q[3], q_mid[3], OE);
  tri_buffer tr4 (q[4], q_mid[4], OE);
  tri_buffer tr5 (q[5], q_mid[5], OE);
  tri_buffer tr6 (q[6], q_mid[6], OE);
  tri_buffer tr7 (q[7], q_mid[7], OE);

endmodule

//Octal Tri State Buffer
//74LS541
module octal_buffer (q,d,OE);

  output wire [7:0] q;
  input [7:0] d;
  input OE;

  tri_buffer tr0 (q[0], d[0], OE);
  tri_buffer tr1 (q[1], d[1], OE);
  tri_buffer tr2 (q[2], d[2], OE);
  tri_buffer tr3 (q[3], d[3], OE);
  tri_buffer tr4 (q[4], d[4], OE);
  tri_buffer tr5 (q[5], d[5], OE);
  tri_buffer tr6 (q[6], d[6], OE);
  tri_buffer tr7 (q[7], d[7], OE);

endmodule

//Octal Inverting Tri State Buffer
//74LS541
module octal_inv_buffer (q,d,OE);

  output wire [7:0] q;
  input [7:0] d;
  input OE;

  inv_tri_buffer tr0 (q[0], d[0], OE);
  inv_tri_buffer tr1 (q[1], d[1], OE);
  inv_tri_buffer tr2 (q[2], d[2], OE);
  inv_tri_buffer tr3 (q[3], d[3], OE);
  inv_tri_buffer tr4 (q[4], d[4], OE);
  inv_tri_buffer tr5 (q[5], d[5], OE);
  inv_tri_buffer tr6 (q[6], d[6], OE);
  inv_tri_buffer tr7 (q[7], d[7], OE);

endmodule

//4 bit adder
//74LS83
module quad_adder (s,a,b,c_in,c_out);

  output wire [3:0] s;
  output c_out;

  input [3:0] a, b;
  input c_in;

  assign {c_out, s} = (a + b + c_in);

endmodule

// 4  bit counter with preset ability
// 4029
module quad_counter (q,j,PE,CLK,UD,BD,Cin,Cout);

	output [3:0] q;
	output Cout;

	input [3:0] j;
	input PE, CLK, UD, BD, Cin;

	reg [3:0] val;

	initial begin
		val = 0;
	end

	//Cout is 0 when counter is at maximum
	assign Cout = (
			(val == 0 && !UD)
			|| (val == 15 && UD && BD)
			|| (val == 9 && UD && !BD)
		) ? 1'b0 : 1'b1;

	assign q = val;

	always @ (posedge CLK) begin
		if (!Cin) begin

			if (UD) begin

				if ((val < 9 && !BD) || (val < 15 && BD)) begin
					val += 1;
				end else begin
					val = 0;
				end

			end else begin

				if (val > 0) begin
					val -= 1;
				end else begin
					val = (BD) ? 4'hF : 4'd9;
				end

			end

		end
	end

	always @ (*) begin : JAM_INPUT
		if (PE) begin
			val = j;
		end
	end

endmodule

// 74LS139
// 2-4 DEMUX
module demux_2_4(o,a0,a1,e);

	output [3:0] o;

	input a0, a1, e;

	assign o[0] = ~(~e & ~a0 & ~a1);
	assign o[1] = ~(~e & a0 & ~a1);
	assign o[2] = ~(~e & ~a0 & a1);
	assign o[3] = ~(~e & a0 & a1);

endmodule
