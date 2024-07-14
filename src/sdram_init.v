/*SDRAM Comand format
*   cmd                 cs    ras     cas      we      
*   precharge           0       0       1       0
*   A_Refresh           0       0       0       1
*   NOP                 0       1       1       1
*   Mode-Set            0       0       0       0
*   
*   addr    :       12'b 0000_0011_0010
*
*/




module sdram_init (
    input                           sclk                           ,
    input                           s_rst_n                        ,

    //others
    output  reg [3:0]               cmd_reg                         ,
    output  wire[12:0]              sdram_addr                      ,
    output  wire                    flag_init_end                   
);

//==============================================================================
//**************Define Parameter and Interface Signal****************//
//==============================================================================
localparam DELAY_200US =  10000     ;

//SDRAM command 
localparam  NOP             = 4'b0111       ;
localparam  PRE             = 4'b0010       ;
localparam  AREF            = 4'b0001       ;
localparam  MSET            = 4'b0000       ;



reg [13:0]              cnt_200us               ;
wire                     flag_200us              ;
reg [3:0]               cnt_cmd                 ;

//===============================================================================
//***************Main Code *******************************************
//============================================================================
//cnt_200us
always @(posedge sclk or negedge s_rst_n) begin
    if(!s_rst_n )
        cnt_200us <= 'd0;
    else if(flag_200us == 1'b0)
        cnt_200us <= cnt_200us +1'b1;
end

always @(posedge sclk or negedge s_rst_n ) begin
    if(!s_rst_n)
        cnt_cmd <= 'd0;
    else if(flag_200us == 1'b1 && flag_init_end ==1'b0)
        cnt_cmd <= cnt_cmd +1'b1; 
end

//cmd_reg
always @(posedge sclk or negedge s_rst_n) begin
    if(!s_rst_n)
        cmd_reg   <= NOP;
    else if(flag_200us == 1'b1 )
        case (cnt_cmd)
            0:  cmd_reg <= PRE      ;
            1:  cmd_reg <= AREF     ;
            5:  cmd_reg <= AREF     ;
            9:  cmd_reg <= MSET     ;
            default: cmd_reg   <= NOP;  
        endcase 
end

// always @(posedge sclk or negedge s_rst_n) begin
//     if(!s_rst_n)
//         sdram_addr <=           'b0;
//     else if(flag_200us ==  1'b1)
//         case(cnt_cmd)
//             0 :     sdram_addr <=       12'b0100_0000_0000  ;
//             0 :     sdram_addr <=       12'b0100_0000_0000  ;
//             0 :     sdram_addr <=       12'b0100_0000_0000  ;
//             0 :     sdram_addr <=       12'b0100_0000_0000  ;
//         default:    
// end
assign  flag_init_end   =   (cnt_cmd >='d10)?1'b1:1'b0;

//根据W9825G6KH-6芯片手册所写，addr的第十位即A10=1时 precharge all bank
assign  sdram_addr  =   (cmd_reg == MSET) ? 13'b0_0000_0011_0010 : 13'b0_0100_0000_0000;//只需要发送precharge命令


assign  flag_200us  =   (cnt_200us >= DELAY_200US )? 1'b1 : 1'b0;
endmodule