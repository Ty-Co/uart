`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/31/2024 04:30:21 PM
// Design Name: 
// Module Name: transmitter
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


module transmitter
#(
    parameter   DBITS = 8,
                STOP_B = 16
)
(
    input logic sysclk,rst,
    input logic baudx16_en, odd_even,
    input logic [DBITS-1:0] tx_data,
    output logic txd,
    output logic tx_busy
    );
    
    
// states 
localparam [5:0]
    sIDLE   = 6'b000_001,
    sWAIT   = 6'b000_010,
    sSTART  = 6'b000_100,
    sSHIFT  = 6'b001_000,
    sPARITY = 6'b010_000,
    sSTOP   = 6'b100_000;
    
logic txr;
logic parity_bit;
logic [3:0] baudx16_cnt;
logic [2:0] bitcnt;
logic [7:0] thr;
logic [5:0] asm_state;

assign txd = txr; //output logic 

always@(posedge sysclk, negedge rst)
    if(~rst)
        begin
        txr <= 1'b1;
        parity_bit <= odd_even;
        tx_busy <= 1'b0;
        baudx16_cnt <= 4'd0;
        bitcnt <= 3'd0;
        thr <= 8'd0;
        asm_state <= sIDLE;
        end
    else
        case(asm_state)
            sIDLE:
                begin
                parity_bit <= odd_even;
                txr<= 1'b1;
                tx_busy <= 1'b0; 
                end
            sWAIT:
                begin
                end
            sSTART:
                begin
                end
            sSHIFT:
                begin
                end
            sPARITY:
                begin
                end
            sSTOP:
                begin
                end
    
    
    
    
    
endmodule
