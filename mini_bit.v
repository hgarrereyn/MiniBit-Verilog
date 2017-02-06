module mini_bit (bus, clk, rx, tx, timer_clear, reg_clear, jam_f);

	inout [7:0] bus;
	output tx;
	input clk, rx, timer_clear, reg_clear, jam_f;

	//Intermediate wires
	wire [7:0] int_direct, a_direct, b_direct, ram_addr, o;

	//ALU
	wire
		a_pass, a_lt, a_rt,
		b_en, b_inv,
		o_add, o_nand,
		carry_bit, carry_add;

	wire
		fl_carry, fl_lt, fl_z,
		pre_carry, pre_lt, pre_z;

	//Control lines
	wire
		a_r, a_bus,
		b_r, b_bus,
		o_r, o_w,
		flb_r, fl_r,
		ip_c, ip_r, ip_w,
		m_c, m_r, m_w, m_d,
		ram_w, ram_r,
		int_r, int_w,
		val_r, val_w;

	/********************
	 *  MODULE ASSEMBLY *
	 ********************/

	//ALU
	main_reg main_reg (a_direct, b_direct, bus, a_r, a_bus, b_r, b_bus);

	alu_decoder alu_decoder (
		bus, fl_carry,
		a_pass, a_lt, a_rt,
		b_en, b_inv,
		o_add, o_nand,
		carry_add, carry_bit
	);

	alu alu (
		o,pre_carry,pre_lt,pre_z,
		a_direct,b_direct,
		carry_bit,a_pass,a_lt,a_rt,
		carry_add,
		b_en,b_inv,
		o_add,o_nand
	);

	alu_reg alu_reg (fl_carry, fl_lt, fl_z, bus, o, pre_carry, pre_lt, pre_z, o_r, o_w, flb_r, fl_r);

	//RAM
	ram_reg ram_reg (bus, ram_addr, ip_c, ip_r, ip_w, m_c, m_r, m_d, m_w);

	ram ram (bus, ram_addr, ram_r, ram_w);

	//Sequencer
	seq_reg seq_reg (bus,int_direct,int_r,int_w,val_r,val_w);

	sequencer sequencer (
		a_r, a_bus,
		b_r, b_bus,
		o_r, o_w,
		flb_r, fl_r,
		ip_c, ip_r, ip_w,
		m_c, m_r, m_w, m_d,
		ram_w, ram_r,
		int_r, int_w,
		val_r, val_w,
		tx,

		int_direct, timer_clear, reg_clear, jam_f, rx,
		fl_lt, fl_z,

		clk
	);


endmodule
