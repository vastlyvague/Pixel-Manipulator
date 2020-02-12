`timescale 1ns / 1ps
//****************************************************************// 
//  File name: top_level.v                                        // 
//                                                                // 
//  Created by       Thomas Nguyen on 12/02/18.                   // 
//  Copyright c 2018 Thomas Nguyen. All rights reserved.          // 
//                                                                // 
//                                                                // 
//  In submitting this file for class work at CSULB               // 
//  I am confirming that this is my work and the work             // 
//  of no one else. In submitting this code I acknowledge that    // 
//  plagiarism in student project work is subject to dismissal.   //  
//  from the class                                                // 
//****************************************************************// 
module top_level(clk100mhz, reset, btnu, btnd, vga_hs, vga_vs, RGB_o);
                 
input              clk100mhz, reset, btnu, btnd;;
output wire        vga_hs, vga_vs;
output wire [11:0] RGB_o;
reg          [1:0] count, count_r;
reg         [11:0] RGB_R;
wire               rst_sync, video_on, pulse25Mhz;
wire         [9:0] pixel_x, pixel_y;
wire        [11:0] RGB_next;

AISO_register   uut0(.clk(clk100mhz), .reset(reset), .reset_sync(rst_sync));
vga_sync        uut1(.clk(clk100mhz), .reset(rst_sync), .tick(pulse25Mhz),
                     .hsync(vga_hs), .vsync(vga_vs), .video_on(video_on),
                     .pixel_x(pixel_x), .pixel_y(pixel_y));
anipx_generator uut2(.clk(clk100mhz), .reset(rst_sync), .pixel_x(pixel_x),
                     .pixel_y(pixel_y), .video_on(video_on), .RGB(RGB_next), 
                     .btn({btnd,btnu}));
                               
// Sequential block for tick counter and RGB buffer
always@(posedge clk100mhz, posedge rst_sync)
   if(rst_sync)
      RGB_R <= 11'b0;
   else
      if(pulse25Mhz)
         RGB_R <= RGB_next;
      
// Output of RGB
assign RGB_o = RGB_R;

endmodule
