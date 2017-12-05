# pantompkins-clash
Pan Tompkins a.k.a. Real-Time QRS Detection Algorithm in CLaSH HDL

## VHDL Generation

The sources are tested to work with **clash 0.7.2** ([see clash-lang.org](http://www.clash-lang.org/) for setup instructions)
```
$ cd src
$ clash --vhdl Sampler.hs
```
The ```src/vhdl/``` folder will contain the RTL code which is FPGA / ASIC
synthesizable

## Simulation

The VHDL simulation can be very useful for running the massive amounts of data
through the signal processing IP and for examining the waveforms and timing
events easily. Even though CLaSH allows for testbench generation, the runtime
data importing into its simulation is not so trivial. The temporary shoehorn
solution is to use a simple VHDL testbench as a CSV reader and IP host for
the simulation, prior to the actual hardware synthesis.

The free version of **ModelSim** from Intel FPGA works quite reliably for such
purposes. Latest version can be [downloaded from Altera](http://dl.altera.com/?product=modelsim_ae). To avoid manually
recompiling the new sources in proper order in ModelSim,
a makefile is produced with the Emacs *vhdl-mode* plugin. Standalone
Windows version of **make** can be found [here](http://www.equation.com/servlet/equation.cmd?fa=make).

For development purposes, Emacs + vhdl-mode is very useful for updating the
VHDL sim library (see the ```makefile-gen.sh``` for more details). However, the
"default" ```Makefile-modelsim``` is already included in the repo if one
wants to skip straight to the simulation.

```
$ cd sim
$ make -f Makefile-modelsim
```
The makefile target automatically produces the working library and ```.ini```
file for the simulator.
The ```sim/``` folder also contains the ```.do``` script that can can be used to
quickly (re)compile the vhdl testbench and run the simulation. The script is
invoked from the ModelSim console
```
ModelSim> cd <path-to-local-repo>/pantompkins-clash/sim
ModelSim> do run_sim.do
```

The simulation uses the non-trivial ECG sample *v111l* from CinC Challenge
2015<sup>[2]</sup> training set in order to expose the possible problems with
the signal processing at the hearbeat pace boundaries.

## About

The target functionality is dictated by the famous work published by Pan and
Tompkins.<sup>[1]</sup> Basically, the synthesized hardware is set to detect
the heartbeat events on the real-time digitized ECG signal and constantly
report the R-R intervals.

The particular tendency to implement this algorithm in a procedural fashion
gives a new challenge in terms of producing equivalent *streaming
implementation* with a hardware description language. The main motivation to
work in **CLaSH HDL** is to compress the signal processing boilerplate, which
is otherwise present in Verilog or VHDL, especially:
- Numerous digital filters
- Moving peak detection
- Interval sampling logic

## Roadmap

The target of the project is to provide a *robust equivalent* to the algorithm
described in the original paper<sup>[1]</sup>, that is to include multiple
real-life processing scenarios in addition to the core functionality.
The significant algorithm features are listed in the table.

| Done              |     To Do           |
| ----------------- | ------------------- |
| Bandpass filters  | Skipped beat lookup |                   
| Moving integrator | R-R averaging       |
| Moving maximum    |                     |
| Smart thresholds  |                     |
| Interval sampling |                     |
| T-wave inhibition |                     |
| Kickstart mode    |                     |

## References

**[1]** *A Real-Time QRS Detection Algorithm*, Jiapu Pan and Willis J. Tompkins,
IEEE Transactions On Biomedical Engineering, Vol. BME-32, No. 3, March 1985

**[2]** *Computing in Cardiology Challenge 2015*. Reducing false arrhytmia alarms
in the icu.
[Training set](https://physionet.org/physiobank/database/challenge/2015/training/)
from PhysioBank Database (PhysioNet)
