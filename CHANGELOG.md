# Changelog

## [0.1.11] - 2021-03-12

### Added
- New *ConductView* figure in **NUCLEUSinv** and **NUCLEUSmod** that shows the hydraulic conductivity and permeability
- New import routines to **NUCLEUSinv** for *IBAC* institute
- New parameter file values in **NUCLEUSinv** for the *BAM TOM* import 

### Changed
- Changed the behavior of the *number of echoes per gate* field. Zero is no longer allowed and will be automatically set to 1
- Rearrangement of some menues regarding the *ConductView* implementation
- Restructured the import menu of **NUCLEUSinv** so that the *GGE* and *IBAC* institute are now in *RWTH*
- The y-axis label of the RTD and PSD plots in **NUCLEUSinv** now only shows *water content [vol %]* if the porosity is not 1. This is much more intuitive

### Fixed
- Fixed two import bugs for *LIAG single/project* data in **NUCLEUSinv** (time scale conversion and background signal treatment)
- Fixed output data when using the *LU* inversion in **NUCLEUSinv** (before the wrong kernel matrix was stored)
- Fixed an internal data managment bug when activating/deactivating the joint inversion options
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
- Session files from an older *NUCLEUSinv* version can now be imported (starting from v.0.1.8). **NUCLEUSinv**

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
- Added a new *PhaseView*  subGUI to view and change the phase between real and imaginary part of a T2 signal. **NUCLEUSinv**
- Added a new import filter for the BAM NMR tomograph. **NUCLEUSinv**
- Added an export feature that allows to save T2 raw data into a csv-file (e.g. LIAG format); during save it is possible to overwrite the imaginary part with zeros. **NUCLEUSinv**

### Changed

- If a T2 signal is imported it is automatically rotated to minimize its imaginary part (the fit incorporates real and imag. part of the signal). **NUCLEUSinv**
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
- T1 inversion recovery factor (1 or 2 depending on inversion or saturation recovery) was missing in *free exp. inversion* and *free joint inversion* (in Jacobian calculation for angular pores). **NUCLEUSinv**

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