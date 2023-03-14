# CSE 125/225 Winter 2023 Class Repository

## Getting Started

1. [Fork](https://git.ucsc.edu/drichmond/cse-x25-wi23/-/forks/new) this repository in GitLab, and set the visibility level to *Private*
2. Add the TA(s) and Instructor as *Project Members* 
   - Replace your_username and navigate to: `https://git.ucsc.edu/<your_username>/cse-x25-wi23/-/project_members` OR `https://git.ucsc.edu/<your_username>/cse-x25-wi23/` > Project Information > Members
	 - Click on *Invite Group*
	 - Type In: `cse-x25-wi23-staff`, or (all three) `drichmond`, `pdutta1` and `bharsh`
	 - Click Invite
3. [Clone](https://docs.gitlab.com/ee/gitlab-basics/start-using-git.html) `https://git.ucsc.edu/<your_username>/cse-x25-wi23/` repository to your machine

This process ensures that we can push lab assignments to you, and you can push lab solutions to us!


## Repository Structure


The repository has the following file structure:

```bash
| README.md (This File)
├── lab1
│   │   assignment.pdf # Details of Lab Assignment
│   │   README.md # Instructions for running the lab
│   ├── provided_modules
│   │   └── *.sv # pre-written SystemVerilog files
│   ├── part1
│   │   ├── <Module Name 1>
│   │   │   ├── <Module Name>.sv # SystemVerilog Skeleton File
│   │   │   ├── testbench.sv # Testbench for module
│   │   │   └── Makefile # Makefile for running tests
│   │   ├── <Module Name 2>
│   │   │   └── ... # Same files as above
│   │   ├── ...
│   │   └── <Module Name N>
│   ├── part2
│   │   └──  ... # Same structure as part 1
│   ├── ...
│   └── part<X>
├── lab2
│   │   assignment.pdf # Details of Lab Assignment
│   │   README.md # Instructions for running the lab
│   ├── part1
│   ├──...
│   └── part<Y>
├── ...
└── lab<Z>
```

Each lab folder will be available in a branch named `cse-x25-lab<N>`
on the day it is assigned in Canvas (typically around 9 AM PST).
In general, the assignment of each lab will be to complete a set of tasks by completing the SystemVerilog skeleton files. 
Correctness can be tested by simulating the Verilog using the provided makefiles. See `make help` in each module.

In general, the assignment of each lab is to complete several
conceptual parts, each with individual modules.  Each module has a set
of verilog skeleton files that must be completed. Correctness is
verfied by running the testbench using the provided makefile.

Each makefile provides a `make help` command that describes the
available commands.

All labs are due by 11:59:59 PM Pacific Standard Time on the due date
listed in Canvas, typically two weeks after the date they are
assigned.


## CSE 125 (Final Exam Option) Lab Completion

To complete and submit a lab for grading:
	1. Demonstrate correctly simulating code for each part of each
       module to an instructor or TA in one of the lab sections. 
	2. Push your working code to your private fork of this git repository.
	3. Submit the git hash for your working code to Canvas.
    4. Complete the post-lab questionaire on Canvas.
    

## CSE 225 (and CSE 125 + Final Project Option) Lab Completion
	
To complete and submit a lab for grading:
	1. Demonstrate correctly simulating code for each part of each
       module to an instructor or TA in one of the lab sections.
	2. Demonstrate correctly operating code on the FPGA for each
       module that has an FPGA component.
	3. Push your working code to your private fork of this git repository.
	4. Submit the git hash for your working code to Canvas.
    5. Complete the post-lab questionaire on Canvas.

Accomodations will be made in situations specified in the class syllabus.


## CSE 125 (Final Exam Option) Tools

To complete the labs for CSE 125 you will need the following tools:

- *Icarus Verilog*: https://bleyer.org/icarus/ (v10.0)
- *Verilator*: https://verilator.org/guide/latest/index.html (v5.0)
- *GTKWave*: https://gtkwave.sourceforge.net/ (v3.0)

If you use the provided VirtualBox image, these tools will already be
installed. You can install VirtualBox using the instructions here:
https://www.virtualbox.org/wiki/Downloads

You will also need the Oracle VM VirtualBox Extension Pack:
https://www.oracle.com/virtualization/technologies/vm/downloads/virtualbox-downloads.html#extpack

Otherwise you can install these tools using the instructions below.

## CSE 225 (and CSE 125 + Final Project Option)

To complete the labs and project for CSE 225 you will need the CSE 125
tools (above) and the following tools:

- *Yosys*: https://yosyshq.net/yosys/ (v0.23)
- *nextpnr-ice40*: https://github.com/YosysHQ/nextpnr (v0.4)
- *project-icestorm*: https://clifford.at/icestorm (No Version)

If you use the provided VirtualBox image available in Canvas, these
tools will already be installed. You can install VirtualBox using the
instructions here: https://www.virtualbox.org/wiki/Downloads


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

If you are running windows we HIGHLY recommend using the provided
VirtualBox image. 

We will update with WSL instructions when they are available.

