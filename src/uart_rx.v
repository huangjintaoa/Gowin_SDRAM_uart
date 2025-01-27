`define SIM  //仿真模块，上板要把这行注释

module  uart_rx (
        //system signals
        input   sclk        ,//50M
        input   s_rst_n     ,
        //UART interface
        input   rs232_rx    ,
        //others
        output  reg [7:0]   rx_data     ,
        output  reg         po_flag     

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
localparam  BIT_END     = 8             ;

reg         rx_rl                   ;
reg         rx_r2                   ;
reg         rx_r3                   ;
reg         rx_flag                 ;
reg [12:0]  baud_cnt                ;
reg         bit_flag                ;
reg [3:0]   bit_cnt                 ;

//=======================================\
//******************Main Code **********
//=======================================\

assign  rx_neg  =   ~rx_r2 & rx_r3  ;


always @(posedge sclk) begin
    rx_rl   <=  rs232_rx    ;
    rx_r2   <=  rx_rl       ;
    rx_r3   <=  rx_r2       ;
end

always @(posedge sclk or negedge s_rst_n) begin
   if(!s_rst_n)
        rx_flag     <=  1'b0    ;
    else if(rx_neg==1)
        rx_flag <=  1'b1;
    else if(bit_cnt == 'd0 && baud_cnt == BAUD_END)
        rx_flag <=1'b0;

end

always @(posedge sclk or negedge s_rst_n) begin
    if(!s_rst_n)
        baud_cnt <= 'd0;
    else if(baud_cnt == BAUD_END)
        baud_cnt <= 'd0;
    else if(rx_flag==1'b1)
        baud_cnt <= baud_cnt +1'b1;
    else
        baud_cnt <= 0;
end
always @(posedge sclk or negedge s_rst_n) begin
    if(!s_rst_n)
        bit_flag    <= 1'b0;
    else if(baud_cnt == BAUD_M)
        bit_flag    <=  1'b1;
    else
        bit_flag    <= 1'b0;
    
end

always @(posedge sclk or negedge s_rst_n) begin
    if(!s_rst_n)
        bit_cnt <= 'd0;
    else if(bit_flag == 1'b1 && bit_cnt ==BIT_END)
        bit_cnt <='d0;
    else  if(bit_flag == 1'b1 )
        bit_cnt <=bit_cnt +1'b1;
end

always @(posedge sclk or negedge s_rst_n) begin
    if(!s_rst_n)
        rx_data <= 'd0;
    else if(bit_flag == 1'b1 && bit_cnt >= 'd1)
        rx_data <= {rx_r2,rx_data[7:1]};
    else if(rx_data !=0 && rx_flag == 'd0)
        rx_data <= 'd0;
    
end

always @(posedge sclk or negedge s_rst_n) begin
    if(!s_rst_n)
        po_flag <=  1'b0;
    else if(bit_cnt == BIT_END && bit_flag ==1'b1)
        po_flag <=  1'b1;
    else 
        po_flag <=1'b0;
end

    
endmodule