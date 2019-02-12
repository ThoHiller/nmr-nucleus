## NUCLEUS

modeling and i**N**version of n**UCL**ear magnetic r**E**sonance data with ang**U**lar pore**S**

[![release](https://img.shields.io/github/release/ThoHiller/nmr-nucleus.svg)](https://github.com/ThoHiller/nmr-nucleus/releases/latest)
- - -

### About

**NUCLEUS** is a set of MATLAB<sup>TM</sup> tools, that allow forward and inverse modeling of nuclear magnetic resonance (NMR) relaxometry data. The main front-ends to these tools are two graphical user interfaces, **NUCLEUSmod** and **NUCLEUSinv** for forward and inverse modeling, respectively. For simple NMR relaxometry data inversion, the **NUCLEUSinv** GUI may be a little *feature-rich*. But one of the ideas, when starting to develop this code, was to help students understand the basic concepts of NMR relaxometry data inversion.

###### NUCLEUSmod basic features:

1. Generate pore size distributions (PSD) that can have a cylindrical, rectangular or polygonal cross section
2. Calculate a capillary pressure saturation curve (CPSC) for the PSD by applying a range of non-zero air pressures (the capillaries are assumed to be water filled and completely water-wet); different saturations for drainage and imbibition conditions are considered
3. Based on the different saturation levels along the CPSC, calculate the corresponding geometry-dependent forward NMR signals

###### NUCLEUSinv basic features:

1. Can import **NUCLEUSmod** data (directly from the open GUI or from a saved file) and a wide range of different laboratory NMR data files (please contact me if you need a specific import routine for your data)
2. Expert mode for more features (Standard mode has basic settings which should be sufficient for most users)
3. Simple pre-processing of NMR signals (cutting, gating, normalizing)
4. Different inversion options to process NMR data (e.g. mono-exponential fit, bi-exponential fit, multi-exponential fit)
5. Different regularization options for multi-exponential fitting (e.g. manual, L-curve, iterative Chi-square, SVD tools)
6. Joint inversion of NMR and CPS data to directly infer a PSD (non-linear inversion of surface relaxivity and PSD)

- - -

### Requirements

In order to work properly you need to meet the following requirements:

1. The [Mathworks](https://www.mathworks.com) MATLAB<sup>TM</sup> software development environment (tested with R2014b and newer)
	- The Optimization toolbox (<span style="color:green">optional</span>)
	- The Statistics toolbox (<span style="color:green">optional</span>)
2. The GUI Layout Toolbox (get it from [FEX](https://de.mathworks.com/matlabcentral/fileexchange/47982-gui-layout-toolbox)) (<span style="color:red">required</span>)
3. The regularization toolbox from P. Hansen (get it from [FEX](https://de.mathworks.com/matlabcentral/fileexchange/52-regtools) or find out more about it [here](http://www.imm.dtu.dk/~pcha/Regutools/)) (<span style="color:red">required</span>)
4. `findjobj` (get it from [FEX](https://de.mathworks.com/matlabcentral/fileexchange/14317-findjobj-find-java-handles-of-matlab-graphic-objects)) (<span style="color:red">required</span>)
5. `fminsearchbnd` (get it from [FEX](https://de.mathworks.com/matlabcentral/fileexchange/8277-fminsearchbnd-fminsearchcon)) (<span style="color:red">required</span>)
6. `dynamicDateTicks` (get it from [FEX](https://de.mathworks.com/matlabcentral/fileexchange/27075-intelligent-dynamic-date-ticks)) (<span style="color:green">optional</span>)

If you do not have the Optimization or Statistics toolboxes then not all features are available (especially parts of the joint inversion). However, the general functionality of obtaining relaxation time distributions (RTD) form NMR relaxometry data is of course working.

#### Operating System

I tested it successfully under Windows 7 (64bit) and 10 (64bit) with Matlab R2014b and newer.

**NOTE:** So far I did not test anything on a Linux or Mac. If you get it to work on either of the two systems (which it basically should I guess) please let me know.

- - -

### Installation

1. It is recommended to install the GUI Layout Toolbox directly into MATLAB<sup>TM</sup> via the mltbx-file (but it should also work via the old-school way of adding the toolbox folders to the MATLAB<sup>TM</sup> path)
2. To use **NUCLEUS** you just need to place the `nucleus` folder from  the git repository on your hard drive and use the start scripts `startNUCLEUSinv` and `startNUCLEUSmod`, respectively (within these scripts all necessary **NUCLEUS** folders are added to the MATLAB<sup>TM</sup> path)

- - -

### Usage

1. By executing the start scripts (see above)
2. Simply type `NUCLEUSinv` or `NUCLEUSmod` on the MATLAB<sup>TM</sup> prompt (make sure the `nucleus` folder is on the MATLAB<sup>TM</sup> path)
3. Check the demo scripts for the usage of the core functions without the GUI (inside the `scripts` folder)

- - -

### Documentation

A basic documentation to **NUCLEUS** can be found in the `nucleus\doc` folder. Just open the `index.html` in the web browser of your choice. The documentation was created with [m2html](https://www.artefact.tk/software/matlab/m2html/) by Guillaume Flandin.

- - -

### TODO

In no particular order and without guarantee that it will ever happen :-) :

1. A Manual (this is on top of my agenda)
2. Adapt the core functionality in a Python module
3. NUCLEUSinv:
	- An import wizard to get rid of the import menu
	- Easy way to set optimization settings
	- For noise estimation: select manually a range of the NMR raw signal
4. ...
	

- - -

### References

1. Hiller, T. and Klitzsch, N., "Joint inversion of nuclear magnetic resonance data from partially saturated rocks using a triangular pore model", GEOPHYSICS **83**(4), JM15-JM28, 2018, [DOI](https://doi.org/10.1190/geo2017-0697.1)

- - -
<p style="text-align: center;"> MATLAB is a registered trademark of The Mathworks, Inc. </p>
