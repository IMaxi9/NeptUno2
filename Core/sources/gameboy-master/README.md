# Gameboy DeMiSTified

22/09/21 DECA port DeMiSTified by somhic from original MiST gameboy https://github.com/mist-devel/gameboy.   

Special thanks to Alastair M. Robinson creator of [DeMiSTify](https://github.com/robinsonb5/DeMiSTify) for helping me. I've also added some of his solutions from https://github.com/robinsonb5/gameboy like phase shift at SDRAM_CLK, and content from firmware/config.h and overrides.c.

[Read this guide if you want to know how I DeMiSTified this core](https://github.com/DECAfpga/DECA_board/tree/main/Tutorials/DeMiSTify).

Original module sound errors and signed/unsigned troubles have been arranged thanks to @rampa069.

**Check additional READMEs into each board folder.**

Follows original readme.md content:

Source code for Gameboy for MIST
================================

This is source code of a gameboy implementation for the MIST. 

It's based on the [t80](http://opencores.org/project,t80) CPU core. A minor
fix was needed for the "LD ($FF00+C)" instruction.

The audio implementation has been taken from the PACE framework. The
original file is available in the [pacedev svn](https://svn.pacedev.net/repos/pace/sw/src/component/sound/gb/gbc_snd.vhd).

Binaries are available at https://github.com/mist-devel/mist-binaries/tree/master/cores/gameboy.
