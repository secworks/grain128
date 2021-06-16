//======================================================================
//
// grain128_core.v
// ---------------
// Grain_128AEAD stream cipher core.
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

module grain128_core(
                     input wire           clk,
                     input wire           reset_n,

                     input wire           init,
                     input wire           next,

                     input wire [127 : 0] key
                    );


  //----------------------------------------------------------------
  // Internal constant and parameter definitions.
  //----------------------------------------------------------------
  localparam CTRL_IDLE = 3'h0;


  //----------------------------------------------------------------
  // Registers including update variables and write enable.
  //----------------------------------------------------------------
  reg [127 : 0] lfsr_reg;
  reg [127 : 0] lfsr_new;
  reg           lfsr_init;
  reg           lfsr_load;
  reg           lfsr_next;
  reg           lfsr_we;

  reg [2 : 0]   core_ctrl_reg;
  reg [2 : 0]   core_ctrl_new;
  reg           core_ctrl_we;


  //----------------------------------------------------------------
  // Wires.
  //----------------------------------------------------------------


  //----------------------------------------------------------------
  // Concurrent connectivity for ports etc.
  //----------------------------------------------------------------


  //----------------------------------------------------------------
  // Internal functions.
  //----------------------------------------------------------------


  //----------------------------------------------------------------
  // reg_update
  //
  // Update functionality for all registers in the core.
  // All registers are positive edge triggered with synchronous
  // active low reset.
  //----------------------------------------------------------------
  always @ (posedge clk)
    begin: reg_update
      if (!reset_n) begin
        lfsr_reg      <= 128'h0;
        core_ctrl_reg <= CTRL_IDLE;
      end

      else begin
        if (lfsr_we)
          lfsr_reg <= lfsr_new;

        if (core_ctrl_we)
          core_ctrl_reg <= core_ctrl_new;
      end
    end // reg_update


  //----------------------------------------------------------------
  // lfsr_update
  // Update logic for the LFSR.
  //----------------------------------------------------------------
  always @*
    begin : lfsr_update
      reg s127_new;

      lfsr_new = 128'h0;
      lfsr_we  = 1'h0;

      s127_new = lfsr_reg[000] ^ lfsr_reg[007] ^ lfsr_reg[038] ^
                 lfsr_reg[070] ^ lfsr_reg[081] ^ lfsr_reg[096];

      if (lfsr_next) begin
        lfsr_new = {s127_new, lfsr_reg[127 : 1]};
        lfsr_we  = 1'h1;
      end
    end


  //----------------------------------------------------------------
  // core_ctrl
  //----------------------------------------------------------------
  always @*
    begin : core_ctrl
      lfsr_init = 1'h0;
      lfsr_load = 1'h0;
      lfsr_next = 1'h0;

      case (core_ctrl_reg)
        CTRL_IDLE : begin

        end

        default : begin
        end
      endcase // case (core_ctrl_reg)
    end

endmodule // grain128_core

//======================================================================
// EOF grain128_core.v
//======================================================================
