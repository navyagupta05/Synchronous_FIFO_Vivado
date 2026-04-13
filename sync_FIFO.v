`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/02/2026 03:27:09 PM
// Design Name: 
// Module Name: sync_FIFO
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


module sync_FIFO
    // Parameters
    #( parameter FIFO_DEPTH = 8,        // no. of memory locations
	   parameter DATA_WIDTH = 32)       // total bits of data stored at each memory location
    // Ports  
	(input clk,                             // clock
     input rst_n,                           // reset
     input cs,                              // chip select	 
     input wr_en,                           // write enable
     input rd_en,                           // read enable
     input [DATA_WIDTH-1:0] data_in,        // input data
     output reg [DATA_WIDTH-1:0] data_out = 0,  // output data
	 output empty,                          // empty flag
	 output full                            // full flag
	 ); 

  localparam FIFO_DEPTH_LOG = $clog2(FIFO_DEPTH);   // FIFO_DEPTH_LOG = 3 (no. of bits required to represent 8 locations (000 to 111)
	
  // Memory, block RAM used
  (* ram_style = "block" *) reg [DATA_WIDTH-1:0] fifo [0:FIFO_DEPTH-1];// depth 8 => [0:7], 32 bit elements
	
   // Pointers (extra MSB for full detection)
  reg [FIFO_DEPTH_LOG:0] write_pointer = 0;//3:0
  reg [FIFO_DEPTH_LOG:0] read_pointer = 0;//3:0

    // write operation 
    always @(posedge clk) 
      begin
      if(!rst_n)// rst = 0 system reset happens
		    write_pointer <= 0;
      else if (cs && wr_en && !full) begin
          fifo[write_pointer[FIFO_DEPTH_LOG-1:0]] <= data_in;  // input data stored in fifo via write pointer
	       write_pointer <= write_pointer + 1'b1;
      end
      end
  
	// read operation
	always @(posedge clk) 
      begin
	    if(!rst_n)
		    read_pointer <= 0;
      else if (cs && rd_en && !empty) begin
          	data_out <= fifo[read_pointer[FIFO_DEPTH_LOG-1:0]];  // data in fifo sent as output via read pointer 
	        read_pointer <= read_pointer + 1'b1;  
      end
	end
	
	// empty/full logic
    assign empty = (read_pointer == write_pointer);
	assign full  = (read_pointer == {~write_pointer[FIFO_DEPTH_LOG], write_pointer[FIFO_DEPTH_LOG-1:0]});

  endmodule