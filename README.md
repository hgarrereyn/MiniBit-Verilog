# Overview

Awhile ago, I got a strong desire to build a CPU from scratch so I could learn about all of the low-level operations in great detail. The MiniBit project is actually my second attempt at this goal. Right now, I have built a significant portion of the computer on 13 different breadboards and I am having trouble debugging it.

I am attempting to recreate the logic in Verilog so that I can simulate it virtually and test new ideas and implementations before fixing the physical computer.

My ultimate goal is not to run this code on an FPGA -- *I actually want to build the physical computer out of TTL and CMOS chips*

# Simulation

I'm using Icarus Verilog for simulation and GTKWave for viewing the waveforms.

To compile and run do:

    iverilog -o out/mini_bit -c source_list.txt

then in the `/out` directory, run:

    vvp mini_bit

Waveforms will be saved to `/out/dump.vcd`.
