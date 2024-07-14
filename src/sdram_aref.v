module sdram_aref (
    //system signal
    input               sclk            ,
    input               s_rst_n         ,

    //communicate with ARBIT
    input               ref_en          ,
    output reg          ref_req         ,
    output wire         flag_ref_end    ,

    output reg [ 3:0 ]  aref_cmd        ,
    output wire[12:0 ]  sdram_addr      ,

    input               flag_init_end       
);

//==============================================================================\
//**************Define Parameter and Interface Signal****************//
//==============================================================================/
localparam  DELAY_15US              = 749           ;
localparam  CMD_AREF                = 4'b0001       ;
localparam  CMD_NOP                 = 4'b0111       ;
localparam  CMD_PRE                 = 4'b0010       ;



reg[ 3: 0]      cmd_cnt             ;
reg[ 9: 0]      ref_cnt             ;

reg             flag_ref            ;

//=============================================================================\
//***************Main Code *******************************************
//============================================================================/


always @(posedge sclk or negedge s_rst_n) begin
    if(!s_rst_n)
        ref_cnt <=  'd0;
    else if(ref_cnt >= DELAY_15US)
        ref_cnt <=  'd0;
    else if(flag_init_end == 1'b1)
        ref_cnt <=  ref_cnt +   1'b1;

end
always @(posedge sclk or negedge s_rst_n) begin
    if(!s_rst_n)
        flag_ref <= 1'b0;
    else if(flag_ref_end == 1'b1)
        flag_ref <= 1'b0;
    else if(ref_en == 1'b1)
        flag_ref <= 1'b1;

end

always @(posedge sclk or negedge s_rst_n) begin
    if(!s_rst_n )
        cmd_cnt <= 1'd0;
    else if(flag_ref == 1'b1 )
        cmd_cnt <= cmd_cnt +1'b1;
    else
        cmd_cnt <= 'd0;
end

always @(posedge sclk or negedge s_rst_n) begin
    if(s_rst_n == 1'b0)
        aref_cmd <=     CMD_NOP ;
    else if(cmd_cnt == 'd2 )
        aref_cmd        <=      CMD_AREF    ;
    else
        aref_cmd        <=      CMD_NOP     ;
    // else case(cmd_cnt)
    //     // 1:          aref_cmd        <=      CMD_PRE     ;
    //     2:          aref_cmd        <=      CMD_AREF    ;
    //     default:    aref_cmd        <=      CMD_NOP     ;
    // endcase
end
always @(posedge sclk or negedge s_rst_n ) begin
    if(!s_rst_n)
        ref_req <= 1'b0 ;
    else if(ref_en == 1'b1)
        ref_req <= 1'b0 ;
    else if(ref_cnt >= DELAY_15US)
        ref_req <= 1'b1 ;
end 
assign  flag_ref_end    =   (cmd_cnt >= 'd3 )? 1'b1 : 1'b0 ;
//根据W9825G6KH-6芯片手册所写，在auto reftesh 的时候addr都可以。
assign  sdram_addr      =   13'b0_0100_0000_0000                      ;
// assign  ref_req         =   (ref_cnt >= DELAY_15US )? 1'b1 : 1'b0   ;



endmodule