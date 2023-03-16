# CSE 125/225 Winter 2023 Class Repository

## Getting Started

1. [Clone](https://medium.datadriveninvestor.com/how-to-clone-a-github-repository-using-ssh-for-windows-linux-macos-78ad9a3959e) Follow the instructions to clone reliably

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

### Hardware Required to run the project

### Directions on how to play the game using the hardware



