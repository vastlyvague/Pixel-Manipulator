`timescale 1ns / 1ps
//****************************************************************// 
//  File name: anipx_generator.v                                  // 
//                                                                // 
//  Created by       Thomas Nguyen on 10/31/18.                   // 
//  Copyright c 2018 Thomas Nguyen. All rights reserved.          // 
//                                                                // 
//                                                                // 
//  In submitting this file for class work at CSULB               // 
//  I am confirming that this is my work and the work             // 
//  of no one else. In submitting this code I acknowledge that    // 
//  plagiarism in student project work is subject to dismissal.   // 
//  from the class                                                // 
//****************************************************************// 
module anipx_generator(clk, reset, pixel_x, pixel_y, video_on,
                       btn, RGB);
   
   input               clk, reset, video_on;   
   input       [9:0]   pixel_x, pixel_y;
   
   //button input      btn[0] = up; btn[1] = down;
   input       [1:0]   btn;
   output reg [11:0]   RGB;
   
   //Paddle
   reg         [9:0]   padd_y_reg, padd_y_next;
   wire        [9:0]   padd_y_t, padd_y_b; //top bottom
   
   //Ball
   reg         [9:0]   ball_x_reg, ball_y_reg;
   wire        [9:0]   ball_x_next, ball_y_next;
   wire        [9:0]   ball_y_t, ball_y_b; //top bottom
   wire        [9:0]   ball_x_l, ball_x_r; //left right
   
   // reg to track ball speed
   reg         [9:0]   x_delta_reg, y_delta_reg, x_delta_next, y_delta_next;
   
   reg        [20:0]   count, count_r;
   wire       [11:0]   wall_rgb, padd_rgb, ball_rgb;
   
   // Conversion to 60Hz clock
   assign pulse60hz = (count_r==21'd1_666_666);
   assign game_over = (ball_x_r >= 640);
  
   always @(*)
      if(pulse60hz) count = 21'b0; else
         count = count_r + 21'b1;
   
   //registers
   always@(posedge clk, posedge reset)
      if(reset) begin
         padd_y_reg <= 10'd204; //paddle at middle
         ball_x_reg <= 10'd35;  //ball next to wall
         ball_y_reg <= 10'b0;   //     at the top
         x_delta_reg <= 10'h4;
         y_delta_reg <= 10'h4;
         count_r <= 21'b0;
      end
      else begin
         padd_y_reg <= padd_y_next;
         ball_x_reg <= ball_x_next;
         ball_y_reg <= ball_y_next;
         x_delta_reg <= x_delta_next;
         y_delta_reg <= y_delta_next;
         count_r <= count;
      end
      
   //Assign constraints on pixel x and y coordinates to check
   //where the shape is.
   //If within these regions, wall checker will be active
   assign wall_on = (pixel_x >= 10'd32) && (pixel_x <= 10'd35);
   
   //  Paddle section  //////////////////////////////                    
   assign padd_y_t = padd_y_reg;
   assign padd_y_b = padd_y_t + 10'd72 - 10'b1;
   
   //If within these regions, paddle checker will be active
   assign padd_on = (pixel_x >= 10'd600) && (pixel_x <= 10'd603) &&
                    (pixel_y >= padd_y_t) && (pixel_y <= padd_y_b);
   
   //For paddle moving up and down
   always@(*) begin
      padd_y_next = padd_y_reg;
      if(game_over)
         padd_y_next = 10'd204;
      else
         if(pulse60hz)
            //max y - 1 - paddle size
            if((btn[1]) && (padd_y_b < (10'd480 - 10'b1)))
               padd_y_next = padd_y_reg + 10'd4; //pixel increment (move down)
            else if((btn[0]) && (padd_y_t > 10'd0))
               padd_y_next = padd_y_reg - 10'd4; //pixel decrement (move up)
   end
      
   //  Ball section  //////////////////////////////
   assign ball_x_l = ball_x_reg;
   assign ball_y_t = ball_y_reg;
   assign ball_x_r = ball_x_l + 10'd8 - 10'b1;
   assign ball_y_b = ball_y_t + 10'd8 - 10'b1;
   
   //If within these regions, ball checker will be active
   assign ball_on = (pixel_x >= ball_x_l) && (pixel_x <= ball_x_r) &&
                    (pixel_y >= ball_y_t) && (pixel_y <= ball_y_b);
   
   //ball position
   assign ball_x_next = (game_over) ? 10'd35 :
                           ((pulse60hz) ? ball_x_reg + x_delta_reg : ball_x_reg);
   assign ball_y_next = (game_over) ? 10'b0 :
                           ((pulse60hz) ? ball_y_reg + y_delta_reg : ball_y_reg);
   
   //ball velocity
   always@(*) begin
      x_delta_next = x_delta_reg;
      y_delta_next = y_delta_reg;
      if(ball_y_t < 10'b1) // reach top
         y_delta_next = 2; //velocity positive
      else if(ball_y_b > (10'd480 - 10'b1)) // reach bottom
         y_delta_next = -2; //velocity negative
      else if(ball_x_l <= 10'd35) // reach wall
         x_delta_next = 2;
      else if((10'd600 <= ball_x_r) && (ball_x_r <= 10'd603) &&
              (padd_y_t <= ball_y_b) && (padd_y_b >= ball_y_t))
         x_delta_next = -2;
      else if(game_over) begin
         x_delta_next = 10'h4;
         y_delta_next = 10'h4;
         end
   end
         
   //Assign colours for objects
   assign wall_rgb = 12'h00f;
   assign padd_rgb = 12'h0f0;
   assign ball_rgb = 12'hf00;
   
   //RGB setting for objects and background
   always@(*)
      if(video_on)
         if(wall_on)
            RGB = wall_rgb;
         else if(padd_on)
            RGB = padd_rgb;
         else if(ball_on)
            RGB = ball_rgb;
         else
            RGB = 12'hfff;
      else
         RGB = 12'h0;
   
endmodule
