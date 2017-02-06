//Output flags are high when logically true
module seq_decoder(
	int_direct,
	fl_lt,
	fl_z,

	alu,
	read_b,
	read_ram,
	write_a,
	write_ram,
	read,
	disp,
	store_val,
	inc,
	dec,
	gojmp
);

	output alu,read_b,read_ram,write_a,write_ram,read,disp,store_val,inc,dec,gojmp;

	input [7:0] int_direct;
	input fl_lt, fl_z;

	wire mov, val, hlt, op; //Intermediate flags (these are inverted)
	wire jmp, inc_dec; //Intermediate flags (not inverted)

	reg r0;

	initial begin
	  r0 = 1'b0;
	end

	demux_2_4 q0 ({op, hlt, val, mov}, int_direct[1], int_direct[0], r0);

	assign alu = (~op & int_direct[2]);
	assign read_b = (~mov | ~val | ~hlt) & ~int_direct[3];
	assign read_ram = (~mov | ~val) & int_direct[3];
	assign write_a = (~mov | ~hlt) & ~int_direct[2];
	assign write_ram = ~mov & int_direct[2];
	assign read = read_b & ~hlt;
	assign disp = write_a & ~hlt;
	assign jmp = (~int_direct[2] & int_direct[3]) & ~op;
	assign store_val = (~val | jmp);
	assign inc_dec = (~int_direct[2] & ~int_direct[3]) & ~op;
	assign inc = inc_dec & int_direct[6];
	assign dec = inc_dec & int_direct[7];
	assign gojmp = jmp & (int_direct[5] | (int_direct[6] & fl_lt) | (int_direct[7] & ~fl_z));

endmodule

module controller(
	a_r, a_bus,
	b_r, b_bus,
	o_r, o_w,
	flb_r, fl_r,
	ip_c, ip_r, ip_w,
	m_c, m_r, m_w, m_d,
	ram_w, ram_r,
	int_r, int_w,
	val_r, val_w,
	hlt,
	tx,

	alu,
	read_b,
	read_ram,
	write_a,
	write_ram,
	read,
	disp,
	store_val,
	inc,
	dec,
	gojmp,

	f,int_direct
);

	// Control outputs
	// *_r are 1 when true
	// *_bus and *_w are 0 when true
	// m_d is 0 when true
	output
		a_r, a_bus,
		b_r, b_bus,
		o_r, o_w,
		flb_r, fl_r,
		ip_c, ip_r, ip_w,
		m_c, m_r, m_w, m_d,
		ram_w, ram_r,
		int_r, int_w,
		val_r, val_w,
		hlt,
		tx;

	input alu,read_b,read_ram,write_a,write_ram,read,disp,store_val,inc,dec,gojmp;

	input [5:0] f;
	input [7:0] int_direct;

	//Demux register addresses
	wire e_a, e_b;
	wire [3:0] r_bu, w_bu; // read/write buffer for demux output

	assign e_a = ~((f[4] | f[5]) & write_a);
	assign e_b = ~(f[4] & read_b);

	demux_2_4 q0 (w_bu, int_direct[5], int_direct[4], e_a);
	demux_2_4 q1 (r_bu, int_direct[7], int_direct[6], e_b);

	//WRITE A
	assign a_bus = w_bu[0];
	assign b_bus = w_bu[1];
	assign o_w = w_bu[2];
	assign val_w = ~(~w_bu[3] | ((f[4] | f[5]) & (gojmp | store_val)));

	//READ B
	assign a_r = ~r_bu[0];
	assign b_r = ~r_bu[1];
	assign ip_r = (~r_bu[2] | (f[4] & gojmp));
	assign m_r = ~r_bu[3];

	//INC/DEC
	assign m_d = ~((f[2] | f[3]) & dec);
	assign m_c = (inc | dec) & f[3];

	//ALU
	assign int_w = !(f[2] & alu);
	assign {o_r, flb_r} = {~int_w, ~int_w}; //mirror
	assign fl_r = f[3] & alu;

	assign ip_c = f[1] | (f[3] & store_val);
	assign int_r = f[0];
	assign val_r = f[2] & store_val;

	assign ip_w = ~(f[0] | (f[2] & store_val));
	assign m_w = ~((write_ram & (f[4] | f[5])) | (f[4] & read_ram));
	assign ram_w = ~(~ip_w | ~m_w);
	assign ram_r = f[4] & read_ram;

	//I/O
	assign tx = f[5] & disp;
	assign hlt = f[4] & read;

endmodule

module timer(f,timer_clear,hlt,rx,clk);

	output [5:0] f;

	input timer_clear, hlt, rx, clk;

	reg [3:0] v;

	initial begin
		v = 3'd0;
	end

	assign f = (1 << v);

	always @ (posedge clk) begin
		if ((rx || !hlt) && !timer_clear) begin

			if (v < 5) begin
				v = v + 1;
			end else begin
				v = 0;
			end

		end
	end

	always @ (timer_clear) begin
		if (timer_clear) begin
			v = 0;
		end
	end

endmodule

module seq_reg(bus,int_direct,int_r,int_w,val_r,val_w);

	inout [7:0] bus;

	output [7:0] int_direct;

	input int_r, int_w, val_r, val_w;

	wire [7:0] w0, w1;

	reg r0;

	initial begin
		r0 = 1'b0;
	end

	octal_d_flip_flop int_reg (w0, bus, r0, int_r);
	octal_buffer int_buff (bus, w0, int_w);
	assign int_direct = w0;

	octal_d_flip_flop q3 (w1, bus, r0, val_r);
	octal_buffer q4 (bus, w1, val_w);

endmodule

module sequencer(
	a_r, a_bus,
	b_r, b_bus,
	o_r, o_w,
	flb_r, fl_r,
	ip_c, ip_r, ip_w,
	m_c, m_r, m_w, m_d,
	ram_w, ram_r,
	int_r, int_w,
	val_r, val_w,
	tx, hlt,

	int_direct, timer_clear, reg_clear, jam_f, rx,
	fl_lt, fl_z,

	clk
);

	output
		a_r, a_bus,
		b_r, b_bus,
		o_r, o_w,
		flb_r, fl_r,
		ip_c, ip_r, ip_w,
		m_c, m_r, m_w, m_d,
		ram_w, ram_r,
		int_r, int_w,
		val_r, val_w,
		tx;

	input [7:0] int_direct;

	input timer_clear, reg_clear, jam_f, rx, fl_lt, fl_z, clk;

	//intermediates
	wire alu,read_b,read_ram,write_a,write_ram,read,disp,store_val,inc,dec,gojmp;
	wire [5:0] f0, f1; //f is buffered

	//Loopback
	output wire hlt;

	//Reg read buffer
	wire a_rb, b_rb, ip_rb, m_rb, int_rb, val_rb;

	assign a_r = a_rb | reg_clear;
	assign b_r = b_rb | reg_clear;
	assign ip_r = ip_rb | reg_clear;
	assign m_r = m_rb | reg_clear;
	assign int_r = int_rb | reg_clear;
	assign val_r = val_rb | reg_clear;

	seq_decoder seq_decoder (
		int_direct,
		fl_lt,
		fl_z,

		alu,
		read_b,
		read_ram,
		write_a,
		write_ram,
		read,
		disp,
		store_val,
		inc,
		dec,
		gojmp);

	timer timer (f0,timer_clear,hlt,rx,clk);

	assign f1 = f0 & ~jam_f;

	controller controller (
		a_rb, a_bus,
		b_rb, b_bus,
		o_r, o_w,
		flb_r, fl_r,
		ip_c, ip_rb, ip_w,
		m_c, m_rb, m_w, m_d,
		ram_w, ram_r,
		int_rb, int_w,
		val_rb, val_w,
		hlt,
		tx,

		alu,
		read_b,
		read_ram,
		write_a,
		write_ram,
		read,
		disp,
		store_val,
		inc,
		dec,
		gojmp,

		f1,int_direct);

endmodule
