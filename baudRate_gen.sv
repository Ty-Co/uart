`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/11/2024 12:42:38 PM
// Design Name: 
// Module Name: baudRate_gen
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
/* 
*   sysclk = 100MHz , SAMPLING RATE = x16
*   baud rate       Mod         frac_adj (fractional adustment) 
*   4800            1302.083    1/12 
*   9600            651.041     1/24
*   19200           325.520     13/25     
*   38400           162.760     19/25
*   57600           108.507     1/2
*   115200          54.253      1/4 
*   230400          27.1267     1/8
*   460800          13.563      9/16
*/


module baudRate_gen
#(
parameter MOD = 27 // integer value of 27.1267
)
(
    input logic sysclk, rst,
    output logic baudx16_ena
    );  
localparam N = log2(MOD);

//signal declaration 
logic [N-1:0] state,nstate; 
logic [3:0] count8,ncount8; // used with a baud rate of 230400, denominator fractional adjustment
logic frac_adj; // numerator of the fractional adjustment. 


always_ff @(posedge sysclk, negedge rst)
    if(!rst)
        begin
            state <= 0;
            count8 <=0;
        end 
    else
         begin
             state <= nstate;  
             count8 <= ncount8;
         end


//output logic
assign baudx16_ena =(state == (MOD-1) + frac_adj)? 1'b1:1'b0;
assign frac_adj = (count8 == 3'd7)? 1'b1:1'b0;

//next-state logic   
assign nstate = (state == ((MOD-1) + frac_adj)? 0 : state +1);  
always_comb
    if (baudx16_ena)
        if(count8 == 3'd7)
            ncount8 = 0;
        else 
            ncount8 = count8+1;
    else
        ncount8 = count8;
        
        
        

    
function integer log2(input integer n);
    integer i;
    begin
        log2 = 1;
        for(i=0; 2**i<n; i = i+1)
            log2 = i + 1;
    end 
endfunction
    
endmodule
