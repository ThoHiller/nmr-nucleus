# NUCLEUS

<img src="nucleus_logo_small.png" alt="NUCLEUS logo" width="150">

modeling and i**N**version of n**UCL**ear magnetic r**E**sonance data with ang**U**lar pore**S**

[![release](https://img.shields.io/github/release/NMR-NUCLEUS/nmr-nucleus.svg)](https://github.com/NMR-NUCLEUS/nmr-nucleus/releases/latest)
[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.4022195.svg)](https://doi.org/10.5281/zenodo.4022195)

- - -

## Table of Contents
1. [About](#about)
2. [Requirements](#requirements)
3. [Installation](#installation)
4. [Usage](#usage)
5. [Documentation](#documentation)
6. [ToDo](#todo)
7. [Cite as & References](#references)
8. [Changelog](CHANGELOG.md)

- - -

<a name="about"></a>

## About

**NUCLEUS** is a set of MATLAB<sup>TM</sup> tools, that allow forward and inverse modeling of nuclear magnetic resonance (NMR) relaxometry data (T<sub>1</sub> and T<sub>2</sub> relaxation). The main front-ends to these tools are two graphical user interfaces, **NUCLEUSmod** and **NUCLEUSinv** for forward and inverse modeling, respectively. For simple NMR relaxometry data inversion, the **NUCLEUSinv** GUI may be a little *feature-rich*. But one of the ideas, when starting to develop this code, was to help students understand the basic concepts of NMR relaxometry data inversion.

### NUCLEUSmod basic features

1. Generate pore size distributions (PSD) where the individual pores (capillaries) of the capillary bundle can either have a cylindrical, rectangular or polygonal cross section
2. Calculate a capillary pressure saturation curve (CPSC) for the PSD by applying a range of non-zero air pressures (the capillaries are assumed to be water filled and completely water-wet); different saturations for drainage and imbibition conditions are considered
3. Based on the different saturation levels along the CPSC, calculate the corresponding geometry-dependent forward NMR signals
4. 2D forward modeling of T<sub>1</sub>-T<sub>2</sub> data (without pore geometry considerations)

|    <div style="width:400px">![nucleusmod](images/nucleusmod_gui.png)</div> | <div style="width:330px">![nucleusmod2d](images/2dmod_gui.png)</div> |
|:-------------------------------------------------------------------:|:-------------------------------------------------------------:|
|                 NUCLEUSmod                                          |                   NUCLEUSmod - 2D (T1-T2)                     |



### NUCLEUSinv basic features

1. Can import **NUCLEUSmod** data (directly from the open GUI or from a saved session file) and a wide range of different laboratory NMR data files (please contact me if you need a specific import routine for your data)
2. Expert mode for more features (Standard mode has basic settings which should be sufficient for most users)
3. Simple pre-processing of NMR signals (cutting, gating, normalizing, phasing)
4. Different inversion options to process NMR data (e.g. mono-exponential fit, bi-exponential fit, multi-exponential fit) and estimate the uncertainty of the resulting relaxation time distributions (RTDs)
5. Different regularization options for multi-exponential fitting (e.g. manual, L-curve, SVD tools)
6. Joint inversion of NMR and CPS data to directly infer a PSD (non-linear inversion of surface relaxivity and PSD)
7. 2D inversion of T<sub>1</sub>-T<sub>2</sub> data

|    <div style="width:400px">![nucleusinv](images/nucleusinv_gui.png)</div> | <div style="width:330px">![nucleusinv2d](images/2dinv_gui.png)</div>  |
|:-------------------------------------------------------------------:|:--------------------------------------------------------------:|
|                 NUCLEUSinv                                          |                   NUCLEUSinv - 2D (T<sub>1</sub>-T<sub>2</sub>)                      |
|    <div style="width:400px">![uncert](images/uncertview_gui.png)</div>     | <div style="width:335px">![phaseview](images/phaseview_gui.png)</div> |
|                 NUCLEUSinv - RTD Uncertainty View                   |                   NUCLEUSinv - Phase View                      |

- - -

<a name="requirements"></a>

## Requirements

In order to work properly you need to meet the following requirements:

1. The [Mathworks](https://www.mathworks.com) MATLAB<sup>TM</sup> software development environment (tested with R2016b and newer)
    - The Optimization toolbox (<span style="color:green">optional</span>)
    - The Statistics toolbox (<span style="color:green">optional</span>)
2. The GUI Layout Toolbox (get it from [FEX](https://de.mathworks.com/matlabcentral/fileexchange/47982-gui-layout-toolbox)) (<span style="color:red">required</span>)
3. The regularization toolbox from P. Hansen (get it from [FEX](https://de.mathworks.com/matlabcentral/fileexchange/52-regtools) or find out more about it [here](http://www.imm.dtu.dk/~pcha/Regutools/)) (<span style="color:red">required</span>)
4. `findjobj` (get it from [FEX](https://de.mathworks.com/matlabcentral/fileexchange/14317-findjobj-find-java-handles-of-matlab-graphic-objects)) (<span style="color:red">required</span>)
5. `fminsearchbnd` (get it from [FEX](https://de.mathworks.com/matlabcentral/fileexchange/8277-fminsearchbnd-fminsearchcon)) (<span style="color:red">required</span>)
6. `dynamicDateTicks` (get it from [FEX](https://de.mathworks.com/matlabcentral/fileexchange/27075-intelligent-dynamic-date-ticks)) (<span style="color:green">optional</span>)
7. `kde` kernel density estimator (get it from [FEX](https://de.mathworks.com/matlabcentral/fileexchange/14034-kernel-density-estimator)) (<span style="color:green">optional; not needed for R2023b and newer</span>)
8. `imagescnan` (get it from [FEX](https://de.mathworks.com/matlabcentral/fileexchange/20516-imagescnan-m-v2-1-aug-2009)) (<span style="color:green">optional; only needed for the 2D inversion</span>)

If you do not have the Optimization or Statistics toolboxes then not all features are available (especially parts of the joint inversion). However, the general functionality of obtaining relaxation time distributions (RTDs) from NMR relaxometry data is of course working.

### Operating System

I tested it successfully under Windows 7 (64bit), 10 (64bit)  and 11 (64bit) with Matlab R2016b and newer. Always with the latest version of the GUI Layout Toolbox (current version is afaik v2.4.1 but I used v2.3.9)

**NOTE:** So far I did not test anything on Linux or a Mac. If you get it to work on either of the two systems (which it basically should I guess) please let me know.

- - -

<a name="installation"></a>

## Installation

1. It is recommended to install the GUI Layout Toolbox directly into MATLAB<sup>TM</sup> via the mltbx-file (but it should also work via the old-school way of adding the toolbox folders to the MATLAB<sup>TM</sup> path)
2. To use **NUCLEUS** you just need to place the `nucleus` folder from  the git repository on your hard drive and use the start scripts `startNUCLEUSinv` and `startNUCLEUSmod`, respectively (within these scripts all necessary **NUCLEUS** folders are added to the MATLAB<sup>TM</sup> path)

**NOTE:** It is recommended to have only *one* version of **NUCLEUS** on your current  MATLAB<sup>TM</sup> path.

- - -

<a name="usage"></a>

## Usage

1. By executing the start scripts (see above)
2. Simply type `NUCLEUSinv` or `NUCLEUSmod` on the MATLAB<sup>TM</sup> prompt (make sure the `nucleus` folder is on the MATLAB<sup>TM</sup> path)
3. Check the demo scripts for the usage of the core functions without the GUI (inside the `scripts` folder)

- - -

<a name="documentation"></a>

## Documentation

A basic documentation to **NUCLEUS** can be found in the `nucleus\doc` folder. Just open the `index.html` in the web browser of your choice. The documentation was created with [m2html](https://www.artefact.tk/software/matlab/m2html/) by Guillaume Flandin.

- - -

<a name="todo"></a>

## TODO

In no particular order and without guarantee that it will ever happen :-) :

1. A Manual (this is on top of my agenda)
2. Adapt the core functionality in a Python module
3. NUCLEUSinv:
    - An import wizard to get rid of the import menu
    - Easy way to set optimization settings
    - For noise estimation: select manually a range of the NMR raw signal
4. ...
	
- - -

<a name="references"></a>

## Cite as
If you use NUCLEUS for your research, please cite it as:

Thomas Hiller. (2025, Jun 10). ThoHiller/nmr-nucleus: v0.4.0 (Version v0.4.0). Zenodo. [https://doi.org/10.5281/zenodo.4022195]

Note: Even though the version number might change due to updates, this DOI is permanent (represents all versions) and always links to the latest version.

## References

1. Lorenzoni,R., Cunningham, P., Fritsch, T., Schmidt, W., Kruschwitz, S. and Bruno, G. "Microstructure analysis of cement-biochar composites", *Materials and Structures*, **57**, 2024, 175, [DOI](https://doi.org/10.1617/s11527-024-02452-5)
2. Kruschwitz, S., Munsch, S., Telong, M., Schmidt, W., Bintz, T., Fladt, M. and Stelzner, L., "The NMR core analyzing tomograph: a multi-functional tool for non-destructive testing of building materials", *Magnetic Resonance Letters*. **3**(3), 2023, 207-219, [DOI](https://doi.org/10.1016/j.mrl.2023.03.004)
3. Costabel, S., Hiller, T. and Houben, G. "Nuclear magnetic resonance at the laboratory and field scale as a tool for detecting redox fronts in aquifers", *GEOPHYSICS*, **88**(2), 2023, KS13-KS25, [DOI](https://doi.org/10.1190/geo2022-0127.1)
4. Costabel, S., Hiller, T., Dlugosch, R., Kruschwitz, S. and Müller-Petke, M. "Evaluation of single-sided nuclear magnetic resonance technology for usage in geosciences", *Measurement Science and Technology*, **34**(1), 2023, 015112, [DOI](https://dx.doi.org/10.1088/1361-6501/ac9800)
5. Munsch, S., Bintz, T., Heyn, R., Hirsch, H., Grunewald, J. and Kruschwitz, S., "Detailed investigation of capillary active insulation materials by 1H nuclear magnetic resonance (NMR) and thermogravimetric drying",  International Symposium on Non-Destructive Testing in Civil Engineering (NDT-CE 2022), 16-18 August 2022, Zurich, Switzerland, *e-Journal of Nondestructive Testing*, **27**(9), [DOI](https://doi.org/10.58286/27205)
6. Hiller, T., Costabel, S., Radic, T., Dlugosch, R. and Müller-Petke, M. "Feasibility study on prepolarized surface nuclear magnetic resonance for soil moisture measurements", *Vadose Zone Journal*, **20**(5), 2021, e20138, [DOI](https://doi.org/10.1002/vzj2.20138)
7. Costabel, S. and Hiller, T., "Soil hydraulic interpretation of nuclear magnetic resonance measurements based on circular and triangular capillary models", *Vadose Zone Journal*, **20**(2), 2021, e20104, [DOI](https://doi.org/10.1002/vzj2.20104)
8. Hiller, T. and Klitzsch, N., "Joint inversion of nuclear magnetic resonance data from partially saturated rocks using a triangular pore model", *GEOPHYSICS*, **83**(4), JM15-JM28, 2018, [DOI](https://doi.org/10.1190/geo2017-0697.1)

- - -

<p style="text-align: center;"> MATLAB is a registered trademark of The Mathworks, Inc. </p>