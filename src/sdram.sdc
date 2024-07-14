//Copyright (C)2014-2024 GOWIN Semiconductor Corporation.
//All rights reserved.
//File Title: Timing Constraints file
//Tool Version: V1.9.9 (64-bit) 
//Created Time: 2024-07-07 01:14:43
create_clock -name sclk -period 20 -waveform {0 10} [get_ports {sclk}] -add
