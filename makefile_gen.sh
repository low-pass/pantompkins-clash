#!/usr/bin/bash

rm -rf src/vhdl
rm -rf sim/work-modelsim
rm -f sim/Makefile-modelsim
rm -f sim/modelsim.ini
rm -f sim/.emacs-vhdl-cache*
cd src
clash --vhdl Sampler.hs

# Emacs needs the project, its folder and vhdl sources path
# to be defined from "Customize Project" buffer in vhdl-mode.
# Specify your init file path to load these settings

cd ../sim
emacs -batch -l C:/Users/USER/AppData/Roaming/.emacs.d/init.el -l vhdl-mode -compiler ModelSim -project sampler -f vhdl-generate-makefile
make -f Makefile-modelsim
