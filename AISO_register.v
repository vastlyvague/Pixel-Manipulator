`timescale 1ns / 1ps
//****************************************************************// 
//  File name: AISO_register.v                                    // 
//                                                                // 
//  Created by       Thomas Nguyen on 9/13/18    .                // 
//  Copyright c 2018 Thomas Nguyen. All rights reserved.          // 
//                                                                // 
//                                                                // 
//  In submitting this file for class work at CSULB               // 
//  I am confirming that this is my work and the work             // 
//  of no one else. In submitting this code I acknowledge that    // 
//  plagiarism in student project work is subject to dismissal.   //  
//  from the class                                                // 
//****************************************************************// 
/* Description: 
 * Asynchronous in and synchronous out for reset.
 */
module AISO_register(clk, reset, reset_sync);
   input      clk, reset;
   output     reset_sync;
   reg        q, d_reg;
   
   always@(posedge clk or posedge reset)
      if(reset) begin
                  d_reg <= 1'b0; 
                  q <= 1'b0; 
                end else begin
                  d_reg <= 1'b1;
                  q <= d_reg;
                end
   
   assign reset_sync = ~q;
   
endmodule
