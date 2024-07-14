/** ---------------------------------File Info-------------------------------- 
 ** @file:               sdram_write.v                                        
 ** @author:             黄锦  
 ** @contact			 3056830955@qq.com                                    
 ** @date:               2024-06-19            
 ** @version:            V0.0                                                  
 ** @brief:              sdram写模块
 **                      
 **--------------------------------------------------------------------------- 
 ** @modified:                                                               
 ** @date:               2024-06-19            
 ** @version:            V0.0                                                  
 ** @description:        sdram写模块
 ** @note:               
 **--------------------------------------------------------------------------- 
 ** @copyright:          开源骚客
 ***********************************************************************/ 
module sdram_write (
    //system signal
    input                       sclk                    ,
    input                       s_rst_n                 ,

    //Cmomunicate with TOP
    input                       wr_en                   ,
    output wire                 wr_req                  ,
    output reg                  flag_wr_end             ,

    //others
    input                       ref_req                 ,
    input                       wr_trig                 ,

    //write interfaces
    output reg [ 3:0]            wr_cmd                  ,
    output reg [12:0]            wr_addr                 ,
    output wire[ 1:0]            bank_addr               ,
    output wire[15:0]            wr_data                 ,
    //wrfifo interface 
    output wire                 wfifo_rd_en             ,
    input [7:0]                 wfifo_rd_data           

    //
);

/*=========================================/		
//*******    Parameter  define     ******		   
/=========================================*/		
//define state
localparam  S_IDLE              =   5'b0_0001               ;
localparam  S_REQ               =   5'b0_0010               ;
localparam  S_ACT               =   5'b0_0100               ;
localparam  S_WR                =   5'b0_1000               ;
localparam  S_PRE               =   5'b1_0000               ;

//SDRAM command
localparam  CMD_NOP             = 4'b0111       ;
localparam  CMD_PRE             = 4'b0010       ;
localparam  CMD_AREF            = 4'b0001       ;
localparam  CMD_MSET            = 4'b0000       ;
localparam  CMD_ACT             = 4'b0011       ;
localparam  CMD_WR              = 4'b0100       ;


/*=========================================/		
//*******   reg interface define   ******		
/=========================================*/		
reg         flag_wr             ;
reg[ 4:0]   state               ;
reg         falg_act_end        ;
reg         flag_pre_end        ;
reg         sd_row_end          ;

reg[ 1:0]   burst_cnt           ;
reg[ 1:0]   burst_cnt_t         ;
reg         wr_data_end         ;

reg[ 3:0]   act_cnt             ;
reg[ 3:0]   break_cnt           ;
reg[ 6:0]   col_cnt             ;

reg[12:0]   row_addr            ;
        
/*=========================================/		
//*******    wire interface  define ******		
/=========================================*/		
wire[8:0]  col_addr            ;
        
/*========================================		
//*******       Main  Code         ******		
=========================================*/		

//flag_wr
always @(posedge sclk or negedge s_rst_n) begin
    if(!s_rst_n)
        flag_wr <=  1'b0 ;
    else if(wr_trig == 1'b1 && flag_wr == 1'b0 )
        flag_wr <=  1'b1 ;
    else if(wr_data_end == 1'b1 )
        flag_wr <=  1'b0 ;
end

//****************************STATE**********************************
always @(posedge sclk or negedge s_rst_n) begin
    if(!s_rst_n)
        state   <=  S_IDLE  ;
    else case (state)
        S_IDLE:
                if(wr_trig == 1'b1 )
                    state <= S_REQ  ;
                else 
                    state <= S_IDLE ;
        S_REQ :
                if(wr_en == 1'b1 )
                    state <= S_ACT  ;
                else 
                    state <= S_REQ  ;
        S_ACT :
                if(falg_act_end == 1'b1 )
                    state <= S_WR   ;
                else 
                    state <= S_ACT  ;
        S_WR  :
                if(wr_data_end == 1'b1 )
                    state <= S_PRE  ;
                else if(ref_req == 1'b1 && burst_cnt_t == 'd2 && flag_wr == 1'b1 )
                    state <= S_PRE  ;
                else if(sd_row_end == 1'b1 && flag_wr == 1'b1)
                    state <= S_PRE  ;
        S_PRE :
                if(ref_req == 1'b1 && flag_wr == 1'b1 )
                    state <= S_REQ  ;
                // else if(sd_row_end == 1'b1 )
                    // state <= S_ACT  ;
                else if(flag_pre_end == 1'b1 && flag_wr == 1'b1 )
                    // state <= S_IDLE ;
                    state <= S_ACT  ;
                // else if(wr_data_end == 1'b1 )
                else if(flag_wr == 1'b0 )
                    state <= S_IDLE ;

        default: 
                state   <= S_IDLE   ;
    endcase
end
    
    
//---------------------------------------------------------------------
//wr_cmd
always @(posedge sclk or negedge s_rst_n) begin
    if(!s_rst_n )
        wr_cmd  <=  CMD_NOP ;
    else case(state)
        S_ACT : 
                if(act_cnt == 'd0)
                    wr_cmd <= CMD_ACT ;
                else
                    wr_cmd <= CMD_NOP ;
        S_WR  :
                if(burst_cnt == 'd0)
                    wr_cmd <= CMD_WR    ;
                else
                    wr_cmd <= CMD_NOP   ;
        S_PRE :
                if(break_cnt == 'd0)
                    wr_cmd <= CMD_PRE    ;
                else
                    wr_cmd <= CMD_NOP   ;
        default:
                wr_cmd <= CMD_NOP   ;
    endcase     
end

//

//wr_addr
always @(*) begin
    case (state)
        S_ACT   : 
            if(act_cnt == 'd0)
                wr_addr <= row_addr ;
            else
                wr_addr <=  'd0     ;
        S_WR    :
            wr_addr <= {4'b0000,col_addr} ;
        S_PRE   :
            if(break_cnt == 'd0 )
                wr_addr <= {13'b0_0100_0000_0000} ;
            else
                wr_addr <=  'd0     ;
        default: 
                wr_addr <=  'd0     ;
            
    endcase
end
//flag act end
always @(posedge sclk or negedge s_rst_n)begin
    if(!s_rst_n)
        falg_act_end <= 1'b0 ;
    else if(act_cnt == 'd3 )
        falg_act_end <= 1'b1 ;
    else 
        falg_act_end <= 1'b0 ;
end
//act_cnt
always @(posedge sclk or negedge s_rst_n) begin
    if(!s_rst_n)
        act_cnt <= 'd0;
    else if(state == S_ACT)
        act_cnt <= act_cnt + 1'b1 ;
    else
        act_cnt <= 'd0;
end
//flag pre end
always@(posedge sclk or negedge s_rst_n)begin
    if(!s_rst_n)    
        flag_pre_end <= 1'b0 ;
    else if(break_cnt == 'd3 )
        flag_pre_end <= 1'b1 ;
    else
        flag_pre_end <= 1'b0 ;

end

always @(posedge sclk or negedge s_rst_n) begin
    if(!s_rst_n)
        flag_wr_end <= 1'b0 ;
    else if( (state == S_PRE && ref_req == 1'b1 )
            || (state == S_PRE && flag_wr == 1'b0) )
        flag_wr_end <= 1'b1 ;
    else 
        flag_wr_end <= 1'b0 ; 
end
//burst_cnt
always @(posedge sclk or negedge s_rst_n) begin
    if(!s_rst_n)
        burst_cnt <= 'd0 ;
    else if(state == S_WR )
        burst_cnt <= burst_cnt + 1'b1 ;
    else
        burst_cnt <= 'd0 ;
end
//burst_cnt_t
always @(posedge sclk ) begin
        burst_cnt_t <= burst_cnt ;
end
//break_cnt
always @(posedge sclk or negedge s_rst_n) begin
    if(!s_rst_n)
        break_cnt <= 'd0;
    else if(state == S_PRE)
        break_cnt <= break_cnt + 1'b1 ;
    else
        break_cnt <= 'd0;
end

//wr_data_end
always @(posedge sclk or negedge s_rst_n) begin
    if(!s_rst_n)
        wr_data_end <= 1'b0 ;
    else if(row_addr =='d0 && col_addr == 'd1 )//更改
        wr_data_end <= 1'b1 ;
    else
        wr_data_end <= 1'b0 ;
end

//col_cnt
always @(posedge sclk or negedge s_rst_n) begin
    if(!s_rst_n)
        col_cnt <= 'd0 ;
    else if(col_addr == 'd511 )
        col_cnt <= 'd0 ;
    else if(burst_cnt_t == 'd3 )
        col_cnt <= col_cnt + 1'b1 ;

end

always @(posedge sclk or negedge s_rst_n) begin
    if(!s_rst_n)
        sd_row_end <= 1'b0 ;
    else if(col_addr == 'd509)
        sd_row_end <= 1'b1 ;
    else
        sd_row_end <= 1'b0 ; 
end
always @(posedge sclk or negedge s_rst_n) begin
    if(!s_rst_n)
        row_addr    <=  'd0 ;
    else if(sd_row_end == 1'b1 )
        row_addr    <=  row_addr + 1'b1 ; 
end

//-----------------------------------------------------------
// always @(*) begin
//     case (burst_cnt_t)
//         0 : wr_data <=  'd3 ;
//         1 : wr_data <=  'd5 ;
//         2 : wr_data <=  'd7 ;
//         3 : wr_data <=  'd9 ;

//         default: wr_data <= 'd0 ;
//     endcase
// end
//-----------------------------------------------------------

// assign col_addr     =   {col_cnt , burst_cnt_t } ;
assign col_addr     =   {7'd0 , burst_cnt_t } ;

// assign col_addr     =   'd0      ;//只使用SDRAM的前4个地址
assign bank_addr    =   2'b00    ;
assign wr_req       =   state[1] ;

assign  wfifo_rd_en =   state[3]    ;
assign  wr_data     =   wfifo_rd_data   ;

endmodule