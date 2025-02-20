/*
  
   Multicore 2 / Multicore 2+
  
   Copyright (c) 2017-2020 - Victor Trucco

  
   All rights reserved
  
   Redistribution and use in source and synthezised forms, with or without
   modification, are permitted provided that the following conditions are met:
  
   Redistributions of source code must retain the above copyright notice,
   this list of conditions and the following disclaimer.
  
   Redistributions in synthesized form must reproduce the above copyright
   notice, this list of conditions and the following disclaimer in the
   documentation and/or other materials provided with the distribution.
  
   Neither the name of the author nor the names of other contributors may
   be used to endorse or promote products derived from this software without
   specific prior written permission.
  
   THIS CODE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
   AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
   THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
   PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE
   LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
   CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
   SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
   INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
   CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
   ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
   POSSIBILITY OF SUCH DAMAGE.
  
   You are responsible for any legal issues arising from your use of this code.
  
*//*  This file is part of JTFRAME.
    JTFRAME program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    JTFRAME program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with JTFRAME.  If not, see <http://www.gnu.org/licenses/>.

    Author: Jose Tejada Gomez. Twitter: @topapate
    Version: 1.0
    Date: 22-2-2019 */

`timescale 1ns/1ps

// This is the MiST top level
// It will instantiate the appropriate game core according
// to the macro GAMETOP
// It will get the config string for the microcontroller
// from the include file conf_str.v

//============================================================================
//
//  Multicore 2+ Top by Victor Trucco
//
//============================================================================

`default_nettype none

module `MISTTOP(
       // Clocks
    input wire  clock_50_i,

    // Buttons
    //input wire [4:1]    btn_n_i,

    // SRAM 
    output wire [19:0]sram_addr_o  = 20'b00000000000000000000,
    inout wire  [15:0]sram_data_io   = 8'bzzzzzzzzbzzzzzzzz,
    output wire sram_we_n_o     = 1'b1,
    output wire sram_oe_n_o     = 1'b1,	 
	 
        
    // SDRAM (W9825G6KH-6)
    output [12:0] SDRAM_A,
    output  [1:0] SDRAM_BA,
    inout  [15:0] SDRAM_DQ,
    output        SDRAM_DQMH,
    output        SDRAM_DQML,
    output        SDRAM_CKE,
    output        SDRAM_nCS,
    output        SDRAM_nWE,
    output        SDRAM_nRAS,
    output        SDRAM_nCAS,
    output        SDRAM_CLK,

    // PS2
    inout wire  ps2_clk_io        = 1'bz,
    inout wire  ps2_data_io       = 1'bz,
    inout wire  ps2_mouse_clk_io  = 1'bz,
    inout wire  ps2_mouse_data_io = 1'bz,

    // SD Card
    output wire sd_cs_n_o         = 1'bZ,
    output wire sd_sclk_o         = 1'bZ,
    output wire sd_mosi_o         = 1'bZ,
    input wire  sd_miso_i,

    // Joysticks
    output wire joy_clock_o       = 1'b1,
    output wire joy_load_o        = 1'b1,
    input  wire joy_data_i,
    output wire joy_p7_o          = 1'b1,

    // Audio
    output      AUDIO_L,
    output      AUDIO_R,
    //input wire  ear_i,
    output wire mic_o             = 1'b0,
	 
    //  I2S
    output		SCLK,
    output		LRCLK,
    output		SDIN,		 

    // VGA
    output  [5:0] VGA_R,
    output  [5:0] VGA_G,
    output  [5:0] VGA_B,
    output        VGA_HS,
    output        VGA_VS,
	 output        VGA_PIX,

    //STM32
    input wire  stm_tx_i,
    output wire stm_rx_o,
    output wire stm_rst_o           = 1'bz, // '0' to hold the microcontroller reset line, to free the SD card
   
    input         SPI_SCK,
    output        SPI_DO,
    input         SPI_DI,
    input         SPI_SS2,
    //output wire   SPI_nWAIT        = 1'b1, // '0' to hold the microcontroller data streaming

    //inout [31:0] GPIO,

    output LED                    = 1'b1 // '0' is LED on

    `ifdef SIMULATION
    ,output         sim_pxl_cen,
    output          sim_pxl_clk,
    output          sim_vb,
    output          sim_hb
    `endif
);



//---------------------------------------------------------
//-- MC2+ defaults
//---------------------------------------------------------
//assign GPIO = 32'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
assign stm_rst_o    = 1'bZ;
assign stm_rx_o = 1'bZ;

//no SRAM for this core
assign sram_we_n_o  = 1'b1;
assign sram_oe_n_o  = 1'b1;

//all the SD reading goes thru the microcontroller for this core
assign sd_cs_n_o = 1'bZ;
assign sd_sclk_o = 1'bZ;
assign sd_mosi_o = 1'bZ;

wire joy1_up_i, joy1_down_i, joy1_left_i, joy1_right_i, joy1_p6_i, joy1_p9_i;
wire joy2_up_i, joy2_down_i, joy2_left_i, joy2_right_i, joy2_p6_i, joy2_p9_i;

//joystick_serial  joystick_serial 
//(
//    .clk_i           ( clk_sys ),
//    .joy_data_i      ( joy_data_i ),
//    .joy_clk_o       ( joy_clock_o ),
//    .joy_load_o      ( joy_load_o ),
//
//    .joy1_up_o       ( joy1_up_i ),
//    .joy1_down_o     ( joy1_down_i ),
//    .joy1_left_o     ( joy1_left_i ),
//    .joy1_right_o    ( joy1_right_i ),
//    .joy1_fire1_o    ( joy1_p6_i ),
//    .joy1_fire2_o    ( joy1_p9_i ),
//
//    .joy2_up_o       ( joy2_up_i ),
//    .joy2_down_o     ( joy2_down_i ),
//    .joy2_left_o     ( joy2_left_i ),
//    .joy2_right_o    ( joy2_right_i ),
//    .joy2_fire1_o    ( joy2_p6_i ),
//    .joy2_fire2_o    ( joy2_p9_i )
//);

joydecoder joystick_serial  (
    .clk          ( clk_sys ), 	//48mhz  --> (4)
    .joy_data     ( joy_data_i ),
    .joy_clk      ( joy_clock_o ),
    .joy_load     ( joy_load_o ),
	 .clock_locked ( pll_locked ),

    .joy1up       ( joy1_up_i ),
    .joy1down     ( joy1_down_i ),
    .joy1left     ( joy1_left_i ),
    .joy1right    ( joy1_right_i ),
    .joy1fire1    ( joy1_p6_i ),
    .joy1fire2    ( joy1_p9_i ),

    .joy2up       ( joy2_up_i ),
    .joy2down     ( joy2_down_i ),
    .joy2left     ( joy2_left_i ),
    .joy2right    ( joy2_right_i ),
    .joy2fire1    ( joy2_p6_i ),
    .joy2fire2    ( joy2_p9_i )
); 

//-----------------------------------------------------------------

`ifdef SIMULATION
localparam CONF_STR="JTGNG;;";
`else
// Config string
`define SEPARATOR "",
`include "conf_str.v"

localparam CONF_STR = {
     "P,CORE_NAME.dat;",
//   "P,DoubleDragon.dat;",
//   "P,DoubleDragon2.dat;",
     "S,DAT,Alternative ROM...;",
    "O1,Credits,OFF,ON;",
    "OC,Flip screen,OFF,ON;",
    "OE,Double Framebuffer,ON,OFF;",
    `ifdef JOIN_JOYSTICKS
    "OE,Separate Joysticks,Yes,No;",    // If no, then player 2 joystick
        // is assimilated to player 1 joystick
    `endif

    "O5,Scandoubler,On,Off;",
    
    `ifdef MISTER_VIDEO_MIXER
        "O35,Scandoubler Fx,None,HQ2x,CRT 25%,CRT 50%,CRT 75%;",
    `else
        `ifdef JTGNG_VGA
            "O9,Screen filter,ON,OFF;",
        `else
               "O34,Scanlines,Off,25%,50%,75%;",
        `endif
    `endif
    `ifdef HAS_TESTMODE
    "O6,Test mode,OFF,ON;",
    `endif
    `ifdef JT12
    "O7,PSG,ON,OFF;",
    "O8,FM ,ON,OFF;",
    "OAB,FX volume, high, very high, very low, low;",
     `else
     "OAB,Volume Gain, Low, Medium, High;",
    `endif
    `SEPARATOR
    `CORE_OSD
    "T0,Reset;",
    "V,patreon.com/topapate;"
};

`undef SEPARATOR`endif

wire          rst, rst_n, clk_sys, clk_rom, clk6, clk24;
wire [31:0]   status, joystick1, joystick2;
wire [21:0]   sdram_addr;
wire [31:0]   data_read;
wire          loop_rst;
wire          downloading, dwnld_busy;
wire [22:0]   ioctl_addr;
wire [ 7:0]   ioctl_data;
wire          ioctl_wr;

wire [ 1:0]   sdram_wrmask;
wire          sdram_rnw;
wire [15:0]   data_write;

`ifndef JTFRAME_WRITEBACK
assign sdram_wrmask = 2'b11;
assign sdram_rnw    = 1'b1;
assign data_write   = 16'h00;
`endif

//wire rst_req   = status[0] | ~btn_n_i[4];
wire rst_req   = status[0];
wire join_joys = status[32'he];

wire sdram_req;

wire [21:0]   prog_addr;
wire [ 7:0]   prog_data;
wire [ 1:0]   prog_mask;
wire          prog_we, prog_rd;

`ifndef COLORW
`define COLORW 4
`endif
localparam COLORW=`COLORW;

wire [COLORW-1:0] red;
wire [COLORW-1:0] green;
wire [COLORW-1:0] blue;

wire LHBL_dly, LVBL_dly, hs, vs;
wire [15:0] snd_left, snd_right;

`ifndef STEREO_GAME
assign snd_right = snd_left;
`endif

wire [9:0] game_joy1, game_joy2, game_joy3, game_joy4;
wire [3:0] game_coin, game_start;
wire game_rst;
wire [3:0] gfx_en;
// SDRAM
wire data_rdy, sdram_ack;
wire refresh_en;


// PLL's
// 24 MHz or 12 MHz base clock
wire clk_vga_in, clk_vga, clk_40, pll_locked;
jtframe_pll0 u_pll_game (
    .inclk0 ( clock_50_i ),
    .c1     ( clk_rom     ), // 48 MHz
    .c2     ( SDRAM_CLK   ),
    .c3     ( clk24       ),
    .c4     ( clk6        ),
    .locked ( pll_locked  )
);

// assign SDRAM_CLK = clk_rom;
assign clk_sys   = clk_rom;

jtframe_pll1 u_pll_vga (
    .inclk0 ( clk_sys    ),
    .c0     ( clk_vga    ), // 25
    .c1     ( clk_40     ),
);

wire [7:0] dipsw_a, dipsw_b;
wire [1:0] dip_fxlevel;
wire       enable_fm, enable_psg;
wire       dip_pause, dip_flip, dip_test;
wire       pxl_cen, pxl2_cen;

`ifdef SIMULATION
assign sim_pxl_clk = clk_sys;
assign sim_pxl_cen = pxl_cen;
assign sim_vb = ~LVBL_dly;
assign sim_hb = ~LHBL_dly;
`endif

`ifndef SIGNED_SND
`define SIGNED_SND 1'b1
`endif

`ifndef BUTTONS
`define BUTTONS 2
`endif


wire [5:0] vga_r_s; 
wire [5:0] vga_g_s; 
wire [5:0] vga_b_s; 

//assign VGA_R = vga_r_s[5:1];
//assign VGA_G = vga_g_s[5:1];
//assign VGA_B = vga_b_s[5:1];
assign VGA_R = vga_r_s;
assign VGA_G = vga_g_s;
assign VGA_B = vga_b_s;

wire MCLK;

jtframe_np1 #( 
    .CONF_STR     ( CONF_STR       ),
    .SIGNED_SND   ( `SIGNED_SND    ),
    .BUTTONS      ( `BUTTONS       ),
    .COLORW       ( COLORW         )
    `ifdef VIDEO_WIDTH
    ,.VIDEO_WIDTH   ( `VIDEO_WIDTH   )
    `endif
    `ifdef VIDEO_HEIGHT
    ,.VIDEO_HEIGHT  ( `VIDEO_HEIGHT  )
    `endif
)
u_frame(
    .clk_sys        ( clk_sys        ),
    .clk_rom        ( clk_rom        ),
    .clk_vga        ( clk_vga        ),
	 .clk_40         ( clk_40         ),
    .pll_locked     ( pll_locked     ),
    .status         ( status         ),
    // Base video
    .game_r         ( red            ),
    .game_g         ( green          ),
    .game_b         ( blue           ),
    .LHBL           ( LHBL_dly       ),
    .LVBL           ( LVBL_dly       ),
    .hs             ( hs             ),
    .vs             ( vs             ),
    .pxl_cen        ( pxl_cen        ),
    .pxl2_cen       ( pxl2_cen       ),
    // MiST VGA pins
    .VGA_R           ( vga_r_s        ),
    .VGA_G           ( vga_g_s        ),
    .VGA_B           ( vga_b_s        ),
    .VGA_HS         ( VGA_HS         ),
    .VGA_VS         ( VGA_VS         ),
	 .VGA_CLK        ( VGA_PIX        ),
    // SDRAM interface
    .SDRAM_CLK      ( SDRAM_CLK      ),
    .SDRAM_DQ       ( SDRAM_DQ       ),
    .SDRAM_A        ( SDRAM_A        ),
    .SDRAM_DQML     ( SDRAM_DQML     ),
    .SDRAM_DQMH     ( SDRAM_DQMH     ),
    .SDRAM_nWE      ( SDRAM_nWE      ),
    .SDRAM_nCAS     ( SDRAM_nCAS     ),
    .SDRAM_nRAS     ( SDRAM_nRAS     ),
    .SDRAM_nCS      ( SDRAM_nCS      ),
    .SDRAM_BA       ( SDRAM_BA       ),
    .SDRAM_CKE      ( SDRAM_CKE      ),
    // SPI interface to arm io controller
    .SPI_DO         ( SPI_DO         ),
    .SPI_DI         ( SPI_DI         ),
    .SPI_SCK        ( SPI_SCK        ),
    .SPI_SS2        ( SPI_SS2        ),
    .SPI_SS3        ( ),//SPI_SS3        ),
    .SPI_SS4        ( ),//SPI_SS4        ),
    .CONF_DATA0     ( ),//CONF_DATA0     ),
    // ROM
    .ioctl_addr     ( ioctl_addr     ),
    .ioctl_data     ( ioctl_data     ),
    .ioctl_wr       ( ioctl_wr       ),
    .prog_addr      ( prog_addr      ),
    .prog_data      ( prog_data      ),
    .prog_mask      ( prog_mask      ),
    .prog_we        ( prog_we        ),
    .prog_rd        ( prog_rd        ),
    .downloading    ( downloading    ),
    .dwnld_busy     ( dwnld_busy     ),
     //Keyboard
     .ps2_kbd_clk    ( ps2_clk_io  ),
    .ps2_kbd_data   ( ps2_data_io ),
    // ROM access from game
    .loop_rst       ( loop_rst       ),
    .sdram_addr     ( sdram_addr     ),
    .sdram_req      ( sdram_req      ),
    .sdram_ack      ( sdram_ack      ),
    .data_read      ( data_read      ),
    .data_rdy       ( data_rdy       ),
    .refresh_en     ( refresh_en     ),
    // write support
    .sdram_wrmask   ( sdram_wrmask   ),
    .sdram_rnw      ( sdram_rnw      ),
    .data_write     ( data_write     ),
//////////// board
    .rst            ( rst            ),
    .rst_n          ( rst_n          ), // unused
    .game_rst       ( game_rst       ),
    .game_rst_n     (                ),
    // reset forcing signals:
    .rst_req        ( rst_req        ),
    // Sound
    .snd_left       ( snd_left       ),
    .snd_right      ( snd_right      ),
    .AUDIO_L        ( AUDIO_L        ),
    .AUDIO_R        ( AUDIO_R        ),
    // joystick
    .game_joystick1 ( game_joy1      ),
    .game_joystick2 ( game_joy2      ),
    .game_joystick3 ( game_joy3      ),
    .game_joystick4 ( game_joy4      ),
    .game_coin      ( game_coin      ),
    .game_start     ( game_start     ),
    .game_service   (                ), // unused
    .LED            ( LED            ),
    // DIP and OSD settings
    .enable_fm      ( enable_fm      ),
    .enable_psg     ( enable_psg     ),
    .dip_test       ( dip_test       ),
    .dip_pause      ( dip_pause      ),
    .dip_flip       ( dip_flip       ),
    .dip_fxlevel    ( dip_fxlevel    ),
    // Debug
    .gfx_en         ( gfx_en         ),
     
     //MC2 joysticks
    .joy1_up_i          ( joy1_up_i     ),
    .joy1_down_i        ( joy1_down_i   ),
    .joy1_left_i        ( joy1_left_i   ),
    .joy1_right_i       ( joy1_right_i  ),
    .joy1_p6_i          ( joy1_p6_i     ),
    .joy1_p9_i          ( joy1_p9_i     ),
    .joy2_up_i          ( joy2_up_i     ),
    .joy2_down_i        ( joy2_down_i   ),
    .joy2_left_i        ( joy2_left_i   ),
    .joy2_right_i       ( joy2_right_i  ),
    .joy2_p6_i          ( joy2_p6_i     ),
    .joy2_p9_i          ( joy2_p9_i     ),
    .joyX_p7_o          ( joy_p7_o     ),
	
	 // SONIDO I2S
	 .CLK_I2S        ( clock_50_i   ),
	 .SCLK           ( SCLK         ),
	 .LRCLK          ( LRCLK        ),
	 .MCLK           ( MCLK         ),
	 .SDIN	        ( SDIN         ) 
);	 	 

`ifdef SIMULATION
`ifdef TESTINPUTS
    test_inputs u_test_inputs(
        .loop_rst       ( loop_rst       ),
        .LVBL           ( LVBL           ),
        .game_joystick1 ( game_joy1[6:0] ),
        .button_1p      ( game_start[0]  ),
        .coin_left      ( game_coin[0]   )
    );
    assign game_start[1] = 1'b1;
    assign game_coin[1]  = 1'b1;
    assign game_joystick2 = ~10'd0;
    assign game_joystick3 = ~10'd0;
    assign game_joystick4 = ~10'd0;
    assign game_joystick1[9:7] = 3'b111;
    assign sim_vb = vs;
    assign sim_hb = hs;
`endif
`endif

wire sample;

`GAMETOP
u_game(
    .rst         ( game_rst       ),
    .clk         ( clk_sys        ),
    `ifdef JTFRAME_CLK24
    .clk24       ( clk24          ),
    `endif
    `ifdef JTFRAME_CLK6
    .clk6        ( clk6           ),
    `endif
    .pxl2_cen    ( pxl2_cen       ),
    .pxl_cen     ( pxl_cen        ),
    .red         ( red            ),
    .green       ( green          ),
    .blue        ( blue           ),
    .LHBL_dly    ( LHBL_dly       ),
    .LVBL_dly    ( LVBL_dly       ),
    .HS          ( hs             ),
    .VS          ( vs             ),

    //.start_button( game_start & { 2'b11, btn_n_i[2], btn_n_i[1]} ),
    //.coin_input  ( game_coin  & {3'b111, btn_n_i[3]} ),
    .start_button( game_start ),
    .coin_input  ( game_coin  ),	 
	 .joystick1   ( game_joy1[7:0] ),
    .joystick2   ( game_joy2[7:0] ),
    `ifdef JTFRAME_4PLAYERS
    .joystick3    ( game_joy3[7:0]   ),
    .joystick4    ( game_joy4[7:0]   ),
    `endif

    // Sound control
    .enable_fm   ( enable_fm      ),
    .enable_psg  ( enable_psg     ),
    // PROM programming
    .ioctl_addr  ( ioctl_addr     ),
    .ioctl_data  ( ioctl_data     ),
    .ioctl_wr    ( ioctl_wr       ),
    .prog_addr   ( prog_addr      ),
    .prog_data   ( prog_data      ),
    .prog_mask   ( prog_mask      ),
    .prog_we     ( prog_we        ),
    .prog_rd     ( prog_rd        ),
    // ROM load
    .downloading ( downloading    ),
    .dwnld_busy  ( dwnld_busy     ),
    .loop_rst    ( loop_rst       ),
    .sdram_req   ( sdram_req      ),
    .sdram_addr  ( sdram_addr     ),
    .data_read   ( data_read      ),
    .sdram_ack   ( sdram_ack      ),
    .data_rdy    ( data_rdy       ),
    .refresh_en  ( refresh_en     ),
    `ifdef JTFRAME_WRITEBACK
    .sdram_wrmask( sdram_wrmask   ),
    .sdram_rnw   ( sdram_rnw      ),
    .data_write  ( data_write     ),
    `endif

    // DIP switches
    .status      ( status         ),
    .dip_pause   ( dip_pause      ),
    .dip_flip    ( dip_flip       ),
    .dip_test    ( dip_test       ),
    .dip_fxlevel ( dip_fxlevel    ),  

    // sound
    `ifndef STEREO_GAME
    .snd         ( snd_left       ),
    `else
    .snd_left    ( snd_left       ),
    .snd_right   ( snd_right      ),
    `endif
    .sample      ( sample         ),
    // Debug
    .gfx_en      ( gfx_en         )
);

`ifdef SIMULATION
integer fsnd;
initial begin
    fsnd=$fopen("sound.raw","wb");
end
always @(posedge sample) begin
    $fwrite(fsnd,"%u", {snd_left, snd_right});
end
`endif

endmodule