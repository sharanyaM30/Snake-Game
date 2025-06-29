`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 17.03.2025 20:27:11
// Design Name: 
// Module Name: VGA
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


module VGA(input clk,reset,
output reg v_sync,h_sync,v_disp,h_disp,
output reg[9:0] v_loc,
output reg[10:0] h_loc
    );
    
    always @(posedge clk) begin
        if(reset)
            h_loc<=11'b00000000001;
        else if(h_loc >= 11'b10000100000)
            h_loc <= 11'b00000000001;
        else
            h_loc <= h_loc +1'b1;
        
        if(reset)
            v_loc <= 10'b0000000001;
        else if(v_loc >= 10'b1001110100 && h_loc == 11'b10000100000)
            v_loc <= 10'b0000000001;
        else if(h_loc == 11'b10000100000)
            v_loc <= v_loc +1'b1;
        else
            v_loc <= v_loc;
        
        if(reset)
            h_sync <=1'b0;
        else if(h_loc==11'b01101001000)
            h_sync <= 1'b1;
        else if(h_loc == 11'b1111001000)
            h_sync <= 1'b0;
        
        if(reset)
            v_sync <=1'b0;
        else if(v_loc == 10'b1001011001)
            v_sync <= 1'b1;
        else if(v_loc == 10'b1001011101)
            v_sync <= 1'b0;
        
        if(reset)
            h_disp <= 1'b1;
        else if(h_loc == 11'b01100100000)
            h_disp <= 1'b0;
        else if(h_loc == 11'b10000100000)
            h_disp <= 1'b1;
        
        if(reset)
            v_disp <= 1'b1;
        else if(v_loc == 10'b1001010111)
            v_disp <= 1'b0;
        else if(v_loc == 10'b1001110100)
            v_disp <= 1'b1;
    end
            
endmodule
