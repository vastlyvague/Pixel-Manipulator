`timescale 1ns / 1ps
//****************************************************************// 
//  File name: vga_sync.v                                         // 
//                                                                // 
//  Created by       Thomas Nguyen on 10/07/18.                   // 
//  Copyright c 2018 Thomas Nguyen. All rights reserved.          // 
//                                                                // 
//                                                                // 
//  In submitting this file for class work at CSULB               // 
//  I am confirming that this is my work and the work             // 
//  of no one else. In submitting this code I acknowledge that    // 
//  plagiarism in student project work is subject to dismissal.   //  
//  from the class                                                // 
//****************************************************************// 
module vga_sync(clk, reset, hsync, vsync, video_on, pixel_x, pixel_y,
                tick);
input              clk, reset;
output             hsync, vsync, video_on, tick;
output       [9:0] pixel_x, pixel_y;
wire               pulse25Mhz, h_ss, v_ss, hend, vend;
reg                h_ss_r, v_ss_r;
reg          [1:0] count, count_r;
reg          [9:0] v_count, h_count, v_count_r, h_count_r;

// Conversion to 25MHz clock
assign pulse25Mhz = (count_r==2'b11);
  
always @(*)
  if(pulse25Mhz) count = 2'b0; else
            count = count_r + 2'b1;

// Sequential Logic      
always @(posedge clk or posedge reset)
  if(reset) begin
   count_r <= 2'b0; 
   h_count_r <= 10'd0;
   v_count_r <= 10'd0;
   h_ss_r <= 1'b0;
   v_ss_r <= 1'b0;
   end 
  else begin
   count_r <= count;
   h_count_r <= h_count;
   v_count_r <= v_count;
   h_ss_r <= h_ss;
   v_ss_r <= v_ss;
   end
   
// Assign Flags for when both Horizontal and Vertical
// Counts reach 799 and 524 counts
assign hend = (h_count_r == 10'd799);
assign vend = (v_count_r == 10'd524);

// Horizontal and Vertical Scan Counter
always @(*)
   if(pulse25Mhz)
      // Checks if horizontal counter is 799
      // Sets to 0 if true else increments
      if(hend)
         h_count = 10'b0;

      else
         // Increments Horizontal Count
         h_count = h_count_r + 10'b1;
   else
      h_count = h_count_r; // Horizontal Scan Count
      
always @(*)
   if((pulse25Mhz) && (hend))
      // Checks if Vertical Scan Counter is 524
      // Sets to 0 if true else increments
      if(vend)
         v_count = 10'b0;
      else
      // Increments Vertical Count
         v_count = v_count_r + 10'b1;
   else
      v_count = v_count_r; // Vertical Scan Count

// Assign Horizontal/Vertical Sync Signal for low active
// hsync is from 656 to 751 and vsync is from 490 to 491
assign h_ss = (h_count_r >= 10'd656)&&(h_count_r <= 10'd751)?1'b0:1'b1;
assign v_ss = (v_count_r >= 10'd490)&&(v_count_r <= 10'd491)?1'b0:1'b1;

// Assign Horizontal/Vertical video on for high active
// h_vo is from 0 to 639 and v_vo is from 0 to 479
assign h_vo = (h_count_r >= 10'd0)&&(h_count_r <= 10'd639);
assign v_vo = (v_count_r >= 10'd0)&&(v_count_r <= 10'd479);

// Assign Video On for when both h_vo and v_vo are active
assign video_on = (h_vo == 1'b1)&&(v_vo == 1'b1);

// Assign output location for the pixels
assign pixel_x = h_count_r;
assign pixel_y = v_count_r;

// Assign vysnc and hsync
assign hsync = h_ss_r;
assign vsync = v_ss_r;

// Assign tick
assign tick = pulse25Mhz;

endmodule
