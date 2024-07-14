/** ---------------------------------File Info-------------------------------- 
 ** @file:               IPtop.v                                        
 ** @author:             黄锦  											“，
 ** @contact			 3056830955@qq.com                                    
 ** @date:               2024-07-14            
 ** @version:            V0.0                                                  
 ** @brief:              使用了高云外挂SDRAM的控制器IP核，对SDRAM进行uart收发读写测试
 **                      
 **--------------------------------------------------------------------------- 
 ** @modified:                                                               
 ** @date:               2024-07-14            
 ** @version:            V0.0                                                  
 ** @description:        
 ** @note:               
 **--------------------------------------------------------------------------- 
 ** @copyright:          最初版来源与开源骚客（非IP核）
 ***********************************************************************/ 
`timescale 1ns/1ns
module IPtop(
    //system signal
    input           sclk            ,   //系统时钟50M
    // input           s_rst_n         ,
    input           sys_rstn        ,//上板的时候根据复位按键的画法决定用要不要用这个复位
    //UART insterface
    input           rs232_rx        ,
    output  wire    rs232_tx        ,
    //
    //SDRAM signal
    output  wire            sdram_clk               ,
    output  wire            sdram_cke               ,
    output  wire            sdram_cs_n              ,
    output  wire            sdram_cas_n             ,
    output  wire            sdram_ras_n             ,
    output  wire            sdram_we_n              ,
    output  wire[1:0]       sdram_bank              ,
    output  wire[12:0]      sdram_addr              ,
    output  wire[1:0]       sdram_dqm               ,
    inout       [15:0]      sdram_dq                

);


//=========================================\
//*******************Define Parameter  and Internal Signal
//=========================================\

wire    [7:0]   rx_data                         ;
wire            tx_trig                         ;

wire                     sdram_wr_trig          ;
wire                     sdram_rd_trig          ;

wire                     wfifo_wr_en            ;
wire[ 7:0]               wfifo_data             ;
wire                     wfifo_rd_en            ;
wire[ 7:0]               wfifo_rd_data          ;

wire                    rfifo_wr_en             ;
wire[7:0]               rfifo_wr_data           ;      
wire                    rfifo_rd_en             ;
wire[7:0]               rfifo_rd_data           ;      
wire                     rfifo_empty            ;

wire             I_sdrc_selfrefresh_i           ;
wire             I_sdrc_power_down_i            ;
wire[ 8:0]       I_sdrc_data_len_i              ;
wire[ 1:0]       I_sdrc_dqm_i                   ;
wire             I_sdrc_wr_n_i                  ;
wire             I_sdrc_rd_n_i                  ;
wire[23:0]       I_sdrc_addr_i                  ;
wire[15:0]       I_sdrc_data_i                  ;
wire[15:0]       O_sdrc_data_o                  ;
wire             O_sdrc_init_done_o             ;
wire             O_sdrc_busy_n_o                ;
wire             O_sdrc_wrd_ack_o               ;
wire             O_sdrc_rd_valid_o              ;

wire[ 3:0]       sdram_cmd                      ;

wire                     s_rst_n   ;
//=======================================\
//******************Main Code **********
//=======================================\
assign s_rst_n = ~sys_rstn ; //常态下高电平

//串口和接收模块在仿真和上板有计数区别，目前设置为仿真模式，具体去对应模块内更改
//串口接收，必须固定接收 6个十六进制数，以任意数开口，aa结尾，中间4个为有效值
uart_rx  uart_rx_inst (
        //system signals
        .sclk      (sclk    )  ,
        .s_rst_n   (s_rst_n )  ,
        //UART interface
        .rs232_rx  (rs232_rx)  ,
        //others
        .rx_data   (rx_data )  ,
        .po_flag   (tx_trig ) 

);

//----------------------------------------------------------
//编码
cmd_decode cmd_decode_inst(
    //system sigmal
    .sclk             (sclk         )     ,
    .s_rst_n          (s_rst_n      )     ,

    //From uart moudles
    . uart_flag     (tx_trig        )   ,
    . uart_data     (rx_data        )   ,

    
    . wr_trig       (sdram_wr_trig  )   ,
    . rd_trig       (sdram_rd_trig  )   ,
    . wfifo_wr_en   (wfifo_wr_en    )   ,
    . wfifo_data    (wfifo_data     )     
 );

//----------------------------------------------------------
//深度为8，位宽16
//wrfifo 16✖8 
	fifo_sc_top wrfifo_inst(
		.Data   (wfifo_data     ), //input [7:0] Data
		.Clk    (sclk           ), //input Clk
		.WrEn   (wfifo_wr_en    ), //input WrEn
		.RdEn   (wfifo_rd_en    ), //input RdEn
		.Reset  (~s_rst_n       ), //input Reset
		.Q      (wfifo_rd_data  ), //output [7:0] Q
		.Empty  (               ), //output Empty
		.Full   (               ) //output Full
	);
//rdfifo 16✖8 
	fifo_sc_top rdfifo_inst(
		.Data   (rfifo_wr_data      ), //input [7:0] Data
		.Clk    (sclk               ), //input Clk
		.WrEn   (rfifo_wr_en        ), //input WrEn
		.RdEn   (rfifo_rd_en        ), //input RdEn
		.Reset  (~s_rst_n           ), //input Reset
		.Q      (rfifo_rd_data      ), //output [7:0] Q
		.Empty  (rfifo_empty        ), //output Empty
		.Full   (                    ) //output Full
	);
// //----------------------------------------------------------

//串口发送
uart_tx uart_tx_inst(
    .sclk         (sclk     ) ,
    .s_rst_n      (s_rst_n  ) ,

    .rs232_tx     (rs232_tx ) ,
    .rfifo_empty  ( rfifo_empty  )   ,
    .rfifo_rd_en  ( rfifo_rd_en  )   ,
    .rfifo_rd_data(rfifo_rd_data )
);

//***********************'
//PLL用来产生两个SDRAM时钟，必须有相位差，相位差多大可以在配置PLL的时候选择
//目前相位差180，两时钟频率都为50M
//也可不适用PLL，直接sdrc_clk=~sdram_clk即可。

wire I_sdrc_clk ;
wire I_sdram_clk ;
wire lock_o ;
    Gowin_PLL Gowin_PLL_inst(
        .lock(lock_o), //output lock
        .clkout0(I_sdram_clk), //output clkout0
        .clkout1(I_sdrc_clk), //output clkout1
        .clkin(sclk) //input clkin
    );

//**************************


assign sdram_cmd = { sdram_cs_n , sdram_ras_n ,sdram_cas_n ,sdram_we_n } ;

//SDRAM逻辑控制
IPsdram_top IPsdram_top_inst(
    . sclk          (  I_sdrc_clk  ),
    
    .flag_rst_n     (flag_rst_n     ),//等待200us 可用于控制器复位，确保稳定
    . s_rst_n       (   s_rst_n     ),
    . wr_trig       (sdram_wr_trig  )   ,
    . rd_trig       (sdram_rd_trig  )   ,
    .I_sdrc_selfrefresh_i  (I_sdrc_selfrefresh_i)  ,
    .I_sdrc_power_down_i   (I_sdrc_power_down_i)  ,
    .I_sdrc_data_len_i     (I_sdrc_data_len_i)  ,
    .I_sdrc_dqm_i          (I_sdrc_dqm_i)  ,

    .I_sdrc_wr_n_i         (I_sdrc_wr_n_i)  ,
    .I_sdrc_rd_n_i         (I_sdrc_rd_n_i)  ,
    .I_sdrc_addr_i         (I_sdrc_addr_i)  ,
    .I_sdrc_data_i         (I_sdrc_data_i)  ,
    .sdram_cmd              (sdram_cmd   )  ,
    .O_sdrc_data_o         (O_sdrc_data_o)  ,
    .O_sdrc_init_done_o    (O_sdrc_init_done_o)  ,
    .O_sdrc_busy_n_o       (O_sdrc_busy_n_o)  ,
    .O_sdrc_wrd_ack_o      (O_sdrc_wrd_ack_o)  ,
    .O_sdrc_rd_valid_o     (O_sdrc_rd_valid_o)  ,
    .wfifo_rd_en    (wfifo_rd_en    ) ,
    .wfifo_rd_data  (wfifo_rd_data   ) ,
    .rfifo_wr_en    ( rfifo_wr_en   ) ,
    .rfifo_wr_data  (rfifo_wr_data  )   
);


//SDRAM控制器
SDRAM_controller_top_SIP SDRAM_controller_top_SIP_inst(
	.O_sdram_clk            (sdram_clk              ), //output O_sdram_clk
	.O_sdram_cke            (sdram_cke              ), //output O_sdram_cke
	.O_sdram_cs_n           (sdram_cs_n             ), //output O_sdram_cs_n
	.O_sdram_cas_n          (sdram_cas_n            ), //output O_sdram_cas_n
	.O_sdram_ras_n          (sdram_ras_n            ), //output O_sdram_ras_n
	.O_sdram_wen_n          (sdram_we_n             ), //output O_sdram_wen_n
	.O_sdram_dqm            (sdram_dqm              ), //output [1:0] O_sdram_dqm
	.O_sdram_addr           (sdram_addr             ), //output [12:0] O_sdram_addr
	.O_sdram_ba             (sdram_bank             ), //output [1:0] O_sdram_ba
	.IO_sdram_dq            (sdram_dq               ), //inout [15:0] IO_sdram_dq

	.I_sdrc_rst_n           (s_rst_n &lock_o        ), //input I_sdrc_rst_n 
	.I_sdrc_clk             (I_sdrc_clk             ), //input I_sdrc_clk
	.I_sdram_clk            (I_sdram_clk            ), //input I_sdram_clk
	.I_sdrc_selfrefresh     (1'b0                   ), //input I_sdrc_selfrefresh
	.I_sdrc_power_down      (1'b0                   ), //input I_sdrc_power_down
	.I_sdrc_wr_n            (I_sdrc_wr_n_i          ), //input I_sdrc_wr_n
	.I_sdrc_rd_n            (I_sdrc_rd_n_i          ), //input I_sdrc_rd_n
	.I_sdrc_addr            (I_sdrc_addr_i          ), //input [23:0] I_sdrc_addr
	.I_sdrc_data_len        (I_sdrc_data_len_i      ), //input [8:0] I_sdrc_data_len
	.I_sdrc_dqm             (2'b0                   ), //input [1:0] I_sdrc_dqm
	.I_sdrc_data            (I_sdrc_data_i          ), //input [15:0] I_sdrc_data

	.O_sdrc_data            (O_sdrc_data_o          ), //output [15:0] O_sdrc_data
	.O_sdrc_init_done       (O_sdrc_init_done_o     ), //output O_sdrc_init_done
	.O_sdrc_busy_n          (O_sdrc_busy_n_o        ), //output O_sdrc_busy_n
	.O_sdrc_rd_valid        (O_sdrc_rd_valid_o      ), //output O_sdrc_rd_valid
	.O_sdrc_wrd_ack         (O_sdrc_wrd_ack_o       ) //output O_sdrc_wrd_ack
);





endmodule