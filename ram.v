// CY62128E
// 128k x 8 bit CMOS SRAM
//
// Tri state 8-bit ram
// 17 address pins
//
// Active when CE1=0 and CE2=1
module ram_chip(data, address, CE1, CE2, WE, OE);

	inout [7:0] data;

	input [16:0] address;
	input CE1, CE2, WE, OE;

	// Currently only 8 bits of address space are used so I reduced the memory
	// array to reflect that. This means that all other address pins must be
	// grounded or you will go out of bounds. This change reduces the compilation
	// time significantly.
	reg [7:0] mem [0:(1<<8)-1];

	reg [7:0] data_out;

	//Write when active and WE=1, OE=0
	assign data = (~CE1 & CE2 & WE & ~OE) ? data_out : 8'bZ;

	always @ (*) begin

		if (~CE1 & CE2 & ~WE) begin : IN_RAM
			mem[address] = data;
		end

		if (!CE1 && CE2 && WE && !OE) begin
			data_out = mem[address];
		end

	end

endmodule

module ram(bus, ram_addr, ram_r, ram_w);

	inout [7:0] bus;

	input [7:0] ram_addr; //currently ram addresses are only 8-bit

	input ram_r, ram_w;

	wire WE, OE;
	assign WE = ~ram_r;
	assign OE = ram_w;

	wire [7:0] w_data;

	reg r0, r1;

	initial begin
		r0 <= 1'b0;
		r1 <= 1'b1;
	end

	wire [16:0] addr_feed = {r0,r0,r0,r0,r0,r0,r0,r0,r0, ram_addr};

	octal_buffer read_buffer (w_data, bus, WE);
	octal_buffer write_buffer (bus, w_data, ram_w);
	ram_chip ram_chip (w_data, addr_feed, r0, r1, WE, OE);

endmodule

//Increment when m_d is high
//Decrement when m_d is low
module ram_reg(bus,ram_addr,ip_c,ip_r,ip_w,m_c,m_r,m_d,m_w);

	inout [7:0] bus;

	output [7:0] ram_addr;

	input ip_c,ip_r,ip_w,m_c,m_r,m_d,m_w;

	wire [7:0] w0,w1;
	wire c0,c1,c2,c3;

	reg r0, r1;

	initial begin
	  r0 = 1'b0;
		r1 = 1'b1;
	end

	quad_counter q1 (w0[3:0],bus[3:0],ip_r,ip_c,r1,r1,r0,c0);
	quad_counter q2 (w0[7:4],bus[7:4],ip_r,ip_c,r1,r1,c0,c1);
	octal_buffer q3 (ram_addr,w0,ip_w);

	quad_counter q4 (w1[3:0],bus[3:0],m_r,m_c,m_d,r1,r0,c2);
	quad_counter q5 (w1[7:4],bus[7:4],m_r,m_c,m_d,r1,c2,c3);
	octal_buffer q6 (ram_addr,w1,m_w);

endmodule
