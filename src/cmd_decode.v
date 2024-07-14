/** ---------------------------------File Info-------------------------------- 
 ** @file:               cmd_decode.v                                        
 ** @author:             黄锦  
 ** @contact			 3056830955@qq.com                                    
 ** @date:               2024-06-21            
 ** @version:            V0.0                                                  
 ** @brief:              
 **                      
 **--------------------------------------------------------------------------- 
 ** @modified:                                                               
 ** @date:               2024-06-21            
 ** @version:            V0.0                                                  
 ** @description:        
 ** @note:               
 **--------------------------------------------------------------------------- 
 ** @copyright:          
 ***********************************************************************/ 

 module cmd_decode (
    //system sigmal
    input                           sclk                    ,
    input                           s_rst_n                 ,

    //From uart moudles
    input                           uart_flag               ,
    input[ 7:0]                     uart_data               ,

    //
    output wire                     wr_trig                 ,
    output wire                     rd_trig                 ,
    output wire                     wfifo_wr_en             ,
    output wire[ 7:0]               wfifo_data
 );

 /*=========================================/		
 //*******    Parameter  define     ******		
 /=========================================*/		
localparam              REC_NUM_END             =           'd4                 ;
 /*=========================================/		
 //*******   reg interface define   ******		
 /=========================================*/		
reg[ 2:0]               rec_num                     ;
reg[ 7:0]               cmd_reg                     ;
        
 /*=========================================/		
 //*******    wire interface  define ******		
 /=========================================*/		
        
        
 /*========================================		
 //*******       Main  CODE       ******		
 =========================================*/		
    
always @(posedge sclk or negedge s_rst_n) begin
    if(!s_rst_n)
        rec_num <= 'd0 ;
    else if(uart_flag == 1'b1  && uart_data == 8'haa && rec_num =='d0)
        rec_num <= 'd0 ;
    else if(uart_flag == 1'b1 && rec_num == REC_NUM_END )
        rec_num <= 'd0 ;
    else if(uart_flag == 1'b1)
        rec_num <= rec_num + 1'b1 ;
end

always @(posedge sclk or negedge s_rst_n) begin
    if(!s_rst_n)
        cmd_reg <= 8'h00 ;
    else if(uart_flag == 1'b1  )
        cmd_reg <= uart_data ;

end

assign wr_trig  =   (rec_num == REC_NUM_END  )? uart_flag : 1'b0 ;
assign rd_trig  =   (rec_num == 'd0 && uart_data == 8'haa )? uart_flag : 1'b0 ;
assign wfifo_wr_en  =   (rec_num >= 'd1) ? uart_flag : 1'b0 ;
assign wfifo_data  =    uart_data ;
 endmodule