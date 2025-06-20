# Changelog

## [0.4.0] - 2025-06-10

### Added
- Uncertainty calculation and 2D T1-T2 inversion in **NUCLEUSinv** now also work with gated signals
- New L-curve calculation routine for 1D and 2D data in **NUCLEUSinv** that estimates the optimal regularization parameter iteratively (selectable via the *Extra* menu)
- New *Extra* menu entry in **NUCLEUSinv** to estimate the noise of a signal from the RMS of its data  fit (sometimes useful e.g. for T1 data)
- New import routines in **NUCLEUSinv** for *MRSMatlab* mrsd-files and *NMR Mouse* T1T2 data files
- New *Batch* checkbox in **NUCLEUSinv** to invert all signals automatically with identical settings
- New *File* menu for sorting the imported signals in **NUCLEUSinv**
- New *Extra* menu for batch processing options in **NUCLEUSinv**
- Several usability improvements in all parts of **NUCLEUSinv** and **NUCLEUSmod**

### Changed
- Changed the labels of the context menu for coloring the plots in the **NUCLEUSinv** sub GUI *UncertView*
- Changed the default LSQ solver in **NUCLEUSinv** to *LSQLIN* (if the Optimization Toolbox is available)


### Fixed
- Fixed a bug when automatically determining Lambda from the L-curve in the **NUCLEUSinv** main GUI
- Fixed a bug when calculating uncertainty runs within the **NUCLEUSinv** main GUI
- Fixed a coloring bug in the **NUCLEUSinv** sub GUI *UncertView*
- Fixed a figure-resizing bug in both 2D sub GUIs in **NUCLEUSinv** and **NUCLEUSmod**

## [0.3.0] - 2024-11-27

### Added
- New sub GUI *2DInv* in **NUCLEUSinv** for 2D T1-T2 inversion (works so far for HELIOS, DART and JAVELIN (Vista Clara) and RockCoreAnalyzer (Magritek) data)
- New import routines in **NUCLEUSinv** for the NMR Dart Logging tool
- New *Extra* menu entry in **NUCLEUSinv** to find duplicate NMR signals in the file list
- New fitting options in the *PhaseView* sub GUI of **NUCLEUSinv**

### Changed
- Unified the appearance along several sub GUIs for consistency
- Updated the wait bar increments for very long batch runs
- When *HELIOS* data is imported, the user can now decide if several files should be stacked together

### Fixed
- Fixed a bug when importing data and the Statistics Toolbox is not available

## [0.2.1] - 2024-02-11

### Added
- Added uncertainty data do Excel export in **NUCLEUSinv**
- Added uncertainty calculation to batch mode in **NUCLEUSinv**
- Added a new flag to the *Extra* menu of **NUCLEUSinv** that allows to set all relaxation times < *TE/5* to zero when `lsqlin` is used for the RTD inversion

### Changed
- Changed the default settings for NMR signal calculation in **NUCLEUSmod** (more realistic echo time *TE* of 200µs and the first echo within the time vector is actually *TE* or *TE/2* and not 0)

### Fixed
- Fixed an issue when exporting data from *UncertView* GUI to **NUCLEUSinv** main GUI
- Re-factored a few of the uncertainty calculation functions
- More seamless integration of *UncertView* GUI

## [0.2.0] - 2024-02-01

### Added
- New functionality to estimate the uncertainty of relaxation time distributions (RTDs) by using a simple bootstrapping method
- New sub GUI *UncertView* in **NUCLEUSinv** to process and evaluate the uncertainty data

### Fixed
 - Fixed an issue when importing **NUCLEUSinv** session files older than version v.0.1.14 (there is a new general *T* field for *mono* and *N free exp. (2-5)* inversion results which was not initialized)
- Several minor improvements in GUI handling, usability and visualization.

## [0.1.14] - 2023-09-27

### Added
- New optional sub GUI *FixedTimeView* in **NUCLEUSinv** that allows to fix relaxation times (up to five) if the *N free exp. (2-5)* option for inversion is chosen and thus only the corresponding amplitudes are fitted
- New import routine in **NUCLEUSinv** for the LIAG core scanner (several NMR measurements along a core)

### Changed
- Changed the import routines in **NUCLEUSinv** for *BGR* devices (*Mouse* and *Helios*) due to device software updates

## [0.1.13] - 2022-08-11

### Changed
- Changed the way the uncertainty region is displayed when the *Multi modal* fitting option in **NUCLEUSinv** is used (now it is `[mean-2*std mean+2*std]` before it was `[min max]`)

### Fixed
- Fixed an issue in **NUCLEUSmod** when calculating forward NMR data for single capillaries with corners (*right angular* and *polygon*)
- Fixed an issue in the **NUCLEUSmod** example scripts (*T<sub>diff</sub>* was not initialized)
- Fixed an issue in **NUCLEUSinv** regarding the fitting routine `fitDataFree` in combination with the Optimization Toolbox in Matlab Versions newer than R2019b

## [0.1.12] - 2022-02-17

### Added
- New *SNR*-option in **NUCLEUSmod** to set the noise of the forward modeled NMR data either by noise level or signal-to-noise ratio (SNR)
- New *Multi modal* fitting option in **NUCLEUSinv** (only in Expert mode) with built-in uncertainty estimation for the final RTD
- New import routines to **NUCLEUSinv** for *BGR* devices (*Mouse* and *Helios*)
- Diffusion relaxation time *T<sub>diff</sub>*  is now considered in **NUCLEUSmod** (*NMR* panel) and **NUCLEUSinv** (*Petro Parameter* panel)
- Added an `AUTHORS.md` file to the repository.

### Changed
- Changed the default export path and file name for graphics files in **NUCLEUSinv** to the current import path and data file
- Changed the visualization of the imaginary part of the raw data (if available)
- Minor internal changes

### Fixed
- Fixed an issue regarding the import of T<sub>1</sub> data without noise (noise is now estimated on-the-fly via a fit with five free exponents)

## [0.1.11] - 2021-03-12

### Added
- New *ConductView* figure in **NUCLEUSinv** and **NUCLEUSmod** that shows the hydraulic conductivity and permeability
- New import routines to **NUCLEUSinv** for *IBAC* institute
- New parameter file values in **NUCLEUSinv** for the *BAM TOM* import 

### Changed
- Changed the behavior of the *number of echoes per gate* field. Zero is no longer allowed and will be automatically set to 1
- Rearrangement of some menus regarding the *ConductView* implementation
- Restructured the import menu of **NUCLEUSinv** so that the *GGE* and *IBAC* institute are now in *RWTH*
- The y-axis label of the RTD and PSD plots in **NUCLEUSinv** now only shows *water content [vol %]* if the porosity is not 1. This is much more intuitive

### Fixed
- Fixed two import bugs for *LIAG single/project* data in **NUCLEUSinv** (time scale conversion and background signal treatment)
- Fixed output data when using the *LU* inversion in **NUCLEUSinv** (before the wrong kernel matrix was stored)
- Fixed an internal data management bug when activating/deactivating the joint inversion options
- Fixed an issue regarding the use of only a single signal for the joint inversion and the inversion-geometry exhibits corners

## [0.1.10] - 2020-09-10

### Added
- Added an updated `CHANGELOG.md` file to the repository.
- Added a new *Dart* import routine. **NUCLEUSinv**
- Added a complete status bar to **NUCLEUSmod**

### Changed
- Restructured the menus of both GUIs to be more precise and consistent and with less sub-menu levels
- Removed the complete *iterative &chi;<sup>2</sup>* inversion option because it never worked as reliable as I would have liked it. **NUCLEUSinv**
- Shortened the *Info*-field numbers to fit into the output window. **NUCLEUSinv**

### Fixed
- Fixed a nasty minimize / maximize bug for the panels in **NUCLEUSmod**

## [0.1.9] - 2019-10-30

### Added
- A *last export* entry added to the export menu. It always shows the last chosen export routine (speeds up exporting when handling a lot of data). **NUCLEUSinv**
- Session files from an older **NUCLEUSinv** version can now be imported (starting from v.0.1.8). **NUCLEUSinv**

### Changed
-  Within the context menu of the signal list the entry *all* was renamed to *batch*. Now it indicates what it is actually doing - batch processing of multiple files. **NUCLEUSinv**
- Renamed the *InvLaplace* inversion option to *LU* (LU-decomposition) to resolve the confusion with a real inverse Laplace transform. **NUCLEUSinv**

### Fixed
- Fixed typos and several minor improvements.

## [0.1.8] - 2019-07-09

### Added

- Added a new color theme: *black*

### Changed
- Adjusted the dark color theme to new darker background colors
- Extended the BAM NMR tomograph import filter to take care of background measurements. **NUCLEUSinv**
- The Matlab internal `lsqnonneg` is now the default multi-exponential LSQ option even if the Optimization Toolbox is available. **NUCLEUSinv**
- If the Optimization Toolbox is available the user can now choose between `lsqnonneg` and `lsqlin`. **NUCLEUSinv**

### Fixed
- `lsqlin` was not working properly (default settings adjusted). **NUCLEUSinv**
- Fixed the tool tip update when changing the solver or regularization option. **NUCLEUSinv**
- Several minor improvements.

## [0.1.7] - 2019-06-27

### Changed
- Extended the BAM NMR tomograph import routine to handle data files that do not belong to a *lift*-set (i.e. do not have a z-position defined in the par-file). **NUCLEUSinv**

### Fixed
- When importing a *LIAG* project where the calibration file is already inverted, and hence, automatically imported, the relaxation time is now used as *Tbulk* time for the sample. **NUCLEUSinv**

## [0.1.6] - 2019-06-24

### Added
- Added a new *PhaseView*  subGUI to view and change the phase between real and imaginary part of a T<sub>2</sub> signal. **NUCLEUSinv**
- Added a new import filter for the BAM NMR tomograph. **NUCLEUSinv**
- Added an export feature that allows to save T<sub>2</sub> raw data into a csv-file (e.g. LIAG format); during save it is possible to overwrite the imaginary part with zeros. **NUCLEUSinv**

### Changed

- If a T<sub>2</sub> signal is imported it is automatically rotated to minimize its imaginary part (the fit incorporates real and imag. part of the signal). **NUCLEUSinv**
- The *FitStatistics* window layout is now in line with the *PhaseView* layout for consistency reasons. **NUCLEUSinv**

### Fixed
- If a signal is already inverted and the user changes one of the *petro* settings, these settings are now stored in the inverted data set too. **NUCLEUSinv**
- Many minor improvements mainly regarding a consistent usage experience.

## [0.1.5] - 2019-03-27

### Added
- Restructured the *Process* panel and added an additional edit field to set the maximum numbers of echoes per time gate (if gating is activated). **NUCLEUSinv**
- Added an option (Extra-Settings-Joint Inversion-menu) to set the inversion bounds for the surface relaxivity (only possible within the joint inversion). **NUCLEUSinv**
- Added an option to plot *AMP vs TLGM* to the Extra-Figures-menu. **NUCLEUSinv**

### Changed
- Globally renamed *rectangular* to *right angular* to avoid any confusion.
- Restructured the *Extra* menu to comply with the menu structure of *NUCLEUSinv*. **NUCLEUSmod**

### Fixed
- When importing *ASCII* or *EXCEL* data the ini-file gets now updated. **NUCLEUSinv**
- *Export* menu now also works for joint inversion data. **NUCLEUSinv**
- When switching *Expert Mode* *on* / *off* the availability of the Optimization toolbox is now properly checked and accounted for. **NUCLEUSinv**
- Many minor improvements mainly regarding a consistent usage experience. **NUCLEUSinv**
- Color theme switching now works (but default theme is used at every startup). **NUCLEUSmod**

## [0.1.4] - 2019-03-08

### Added
- Added error weights to the *free exp. inversion* (new routine `fcn_fitFreeT2w`). **NUCLEUSinv**

### Changed
- Due to the new error weights there is no default gating method anymore for the *free exp. inversion*. **NUCLEUSinv**

### Fixed
- T<sub>1</sub> inversion recovery factor (1 or 2 depending on inversion or saturation recovery) was missing in *free exp. inversion* and *free joint inversion* (in Jacobian calculation for angular pores). **NUCLEUSinv**

## [0.1.3] - 2019-02-22

### Added
- Added a water content column to the csv-export of the *LIAG archive*-option **NUCLEUSinv**
- Also importing porosity and surface relaxivity information when importing *NUCLEUSmod* data into *NUCLEUSinv*. **NUCLEUSinv**

### Changed
- Changed the y-label of all RTD and PSD axes to volumetric water content *[vol %]* **NUCLEUSinv**
- When using *NUCLEUSmod* data in *NUCLEUSinv* and performing a joint inversion, the forward and inverted PSDs are now rescaled to the correct water content to be comparable (added a second rescaling after rescaling by the integral of individual PSDs). **NUCLEUSinv**
- Noise is now handled as absolute value instead of percentage. **NUCLEUSmod**
- Noise and porosity scaling get handled now within the same routine during forward NMR signal calculation (`updateNMRsignals`). **NUCLEUSmod**

### Fixed
- The error vector *e* is now correctly scaled at the beginning of the joint inversion routine `runInversionJoint`, therefore accounting for noise and porosity / water content. **NUCLEUSinv**

## [0.1.2] - 2019-02-12

### Added
- Added a *residual* (error) axes to the joint inversion signal axes panel. **NUCLEUSinv**
- Added *myui* information to the session file (this is needed in the future for backward compatibility). **NUCLEUSinv**

### Fixed
- When a session file with joint inversion data is imported, the GUI is now correctly updated (this check was missing before). **NUCLEUSinv**
- When importing a session file, the axes context menus get activated now. **NUCLEUSinv**
- When selecting a NMR signal, the joint inversion plots did not get updated when there was already inverted data (fixed in `onListboxData`). **NUCLEUSinv**
- When exporting joint inversion plots the legends were not shown correctly (fixed in `exportGraphics`). **NUCLEUSinv**

## [0.1.1] - 2019-02-12

### Fixed
- Some vector sizes did not match in `runInversionJoint`. **NUCLEUSinv**
- Heavy typo fixing within comments. **NUCLEUSinv**

## [0.1.0] - 2019-02-12

Initial Version

[0.4.0]: https://github.com/ThoHiller/nmr-nucleus/compare/v.0.3.0...v.0.4.0
[0.3.0]: https://github.com/ThoHiller/nmr-nucleus/compare/v.0.2.1...v.0.3.0
[0.2.1]: https://github.com/ThoHiller/nmr-nucleus/compare/v.0.2.0...v.0.2.1
[0.2.0]: https://github.com/ThoHiller/nmr-nucleus/compare/v.0.1.14...v.0.2.0
[0.1.14]: https://github.com/ThoHiller/nmr-nucleus/compare/v.0.1.13...v.0.1.14
[0.1.13]: https://github.com/ThoHiller/nmr-nucleus/compare/v.0.1.12...v.0.1.13
[0.1.12]: https://github.com/ThoHiller/nmr-nucleus/compare/v.0.1.11...v.0.1.12
[0.1.11]: https://github.com/ThoHiller/nmr-nucleus/compare/v.0.1.10...v.0.1.11
[0.1.10]: https://github.com/ThoHiller/nmr-nucleus/compare/v.0.1.9...v.0.1.10
[0.1.9]: https://github.com/ThoHiller/nmr-nucleus/compare/v.0.1.8...v.0.1.9
[0.1.8]: https://github.com/ThoHiller/nmr-nucleus/compare/v.0.1.7...v.0.1.8
[0.1.7]: https://github.com/ThoHiller/nmr-nucleus/compare/v.0.1.6...v.0.1.7
[0.1.6]: https://github.com/ThoHiller/nmr-nucleus/compare/v.0.1.5...v.0.1.6
[0.1.5]: https://github.com/ThoHiller/nmr-nucleus/compare/v.0.1.4...v.0.1.5
[0.1.4]: https://github.com/ThoHiller/nmr-nucleus/compare/v.0.1.3...v.0.1.4
[0.1.3]: https://github.com/ThoHiller/nmr-nucleus/compare/v.0.1.2...v.0.1.3
[0.1.2]: https://github.com/ThoHiller/nmr-nucleus/compare/v.0.1.1...v.0.1.2
[0.1.1]: https://github.com/ThoHiller/nmr-nucleus/compare/v.0.1.0...v.0.1.1
[0.1.0]: https://github.com/ThoHiller/nmr-nucleus/releases/tag/v.0.1.0