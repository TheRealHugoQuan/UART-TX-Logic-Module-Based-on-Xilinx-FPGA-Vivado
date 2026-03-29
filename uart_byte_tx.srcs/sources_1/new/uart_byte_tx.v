module uart_byte_tx(
    Clk,
    Reset_n,
    Send_Go,
    Data,
    uart_tx,
    Tx_Done
);

//

    input Clk;
    input Reset_n;
    input Send_Go;
    input [7:0]Data;
    output reg uart_tx;
    output reg Tx_Done;
    
    parameter BAUD = 9600;
    parameter CLOCK_FREQ = 50_000_000;
    
    parameter MCNT_BAUD = CLOCK_FREQ / BAUD - 1;

    parameter MCNT_BIT = 10-1;
    
    reg [29:0]baud_div_cnt;
    reg en_baud_cnt;
    reg [3:0]bit_cnt;
    reg [7:0]r_Data;

    wire w_Tx_Done;
    
//�����ʼ����� 1/9600  *1000000000 / 20 - 1

    always@(posedge Clk or negedge Reset_n)
    if(!Reset_n)
        baud_div_cnt <= 0;
    else if(en_baud_cnt)begin
        if(baud_div_cnt == MCNT_BAUD)
            baud_div_cnt <= 0;
        else
            baud_div_cnt <= baud_div_cnt + 1'd1;
    end
    else
        baud_div_cnt <= 0;
        
    always@(posedge Clk or negedge Reset_n)
    if(!Reset_n)
        en_baud_cnt <= 0;
    else if(Send_Go)
        en_baud_cnt <= 1;
    else if(w_Tx_Done)
        en_baud_cnt <= 0; 

//λ������
    always@(posedge Clk or negedge Reset_n)
    if(!Reset_n)
        bit_cnt <= 0;
    else if(baud_div_cnt == MCNT_BAUD)begin
        if(bit_cnt == MCNT_BIT)
            bit_cnt <= 0;
        else
            bit_cnt <= bit_cnt + 1'd1;
    end
    
    always@(posedge Clk or negedge Reset_n)
    if(!Reset_n)
        r_Data <= 0;
    else if(Send_Go)
        r_Data <= Data;
        
//    always@(posedge Clk)
//    if(Send_Go)
//        r_Data <= Data;   
    
    

//λ�����߼�
    always@(posedge Clk or negedge Reset_n)
    if(!Reset_n)
        uart_tx <= 1'd1;
    else if(en_baud_cnt == 0)
        uart_tx <= 1'd1;
    else begin
        case(bit_cnt)
            0:uart_tx <= 1'd0;
            1:uart_tx <= r_Data[0];
            2:uart_tx <= r_Data[1];
            3:uart_tx <= r_Data[2];
            4:uart_tx <= r_Data[3];
            5:uart_tx <= r_Data[4];
            6:uart_tx <= r_Data[5];
            7:uart_tx <= r_Data[6];
            8:uart_tx <= r_Data[7];
            9:uart_tx <= 1'd1;
            default:uart_tx <= uart_tx;
        endcase    
    end
    
    assign w_Tx_Done = ((bit_cnt == 9) && (baud_div_cnt == MCNT_BAUD)); //assigns this condition to w_tx_done
    
    always@(posedge Clk) //always at the positive edge assign it to tx done, do whenever this w_tx_Done has a condition to be 1 it immediately assigns it to the tx_done signal pulling it up high to 1
         Tx_Done <= w_Tx_Done;
    
endmodule
