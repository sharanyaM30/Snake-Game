`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04.03.2025 20:12:48
// Design Name: 
// Module Name: sf
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

module sf1(
input clk,
input reset,restart,start,
input right,left,down,up,
output h_sync,v_sync,
output[11:0] red_colour,
output reg [0:6] disp,
output  reg [0:7] act
//output reg self_coll,
//output reg stop
    );
    
    wire right_db,left_db,down_db,up_db;
    
    parameter r=0,u=1,d=2,l=3;
    parameter box_size = 10;
    parameter block_size = 10;
    parameter max_length = 50;
    
    
    reg[1:0] current_state;
    wire h_disp,v_disp;
    wire[10:0] h_loc;
    wire [9:0]v_loc;
    reg[11:0] colour_reg;
    reg[11:0] screen_colour;
    reg[24:0] counter;
    reg stop;

    reg [10:0] snake_x[0:max_length-1];
    reg [9:0] snake_y[0:max_length-1];
    reg [5:0] snake_length;
    reg lengthincrease;

    reg [10:0] h_food_reg;
    reg [9:0] v_food_reg; 
    reg [10:0] h_food_next;
    reg [9:0] v_food_next; 
    reg [5:0] temp;
    reg [5:0] score;
    reg [3:0] a; // Unit digit (0-9)
    reg [3:0] b;
    
    integer j;
    integer k;
    reg snake_appear;
    reg food_appear;
    reg self_coll;
    
    clk_wiz_0 inst1
   (
    .clk_out1(CLK_100MHz),     // output CLK_100MHz
    .clk_out2(CLK_40MHz),     // output CLK_40MHz
    .reset(reset), // input reset
    .locked(locked),       // output locked
    .clk_in1(clk)      // input clk_in1
    );
    
    wire [11:0] game_over_color;
    final_rom game_over_screen (
    .clk(CLK_40MHz),       // Use the same clock as VGA timing
    .row(h_loc),           // Pass horizontal pixel coordinate
    .col(v_loc),           // Pass vertical pixel coordinate
    .color_data_over(game_over_color) // Output color data
    );
    
    debouncing_circuit for_anti_clkwise (CLK_100MHz, reset, up, up_db);
    debouncing_circuit for_down (CLK_100MHz, reset, down, down_db);
    debouncing_circuit for_left (CLK_100MHz, reset, left, left_db);
    debouncing_circuit for_right (CLK_100MHz, reset, right, right_db);

    VGA inst2(.clk(CLK_40MHz),.reset(reset),.h_sync(h_sync),.v_sync(v_sync),.v_disp(v_disp),.h_disp(h_disp),.v_loc(v_loc),.h_loc(h_loc));
//    home_screen inst3(.clk(clk),.reset(restart),.screen_colour_reg(screen_colour_reg));
    integer i;
    integer z;
    always @(*)
    begin
        h_food_next[0]  = (h_food_reg[10] ^ h_food_reg[5]) | (~h_food_reg[2] & h_food_reg[8]);
        h_food_next[1]  = (h_food_reg[9] & h_food_reg[3]) ^ (h_food_reg[1] | h_food_reg[7]);
        h_food_next[2]  = (~h_food_reg[8] | h_food_reg[0]) & (h_food_reg[6] ^ h_food_reg[4]);
        h_food_next[3]  = (h_food_reg[7] & h_food_reg[2]) | (~h_food_reg[1] ^ h_food_reg[5]);
        h_food_next[4]  = (h_food_reg[6] ^ h_food_reg[3]) & (~h_food_reg[0] | h_food_reg[9]);
        h_food_next[5]  = (h_food_reg[5] | h_food_reg[1]) ^ (h_food_reg[8] & ~h_food_reg[10]);
        h_food_next[6]  = (~h_food_reg[4] ^ h_food_reg[2]) & (h_food_reg[9] | h_food_reg[7]);
        h_food_next[7]  = (h_food_reg[3] & h_food_reg[10]) | (~h_food_reg[5] ^ h_food_reg[6]);
        h_food_next[8]  = (h_food_reg[2] | ~h_food_reg[7]) ^ (h_food_reg[8] & h_food_reg[0]);
        h_food_next[9]  =  1'b0; //(h_food_reg[1] & ~h_food_reg[6]) | (h_food_reg[4] ^ h_food_reg[5]);
        h_food_next[10] = 1'b0; //(h_food_reg[0] | h_food_reg[9]) & (~h_food_reg[8] ^ h_food_reg[3]);
        
        v_food_next[0] = (v_food_reg[9] ^ v_food_reg[4]) | (~v_food_reg[2] & v_food_reg[7]);
        v_food_next[1] = (v_food_reg[8] & v_food_reg[3]) ^ (v_food_reg[1] | v_food_reg[6]);
        v_food_next[2] = (~v_food_reg[7] | v_food_reg[0]) & (v_food_reg[5] ^ v_food_reg[4]);
        v_food_next[3] = (v_food_reg[6] & v_food_reg[2]) | (~v_food_reg[1] ^ v_food_reg[4]);
        v_food_next[4] = (v_food_reg[5] ^ v_food_reg[3]) & (~v_food_reg[0] | v_food_reg[8]);
        v_food_next[5] = (v_food_reg[4] | v_food_reg[1]) ^ (v_food_reg[7] & ~v_food_reg[9]);
        v_food_next[6] = (~v_food_reg[3] ^ v_food_reg[2]) & (v_food_reg[8] | v_food_reg[6]);
        v_food_next[7] = (v_food_reg[2] & v_food_reg[9]) | (~v_food_reg[5] ^ v_food_reg[7]);
        v_food_next[8] = (v_food_reg[1] | ~v_food_reg[6]) ^ (v_food_reg[8] & v_food_reg[0]);
        v_food_next[9] = 1'b0; //(v_food_reg[0] & ~v_food_reg[4]) | (v_food_reg[3] ^ v_food_reg[5]);
    end
    
    
    always @(posedge CLK_100MHz) begin
        
        if((snake_x[0] >= h_food_reg && snake_x[0]- box_size < h_food_reg ) && (snake_y[0] >= v_food_reg && snake_y[0]- box_size < v_food_reg ))
        begin
            lengthincrease <= 1'b1;
            score<= score + 1'b1;
            h_food_reg <= (h_food_next/10)*10 + 3'd6;
            v_food_reg <= (v_food_next/10)*10 + 3'd6;
                end

        else begin
            h_food_reg <= h_food_reg;
            v_food_reg <= v_food_reg;
            end
        
        if(reset || restart) begin
            counter <= 25'b0;
            current_state <= r;
            snake_length <= 6'd1;
            //colour_reg <= 12'b000011110000; // Reset color
            snake_x[0] <= 11'b00110001100;   // Initial location
            snake_y[0] <= 10'b0100101000;
//            snake_x[1] <= 11'b00100101000;
//            snake_y[1] <= 10'b0100101000;
            h_food_reg <= 11'b00011001110;
            v_food_reg <= 10'b0001101010;
            score <= 6'b000000;
            temp <= 6'b000000;
            self_coll <= 1'b0;
            stop <= 1'b0;
            //food_eaten <= 1'b0;   
            lengthincrease <= 1'b0;  
//            stop<=1'b0;      
            //colour_reg <= 12'b000011110000;
        end else
        begin
            case(current_state)
                r:
                begin
                    if(up_db)
                        current_state <= u;
                    else if(down_db)
                        current_state <= d;
                    else
                        current_state <= r;

                end
                l:
                begin
                    if(up_db)
                        current_state <= u;
                    else if(down_db)
                        current_state <= d;
//                    else if(stop)
//                        current_state <= the_end;    
                    else
                        current_state <= l;

                end
                u:
                begin
                    if(right_db)
                        current_state <= r;
                    else if(left_db)
                        current_state <= l;
//                    else if(stop)
//                        current_state <= the_end;
                    else
                        current_state <= u;

                end
                
                
                d:
                begin
                    if(right_db)
                        current_state <= r;
                    else if(left_db)
                        current_state <= l;
//                    else if(stop)
//                        current_state <= the_end;
                    else
                        current_state <= d;

                end
//                the_end:
//                begin
//                    current_state <= the_end;
//                    counter <= counter;
//                end
                
//                default: current_state <= r;
            endcase
            
            if(counter > 25'b1110010011100001110000000) begin
                counter <= 25'b0;
                
                if(~stop && ~self_coll) begin
                for (i = max_length - 1; i > 0; i = i - 1) begin
                        if (i < snake_length)
                            begin
                                snake_x[i] <= snake_x[i-1];
                                snake_y[i] <= snake_y[i-1];
                            end
                end
                end
                else begin
                for (i = max_length - 1; i >= 0; i = i - 1) begin
                        if (i < snake_length)
                            begin
                                snake_x[i] <= snake_x[i];
                                snake_y[i] <= snake_y[i];
                            end
                end
                end
                 
                case(current_state)
                    r:
                    begin
                        if(snake_x[0] < 11'b01100100000 && ((~stop) && (~self_coll)))
                            snake_x[0] <= snake_x[0] + block_size;
                    end
                    l:
                    begin
                        if(snake_x[0] > box_size && ((~stop) && (~self_coll)))
                            snake_x[0] <= snake_x[0] - block_size;
                    end
                    u:
                    begin
                        if(snake_y[0] > box_size && ((~stop) && (~self_coll)))
                            snake_y[0] <= snake_y[0] - block_size;
                    end
                    d:
                    begin
                        if(snake_y[0] < 10'b1001011000 && ((~stop) && (~self_coll)))
                            snake_y[0] <= snake_y[0] + block_size;
                    end
                endcase
                
                if(lengthincrease && (snake_length < max_length)) begin
                    snake_x[snake_length] <= snake_x[snake_length-1];
                    snake_y[snake_length] <= snake_y[snake_length-1];
                    snake_length <= snake_length + 1;
                   
                end
                lengthincrease <= 1'b0;
            end      
            else
                counter <= counter + 1'b1;
            
            for(k=4; k < snake_length; k=k+1) begin // Start from 1 to avoid head
                if((snake_x[0] <= snake_x[k] && snake_x[0] >= snake_x[k] - block_size) && 
                   (snake_y[0] <= snake_y[k] && snake_y[0] >= snake_y[k] - block_size))
                    self_coll <= 1'b1;
            end
            
            if((snake_x[0] > 11'b01100100000 || snake_x[0] < block_size || snake_y[0] > 10'b1001011000 || snake_y[0] < block_size || (self_coll >= 1'b1)))
                stop <= 1'b1;       
        end
    end
    
    
    always @(*) begin
        snake_appear = 1'b0;
        food_appear = 1'b0;
//        stop = 1'b0;
//        self_coll = 1'b0;
        if(h_disp && v_disp) begin
            for(j=0;j<snake_length;j=j+1) begin
                if((h_loc <= snake_x[j] && h_loc > snake_x[j] - block_size) && (v_loc <= snake_y[j] && v_loc > snake_y[j] - block_size))
                    snake_appear = 1'b1;
            end
            
            
                
            if((h_loc <= h_food_reg && h_loc > h_food_reg - box_size) && (v_loc <= v_food_reg && v_loc > v_food_reg - box_size))
                food_appear = 1'b1;
            else if((snake_x[0] >= h_food_reg && snake_x[0] < h_food_reg + box_size) && (snake_y[0] >= v_food_reg && snake_y[0] < v_food_reg + box_size))
                food_appear = 1'b0;
                
            if(snake_appear)
                colour_reg =12'b000000000000;
            else if(food_appear)
                colour_reg =12'b111100000000;
            else
                colour_reg = 12'b0000_1001_0000;   
            
              
        end
        
        else
            colour_reg = 12'b000000000000;
    end
    
    always @(*) begin
        if(h_disp && v_disp) begin
        screen_colour = 12'b0000_1001_0000;
        // W
        if(((h_loc >= 11'd184 && h_loc <= 11'd200) || (h_loc >= 11'd226 && h_loc <= 11'd242)) && (v_loc >= 10'd112 && v_loc <= 10'd178))
            screen_colour = 12'b1111_0000_0000;
        
        if(((h_loc >= 11'd201 && h_loc <= 11'd209) || (h_loc >= 11'd218 && h_loc <= 11'd225)) && (v_loc >= 10'd154 && v_loc <= 10'd169))
            screen_colour = 12'b1111_0000_0000;
        
        if((h_loc >= 11'd210 && h_loc <= 11'd217) && (v_loc >= 10'd145 && v_loc <= 10'd161))
            screen_colour = 12'b1111_0000_0000;
            
        // E
        if(((h_loc >= 11'd252 && h_loc <= 11'd259) || (h_loc >= 11'd554 && h_loc <= 11'd561)) && (v_loc >= 10'd120 && v_loc <= 10'd169))
            screen_colour = 12'b1111_0000_0000;
            
        if(((h_loc >= 11'd260 && h_loc <= 11'd267) || (h_loc >= 11'd562 && h_loc <= 11'd570)) && (v_loc >= 10'd112 && v_loc <= 10'd178))
            screen_colour = 12'b1111_0000_0000;
            
        if(((h_loc >= 11'd268 && h_loc <= 11'd301) ||(h_loc >= 11'd571 && h_loc <= 11'd603)) && ((v_loc >= 10'd112 && v_loc <= 10'd127) || (v_loc >= 10'd137 && v_loc <= 10'd153) || (v_loc >= 10'd162 && v_loc <= 10'd178)))
            screen_colour = 12'b1111_0000_0000;
            
        // L
        if((h_loc >= 11'd310 && h_loc <= 11'd318) && (v_loc >= 10'd112 && v_loc <= 10'd169))
            screen_colour = 12'b1111_0000_0000;
       
        if((h_loc >= 11'd319 && h_loc <= 11'd326) && (v_loc >= 10'd112 && v_loc <= 10'd178))
            screen_colour = 12'b1111_0000_0000;
        
        if((h_loc >= 11'd327 && h_loc <= 11'd360) && (v_loc >= 10'd162 && v_loc <= 10'd178))
            screen_colour = 12'b1111_0000_0000;
            
        // C
        if((h_loc >= 11'd369 && h_loc <= 11'd377) && (v_loc >= 10'd120 && v_loc <= 10'd169))
            screen_colour = 12'b1111_0000_0000;
       
        if((h_loc >= 11'd378 && h_loc <= 11'd385) && (v_loc >= 10'd112 && v_loc <= 10'd178))
            screen_colour = 12'b1111_0000_0000;
        
        if((h_loc >= 11'd386 && h_loc <= 11'd419) && ((v_loc >= 10'd112 && v_loc <= 10'd127) || (v_loc >= 10'd162 && v_loc <= 10'd178)))
            screen_colour = 12'b1111_0000_0000;
            
        // O
        if(((h_loc >= 11'd428 && h_loc <= 11'd435) || (h_loc >= 11'd470 && h_loc <= 11'd477)) && (v_loc >= 10'd120 && v_loc <= 10'd169))
            screen_colour = 12'b1111_0000_0000;
       
        if(((h_loc >= 11'd436 && h_loc <= 11'd444) || (h_loc >= 11'd462 && h_loc <= 11'd469)) && (v_loc >= 10'd112 && v_loc <= 10'd178))
            screen_colour = 12'b1111_0000_0000;
        
        if((h_loc >= 11'd445 && h_loc <= 11'd461) && ((v_loc >= 10'd112 && v_loc <= 10'd127) || (v_loc >= 10'd162 && v_loc <= 10'd178)))
            screen_colour = 12'b1111_0000_0000;
            
        // M
        if(((h_loc >= 11'd487 && h_loc <= 11'd503) || (h_loc >= 11'd529 && h_loc <= 11'd545)) && (v_loc >= 10'd112 && v_loc <= 10'd178))
            screen_colour = 12'b1111_0000_0000;
       
        if(((h_loc >= 11'd504 && h_loc <= 11'd511) || (h_loc >= 11'd520 && h_loc <= 11'd528)) && (v_loc >= 10'd128 && v_loc <= 10'd144))
            screen_colour = 12'b1111_0000_0000;
            
        if((h_loc >= 11'd512 && h_loc <= 11'd519) && (v_loc >= 10'd137 && v_loc <= 10'd153))
            screen_colour = 12'b1111_0000_0000;
            
        // E in upper E
        
        
        // TO
        // T
        if((h_loc >= 11'd318 && h_loc <= 11'd383) && (v_loc >= 10'd224 && v_loc <= 10'd241))
            screen_colour = 12'b1111_0000_0000;
       
        if((h_loc >= 11'd340 && h_loc <= 11'd361) && (v_loc >= 10'd242 && v_loc <= 10'd295))
            screen_colour = 12'b1111_0000_0000;
            
        // O
        if(((h_loc >= 11'd395 && h_loc <= 11'd404) || (h_loc >= 11'd449 && h_loc <= 11'd451)) && (v_loc >= 10'd232 && v_loc <= 10'd285))
            screen_colour = 12'b1111_0000_0000;
       
        if(((h_loc >= 11'd405 && h_loc <= 11'd416) || (h_loc >= 11'd438 && h_loc <= 11'd448)) && (v_loc >= 10'd224 && v_loc <= 10'd295))
            screen_colour = 12'b1111_0000_0000;
            
        if((h_loc >= 11'd417 && h_loc <= 11'd437) && ((v_loc >= 10'd224 && v_loc <= 10'd241) || (v_loc >= 10'd277 && v_loc <= 10'd295)))
            screen_colour = 12'b1111_0000_0000;
            
            
        // SNAKE
        // S
        if((h_loc >= 11'd150 && h_loc <= 11'd157) && ((v_loc >= 10'd347 && v_loc <= 10'd382) || (v_loc >= 10'd407 && v_loc <= 10'd430)))
            screen_colour = 12'b1111_0000_0000;
            
        if((h_loc >= 11'd158 && h_loc <= 11'd164) && ((v_loc >= 10'd335 && v_loc <= 10'd394) || (v_loc >= 10'd407 && v_loc <= 10'd430)))
            screen_colour = 12'b1111_0000_0000;
        
        if((h_loc >= 11'd165 && h_loc <= 11'd179) && ((v_loc >= 10'd335 && v_loc <= 10'd358) || (v_loc >= 10'd371 && v_loc <= 10'd394) || (v_loc >= 10'd407 && v_loc <= 10'd430)))
            screen_colour = 12'b1111_0000_0000;
            
        if((h_loc >= 11'd180 && h_loc <= 11'd187) && ((v_loc >= 10'd335 && v_loc <= 10'd358) || (v_loc >= 10'd371 && v_loc <= 10'd430)))
            screen_colour = 12'b1111_0000_0000;
            
        if((h_loc >= 11'd188 && h_loc <= 11'd194) && ((v_loc >= 10'd335 && v_loc <= 10'd358) || (v_loc >= 10'd383 && v_loc <= 10'd418)))
            screen_colour = 12'b1111_0000_0000;
            
        // N
        if(((h_loc >= 11'd203 && h_loc <= 11'd216) || (h_loc >= 11'd240 && h_loc <= 11'd254)) && (v_loc >= 10'd335 && v_loc <= 10'd430))
            screen_colour = 12'b1111_0000_0000;
       
        if((h_loc >= 11'd217 && h_loc <= 11'd224) && (v_loc >= 10'd347 && v_loc <= 10'd382))
            screen_colour = 12'b1111_0000_0000;
            
        if((h_loc >= 11'd218 && h_loc <= 11'd231) && (v_loc >= 10'd359 && v_loc <= 10'd394))
            screen_colour = 12'b1111_0000_0000;
       
        if((h_loc >= 11'd232 && h_loc <= 11'd239) && (v_loc >= 10'd371 && v_loc <= 10'd406))
            screen_colour = 12'b1111_0000_0000;
            
        // A
        if(((h_loc >= 11'd262 && h_loc <= 11'd276) || (h_loc >= 11'd292 && h_loc <= 11'd306)) && (v_loc >= 10'd347 && v_loc <= 10'd430))
            screen_colour = 12'b1111_0000_0000;
        
        if(((h_loc >= 11'd270 && h_loc <= 11'd276) || (h_loc >= 11'd292 && h_loc <= 11'd298)) && (v_loc >= 10'd335 && v_loc <= 10'd346))
            screen_colour = 12'b1111_0000_0000;
        
        if((h_loc >= 11'd277 && h_loc <= 11'd291) && ((v_loc >= 10'd335 && v_loc <= 10'd358) || (v_loc >= 10'd371 && v_loc <= 10'd394)))
            screen_colour = 12'b1111_0000_0000;
            
        // K
        if((h_loc >= 11'd314 && h_loc <= 11'd328) && (v_loc >= 10'd335 && v_loc <= 10'd430))
            screen_colour = 12'b1111_0000_0000;
            
        if((h_loc >= 11'd329 && h_loc <= 11'd335) && (v_loc >= 10'd371 && v_loc <= 10'd394))
            screen_colour = 12'b1111_0000_0000;
       
        if((h_loc >= 11'd336 && h_loc <= 11'd343) && (v_loc >= 10'd347 && v_loc <= 10'd418))
            screen_colour = 12'b1111_0000_0000;
            
        if((h_loc >= 11'd344 && h_loc <= 11'd350) && ((v_loc >= 10'd335 && v_loc <= 10'd370) || (v_loc >= 10'd395 && v_loc <= 10'd430)))
            screen_colour = 12'b1111_0000_0000;
        
        if((h_loc >= 11'd351 && h_loc <= 11'd358) && ((v_loc >= 10'd335 && v_loc <= 10'd358) || (v_loc >= 10'd407 && v_loc <= 10'd430)))
            screen_colour = 12'b1111_0000_0000;
            
        // E
        if((h_loc >= 11'd366 && h_loc <= 11'd373) && (v_loc >= 10'd347 && v_loc <= 10'd418))
            screen_colour = 12'b1111_0000_0000;
            
        if((h_loc >= 11'd374 && h_loc <= 11'd380) && (v_loc >= 10'd335 && v_loc <= 10'd430))
            screen_colour = 12'b1111_0000_0000;
            
        if((h_loc >= 11'd381 && h_loc <= 11'd410) && ((v_loc >= 10'd335 && v_loc <= 10'd358) || (v_loc >= 10'd371 && v_loc <= 10'd394) || (v_loc >= 10'd407 && v_loc <= 10'd430)))
            screen_colour = 12'b1111_0000_0000;
            
        
        // GAME
        // G
        if((h_loc >= 11'd433 && h_loc <= 11'd440) && (v_loc >= 10'd347 && v_loc <= 10'd418))
            screen_colour = 12'b1111_0000_0000;
            
        if((h_loc >= 11'd441 && h_loc <= 11'd447) && (v_loc >= 10'd335 && v_loc <= 10'd430))
            screen_colour = 12'b1111_0000_0000;
        
        if((h_loc >= 11'd448 && h_loc <= 11'd455) && ((v_loc >= 10'd335 && v_loc <= 10'd358) || (v_loc >= 10'd407 && v_loc <= 10'd430)))
            screen_colour = 12'b1111_0000_0000;
        
        if((h_loc >= 11'd456 && h_loc <= 11'd477) && ((v_loc >= 10'd335 && v_loc <= 10'd358) || (v_loc >= 10'd371 && v_loc <= 10'd430)))
            screen_colour = 12'b1111_0000_0000;
            
        // A
        if(((h_loc >= 11'd493 && h_loc <= 11'd499) || (h_loc >= 11'd515 && h_loc <= 11'd521)) && (v_loc >= 10'd335 && v_loc <= 10'd346))
            screen_colour = 12'b1111_0000_0000;
        
        if(((h_loc >= 11'd485 && h_loc <= 11'd499) || (h_loc >= 11'd515 && h_loc <= 11'd529)) && (v_loc >= 10'd347 && v_loc <= 10'd430))
            screen_colour = 12'b1111_0000_0000;
            
        if((h_loc >= 11'd500 && h_loc <= 11'd514) && ((v_loc >= 10'd335 && v_loc <= 10'd358) || (v_loc >= 10'd371 && v_loc <= 10'd394)))
            screen_colour = 12'b1111_0000_0000;
            
        // M
        if(((h_loc >= 11'd537 && h_loc <= 11'd551) || (h_loc >= 11'd575 && h_loc <= 11'd588)) && (v_loc >= 10'd335 && v_loc <= 10'd430))
            screen_colour = 12'b1111_0000_0000;
       
        if(((h_loc >= 11'd552 && h_loc <= 11'd559) || (h_loc >= 11'd567 && h_loc <= 11'd587)) && (v_loc >= 10'd359 && v_loc <= 10'd382))
            screen_colour = 12'b1111_0000_0000;
            
        if((h_loc >= 11'd560 && h_loc <= 11'd566) && (v_loc >= 10'd371 && v_loc <= 10'd394))
            screen_colour = 12'b1111_0000_0000;
            
        // E
        if((h_loc >= 11'd597 && h_loc <= 11'd603) && (v_loc >= 10'd347 && v_loc <= 10'd418))
            screen_colour = 12'b1111_0000_0000;
            
        if((h_loc >= 11'd604 && h_loc <= 11'd611) && (v_loc >= 10'd335 && v_loc <= 10'd430))
            screen_colour = 12'b1111_0000_0000;
            
        if((h_loc >= 11'd612 && h_loc <= 11'd640) && ((v_loc >= 10'd335 && v_loc <= 10'd358) || (v_loc >= 10'd371 && v_loc <= 10'd394) || (v_loc >= 10'd407 && v_loc <= 10'd430)))
            screen_colour = 12'b1111_0000_0000;
            
            
        // Press Start Key to Play
        // P
        if(((h_loc >= 11'd267 && h_loc <= 11'd270) || (h_loc >= 11'd489 && h_loc <= 11'd492)) && (v_loc >= 10'd476 && v_loc <= 10'd491))
            screen_colour = 12'b0000_0000_0000;
       
        if(((h_loc >= 11'd271 && h_loc <= 11'd274) || (h_loc >= 11'd493 && h_loc <= 11'd496)) && ((v_loc >= 10'd476 && v_loc <= 10'd479) || (v_loc >= 10'd482 && v_loc <= 10'd485)))
            screen_colour = 12'b0000_0000_0000;
        
        if(((h_loc >= 11'd275 && h_loc <= 11'd276) || (h_loc >= 11'd497 && h_loc <= 11'd498)) && (v_loc >= 10'd476 && v_loc <= 10'd485))
            screen_colour = 12'b0;
       
        if(((h_loc >= 11'd277 && h_loc <= 11'd278) || (h_loc >= 11'd499 && h_loc <= 11'd500)) && (v_loc >= 10'd478 && v_loc <= 10'd483))
            screen_colour = 12'b0;
            
        // r
        if(((h_loc >= 11'd281 && h_loc <= 11'd282) || (h_loc >= 11'd381 && h_loc <= 11'd382)) && (v_loc >= 10'd482 && v_loc <= 10'd491))
            screen_colour = 12'b0;
       
        if(((h_loc >= 11'd283 && h_loc <= 11'd284) || (h_loc >= 11'd383 && h_loc <= 11'd384)) && (v_loc >= 10'd480 && v_loc <= 10'd491))
            screen_colour = 12'b0;
        
        if(((h_loc >= 11'd285 && h_loc <= 11'd286) || (h_loc >= 11'd385 && h_loc <= 11'd386)) && (v_loc >= 10'd480 && v_loc <= 10'd483))
            screen_colour = 12'b0;
       
        if(((h_loc >= 11'd287 && h_loc <= 11'd288) || (h_loc >= 11'd387 && h_loc <= 11'd388)) && (v_loc >= 10'd480 && v_loc <= 10'd485))
            screen_colour = 12'b0;
        
        if(((h_loc >= 11'd289 && h_loc <= 11'd290) || (h_loc >= 11'd389 && h_loc <= 11'd390)) && (v_loc >= 10'd482 && v_loc <= 10'd485))
            screen_colour = 12'b0;
            
        // e
        if(((h_loc >= 11'd293 && h_loc <= 11'd294) || (h_loc >= 11'd425 && h_loc <= 11'd426)) && (v_loc >= 10'd482 && v_loc <= 10'd491))
            screen_colour = 12'b0;
       
        if(((h_loc >= 11'd295 && h_loc <= 11'd296) || (h_loc >= 11'd427 && h_loc <= 11'd428)) && (v_loc >= 10'd480 && v_loc <= 10'd491))
            screen_colour = 12'b0;
            
        if(((h_loc >= 11'd297 && h_loc <= 11'd300) || (h_loc >= 11'd429 && h_loc <= 11'd432)) && ((v_loc >= 10'd480 && v_loc <= 10'd481) || (v_loc >= 10'd484 && v_loc <= 10'd485) || (v_loc >= 10'd488 && v_loc <= 10'd491)))
            screen_colour = 12'b0;
        
        if(((h_loc >= 11'd301 && h_loc <= 11'd302) || (h_loc >= 11'd433 && h_loc <= 11'd434)) && ((v_loc >= 10'd480 && v_loc <= 10'd485) || (v_loc >= 10'd488 && v_loc <= 10'd491)))
            screen_colour = 12'b0;
       
        if(((h_loc >= 11'd303 && h_loc <= 11'd304) || (h_loc >= 11'd435 && h_loc <= 11'd436)) && ((v_loc >= 10'd482 && v_loc <= 10'd485) || (v_loc >= 10'd488 && v_loc <= 10'd489)))
            screen_colour = 12'b0;
            
        // s
        if(((h_loc >= 11'd307 && h_loc <= 11'd308) || (h_loc >= 11'd321 && h_loc <= 11'd322)) && ((v_loc >= 10'd482 && v_loc <= 10'd486) || (v_loc >= 10'd490 && v_loc <= 10'd491)))
            screen_colour = 12'b0;
       
        if(((h_loc >= 11'd309 && h_loc <= 11'd310) || (h_loc >= 11'd323 && h_loc <= 11'd324)) && ((v_loc >= 10'd480 && v_loc <= 10'd487) || (v_loc >= 10'd490 && v_loc <= 10'd491)))
            screen_colour = 12'b0;
            
        if(((h_loc >= 11'd311 && h_loc <= 11'd314) || (h_loc >= 11'd325 && h_loc <= 11'd328)) && ((v_loc >= 10'd480 && v_loc <= 10'd481) || (v_loc >= 10'd484 && v_loc <= 10'd487) || (v_loc >= 10'd490 && v_loc <= 10'd491)))
            screen_colour = 12'b0;
        
        if(((h_loc >= 11'd315 && h_loc <= 11'd316) || (h_loc >= 11'd329 && h_loc <= 11'd330)) && ((v_loc >= 10'd480 && v_loc <= 10'd481) || (v_loc >= 10'd484 && v_loc <= 10'd491)))
            screen_colour = 12'b0;
       
        if(((h_loc >= 11'd317 && h_loc <= 11'd318) || (h_loc >= 11'd331 && h_loc <= 11'd332)) && ((v_loc >= 10'd480 && v_loc <= 10'd481) || (v_loc >= 10'd486 && v_loc <= 10'd489)))
            screen_colour = 12'b0;
            
        // S
        if((h_loc >= 11'd339 && h_loc <= 11'd340) && ((v_loc >= 10'd478 && v_loc <= 10'd483) || (v_loc >= 10'd488 && v_loc <= 10'd491)))
            screen_colour = 12'b0;
        
        if((h_loc >= 11'd341 && h_loc <= 11'd342) && ((v_loc >= 10'd476 && v_loc <= 10'd485) || (v_loc >= 10'd488 && v_loc <= 10'd491)))
            screen_colour = 12'b0;
            
        if((h_loc >= 11'd343 && h_loc <= 11'd346) && ((v_loc >= 10'd476 && v_loc <= 10'd479) || (v_loc >= 10'd482 && v_loc <= 10'd485) || (v_loc >= 10'd488 && v_loc <= 10'd491)))
            screen_colour = 12'b0;
        
        if((h_loc >= 11'd347 && h_loc <= 11'd348) && ((v_loc >= 10'd476 && v_loc <= 10'd479) || (v_loc >= 10'd482 && v_loc <= 10'd491)))
            screen_colour = 12'b0;
        
        if((h_loc >= 11'd349 && h_loc <= 11'd350) && ((v_loc >= 10'd476 && v_loc <= 10'd479) || (v_loc >= 10'd484 && v_loc <= 10'd489)))
            screen_colour = 12'b0;
            
        // t
        if(((h_loc >= 11'd353 && h_loc <= 11'd356) || (h_loc >= 11'd393 && h_loc <= 11'd396) || (h_loc >= 11'd457 && h_loc <= 11'd460)) && (v_loc >= 10'd480 && v_loc <= 10'd483))
            screen_colour = 12'b0;
       
        if(((h_loc >= 11'd357 && h_loc <= 11'd360) || (h_loc >= 11'd397 && h_loc <= 11'd400) || (h_loc >= 11'd461 && h_loc <= 11'd464)) && (v_loc >= 10'd476 && v_loc <= 10'd491))
            screen_colour = 12'b0;
        
        if(((h_loc >= 11'd361 && h_loc <= 11'd364) || (h_loc >= 11'd401 && h_loc <= 11'd404) || (h_loc >= 11'd465 && h_loc <= 11'd468)) && (v_loc >= 10'd480 && v_loc <= 10'd483))
            screen_colour = 12'b0;
            
        // a
        if(((h_loc >= 11'd367 && h_loc <= 11'd368) || (h_loc >= 11'd511 && h_loc <= 11'd512)) && (v_loc >= 10'd486 && v_loc <= 10'd489))
            screen_colour = 12'b0;
       
        if(((h_loc >= 11'd369 && h_loc <= 11'd370) || (h_loc >= 11'd513 && h_loc <= 11'd514)) && (v_loc >= 10'd484 && v_loc <= 10'd491))
            screen_colour = 12'b0;
            
        if(((h_loc >= 11'd371 && h_loc <= 11'd372) || (h_loc >= 11'd515 && h_loc <= 11'd516)) && ((v_loc >= 10'd480 && v_loc <= 10'd481) || (v_loc >= 10'd484 && v_loc <= 10'd485) || (v_loc >= 10'd488 && v_loc <= 10'd491)))
            screen_colour = 12'b0;
        
        if(((h_loc >= 11'd375 && h_loc <= 11'd376) || (h_loc >= 11'd519 && h_loc <= 11'd520)) && ((v_loc >= 10'd480 && v_loc <= 10'd491)))
            screen_colour = 12'b0;
            
        if(((h_loc >= 11'd377 && h_loc <= 11'd378) || (h_loc >= 11'd521 && h_loc <= 11'd522)) && ((v_loc >= 10'd482 && v_loc <= 10'd489)))
            screen_colour = 12'b0;
       
        if(((h_loc >= 11'd373 && h_loc <= 11'd374) || (h_loc >= 11'd517 && h_loc <= 11'd518)) && ((v_loc >= 10'd480 && v_loc <= 10'd485) || (v_loc >= 10'd488 && v_loc <= 10'd491)))
            screen_colour = 12'b0;
            
            
        // K
        if((h_loc >= 11'd411 && h_loc <= 11'd414) && (v_loc >= 10'd476 && v_loc <= 10'd491))
            screen_colour = 12'b0;
            
        if((h_loc >= 11'd415 && h_loc <= 11'd416) && (v_loc >= 10'd482 && v_loc <= 10'd485))
            screen_colour = 12'b0;
            
        if((h_loc >= 11'd417 && h_loc <= 11'd418) && (v_loc >= 10'd478 && v_loc <= 10'd489))
            screen_colour = 12'b0;
            
        if((h_loc >= 11'd419 && h_loc <= 11'd420) && ((v_loc >= 10'd476 && v_loc <= 10'd481) || (v_loc >= 10'd486 && v_loc <= 10'd491)))
            screen_colour = 12'b0;
        
        if((h_loc >= 11'd421 && h_loc <= 11'd422) && ((v_loc >= 10'd476 && v_loc <= 10'd479) || (v_loc >= 10'd488 && v_loc <= 10'd491)))
            screen_colour = 12'b0;
        
            
        // y
        if(((h_loc >= 11'd439 && h_loc <= 11'd440) || (h_loc >= 11'd525 && h_loc <= 11'd526)) && ((v_loc >= 10'd480 && v_loc <= 10'd487) || (v_loc >= 10'd492 && v_loc <= 10'd493) || (v_loc >= 10'd490 && v_loc <= 10'd491)))
            screen_colour = 12'b0;
        
        if(((h_loc >= 11'd441 && h_loc <= 11'd442) || (h_loc >= 11'd527 && h_loc <= 11'd528)) && ((v_loc >= 10'd480 && v_loc <= 10'd489) || (v_loc >= 10'd492 && v_loc <= 10'd493)))
            screen_colour = 12'b0;
       
        if(((h_loc >= 11'd443 && h_loc <= 11'd446) || (h_loc >= 11'd529 && h_loc <= 11'd532)) && ((v_loc >= 10'd486 && v_loc <= 10'd489) || (v_loc >= 10'd492 && v_loc <= 10'd493)))
            screen_colour = 12'b0;
            
        if(((h_loc >= 11'd447 && h_loc <= 11'd450) || (h_loc >= 11'd533 && h_loc <= 11'd536)) && ((v_loc >= 10'd480 && v_loc <= 10'd493)))
            screen_colour = 12'b0;
        
            
        // o
        if(((h_loc >= 11'd471 && h_loc <= 11'd472) || (h_loc >= 11'd481 && h_loc <= 11'd482)) && ((v_loc >= 10'd482 && v_loc <= 10'd489)))
            screen_colour = 12'b0;
            
        if(((h_loc >= 11'd473 && h_loc <= 11'd474) || (h_loc >= 11'd479 && h_loc <= 11'd480)) && ((v_loc >= 10'd480 && v_loc <= 10'd491)))
            screen_colour = 12'b0;
            
        if((h_loc >= 11'd475 && h_loc <= 11'd478) && ((v_loc >= 10'd480 && v_loc <= 10'd483) || (v_loc >= 10'd488 && v_loc <= 10'd491)))
            screen_colour = 12'b0;
           
        
        // l
        if((h_loc >= 11'd503 && h_loc <= 11'd504) && (v_loc >= 10'd476 && v_loc <= 10'd489))
            screen_colour = 12'b0;
            
        if((h_loc >= 11'd505 && h_loc <= 11'd506) && (v_loc >= 10'd476 && v_loc <= 10'd491))
            screen_colour = 12'b0;
            
        if((h_loc >= 11'd507 && h_loc <= 11'd508) && (v_loc >= 10'd490 && v_loc <= 10'd491))
            screen_colour = 12'b0;
    end
    end
    
    
    always @(*) begin
        temp = score; 
     if (temp<10)begin
     a=temp;
     b=0;
     end
     else if (temp>=10 && temp<20)begin
     a=temp-10;
     b=1;
     end
      else if (temp>=20 && temp<30)begin
     a=temp-20;
     b=2;
     end 
     else if (temp>30 && temp<40)begin
     a=temp-30;
     b=3;
     end 
     else if (temp>40 && temp<50)begin
     a=temp-40;
     b=4;
     end
     else begin
     a=0;
     b=0;
     end
     

     
    end
    
     reg [20:0] count ;
 reg state_reg, state_next;
 parameter s0=0, s1=1;
 
 always @(posedge clk) begin
 
 if(reset || restart) begin
 state_reg<=s0;
 count<=0;
 end
 
  else if(count == 400000)
 begin
 state_reg<= state_next;
 count<=0;
 end
 
 else begin
 count<=count+1;
 end
 
 end
 
  always @(*)
  begin
  disp= 7'b1000100;
  case(state_reg)
  s0:state_next=s1;
  s1: state_next=s0;
  endcase 
  
 
  if (state_reg == s0)begin
 
  act= 8'b11111110;
   case (a)
            4'b0000: begin 
            disp= 7'b0000001;
        
            end
            4'b0001: begin
            disp= 7'b1001111;
            end
            4'b0010: begin
            disp= 7'b0010010;
            end
            4'b0011: begin
            disp= 7'b0000110;
            end
            4'b0100: begin
            disp= 7'b1001100;
            end
            4'b0101: begin
            disp= 7'b0100100;
            end
            4'b0110: begin
            disp= 7'b0100000;
            end
            4'b0111: begin
           disp= 7'b0001111;
            end
             4'b1000: begin
           disp= 7'b0000000;
            end
            4'b1001: begin
           disp= 7'b0000100;
            end
            
            
            
        endcase
  end
  else begin
  
   act= 8'b11111101;
   case (b)
            4'b0000: begin 
            disp= 7'b0000001;
        
            end
            4'b0001: begin
            disp= 7'b1001111;
            end
            4'b0010: begin
            disp= 7'b0010010;
            end
            4'b0011: begin
            disp= 7'b0000110;
            end
            4'b0100: begin
            disp= 7'b1000100;
            end
            4'b0101: begin
            disp= 7'b0100100;
            end
            4'b0110: begin
            disp= 7'b0100000;
            end
            4'b0111: begin
           disp= 7'b0001111;
            end
             4'b1000: begin
           disp= 7'b0000000;
            end
            4'b1001: begin
           disp= 7'b0000100;
            end
            
            
            
        endcase
  end
  end
    
 
   
    assign red_colour = (h_disp && v_disp)?(start?((~stop && ~self_coll)?colour_reg:game_over_color):screen_colour):12'b0; 
endmodule