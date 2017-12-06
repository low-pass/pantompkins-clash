# pantompkins-clash
Pan Tompkins a.k.a. Real-Time QRS Detection Algorithm in CLaSH HDL

## Tools

* CLaSH compiler
* ModelSim (Altera free version)
* Emacs + vhdl-mode
* make
* (optional) Xilinx Vivado WebPACK (for elaboration efficiency analysis)

Project is being developed from under Windows, and having linux distro as main
OS would require even less setup time thanks to the repositories.

## VHDL Generation

The sources are tested to work with CLaSH 0.7.2 ([see clash-lang.org](http://www.clash-lang.org/) for setup instructions)
```
$ cd src
$ clash --vhdl Sampler.hs
```
The `src/vhdl/` folder will contain the RTL code which is FPGA / ASIC
synthesizable

## Simulation

The VHDL simulation can be very useful for running the massive amounts of data
through the signal processing IP and for examining the waveforms and timing
events easily. Even though CLaSH allows for testbench generation, the runtime
data importing into its simulation is not so trivial. The *temporary shoehorn
solution* is to use a simple VHDL testbench as a CSV reader and IP host for
the simulation, prior to the actual hardware synthesis.

The free version of ModelSim works quite reliably for such purposes.
Latest version can be
[downloaded from Altera](http://dl.altera.com/?product=modelsim_ae).
To avoid manually recompiling the new sources in proper order in ModelSim,
a makefile is produced with the Emacs *vhdl-mode* plugin. Standalone
Windows version of make can be found [here](http://www.equation.com/servlet/equation.cmd?fa=make).

To hook up the VHDL sources to the Emacs code analyser, a new project has to
be created within the
[vhdl-mode](https://guest.iis.ee.ethz.ch/~zimmi/emacs/vhdl-mode.html)
and customized like such
```
Name              : sampler
...
Default directory : <path-to-local-repo>/pantompkins-clash/sim/
Sources           : ../src/vhdl/Sampler/
```
Now the ModelSim `work` library can be quickly recompiled straight from the
Haskell sources by calling the `makefile-gen.sh` (make sure to read it first).
The `sim/` folder also contains the `.do` script that can can be used to
quickly (re)compile the vhdl testbench and run the simulation from the
pre-compiled `work` library. The simulation script is invoked from the
ModelSim console
```
ModelSim> cd <path-to-local-repo>/pantompkins-clash/sim
ModelSim> do run_sim.do
```

The output should look something like the following (colors are inverted for
clarity)

![alt text]
(https://github.com/low-pass/pantompkins-clash/tree/master/img/waves.png
"ModelSim waveforms (colors inverted)")

The simulation uses the non-trivial ECG sample *v111l* from CinC Challenge
2015<sup>[2]</sup> training set in order to expose the possible problems with
the signal processing at the hearbeat pace boundaries. The flat output regions
that are followed by large spikes are indicating that the algorithm skips some
beats but keeps counting the interval from the last valid beat. This has to be
fixed by debugging the waveforms of VHDL internals.

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
