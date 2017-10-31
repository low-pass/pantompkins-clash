# pantompkins-clash
Pan Tompkins a.k.a. Real-Time QRS Detection Algorithm in CLaSH HDL

## VHDL Generation

The sources are tested to work with **clash 0.7.2** ([see clash-lang.org](http://www.clash-lang.org/) for setup instructions)
```
$ clash --vhdl rolling_max.hs
```
The vhdl/ folder will contain the RTL code which is FPGA / ASIC synthesizable

## Simulation

The free version of **ModelSim** from Intel FPGA is used to simulate the design
functionality. Latest version can be [downloaded from Altera](http://dl.altera.com/?product=modelsim_ae).
The repo root contains the .tcl script that can can be used to *compile the
generated VHDL entities in the proper order* and run the simulation.
```
ModelSim> cd <path-to-local-repo>/pantompkins-clash
ModelSim> do compile_run.tcl
```

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

| Done           |     To Do           |
| -------------- | ------------------- |
| Moving maximum | Bandpass filters    |
|                | Moving integrator   |
|                | Smart thresholds    |
|                | Interval sampling   |
|                | T-wave inhibition   |
|                | R-R averaging       |
|                | Kickstart mode      |
|                | Skipped beat lookup |

## References

**[1]** *A Real-Time QRS Detection Algorithm*, Jiapu Pan and Willis J. Tompkins, IEEE
Transactions On Biomedical Engineering, Vol. BME-32, No. 3, March 1985
