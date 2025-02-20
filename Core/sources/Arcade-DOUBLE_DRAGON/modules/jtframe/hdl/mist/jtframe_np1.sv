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
    Date: 7-3-2019 */

`timescale 1ns/1ps

module jtframe_np1 #(parameter
    SIGNED_SND             = 1'b0,
    BUTTONS                = 2,
    GAME_INPUTS_ACTIVE_LOW = 1'b1,
    CONF_STR               = "",
    COLORW                 = 4,
    VIDEO_WIDTH            = 384,
    VIDEO_HEIGHT           = 224
)(
    input           clk_sys,
    input           clk_rom,
    input           clk_vga,
    input           clk_40,
    input           pll_locked,
    // interface with microcontroller
    output  [31:0]  status,
    // Base video
    input [COLORW-1:0] game_r,
    input [COLORW-1:0] game_g,
    input [COLORW-1:0] game_b,
    input           LHBL,
    input           LVBL,
    input           hs,
    input           vs,
    input           pxl_cen,
    input           pxl2_cen,
    // MiST VGA pins
    output  [5:0]   VGA_R,
    output  [5:0]   VGA_G,
    output  [5:0]   VGA_B,
    output          VGA_HS,
    output          VGA_VS,
	 output          VGA_CLK,
    // SDRAM interface
    inout  [15:0]   SDRAM_DQ,       // SDRAM Data bus 16 Bits
    output [12:0]   SDRAM_A,        // SDRAM Address bus 13 Bits
    output          SDRAM_DQML,     // SDRAM Low-byte Data Mask
    output          SDRAM_DQMH,     // SDRAM High-byte Data Mask
    output          SDRAM_nWE,      // SDRAM Write Enable
    output          SDRAM_nCAS,     // SDRAM Column Address Strobe
    output          SDRAM_nRAS,     // SDRAM Row Address Strobe
    output          SDRAM_nCS,      // SDRAM Chip Select
    output [1:0]    SDRAM_BA,       // SDRAM Bank Address
    input           SDRAM_CLK,      // SDRAM Clock
    output          SDRAM_CKE,      // SDRAM Clock Enable
    // ROM access from game
    input           sdram_req,
    output          sdram_ack,
    input  [21:0]   sdram_addr,
    output [31:0]   data_read,
    output          data_rdy,
    output          loop_rst,
    input           refresh_en,
    // Write back to SDRAM
    input  [ 1:0]   sdram_wrmask,
    input           sdram_rnw,
    input  [15:0]   data_write,
    // SPI interface to arm io controller
    inout           SPI_DO,
    input           SPI_DI,
    input           SPI_SCK,
    input           SPI_SS2,
    input           SPI_SS3,
    input           SPI_SS4,
    input           CONF_DATA0,
    // ROM load from SPI
    output [22:0]   ioctl_addr,
    output [ 7:0]   ioctl_data,
    output          ioctl_wr,
    input  [21:0]   prog_addr,
    input  [ 7:0]   prog_data,
    input  [ 1:0]   prog_mask,
    input           prog_we,
    input           prog_rd,
    output          downloading,
    input           dwnld_busy,
     input              ps2_kbd_clk,
    input               ps2_kbd_data,
     
//////////// board
    output          rst,      // synchronous reset
    output          rst_n,    // asynchronous reset
    output          game_rst,
    output          game_rst_n,
    // reset forcing signals:
    input           rst_req,
    // Sound
    input   [15:0]  snd_left,
    input   [15:0]  snd_right,
    output          AUDIO_L,
    output          AUDIO_R,
    // joystick
    output   [9:0]  game_joystick1,
    output   [9:0]  game_joystick2,
    output   [9:0]  game_joystick3,
    output   [9:0]  game_joystick4,
    output   [3:0]  game_coin,
    output   [3:0]  game_start,
    output          game_service,
    // DIP and OSD settings
    output          enable_fm,
    output          enable_psg,

    output          dip_test,
    // non standard:
    output          dip_pause,
    output          dip_flip,     // A change in dip_flip implies a reset
    output  [ 1:0]  dip_fxlevel,
    // Debug
    output          LED,
    output   [3:0]  gfx_en,
     
     //mc2 joysticks
     input wire joy1_up_i,
    input wire  joy1_down_i,
    input wire  joy1_left_i,
    input wire  joy1_right_i,
    input wire  joy1_p6_i,
    input wire  joy1_p9_i,
    input wire  joy2_up_i,
    input wire  joy2_down_i,
    input wire  joy2_left_i,
    input wire  joy2_right_i,
    input wire  joy2_p6_i,
    input wire  joy2_p9_i,
    output wire joyX_p7_o,
	 
	 // SONIDO I2S
	 input                  CLK_I2S,
	 output						SCLK,
	 output						LRCLK,
	 output						MCLK,
	 output						SDIN
);

// control
wire [31:0]   joystick1, joystick2, joystick3, joystick4;
//wire          ps2_kbd_clk, ps2_kbd_data;
wire          osd_shown;

wire [7:0]    scan2x_r, scan2x_g, scan2x_b;
wire          scan2x_hs, scan2x_vs;
wire          scan2x_enb, video_direct;

wire [7:0] keys_o;

///////////////// LED is on while
// downloading, PLL lock lost, OSD is shown or in reset state
assign LED = ~( downloading | dwnld_busy | ~pll_locked | osd_shown | rst | (|(~gfx_en)));
wire  [ 1:0]  rotate;


jtframe_np1_base #(
    .CONF_STR    (CONF_STR          ),
    .CONF_STR_LEN($size(CONF_STR)/8 ),
    .SIGNED_SND  (SIGNED_SND        ),
    .COLORW      ( COLORW           )
) u_base(
    .rst            ( rst           ),
    .pll_locked     ( pll_locked    ),
    .clk_sys        ( clk_sys       ),
    .clk_vga        ( clk_vga       ),
    .clk_40         ( clk_40        ),
    .clk_rom        ( clk_rom       ),
    .SDRAM_CLK      ( SDRAM_CLK     ),
    .osd_shown      ( osd_shown     ),
    // Base video
    .osd_rotate     ( rotate        ),
    .game_r         ( game_r        ),
    .game_g         ( game_g        ),
    .game_b         ( game_b        ),
    .LHBL           ( LHBL          ),
    .LVBL           ( LVBL          ),
    .hs             ( hs            ),
    .vs             ( vs            ),
    .pxl_cen        ( pxl_cen       ),
    // Scan-doubler video
    .scan2x_r       ( scan2x_r[7:2] ),
    .scan2x_g       ( scan2x_g[7:2] ),
    .scan2x_b       ( scan2x_b[7:2] ),
    .scan2x_hs      ( scan2x_hs     ),
    .scan2x_vs      ( scan2x_vs     ),
    .scan2x_enb     ( scan2x_enb    ),
    // MiST VGA pins (includes OSD)
    .VIDEO_R        ( VGA_R         ),
    .VIDEO_G        ( VGA_G         ),
    .VIDEO_B        ( VGA_B         ),
    .VIDEO_HS       ( VGA_HS        ),
    .VIDEO_VS       ( VGA_VS        ),
	 .VIDEO_CLK      ( VGA_CLK       ),
    // SPI interface to arm io controller
    .SPI_DO         ( SPI_DO        ),
    .SPI_DI         ( SPI_DI        ),
    .SPI_SCK        ( SPI_SCK       ),
    .SPI_SS2        ( SPI_SS2       ),
    .SPI_SS3        ( SPI_SS3       ),
    .SPI_SS4        ( SPI_SS4       ),
    .CONF_DATA0     ( CONF_DATA0    ),
    // control
    .status         ( status        ),
    .joystick1      ( joystick1     ),
    .joystick2      ( joystick2     ),
    .joystick3      ( joystick3     ),
    .joystick4      ( joystick4     ),
    .ps2_kbd_clk    ( ),//ps2_kbd_clk   ),
    .ps2_kbd_data   ( ),//ps2_kbd_data  ),
    // audio
    .clk_dac        ( clk_sys       ),
    .snd_left       ( snd_left      ),
    .snd_right      ( snd_right     ),
    .snd_pwm_left   ( AUDIO_L       ),
    .snd_pwm_right  ( AUDIO_R       ),
    // ROM load from SPI
    .ioctl_addr     ( ioctl_addr    ),
    .ioctl_data     ( ioctl_data    ),
    .ioctl_wr       ( ioctl_wr      ),
    .downloading    ( downloading   ),
     .keys_i          ( keys_o        ),
     
     //MC2 joysticks
    .video_direct       ( video_direct  ),
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
    .joyX_p7_o          ( joyX_p7_o     ),

	 // SONIDO I2S
	 .CLK_I2S        (     CLK_I2S  ),	 
	 .SCLK           (     SCLK     ),
	 .LRCLK          (     LRCLK    ),
	 .MCLK           (     MCLK     ),
	 .SDIN	        (     SDIN     ) 
);

jtframe_board #(
    .BUTTONS               ( BUTTONS                ),
    .GAME_INPUTS_ACTIVE_LOW( GAME_INPUTS_ACTIVE_LOW ),
    .COLORW                ( COLORW                 ),
    .VIDEO_WIDTH           ( VIDEO_WIDTH            ),
    .VIDEO_HEIGHT          ( VIDEO_HEIGHT           )
) u_board(
    .rst            ( rst             ),
    .rst_n          ( rst_n           ),
    .game_rst       ( game_rst        ),
    .game_rst_n     ( game_rst_n      ),
    .rst_req        ( rst_req         ),
    .downloading    ( dwnld_busy      ), // use busy signal from game module

    .clk_sys        ( clk_sys         ),
    .clk_rom        ( clk_rom         ),
    .clk_vga        ( clk_vga         ),
    // joystick
    .ps2_kbd_clk    ( ps2_kbd_clk     ),
    .ps2_kbd_data   ( ps2_kbd_data    ),
    .board_joystick1( joystick1[15:0] ),
    .board_joystick2( joystick2[15:0] ),
    .board_joystick3( joystick3[15:0] ),
    .board_joystick4( joystick4[15:0] ),
    .game_joystick1 ( game_joystick1  ),
    .game_joystick2 ( game_joystick2  ),
    .game_joystick3 ( game_joystick3  ),
    .game_joystick4 ( game_joystick4  ),
    .game_coin      ( game_coin       ),
    .game_start     ( game_start      ),
    .game_service   ( game_service    ),
    // DIP and OSD settings
    .status         ( status          ),
    .enable_fm      ( enable_fm       ),
    .enable_psg     ( enable_psg      ),
    .dip_test       ( dip_test        ),
    .dip_pause      ( dip_pause       ),
    .dip_flip       ( dip_flip        ),
    .dip_fxlevel    ( dip_fxlevel     ),
    // screen
    .rotate         ( rotate          ),
    // SDRAM interface
    .SDRAM_DQ       ( SDRAM_DQ        ),
    .SDRAM_A        ( SDRAM_A         ),
    .SDRAM_DQML     ( SDRAM_DQML      ),
    .SDRAM_DQMH     ( SDRAM_DQMH      ),
    .SDRAM_nWE      ( SDRAM_nWE       ),
    .SDRAM_nCAS     ( SDRAM_nCAS      ),
    .SDRAM_nRAS     ( SDRAM_nRAS      ),
    .SDRAM_nCS      ( SDRAM_nCS       ),
    .SDRAM_BA       ( SDRAM_BA        ),
    .SDRAM_CKE      ( SDRAM_CKE       ),
    // SDRAM controller
    .loop_rst       ( loop_rst        ),
    .sdram_addr     ( sdram_addr      ),
    .sdram_req      ( sdram_req       ),
    .sdram_ack      ( sdram_ack       ),
    .data_read      ( data_read       ),
    .data_rdy       ( data_rdy        ),
    .refresh_en     ( refresh_en      ),
    .prog_addr      ( prog_addr       ),
    .prog_data      ( prog_data       ),
    .prog_mask      ( prog_mask       ),
    .prog_we        ( prog_we         ),
    .prog_rd        ( prog_rd         ),
    // write back support
    .sdram_wrmask   ( sdram_wrmask    ),
    .sdram_rnw      ( sdram_rnw       ),
    .data_write     ( data_write      ),
     
    // Base video
    .osd_rotate     ( rotate          ),
    .game_r         ( game_r          ),
    .game_g         ( game_g          ),
    .game_b         ( game_b          ),
    .LHBL           ( LHBL            ),
    .LVBL           ( LVBL            ),
    .hs             ( hs              ),
    .vs             ( vs              ),
    .pxl_cen        ( pxl_cen         ),
    .pxl2_cen       ( pxl2_cen        ),
    // Scan-doubler video
    .scan2x_r       ( scan2x_r        ),
    .scan2x_g       ( scan2x_g        ),
    .scan2x_b       ( scan2x_b        ),
    .scan2x_hs      ( scan2x_hs       ),
    .scan2x_vs      ( scan2x_vs       ),
    .scan2x_enb     ( scan2x_enb      ),
    // Debug
    .gfx_en         ( gfx_en          ),
    // Unused ports (MiSTer)
    .hdmi_arx       (                 ),
    .hdmi_ary       (                 ),
    .hdmi_clk       (                 ),
    .hdmi_cen       (                 ),
    .hdmi_r         (                 ),
    .hdmi_g         (                 ),
    .hdmi_b         (                 ),
    .hdmi_hs        (                 ),
    .hdmi_vs        (                 ),
    .hdmi_de        (                 ),
    .hdmi_sl        (                 ),
    .scan2x_clk     (                 ),
    .scan2x_cen     (                 ),
    .scan2x_de      (                 ),

    //Multicore 2
    .video_direct   ( video_direct    ),
    .keys_o         ( keys_o          )

);

endmodule // jtframe