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
module sdram_read (
    //system signal
    input                       sclk                    ,
    input                       s_rst_n                 ,

    //Cmomunicate with TOP
    input                       rd_en                   ,
    output wire                 rd_req                  ,
    output reg                  flag_rd_end             ,

    //others
    input                       ref_req                 ,
    input                       rd_trig                 ,
    input[15:0]                 sdram_dq                ,

    //write interfaces
    output reg [ 3:0]            rd_cmd                  ,
    output reg [12:0]            rd_addr                 ,
    output wire[ 1:0]            bank_addr               ,
    // output reg [15:0]            rd_data        

    //FIFO inteface
    output reg                  rfifo_wr_en              ,
    output wire[ 7:0]           rfifo_wr_data           
);

/*=========================================/		
//*******    Parameter  define     ******		   
/=========================================*/		
//define state
localparam  S_IDLE              =   5'b0_0001               ;
localparam  S_REQ               =   5'b0_0010               ;
localparam  S_ACT               =   5'b0_0100               ;
localparam  S_RD                =   5'b0_1000               ;
localparam  S_PRE               =   5'b1_0000               ;

//SDRAM command
localparam  CMD_NOP             = 4'b0111       ;
localparam  CMD_PRE             = 4'b0010       ;
localparam  CMD_AREF            = 4'b0001       ;
localparam  CMD_MSET            = 4'b0000       ;
localparam  CMD_ACT             = 4'b0011       ;
localparam  CMD_RD              = 4'b0101       ;


/*=========================================/		
//*******   reg interface define   ******		
/=========================================*/		
reg         flag_rd             ;
reg[ 4:0]   state               ;
reg         falg_act_end        ;
reg         flag_pre_end        ;
reg         sd_row_end          ;

reg[ 1:0]   burst_cnt           ;
reg[ 1:0]   burst_cnt_t         ;
reg         rd_data_end         ;

reg[ 3:0]   act_cnt             ;
reg[ 3:0]   break_cnt           ;
reg[ 6:0]   col_cnt             ;

reg[12:0]   row_addr            ;
        
reg         rfifo_wr_en_r1      ;
reg         rfifo_wr_en_r2      ;
reg         rfifo_wr_en_r3      ;

/*=========================================/		
//*******    wire interface  define ******		
/=========================================*/		
wire[8:0]  col_addr            ;
        
/*========================================		
//*******       Main  Code         ******		
=========================================*/		

//flag_rd
always @(posedge sclk or negedge s_rst_n) begin
    if(!s_rst_n)
        flag_rd <=  1'b0 ;
    else if(rd_trig == 1'b1 && flag_rd == 1'b0 )
        flag_rd <=  1'b1 ;
    else if(rd_data_end == 1'b1 )
        flag_rd <=  1'b0 ;
end

//****************************STATE**********************************
always @(posedge sclk or negedge s_rst_n) begin
    if(!s_rst_n)
        state   <=  S_IDLE  ;
    else case (state)
        S_IDLE:
                if(rd_trig == 1'b1 )
                    state <= S_REQ  ;
                else 
                    state <= S_IDLE ;
        S_REQ :
                if(rd_en == 1'b1 )
                    state <= S_ACT  ;
                else 
                    state <= S_REQ  ;
        S_ACT :
                if(falg_act_end == 1'b1 )
                    state <= S_RD   ;
                else 
                    state <= S_ACT  ;
        S_RD  :
                if(rd_data_end == 1'b1 )
                    state <= S_PRE  ;
                else if(ref_req == 1'b1 && burst_cnt_t == 'd2 && flag_rd == 1'b1 )
                    state <= S_PRE  ;
                else if(sd_row_end == 1'b1 && flag_rd == 1'b1)
                    state <= S_PRE  ;
        S_PRE :
                if(ref_req == 1'b1 && flag_rd == 1'b1 )
                    state <= S_REQ  ;
                // else if(sd_row_end == 1'b1 )
                //     state <= S_ACT  ;
                else if(flag_pre_end == 1'b1 && flag_rd == 1'b1 )
                    // state <= S_IDLE ;
                    state <= S_ACT  ;
                // else if(rd_data_end == 1'b1 )
                else if(flag_rd == 1'b0 )
                    state <= S_IDLE ;

        default: 
                state   <= S_IDLE   ;
    endcase
end
    
    
//---------------------------------------------------------------------
//rd_cmd
always @(posedge sclk or negedge s_rst_n) begin
    if(!s_rst_n )
        rd_cmd  <=  CMD_NOP ;
    else case(state)
        S_ACT : 
                if(act_cnt == 'd0)
                    rd_cmd <= CMD_ACT ;
                else
                    rd_cmd <= CMD_NOP ;
        S_RD  :
                if(burst_cnt == 'd0)
                    rd_cmd <= CMD_RD    ;
                else
                    rd_cmd <= CMD_NOP   ;
        S_PRE :
                if(break_cnt == 'd0)
                    rd_cmd <= CMD_PRE    ;
                else
                    rd_cmd <= CMD_NOP   ;
        default:
                rd_cmd <= CMD_NOP   ;
    endcase     
end

//

//rd_addr
always @(*) begin
    case (state)
        S_ACT   : 
            if(act_cnt == 'd0)
                rd_addr <= row_addr ;
        S_RD    :
            rd_addr <= {4'b0000,col_addr} ;
        S_PRE   :
            if(break_cnt == 'd0 )
            rd_addr <= {13'b0_0100_0000_0000} ;
        default: 
            ;
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
        flag_rd_end <= 1'b0 ;
    else if( (state == S_PRE && ref_req == 1'b1 )
            || (state == S_PRE && flag_rd == 1'b0) )
        flag_rd_end <= 1'b1 ;
    else 
        flag_rd_end <= 1'b0 ; 
end
//burst_cnt
always @(posedge sclk or negedge s_rst_n) begin
    if(!s_rst_n)
        burst_cnt <= 'd0 ;
    else if(state == S_RD )
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

//rd_data_end
always @(posedge sclk or negedge s_rst_n) begin
    if(!s_rst_n)
        rd_data_end <= 1'b0 ;
    // else if(row_addr =='d2 && col_addr == 'd511 )
    else if(row_addr =='d0 && col_addr == 'd1 )
        rd_data_end <= 1'b1 ;
    else
        rd_data_end <= 1'b0 ;
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
//         0 : rd_data <=  'd3 ;
//         1 : rd_data <=  'd5 ;
//         2 : rd_data <=  'd7 ;
//         3 : rd_data <=  'd9 ;

//         default: rd_data <= 'd0 ;
//     endcase
// end
//-----------------------------------------------------------

//rfifo_wr_en
//延迟三拍正好满足cas潜伏期
always @(posedge sclk) begin
    rfifo_wr_en_r1  <=   state[3] ;
    rfifo_wr_en_r2  <=   rfifo_wr_en_r1 ;
    rfifo_wr_en_r3  <=   rfifo_wr_en_r2 ;
    rfifo_wr_en     <=   rfifo_wr_en_r3 ;
end

// assign col_addr     =   {col_cnt , burst_cnt_t } ;

assign col_addr     =   {7'd0 , burst_cnt_t } ;
assign bank_addr    =   2'b00    ;
assign rd_req       =   state[1] ;
assign rfifo_wr_data=   sdram_dq[ 7:0] ;
// assign rfifo_wr_en  =   state[3] ;
endmodule