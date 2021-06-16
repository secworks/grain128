//======================================================================
//
// grain128.v
// ----------
// Top level wrapper for the Grain_128AEAD stream cipher core.
//
//
// Author: Joachim Strombergson
// Copyright (c) 2021, Assured AB
// All rights reserved.
//
// Redistribution and use in source and binary forms, with or
// without modification, are permitted provided that the following
// conditions are met:
//
// 1. Redistributions of source code must retain the above copyright
//    notice, this list of conditions and the following disclaimer.
//
// 2. Redistributions in binary form must reproduce the above copyright
//    notice, this list of conditions and the following disclaimer in
//    the documentation and/or other materials provided with the
//    distribution.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
// "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
// LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
// FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
// COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
// INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
// BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
// LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
// CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
// STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
// ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
// ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//
//======================================================================

`default_nettype none

module grain128(
                input wire           clk,
                input wire           reset_n,

                input wire           cs,
                input wire           we,

                input wire  [7 : 0]  address,
                input wire  [31 : 0] write_data,
                output wire [31 : 0] read_data
               );


  //----------------------------------------------------------------
  // Internal constant and parameter definitions.
  //----------------------------------------------------------------
  localparam ADDR_NAME0       = 8'h00;
  localparam ADDR_NAME1       = 8'h01;
  localparam ADDR_VERSION     = 8'h02;

  localparam ADDR_CTRL        = 8'h08;
  localparam CTRL_INIT_BIT    = 0;
  localparam CTRL_NEXT_BIT    = 1;

  localparam ADDR_STATUS      = 8'h09;
  localparam STATUS_READY_BIT = 0;

  localparam ADDR_KEY0        = 8'h10;
  localparam ADDR_KEY3        = 8'h13;

  localparam ADDR_BLOCK0      = 8'h20;
  localparam ADDR_BLOCK1      = 8'h21;
  localparam ADDR_BLOCK2      = 8'h22;
  localparam ADDR_BLOCK3      = 8'h23;

  localparam ADDR_RESULT0     = 8'h30;
  localparam ADDR_RESULT1     = 8'h31;
  localparam ADDR_RESULT2     = 8'h32;
  localparam ADDR_RESULT3     = 8'h33;

  localparam CORE_NAME0       = 32'h67726169; // "grai"
  localparam CORE_NAME1       = 32'h6e313238; // "n128"
  localparam CORE_VERSION     = 32'h302e3130; // "0.10"


  //----------------------------------------------------------------
  // Registers including update variables and write enable.
  //----------------------------------------------------------------
  reg init_reg;
  reg init_new;

  reg next_reg;
  reg next_new;

  reg [127 : 0] key_reg;
  reg [127 : 0] key_new;
  reg           key_we;

  reg [095 : 0] iv_reg;
  reg [095 : 0] iv_new;
  reg           iv_we;


  //----------------------------------------------------------------
  // Wires.
  //----------------------------------------------------------------
  reg [31 : 0]   tmp_read_data;


  //----------------------------------------------------------------
  // Concurrent connectivity for ports etc.
  //----------------------------------------------------------------
  assign read_data = tmp_read_data;


  //----------------------------------------------------------------
  // core instantiation.
  //----------------------------------------------------------------
  grain128_core core(
                     .clk(clk),
                     .reset_n(reset_n),

                     .init(init_reg),
                     .next(init_reg),

                     .key(key_reg),
                     .iv(iv_reg)
                    );


  //----------------------------------------------------------------
  // reg_update
  // Update functionality for all registers in the core.
  // All registers are positive edge triggered with synchronous
  // active low reset.
  //----------------------------------------------------------------
  always @ (posedge clk)
    begin : reg_update
      integer i;
      if (!reset_n) begin
        init_reg <= 1'h0;
        next_reg <= 1'h0;
        key_reg  <= 128'h0;
        iv_reg   <= 96'h0;
      end

      else begin
        init_reg <= init_new;
        next_reg <= next_new;

        if (key_we)
          key_reg <= key_new;

        if (iv_we)
          iv_reg  <= iv_new;
      end
    end // reg_update


  //----------------------------------------------------------------
  // api
  //
  // The interface command decoding logic.
  //----------------------------------------------------------------
  always @*
    begin : api
      init_new      = 1'h0;
      next_new      = 1'h0;
      key_we        = 1'h0;
      iv_we          = 1'h0;
      tmp_read_data = 32'h0;

      if (cs)
        begin
          if (we) begin
              if (address == ADDR_CTRL) begin
                init_new = write_data[CTRL_INIT_BIT];
                next_new = write_data[CTRL_NEXT_BIT];
              end
          end

          else begin
            case (address)
              ADDR_NAME0:   tmp_read_data = CORE_NAME0;
              ADDR_NAME1:   tmp_read_data = CORE_NAME1;
              ADDR_VERSION: tmp_read_data = CORE_VERSION;
              default:
                begin
                end
            endcase // case (address)
          end
        end
    end // addr_decoder
endmodule // grain128

//======================================================================
// EOF grain128.v
//======================================================================
