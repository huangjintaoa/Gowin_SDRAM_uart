`timescale 1ns/1ns


module  tb_sdram_top    ;
reg sclk    ;
reg s_rst_n ;

//============================================
    //SDRAM Interface
wire            sdram_clk               ;
wire            sdram_cke               ;
wire            sdram_cs_n              ;
wire            sdram_cas_n             ;
wire            sdram_ras_n             ;
wire            sdram_we_n              ;
wire[1:0]       sdram_bank              ;
wire[12:0]      sdram_addr              ;
wire[1:0]       sdram_dqm               ;
wire[15:0]      sdram_dq                ;

// reg             wr_trig                 ;
// reg             rd_trig                 ;
reg             rs232_tx                ;
reg             rs232_rx                ;
//============================================

initial begin
        sclk         =1;
        s_rst_n     <=0;
        rs232_rx    <=1;
        #100
        s_rst_n     <=1;
        #200000
        // #1000
        tx_byte();
        #50000
        tx_byte();


end
reg [7:0]   mem_a[ 5:0]  ;

initial $readmemh("D:/Quartus/SDRAM_uart/SIM/tx_data.txt", mem_a) ;
task    tx_byte();
        integer i;
        for (i=0;i<6;i=i+1)begin
            tx_bit (mem_a[i]);

        end

    endtask
task    tx_bit(
        input   [7:0]   data
);
        integer i;
        for (i = 0 ; i<10;i=i+1 ) begin
            case (i)
                0:  rs232_rx    <=      1'b0;
                1:  rs232_rx    <=      data[0];
                2:  rs232_rx    <=      data[1];
                3:  rs232_rx    <=      data[2];
                4:  rs232_rx    <=      data[3];
                5:  rs232_rx    <=      data[4];
                6:  rs232_rx    <=      data[5];
                7:  rs232_rx    <=      data[6];
                8:  rs232_rx    <=      data[7];
                9:  rs232_rx    <=      1'b1;

            endcase
            #560 ;
        end
endtask

GSR GSR(.GSRI(1'b1));

always #10 sclk    = ~sclk     ;

IPtop IPtop_inst(
    . sclk          (  sclk         ),
    . s_rst_n       (   s_rst_n     ),
    .rs232_rx       (rs232_rx       ) ,
    .rs232_tx       ( ) ,
    . sdram_clk     (  sdram_clk    ),
    . sdram_cke     (   sdram_cke   ),
    . sdram_cs_n    (  sdram_cs_n   ),
    . sdram_cas_n   ( sdram_cas_n   ),
    . sdram_ras_n   ( sdram_ras_n   ),
    . sdram_we_n    ( sdram_we_n    ),
    . sdram_bank    (  sdram_bank   ),
    . sdram_addr    (  sdram_addr   ),
    . sdram_dqm     ( sdram_dqm     ),
    . sdram_dq      ( sdram_dq      )
);
// top top_inst(
//     . sclk          (  sclk         ),
//     . s_rst_n       (   s_rst_n     ),
//     .rs232_rx       (rs232_rx       ) ,
//     .rs232_tx       ( ) ,
//     . sdram_clk     (  sdram_clk    ),
//     . sdram_cke     (   sdram_cke   ),
//     . sdram_cs_n    (  sdram_cs_n   ),
//     . sdram_cas_n   ( sdram_cas_n   ),
//     . sdram_ras_n   ( sdram_ras_n   ),
//     . sdram_we_n    ( sdram_we_n    ),
//     . sdram_bank    (  sdram_bank   ),
//     . sdram_addr    (  sdram_addr   ),
//     . sdram_dqm     ( sdram_dqm     ),
//     . sdram_dq      ( sdram_dq      )
// );

defparam    sdram_mode_plus_inst.addr_bits  =13             ;
defparam    sdram_mode_plus_inst.data_bits  =16             ;
defparam    sdram_mode_plus_inst.col_bits    =9              ;
defparam    sdram_mode_plus_inst.mem_sizes  =2*1024*1024    ;


// sdr sdram_mode_plus_inst(
//     .Dq      (sdram_dq      ),
//     .Addr    (sdram_addr    ),
//     .Ba      (sdram_bank    ),
//     .Clk     (sdram_clk     ),
//     .Cke     (sdram_cke     ),
//     .Cs_n    (sdram_cs_n    ),
//     .Ras_n   (sdram_ras_n   ),
//     .Cas_n   (sdram_cas_n   ),
//     .We_n    (sdram_we_n    ),
//     .Dqm     (sdram_dqm     )
// );

sdram_model_plus sdram_mode_plus_inst(
    .Dq      (sdram_dq      ),
    .Addr    (sdram_addr    ),
    .Ba      (sdram_bank    ),
    .Clk     (sdram_clk     ),
    .Cke     (sdram_cke     ),
    .Cs_n    (sdram_cs_n    ),
    .Ras_n   (sdram_ras_n   ),
    .Cas_n   (sdram_cas_n   ),
    .We_n    (sdram_we_n    ),
    .Dqm     (sdram_dqm     ),
    .Debug   (1'b1          )
);

endmodule

// module  tb_sdram_top    ;
// reg sclk    ;
// reg s_rst_n ;


// //============================================
//     reg                           uart_flag             ;
//     reg[ 7:0]                     uart_data             ;
// wire                     wr_trig                ;
// wire                     rd_trig                ;
// wire                     wfifo_wr_en            ;
// wire[ 7:0]               wfifo_data             ;

// // wire             wr_trig                 ;
// // wire             rd_trig                 ;
// //============================================

// initial begin
//         sclk         =1;
//         s_rst_n     <=0;
//         // rs232_rx    <=1;
//         #100
//         s_rst_n     <=1;
// end

// initial begin
//         uart_flag     <= 0 ;
//         uart_data     <= 0 ;   

//         #200
//         uart_flag     <= 1 ;
//         uart_data     <= 8'h55 ;  //write command
//         #20
//         uart_flag       <= 0 ;
//         #200
//         uart_flag     <= 1 ;
//         uart_data     <= 8'h12 ;  //the first data
//         #20
//         uart_flag       <= 0 ;
//         #200
//         uart_flag     <=1 ;
//         uart_data     <= 8'h34 ;  //the first data
//         #20
//         uart_flag       <= 0 ;
//         #200
//         uart_flag     <= 1 ;
//         uart_data     <= 8'h56 ;  //the first data
//         #20
//         uart_flag       <= 0 ;
//         #200
//         uart_flag     <= 1 ;
//         uart_data     <= 8'h78 ;  //the first data
//         #20
//         uart_flag       <= 0 ;
//         #200
//         uart_flag     <= 1 ;
//         uart_data     <= 8'haa ;  //the first data
//         #20
//         uart_flag       <= 0 ;
// end


// always #10 sclk    = ~sclk     ;

// cmd_decode cmd_decode_inst(
//     //system sigmal
//     .sclk             (sclk)     ,
//     .s_rst_n          (s_rst_n)     ,

//     //From uart moudles
//     . uart_flag     (uart_flag)   ,
//     . uart_data     (uart_data)   ,

    
//     . wr_trig       (wr_trig    )   ,
//     . rd_trig       (rd_trig    )   ,
//     . wfifo_wr_en   (wfifo_wr_en)   ,
//     . wfifo_data    (wfifo_data )     
//  );




// endmodule








// `include "../w9864g6kh_verilog_p/Config-AC.v"

// module  tb_sdram_top    ;
// reg sclk    ;
// reg s_rst_n ;


// //============================================
//     //SDRAM Interface
// wire            sdram_clk               ;
// wire            sdram_cke               ;
// wire            sdram_cs_n              ;
// wire            sdram_cas_n             ;
// wire            sdram_ras_n             ;
// wire            sdram_we_n              ;
// wire[1:0]       sdram_bank              ;
// wire[11:0]      sdram_addr              ;
// wire[1:0]       sdram_dqm               ;
// wire[15:0]      sdram_dq                ;
// //============================================
// initial begin
//         sclk         =1;
//         s_rst_n     <=0;
//         // rs232_rx    <=1;
//         #100
//         s_rst_n     <=1;

// end

// always #10 sclk    = ~sclk     ;

// sdram_top sdram_top_inst(
//     . sclk          (  sclk         ),
//     . s_rst_n       (   s_rst_n     ),

//     . sdram_clk     (  sdram_clk    ),
//     . sdram_cke     (   sdram_cke   ),
//     . sdram_cs_n    (  sdram_cs_n   ),
//     . sdram_cas_n   ( sdram_cas_n   ),
//     . sdram_ras_n   ( sdram_ras_n   ),
//     . sdram_we_n    ( sdram_we_n    ),
//     . sdram_bank    (  sdram_bank   ),
//     . sdram_addr    (  sdram_addr   ),
//     . sdram_dqm     ( sdram_dqm     ),
//     . sdram_dq      ( sdram_dq      )

// );
// defparam    sdram_mode_plus_inst.addr_bits  =12             ;
// defparam    sdram_mode_plus_inst.data_bits  =16             ;
// defparam    sdram_mode_plus_inst.col_bits    =9              ;
// defparam    sdram_mode_plus_inst.mem_sizes  =2*1024*1024    ;


// // sdr sdram_mode_plus_inst(
// //     .Dq      (sdram_dq      ),
// //     .Addr    (sdram_addr    ),
// //     .Ba      (sdram_bank    ),
// //     .Clk     (sdram_clk     ),
// //     .Cke     (sdram_cke     ),
// //     .Cs_n    (sdram_cs_n    ),
// //     .Ras_n   (sdram_ras_n   ),
// //     .Cas_n   (sdram_cas_n   ),
// //     .We_n    (sdram_we_n    ),
// //     .Dqm     (sdram_dqm     )
// // );
// sdram_model_plus sdram_mode_plus_inst(
//     .Dq      (sdram_dq      ),
//     .Addr    (sdram_addr    ),
//     .Ba      (sdram_bank    ),
//     .Clk     (sdram_clk     ),
//     .Cke     (sdram_cke     ),
//     .Cs_n    (sdram_cs_n    ),
//     .Ras_n   (sdram_ras_n   ),
//     .Cas_n   (sdram_cas_n   ),
//     .We_n    (sdram_we_n    ),
//     .Dqm     (sdram_dqm     ),
//     .Debug   (1'b1          )
// );





// endmodule
