# CSE 125/225 Winter 2023 Class Repository

## Getting Started

1. [Clone](https://medium.datadriveninvestor.com/how-to-clone-a-github-repository-using-ssh-for-windows-linux-macos-78ad9a3959e) Follow the instructions to clone reliably

### How to build and test the project.

Navigate to the 'Final_Project/Pacman'(refer to the repository structure below) Directory, open the terminal and type in 'make test' 
to run the simulation for the main state machine. Type in 'make prog' after plugging in the ice40 board to program the project onto the board, 
use an HDMI cable to connect the DVI to HDMI pmod to a HDMI monitor.

## Repository Structure

The repository has the following file structure:

```bash
├── Final_Project # main folder containing every file and fodler realting to this project
│   ├── fpga.mk # defining parameters for the make file for the the main top module used to program the ice40 board (Type "make prog" in terminal)
│   ├── Pacman # main folder that contains everyfile specifc to running the game
│   │   ├── counter.sv # counter module 
│   │   ├── display_480p.sv # 480 display module that handles the dvi to hdmi conversion and h/vsync generation
│   │   ├── display_clock.sv # Module that uses the ice40 built in PLL module to generate a clock suitable for a 480p display
│   │   ├── dvi_decoder.sv # simplied module that decodes the dvi signal to hdmi
│   │   ├── edge_detector.sv # an edge detector module to record singular button presses
│   │   ├── food_sprite.mem # bitmap for the food pacman eats
│   │   ├── foodXcoords.mem # X coordinates for the food placment in the maze
│   │   ├── foodYcoords.mem # Y coordinates for the food placment in the maze
│   │   ├── ghost_sprite.mem # bitmap for the ghost
│   │   ├── input_de_sync.sv # debounce and syncronizer module for buttons and the joystick inputs
│   │   ├── lsfr.sv # A lsfr module used to generate random numbers
│   │   ├── Makefile # Makefile that is used to programming the board.
│   │   ├── pacman_game_over.mem # bitmap for the game over screen
│   │   ├── pacman_maze.mem # bitmap for the maze
│   │   ├── pacman_menu.mem # bitmap for the main menu screen
│   │   ├── pacman_orientation.sv # state machine to determine which way the pacman is facing based on joystick input
│   │   ├── pacman_sprite_bottom.mem # bitmap for the pacman facing south
│   │   ├── pacman_sprite_circle.mem # bitmap for the pacman with a closed mouth represented as a circle for the eating animation
│   │   ├── pacman_sprite_left.mem # bitmap for the pacman facing west
│   │   ├── pacman_sprite_lives.mem # bitmap for the text "LIVES: "
│   │   ├── pacman_sprite_right.mem # bitmap for the pacman facing east
│   │   ├── pacman_sprite_score.mem # bitmap for the text "SCORE: "
│   │   ├── pacman_sprite_top.mem # btimap for the pacman facing north
│   │   ├── ready_maze.mem # bitmap for the text "READY!" that appears at the start of a round.
│   │   ├── rom_async.sv # async read only memory module to read in the bitmaps
│   │   ├── score2.sv # a module that takes in a 4 bit number and outputs the coressponding number in pixel addresses for the second digit in a two digit number
│   │   ├── score.sv # a module that takes in a 4 bit number and outputs the coressponding number in pixel addresses for the first digit in a two digit number
│   │   ├── screens_state_machine.sv # main state machine that transistions between the 3 different states of the game.
│   │   ├── shift.sv # a shift module that shifts in new data to a speficied width bus; used for the lsfr.
│   │   ├── simple_480p.sv # another version of the dvi to hdmi decoder module that generates hsync/vsync
│   │   ├── sprite_inline.sv # a sprite generation module that takes in a bitmap and uses the async rom to output pixel address based on the bitmap and resolution
│   │   ├── testbench.sv # main tesbench to simulate the main state machine (screen_state_machine).
│   │   ├── timer.sv # a timer module used throughout the project to keep time.
│   │   ├── top.sv # the top module that has all the modules instantiated to the the pacman game
│   │   └── top_temp.sv # temporary top module for testing perposes (you can ignore this).
│   ├── provided_modules
│   │   ├── dff.sv # A delay flip flop module
│   │   ├── icebreaker.pcf # the constraints file for the ice40 fpga.
│   │   ├── inv.sv # an inverter module
│   │   ├── jstk # folder containing modules used to control the joystick pmod
│   │   │   ├── ClkDiv_20Hz.sv
│   │   │   ├── ClkDiv_66_67kHz.sv
│   │   │   ├── PmodJSTK.sv
│   │   │   ├── spiCtrl.v
│   │   │   └── spiMode0.v
│   │   ├── nonsynth_clock_gen.sv # clock generator module
│   │   └── nonsynth_reset_gen.sv # reset signal generator module
│   └── simulation.mk # file that defines the paramters for simulaiton (type "make test" in terminal)
└── README.md # This file
```
Each makefile provides a `make help` command that describes the
available commands.

To run the code in this repo you will need the following tools:

- *Icarus Verilog*: https://bleyer.org/icarus/ (v10.0)
- *Verilator*: https://verilator.org/guide/latest/index.html (v5.0)
- *GTKWave*: https://gtkwave.sourceforge.net/ (v3.0)

### Typical Installation - All Operating Systems

Follow these instructions to install the OSS-CAD-Suite, which contains
all the tools: https://github.com/YosysHQ/oss-cad-suite-build#installation

If you are running on Ubuntu, create `/etc/udev/rules.d/50-lattice-ftdi.rules` (you will need to use sudo), and paste the contents: 

    `ACTION=="add", ATTR{idVendor}=="0403", ATTR{idProduct}=="6010", MODE:="666"`
    
Otherwise you will get the eqivalent of a 'device not found' error when running `iceprog`.


### Advanced Installation - Linux
	
If you like doing things the hard way, you can use these
instructions. Please ensure that you have the correct versions (listed
above).

- On Ubuntu/Debian-like distributions, run: `sudo apt install iverilog verilator gtkwave yosys nextpnr-ice40 fpga-icestorm`

- Then, create `/etc/udev/rules.d/50-lattice-ftdi.rules` (you will need to use sudo), and paste the contents: 

    `ACTION=="add", ATTR{idVendor}=="0403", ATTR{idProduct}=="6010", MODE:="666"`
    
- Double check your installed tool versions against the ones above.


### Advanced Installation - MacOS

(NB: I use my M2 to write and test the lab assignments. I recommend
the oss-cad-suite above, but this setup works too.)

- Install Homebrew: https://brew.sh/
- Run: `brew install icarus-verilog verilator gtkwave`
- Run: `brew tap ktemkin/oss-fpga`
- Run: `brew install --HEAD icestorm yosys nextpnr-ice40`


### Advanced Installation - Windows

We will update with WSL instructions when they are available.

### Description of the project
This project is a recreation of the classic arcade game 'Pacman' on the icebreaker FPGA. The motivation for this project was to demonstrate
knowledge about programming an FPGA in a complex way to demonstrate competence in a course(Logic deisgn with verliog) that I took
at University of California - Santa Cruz. I picked this project specifically because I believe it showcases my skills as a hardware designer
adequately. This recreation includes every main feature of the game in sort form or fashion albeit not perfect.

### Hardware Required to run the project
- Icebreaker board: [Link to buy the board](https://1bitsquared.com/products/icebreaker)
- DVI to HDMI Pmod: [Link to buy the DVI to HDMI PMOD](https://1bitsquared.com/products/pmod-digital-video-interface?variant=11770730020911&currency=USD&utm_medium=product_sync&utm_source=google&utm_content=sag_organic&utm_campaign=sag_organic&gclid=CjwKCAjw_MqgBhAGEiwAnYOAerGehqnmVDzodLJym-XLwjCJqNO1HS9RMvE6-_Q-4wD5j7IrgaNVtxoCZbQQAvD_BwE)
- Joystick Pmod: [Link to buy Joystick PMOD](https://digilent.com/shop/pmod-jstk2-two-axis-joystick/?setCurrencyId=1&utm_source=google&utm_medium=cpc&utm_campaign=19562111224&utm_content=146824038444&utm_term=&gclid=CjwKCAjw_MqgBhAGEiwAnYOAejhdBRVbrTXb_emyjYvTsKTonhf2goy95Sb8wDdn00SZD3X-E1_S8xoCb-kQAvD_BwE)
- A Micro usb cable to power the FPGA
- An HDMI cable to connect the dvi to hdmi pmod to a hdmi display
- A monitor with an HDMI port
- PMOD Connectors: [Link to buy PMOD connectors](https://www.moddiy.com/products/TPM-Module-Header-12-Pin-2.0mm-Pitch-90-Degree-Angled-Connector.html?srsltid=Ad5pg_HNOd0Ap0ORKVBWCqB2N5UfKmE4suOAAy929Nre5N66bENGPsvB3RU) (will require sautering)
- A computer that can install the tools above and run them.

### Directions on how to play the game using the hardware
Look at the image below to see where to connect the pmod and how to orient the board to play the game.
![guide](https://user-images.githubusercontent.com/107451649/226098790-74cd3f49-0b2c-4ab2-a61b-ecdda1e0ec26.png)
Sauter a pmod connector below the buttons seen oon the board above and connect a pmod joystick to the bottom 6 pins.
Program the board(refer to instructions above on how to do this). After you have programed the board and connected to a monitor
press the middle button to start the game. Move around using the joystick, make sure you orient the board the same way as the image
as to not confuse the directions when controlling the pacman. You can then move the pacman around and play the game.


BSD 3-Clause License

Copyright (c) 2018,2019,2020, University of California.
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

* Redistributions of source code must retain the above copyright notice, this
  list of conditions and the following disclaimer.

* Redistributions in binary form must reproduce the above copyright notice,
  this list of conditions and the following disclaimer in the documentation
  and/or other materials provided with the distribution.

* Neither the name of the copyright holder nor the names of its
  contributors may be used to endorse or promote products derived from
  this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

==============================================================================
Copyrights and Licenses for Third Party Software Distributed with LiveHD:
==============================================================================

The LiveHD software contains code written by third parties.  Such software will
have its own individual LICENSE file in the directory in which it appears. This
file will describe the copyrights, license, and restrictions which apply to that
code.

The disclaimer of warranty in the Open Source License applies to all code in the
LiveHD Distribution, and nothing in any of the other licenses gives permission
to use the names of the LiveHD Team to endorse or promote products derived from
this Software.

The following pieces of software have additional or alternate copyrights,
licenses, and/or restrictions:

simlib/?int.hpp: BSD 3-Clause

third_party/lef: Apache-2 license
third_party/def: Apache-2 license
third_party/ezsat: ISC license

external/opentimer: MIT style license
external/abc: BSD style license
external/yosys: ISC license
external/mustache: Boost license
external/spdlog: MIT license
external/sparsehash-c11: BSD 3-Clause
external/bm: Apache-2 license
external/cryptominisat: MIT style license
external/rapidjson: BSD style license
external/httplib: MIT style license
external/replxx: BSD style license
external/googletest: BSD 3-Clause

External repos used for benchmarking, not inside LiveHD:

external/verilator: LGPL license
third_party/anubis: BSD 2-Clause license

