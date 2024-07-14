module top(
    //system signal
    input           sclk            ,
    // input           s_rst_n         ,
    input           sys_rstn        ,
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

 wire                    rfifo_wr_en            ;
 wire[7:0]               rfifo_wr_data          ;      
 wire                    rfifo_rd_en            ;
 wire[7:0]               rfifo_rd_data          ;      
wire                     rfifo_empty            ;

wire                     s_rst_n   ;
//=======================================\
//******************Main Code **********
//=======================================\
assign s_rst_n = ~sys_rstn ;

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

uart_tx uart_tx_inst(
    .sclk         (sclk     ) ,
    .s_rst_n      (s_rst_n  ) ,

    .rs232_tx     (rs232_tx ) ,
    .rfifo_empty  ( rfifo_empty  )   ,
    .rfifo_rd_en  ( rfifo_rd_en  )   ,
    .rfifo_rd_data(rfifo_rd_data )
);

sdram_top sdram_top_inst(
    . sclk          (  sclk         ),
    . s_rst_n       (   s_rst_n     ),

    . sdram_clk     (  sdram_clk    ),
    . sdram_cke     (   sdram_cke   ),
    . sdram_cs_n    (  sdram_cs_n   ),
    . sdram_cas_n   ( sdram_cas_n   ),
    . sdram_ras_n   ( sdram_ras_n   ),
    . sdram_we_n    ( sdram_we_n    ),
    . sdram_bank    (  sdram_bank   ),
    . sdram_addr    (  sdram_addr   ),
    . sdram_dqm     ( sdram_dqm     ),
    . sdram_dq      ( sdram_dq      ),
    . wr_trig       (sdram_wr_trig  )   ,
    . rd_trig       (sdram_rd_trig  )   ,
    .wfifo_rd_en    (wfifo_rd_en    ) ,
    .wfifo_rd_data  (wfifo_rd_data   ) ,
    .rfifo_wr_en    ( rfifo_wr_en   ) ,
    .rfifo_wr_data  (rfifo_wr_data  )   
);

endmodule