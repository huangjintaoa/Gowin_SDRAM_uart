`define SIM  //仿真模块，上板要把这行注释
//
module uart_tx (
    input       sclk                ,//50M
    input       s_rst_n             ,

    output  reg rs232_tx            ,
    
    // input   reg [7:0]tx_data    ,
    // input       tx_trig         
    //FIFO
    input           rfifo_empty     ,
    output  reg     rfifo_rd_en     ,
    input[ 7:0]     rfifo_rd_data
    
    );
    
//=========================================\
//*******************Define Parameter  and Internal Signal
//=========================================\
`ifndef SIM
localparam  BAUD_END    = 5207          ;//波特率9600
`else
localparam  BAUD_END    = 28          ;
`endif
localparam  BAUD_M      = BAUD_END/2-1  ;
localparam  BIT_END     = 9             ;


reg[7:0]        tx_data_r           ;
reg             tx_flag             ;
reg[12:0]       baud_cnt            ;
reg             bit_flag            ;
reg [3:0]       bit_cnt             ;

reg [7:0]tx_data    ;
wire     tx_trig         ;
reg      tx_trig_r  ;
//=======================================\
//******************Main Code **********
//=======================================\
//rfifo_rd_en
always @(posedge sclk or negedge s_rst_n) begin
    if(!s_rst_n)
        rfifo_rd_en <= 1'b0 ;
    else if(rfifo_empty == 1'b0 && tx_flag == 1'b0 && rfifo_rd_en== 1'b0 )
        rfifo_rd_en <= 1'b1 ;
    else
        rfifo_rd_en <= 1'b0 ;
end

//tx_trig_r
always @(posedge sclk) begin
    tx_trig_r <= tx_trig;
end

//tx_data_r
always @(posedge sclk or negedge s_rst_n) begin
    if(!s_rst_n)
        tx_data_r       <=      'd0;
    else if( tx_trig_r == 1'b1 && tx_flag ==1'b1)
        tx_data_r       <=      rfifo_rd_data     ;
        
end

//tx_flag
always @(posedge sclk or negedge s_rst_n) begin
    if(!s_rst_n)
        tx_flag     <=      1'b0        ;
    else if(tx_trig == 1'b1)
        tx_flag     <=      1'b1        ;
    else if( bit_cnt == BIT_END && bit_flag == 1'b1)
        tx_flag     <=      1'b0        ;    
end

//baud_cnt
always @(posedge sclk or negedge s_rst_n) begin
    if(!s_rst_n)
        baud_cnt        <=  'd0;
    else if(baud_cnt ==BAUD_END)
        baud_cnt        <= 'd0 ;
    else if(tx_flag  == 1'b1   )
        baud_cnt        <= baud_cnt + 1'b1 ;
    else    
        baud_cnt        <= 'd0 ;
end
//bit_flag
always @(posedge sclk or negedge s_rst_n) begin
    if(!s_rst_n)
        bit_flag    <=  1'b0        ;
    else if(baud_cnt == BAUD_END)
        bit_flag    <=  1'b1        ;
    else
        bit_flag    <=  1'b0        ;
end

//bit_cnt
always @(posedge sclk or negedge s_rst_n) begin
    if(!s_rst_n)
        bit_cnt <=  'd0     ;
    else if(bit_flag == 1'b1 && bit_cnt == BIT_END) 
        bit_cnt <=  'd0     ;
    else if(bit_flag == 1'b1)
        bit_cnt <= bit_cnt  + 1'b1;
end

//rs232 tx
always @(*) begin
    if(!s_rst_n)
        rs232_tx    <=      1'b1;
    else if(tx_flag == 1'b1)begin
        case (bit_cnt)
            0:  rs232_tx    <=      1'b0;
            1:  rs232_tx    <=      tx_data_r[0];
            2:  rs232_tx    <=      tx_data_r[1];
            3:  rs232_tx    <=      tx_data_r[2];
            4:  rs232_tx    <=      tx_data_r[3];
            5:  rs232_tx    <=      tx_data_r[4];
            6:  rs232_tx    <=      tx_data_r[5];
            7:  rs232_tx    <=      tx_data_r[6];
            8:  rs232_tx    <=      tx_data_r[7];
            9:  rs232_tx    <=      1'b1;
            default : rs232_tx    <=      1'b1;

        endcase
    end
    else 
        rs232_tx        <=      1'b1        ;
end

assign  tx_trig = rfifo_rd_en ;



endmodule