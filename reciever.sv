`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/27/2024 09:53:26 AM
// Design Name: 
// Module Name: receiver
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


module reciever
#(parameter DBITS = 8,
            STOP_B = 16)
(
    input logic sysclk,rst,
    input logic parity_en, odd_even,
    input logic baudx16_ena, rxd,
    output logic [DBITS-1:0] rx_data,
    output logic rx_valid,
    output logic framing_err,
    output logic parity_err
    );

//states of the reciever 
localparam [4:0]
    sIDLE   = 5'b00001,
    sSTART  = 5'b00010,
    sSHIFT  = 5'b00100,
    sPARITY = 5'b01000,
    sSTOP   = 5'b10000;

// signal declarations
logic parity_bit;
logic [1:0] rxd_q; // 2DFF sychronizer for rxd
logic [4:0] asm_state; // asm_state register, next asm_state
logic [3:0] baudx16_cnt; // sampling bit register
logic [2:0] bitcnt; // data_reg
logic [DBITS-1:0] rsr; //recieving shift register

//output logic
assign rx_data = rsr;

always_ff@(posedge sysclk, negedge rst)
if(~rst)
    begin
        rxd_q <= 2'd3;
        baudx16_cnt <= 4'd0;
        bitcnt <= 3'd0;
        rsr <= 8'd0;
        framing_err <= 1'b0;
        parity_bit <= odd_even;
        parity_err <= 1'b0;
        asm_state <= sIDLE;
    end
else
    begin
        rxd_q <= {rxd_q[0], rxd};
        case(asm_state)
            sIDLE:
                begin
                parity_err <= 1'b0;
                rx_valid <= 1'b0;
                framing_err <= 1'b0;
                parity_bit <= odd_even;
                if(rxd_q[1])
                    asm_state <= sIDLE;
                 else
                    asm_state <= sSTART;
                end
            sSTART:
                begin
                    if(rxd_q[1])
                        asm_state <= sIDLE;
                     else 
                        if(baudx16_ena)
                            if(baudx16_cnt == 4'd7)
                                begin
                                baudx16_cnt <= 4'd0;
                                asm_state <= sSHIFT;
                                end
                            else
                                begin
                                baudx16_cnt <= baudx16_cnt +1'b1;
                                asm_state <= sSTART;
                                end
                        else
                            begin
                            asm_state <= sSTART;
                            end
            
                end
            sSHIFT:
                begin
                    if(baudx16_ena)
                        if(baudx16_cnt == (STOP_B-1))
                            begin
                            parity_bit <= parity_bit^rxd_q[1];
                            rsr <= {rxd_q[1],rsr[7:1]};
                            baudx16_cnt <= 4'd0;
                            
                            if(bitcnt == (DBITS-1))
                                begin
                                bitcnt <= 3'd0;
                                if(parity_en)
                                    asm_state <= sPARITY;
                                else
                                    asm_state <= sSTOP;    
                                end
                            else
                                begin
                                bitcnt <= bitcnt +1'b1;
                                asm_state <= sSHIFT;
                                end
                            end
                    else
                    asm_state = sSHIFT;
                end
            sPARITY:
                begin
                if(baudx16_ena)
                    if(baudx16_cnt == (STOP_B-1))
                        begin
                        parity_bit <= parity_bit^rxd_q[1];
                        baudx16_cnt <= 4'd0;
                        asm_state = sSTOP;
                        end
                     else
                     begin
                        baudx16_cnt <= baudx16_cnt +1'b1;
                        asm_state = sPARITY;  
                     end
                end
            sSTOP:
                if(baudx16_ena)
                    if(baudx16_cnt == (STOP_B-1))
                        begin
                        baudx16_cnt = 4'd0;
                        asm_state = sIDLE;
                        if(rxd_q[1])
                            if(parity_bit)
                                parity_err = parity_bit;
                            else 
                                rx_valid = 1'b1;  
                           
                        else
                           framing_err = 1'b1;
                         end
                    else
                        baudx16_cnt <= baudx16_cnt + 1'b1;
            default:
                begin
                asm_state <= sIDLE;
                baudx16_cnt <= 0;
                framing_err <= 0;
                rx_valid <= 1'b0;
                end
        endcase
    end
    
endmodule
