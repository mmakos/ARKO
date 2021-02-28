# Mediane filter
## Written in assembly

Program takes BMP image and applies median filter with 3x3 window to it.

There are two versions available:
* First is written in MIPS architecture (32 registers, no stack usage). You need [Mars simulator software](http://courses.missouristate.edu/kenvollmar/mars/) to run this.
* Second is written for linux x86 NASM style assembly. It can be compiled by `make` command (executing makefile). Make sure you have NASM installed and you have 32-bit libraries. You can satisfy those requirements with: `apt-get install nasm` and `apt-get install gcc-multilib`

Executing: ./median input.bmp output.bmp

You can see some examples in img folder (before and after filtering).

![Original image](https://raw.githubusercontent.com/mmakos/ARKO/master/img/dziecko.bmp)
![Image after filtering](https://raw.githubusercontent.com/mmakos/ARKO/master/img/dzieckoOut.bmp)
