`timescale 1ns/1ns
// cmd  == {O_sdram_ras_n,O_sdram_cas_n,O_sdram_wen_n};

module IPsdram_top (
    input                   sclk                    ,
    input                   s_rst_n                 ,
//sdram clk
    // output wire                   I_sdram_clk             ,
    // output wire                    I_sdrc_clk              ,
    //SDRAM user Interface
    output wire             I_sdrc_selfrefresh_i    ,
    output wire             I_sdrc_power_down_i     ,
    output wire[ 8:0]       I_sdrc_data_len_i       ,
    output wire[ 1:0]       I_sdrc_dqm_i            ,

    output reg              I_sdrc_wr_n_i           ,
    output reg              I_sdrc_rd_n_i           ,
    output reg [23:0]       I_sdrc_addr_i           ,
    output wire[15:0]       I_sdrc_data_i           ,

    input      [15:0]       O_sdrc_data_o           ,
    input                   O_sdrc_init_done_o      ,
    input                   O_sdrc_busy_n_o         ,
    input                   O_sdrc_wrd_ack_o        ,
    input                   O_sdrc_rd_valid_o       ,

    //orthers
    input                   wr_trig                 ,
    input                   rd_trig                 ,

    output reg              flag_rst_n              ,
    input   [ 3:0]          sdram_cmd               ,
    //FIFO signal
    output reg                    wfifo_rd_en       ,
    input [7:0]                 wfifo_rd_data       ,
    output wire                     rfifo_wr_en     ,
    output wire[7:0]            rfifo_wr_data          
);


//==============================================================================\
//**************Define Parameter and Interface Signal****************//
//==============================================================================/
localparam IDLE         =       5'b0_0001 ;
localparam WRITE_WAIT   =       5'b0_0010 ;
localparam WRITE        =       5'b0_0100 ;
localparam READ_WAIT    =       5'b0_1000 ;
localparam READ         =       5'b1_0000 ;

localparam data_len =   4          ;//数据长度
localparam DELAY_200US =  10000     ;


//reg define
reg [ 4:0]      state               ;
// reg [15:0]  delay_cnt       ;
reg [ 7:0]      wr_data_cnt         ;
reg [ 3:0]      rd_addr_cnt         ;
reg [ 3:0]      rd_data_cnt         ;
reg             rd_start_cnt_flag   ; //开始读出计数
reg             wr_flag             ;
reg             rd_flag             ;

wire[ 1:0]      bank_addr           ;
reg [12:0]      wr_row_addr         ;
reg [ 8:0]      wr_col_addr         ;
reg [ 15:0]      RCD_delay_cnt      ;

reg [12:0]      rd_row_addr         ;
reg [ 8:0]      rd_col_addr         ;

reg [13:0]              cnt_200us   ;





//=============================================================================\
//***************Main Code *******************************************
//============================================================================/



assign  I_sdrc_selfrefresh_i    = 1'b0      ;
assign  I_sdrc_power_down_i     = 1'b0      ;
assign  I_sdrc_data_len_i       = data_len-1;
assign  I_sdrc_dqm_i            = 0         ;
assign  bank_addr               = 2'b00     ;//bank选择，此处只选用了bank0 只需要逻辑赋值即可

// assign  
assign  flag_200us  =   (cnt_200us >= DELAY_200US )? 1'b1 : 1'b0;

//cnt_200us
always @(posedge sclk or negedge s_rst_n) begin
    if(!s_rst_n )
        cnt_200us <= 'd0;
    else if(flag_200us == 1'b0 || cnt_200us <=( DELAY_200US + 'd5))
        cnt_200us <= cnt_200us +1'b1;
end



always @(posedge sclk or negedge s_rst_n) begin
    if(!s_rst_n)
        flag_rst_n <= 1'b1 ;
    else if(flag_200us==1 && cnt_200us >=( DELAY_200US + 'd5))
        flag_rst_n <= 1'b1;
    else if(flag_200us)
        flag_rst_n <= 1'b0 ;
    else
        flag_rst_n <= 1'b1 ;

end


always @(posedge sclk or negedge s_rst_n ) begin
    if(!s_rst_n)begin
        state       <=      IDLE        ;
        I_sdrc_wr_n_i <= 1'b1 ;
        I_sdrc_rd_n_i <= 1'b1 ;
        I_sdrc_addr_i <= 'd0 ;
        // I_sdrc_data_i <= 'dz ;
        // data_cnt      <= 'd0 ;
        // wfifo_rd_en   <= 1'b0 ;
        // rfifo_wr_en <= 1'b0;

    end
    else case (state)
        IDLE: 
            if(O_sdrc_init_done_o & O_sdrc_busy_n_o & wr_flag & flag_rst_n )//初始化完成之后进入读写
            begin
                state <= WRITE_WAIT ;
                // wfifo_rd_en <= 1'b1 ;
            end
            else if(O_sdrc_init_done_o & O_sdrc_busy_n_o & rd_flag & flag_rst_n )
            begin
                state <= READ_WAIT ;
                // rfifo_wr_en <= 1'b1 ;
            end

            else
                state <= IDLE ;
        WRITE_WAIT:
            if(O_sdrc_busy_n_o & wr_flag )begin//空闲状态 碰到写请求
                I_sdrc_wr_n_i   <= 1'b0         ;
                state           <= WRITE        ;
                // wfifo_rd_en <= 1'b1 ;
                I_sdrc_addr_i   <= {bank_addr , wr_row_addr , wr_col_addr} ;
                // I_sdrc_data_i <= wfifo_rd_data ; //仿真时候发现在这里进入读fifo比较合适 可更改
                end
            else
                state <= WRITE_WAIT ;
        WRITE:
            begin
            I_sdrc_wr_n_i <= 1'b1 ;
            // I_sdrc_data_i <= wfifo_rd_data ;
            // I_sdrc_data_i <= I_sdrc_data_i + 1'b1 ;
            if(wr_flag == 1'b1 )
                state <= WRITE ;
            else begin
                // wfifo_rd_en <= 1'b0 ;
                state <= READ_WAIT  ;
                // I_sdrc_data_i <= 'dz ;
            end
            end

        READ_WAIT:
            if(O_sdrc_busy_n_o & rd_flag )begin//空闲状态 碰到写请求
                I_sdrc_rd_n_i   <= 1'b0         ;
                state           <= READ        ;
                I_sdrc_addr_i   <= {bank_addr , rd_row_addr , rd_col_addr} ; 
                // data_cnt <= 'd0;
 
            end
            else
                state <= READ_WAIT   ;
        READ:
            begin
            // rfifo_wr_en <= 1'b1 ;
            I_sdrc_rd_n_i <= 1'b1 ;
            if(rd_flag == 1'b1 )
                state <= READ ;
            else begin
                state <= WRITE_WAIT ;
                // rfifo_wr_en <= 1'b0 ;
            end
            end

        default 
            state       <=  IDLE        ; 
    endcase
end

//RCD delay cnt 读写延迟计数
always @(posedge sclk or negedge s_rst_n) begin
    if(!s_rst_n)
        RCD_delay_cnt <= 'd0 ;
    else if( state == WRITE )
        RCD_delay_cnt <= RCD_delay_cnt + 1'b1 ;
    else if( state == READ )
        RCD_delay_cnt <= RCD_delay_cnt + 1'b1 ;
    else
        RCD_delay_cnt <= 'd0 ;
end

//r_fifo_wr_en也是在仿真对着时序更改的，不同的读写长度可能导致r_fifo_en失去准确。
assign rfifo_wr_data = (rfifo_wr_en ) ? O_sdrc_data_o : 'dz ; //读FIFO使能 

assign I_sdrc_data_i = (wfifo_rd_en)? wfifo_rd_data  :'dz ;
//********************WRITE Start*****************************
// wfifo rd en
always @(posedge sclk or negedge s_rst_n) begin
    if(!s_rst_n)
        wfifo_rd_en <= 1'b0 ;
    else if(state == WRITE_WAIT & wr_flag )
        wfifo_rd_en <= 1'b1 ;
    else if(wr_flag == 1'b0  )
        wfifo_rd_en <= 1'b0 ;
    // else if(sdram_cmd == 4'b0010 )
        // wfifo_rd_en <= 1'b0 ;

end
// assign wfifo_rd_en = (state == WRITE_WAIT)? 1'b1 : 1'b0 ;

//wr_flag
always @(posedge sclk or negedge s_rst_n) begin
    if(!s_rst_n)
        wr_flag <= 1'b0;
    else if(wr_trig == 1'b1 && wr_flag == 1'b0 )
        wr_flag <= 1'b1 ;
    else if(wr_data_cnt == data_len -1)
        wr_flag <= 1'b0 ;
end

//wr_col_addr 
always @(posedge sclk or negedge s_rst_n) begin
    if(!s_rst_n)
        wr_col_addr <= 'd0 ;
    else if( wr_col_addr >= 'd511)//超过511就重置地址
        wr_col_addr <= 'd0 ;
    else if(state == WRITE && RCD_delay_cnt >='d2)//下一次写地址=原写地址+1 
        wr_col_addr <= wr_col_addr +  1'b1 ;
    else
        wr_col_addr <= wr_col_addr ;
end

//wr_row_addr
always @(posedge sclk or negedge s_rst_n) begin
    if(!s_rst_n)
        wr_row_addr <= 'd0 ;
    else if( wr_col_addr == 'd511)
        wr_row_addr <= wr_row_addr + 1'b1 ;
end

//wr_data_cnt
always @(posedge sclk or negedge s_rst_n) begin
    if(!s_rst_n)
        wr_data_cnt <= 'd0 ;
    else if(state == WRITE && RCD_delay_cnt >= 'd1)
        wr_data_cnt <= wr_data_cnt + 1'b1 ;
    else
        wr_data_cnt <= 'd0 ;
end

//********************WRITE End*****************************

//cas延迟+RCD延迟=3+2=5
assign rfifo_wr_en = (rd_data_cnt >= 'd5) ? (~O_sdrc_busy_n_o) : 1'b0 ;


always @(posedge sclk or negedge s_rst_n) begin
    if(!s_rst_n )
        rd_start_cnt_flag <= 1'b0 ;
    else if(state ==  READ && rd_flag == 1'b0 && O_sdrc_busy_n_o == 1'b0 )
        rd_start_cnt_flag <= 1'b1 ;
    else if( O_sdrc_busy_n_o == 1'b1)
        rd_start_cnt_flag <= 1'b0 ;
    else 
        rd_start_cnt_flag <= rd_start_cnt_flag ;
end


//rd_data_cnt 
always @(posedge sclk or negedge s_rst_n) begin
    if(!s_rst_n)
        rd_data_cnt <= 'd0 ;
    else if( rd_start_cnt_flag == 1'b1  )
        rd_data_cnt <= rd_data_cnt + 1'b1 ;
    else
        rd_data_cnt <= 'd0 ;
end


//rd_flag
always @(posedge sclk or negedge s_rst_n) begin
    if(!s_rst_n)
        rd_flag <= 1'b0;
    else if(rd_trig == 1'b1 && rd_flag == 1'b0 )
        rd_flag <= 1'b1 ;
    else if(rd_addr_cnt >= data_len -1)
        rd_flag <= 1'b0 ;
end

//rd_col_addr 
always @(posedge sclk or negedge s_rst_n) begin
    if(!s_rst_n)
        rd_col_addr <= 'd0 ;
    else if( rd_col_addr >= 'd511)//超过511就重置地址
        rd_col_addr <= 'd0 ;
    else if(state == READ && RCD_delay_cnt >='d2)//下一次写地址=原写地址+data len+1 
        rd_col_addr <= rd_col_addr + 1'b1;
    else 
        rd_col_addr <= rd_col_addr ;
end

//rd_row_addr
always @(posedge sclk or negedge s_rst_n) begin
    if(!s_rst_n)
        rd_row_addr <= 'd0 ;
    else if( rd_col_addr == 'd511)
        rd_row_addr <= rd_row_addr + 1'b1 ;
end

//rd_addr_cnt
always @(posedge sclk or negedge s_rst_n) begin
    if(!s_rst_n)
        rd_addr_cnt <= 'd0 ;
    else if(state == READ && RCD_delay_cnt >= 'd1)
        rd_addr_cnt <= rd_addr_cnt + 1'b1 ;
    else
        rd_addr_cnt <= 'd0 ;
end




endmodule