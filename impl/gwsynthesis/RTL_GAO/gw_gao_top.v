module gw_gao(
    \sdram_bank[1] ,
    \sdram_bank[0] ,
    \sdram_addr[11] ,
    \sdram_addr[10] ,
    \sdram_addr[9] ,
    \sdram_addr[8] ,
    \sdram_addr[7] ,
    \sdram_addr[6] ,
    \sdram_addr[5] ,
    \sdram_addr[4] ,
    \sdram_addr[3] ,
    \sdram_addr[2] ,
    \sdram_addr[1] ,
    \sdram_addr[0] ,
    \sdram_dqm[1] ,
    \sdram_dqm[0] ,
    \rx_data[7] ,
    \rx_data[6] ,
    \rx_data[5] ,
    \rx_data[4] ,
    \rx_data[3] ,
    \rx_data[2] ,
    \rx_data[1] ,
    \rx_data[0] ,
    \wfifo_data[7] ,
    \wfifo_data[6] ,
    \wfifo_data[5] ,
    \wfifo_data[4] ,
    \wfifo_data[3] ,
    \wfifo_data[2] ,
    \wfifo_data[1] ,
    \wfifo_data[0] ,
    \wfifo_rd_data[7] ,
    \wfifo_rd_data[6] ,
    \wfifo_rd_data[5] ,
    \wfifo_rd_data[4] ,
    \wfifo_rd_data[3] ,
    \wfifo_rd_data[2] ,
    \wfifo_rd_data[1] ,
    \wfifo_rd_data[0] ,
    \rfifo_wr_data[7] ,
    \rfifo_wr_data[6] ,
    \rfifo_wr_data[5] ,
    \rfifo_wr_data[4] ,
    \rfifo_wr_data[3] ,
    \rfifo_wr_data[2] ,
    \rfifo_wr_data[1] ,
    \rfifo_wr_data[0] ,
    \rfifo_rd_data[7] ,
    \rfifo_rd_data[6] ,
    \rfifo_rd_data[5] ,
    \rfifo_rd_data[4] ,
    \rfifo_rd_data[3] ,
    \rfifo_rd_data[2] ,
    \rfifo_rd_data[1] ,
    \rfifo_rd_data[0] ,
    sclk,
    s_rst_n,
    rs232_rx,
    rs232_tx,
    sdram_clk,
    sdram_cke,
    sdram_cs_n,
    sdram_cas_n,
    sdram_ras_n,
    sdram_we_n,
    tx_trig,
    sdram_wr_trig,
    sdram_rd_trig,
    wfifo_wr_en,
    wfifo_rd_en,
    rfifo_wr_en,
    rfifo_rd_en,
    rfifo_empty,
    tms_pad_i,
    tck_pad_i,
    tdi_pad_i,
    tdo_pad_o
);

input \sdram_bank[1] ;
input \sdram_bank[0] ;
input \sdram_addr[11] ;
input \sdram_addr[10] ;
input \sdram_addr[9] ;
input \sdram_addr[8] ;
input \sdram_addr[7] ;
input \sdram_addr[6] ;
input \sdram_addr[5] ;
input \sdram_addr[4] ;
input \sdram_addr[3] ;
input \sdram_addr[2] ;
input \sdram_addr[1] ;
input \sdram_addr[0] ;
input \sdram_dqm[1] ;
input \sdram_dqm[0] ;
input \rx_data[7] ;
input \rx_data[6] ;
input \rx_data[5] ;
input \rx_data[4] ;
input \rx_data[3] ;
input \rx_data[2] ;
input \rx_data[1] ;
input \rx_data[0] ;
input \wfifo_data[7] ;
input \wfifo_data[6] ;
input \wfifo_data[5] ;
input \wfifo_data[4] ;
input \wfifo_data[3] ;
input \wfifo_data[2] ;
input \wfifo_data[1] ;
input \wfifo_data[0] ;
input \wfifo_rd_data[7] ;
input \wfifo_rd_data[6] ;
input \wfifo_rd_data[5] ;
input \wfifo_rd_data[4] ;
input \wfifo_rd_data[3] ;
input \wfifo_rd_data[2] ;
input \wfifo_rd_data[1] ;
input \wfifo_rd_data[0] ;
input \rfifo_wr_data[7] ;
input \rfifo_wr_data[6] ;
input \rfifo_wr_data[5] ;
input \rfifo_wr_data[4] ;
input \rfifo_wr_data[3] ;
input \rfifo_wr_data[2] ;
input \rfifo_wr_data[1] ;
input \rfifo_wr_data[0] ;
input \rfifo_rd_data[7] ;
input \rfifo_rd_data[6] ;
input \rfifo_rd_data[5] ;
input \rfifo_rd_data[4] ;
input \rfifo_rd_data[3] ;
input \rfifo_rd_data[2] ;
input \rfifo_rd_data[1] ;
input \rfifo_rd_data[0] ;
input sclk;
input s_rst_n;
input rs232_rx;
input rs232_tx;
input sdram_clk;
input sdram_cke;
input sdram_cs_n;
input sdram_cas_n;
input sdram_ras_n;
input sdram_we_n;
input tx_trig;
input sdram_wr_trig;
input sdram_rd_trig;
input wfifo_wr_en;
input wfifo_rd_en;
input rfifo_wr_en;
input rfifo_rd_en;
input rfifo_empty;
input tms_pad_i;
input tck_pad_i;
input tdi_pad_i;
output tdo_pad_o;

wire \sdram_bank[1] ;
wire \sdram_bank[0] ;
wire \sdram_addr[11] ;
wire \sdram_addr[10] ;
wire \sdram_addr[9] ;
wire \sdram_addr[8] ;
wire \sdram_addr[7] ;
wire \sdram_addr[6] ;
wire \sdram_addr[5] ;
wire \sdram_addr[4] ;
wire \sdram_addr[3] ;
wire \sdram_addr[2] ;
wire \sdram_addr[1] ;
wire \sdram_addr[0] ;
wire \sdram_dqm[1] ;
wire \sdram_dqm[0] ;
wire \rx_data[7] ;
wire \rx_data[6] ;
wire \rx_data[5] ;
wire \rx_data[4] ;
wire \rx_data[3] ;
wire \rx_data[2] ;
wire \rx_data[1] ;
wire \rx_data[0] ;
wire \wfifo_data[7] ;
wire \wfifo_data[6] ;
wire \wfifo_data[5] ;
wire \wfifo_data[4] ;
wire \wfifo_data[3] ;
wire \wfifo_data[2] ;
wire \wfifo_data[1] ;
wire \wfifo_data[0] ;
wire \wfifo_rd_data[7] ;
wire \wfifo_rd_data[6] ;
wire \wfifo_rd_data[5] ;
wire \wfifo_rd_data[4] ;
wire \wfifo_rd_data[3] ;
wire \wfifo_rd_data[2] ;
wire \wfifo_rd_data[1] ;
wire \wfifo_rd_data[0] ;
wire \rfifo_wr_data[7] ;
wire \rfifo_wr_data[6] ;
wire \rfifo_wr_data[5] ;
wire \rfifo_wr_data[4] ;
wire \rfifo_wr_data[3] ;
wire \rfifo_wr_data[2] ;
wire \rfifo_wr_data[1] ;
wire \rfifo_wr_data[0] ;
wire \rfifo_rd_data[7] ;
wire \rfifo_rd_data[6] ;
wire \rfifo_rd_data[5] ;
wire \rfifo_rd_data[4] ;
wire \rfifo_rd_data[3] ;
wire \rfifo_rd_data[2] ;
wire \rfifo_rd_data[1] ;
wire \rfifo_rd_data[0] ;
wire sclk;
wire s_rst_n;
wire rs232_rx;
wire rs232_tx;
wire sdram_clk;
wire sdram_cke;
wire sdram_cs_n;
wire sdram_cas_n;
wire sdram_ras_n;
wire sdram_we_n;
wire tx_trig;
wire sdram_wr_trig;
wire sdram_rd_trig;
wire wfifo_wr_en;
wire wfifo_rd_en;
wire rfifo_wr_en;
wire rfifo_rd_en;
wire rfifo_empty;
wire tms_pad_i;
wire tck_pad_i;
wire tdi_pad_i;
wire tdo_pad_o;
wire tms_i_c;
wire tck_i_c;
wire tdi_i_c;
wire tdo_o_c;
wire [9:0] control0;
wire gao_jtag_tck;
wire gao_jtag_reset;
wire run_test_idle_er1;
wire run_test_idle_er2;
wire shift_dr_capture_dr;
wire update_dr;
wire pause_dr;
wire enable_er1;
wire enable_er2;
wire gao_jtag_tdi;
wire tdo_er1;

IBUF tms_ibuf (
    .I(tms_pad_i),
    .O(tms_i_c)
);

IBUF tck_ibuf (
    .I(tck_pad_i),
    .O(tck_i_c)
);

IBUF tdi_ibuf (
    .I(tdi_pad_i),
    .O(tdi_i_c)
);

OBUF tdo_obuf (
    .I(tdo_o_c),
    .O(tdo_pad_o)
);

GW_JTAG  u_gw_jtag(
    .tms_pad_i(tms_i_c),
    .tck_pad_i(tck_i_c),
    .tdi_pad_i(tdi_i_c),
    .tdo_pad_o(tdo_o_c),
    .tck_o(gao_jtag_tck),
    .test_logic_reset_o(gao_jtag_reset),
    .run_test_idle_er1_o(run_test_idle_er1),
    .run_test_idle_er2_o(run_test_idle_er2),
    .shift_dr_capture_dr_o(shift_dr_capture_dr),
    .update_dr_o(update_dr),
    .pause_dr_o(pause_dr),
    .enable_er1_o(enable_er1),
    .enable_er2_o(enable_er2),
    .tdi_o(gao_jtag_tdi),
    .tdo_er1_i(tdo_er1),
    .tdo_er2_i(1'b0)
);

gw_con_top  u_icon_top(
    .tck_i(gao_jtag_tck),
    .tdi_i(gao_jtag_tdi),
    .tdo_o(tdo_er1),
    .rst_i(gao_jtag_reset),
    .control0(control0[9:0]),
    .enable_i(enable_er1),
    .shift_dr_capture_dr_i(shift_dr_capture_dr),
    .update_dr_i(update_dr)
);

ao_top_0  u_la0_top(
    .control(control0[9:0]),
    .trig0_i(rs232_rx),
    .data_i({\sdram_bank[1] ,\sdram_bank[0] ,\sdram_addr[11] ,\sdram_addr[10] ,\sdram_addr[9] ,\sdram_addr[8] ,\sdram_addr[7] ,\sdram_addr[6] ,\sdram_addr[5] ,\sdram_addr[4] ,\sdram_addr[3] ,\sdram_addr[2] ,\sdram_addr[1] ,\sdram_addr[0] ,\sdram_dqm[1] ,\sdram_dqm[0] ,\rx_data[7] ,\rx_data[6] ,\rx_data[5] ,\rx_data[4] ,\rx_data[3] ,\rx_data[2] ,\rx_data[1] ,\rx_data[0] ,\wfifo_data[7] ,\wfifo_data[6] ,\wfifo_data[5] ,\wfifo_data[4] ,\wfifo_data[3] ,\wfifo_data[2] ,\wfifo_data[1] ,\wfifo_data[0] ,\wfifo_rd_data[7] ,\wfifo_rd_data[6] ,\wfifo_rd_data[5] ,\wfifo_rd_data[4] ,\wfifo_rd_data[3] ,\wfifo_rd_data[2] ,\wfifo_rd_data[1] ,\wfifo_rd_data[0] ,\rfifo_wr_data[7] ,\rfifo_wr_data[6] ,\rfifo_wr_data[5] ,\rfifo_wr_data[4] ,\rfifo_wr_data[3] ,\rfifo_wr_data[2] ,\rfifo_wr_data[1] ,\rfifo_wr_data[0] ,\rfifo_rd_data[7] ,\rfifo_rd_data[6] ,\rfifo_rd_data[5] ,\rfifo_rd_data[4] ,\rfifo_rd_data[3] ,\rfifo_rd_data[2] ,\rfifo_rd_data[1] ,\rfifo_rd_data[0] ,sclk,s_rst_n,rs232_rx,rs232_tx,sdram_clk,sdram_cke,sdram_cs_n,sdram_cas_n,sdram_ras_n,sdram_we_n,tx_trig,sdram_wr_trig,sdram_rd_trig,wfifo_wr_en,wfifo_rd_en,rfifo_wr_en,rfifo_rd_en,rfifo_empty}),
    .clk_i(sclk)
);

endmodule
