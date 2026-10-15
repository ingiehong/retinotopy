# external

Third-party MATLAB code that the pipeline calls, vendored so that a clone of this repository is self-sufficient.

| folder | what | used by | licence |
|---|---|---|---|
| `saveastiff_4.0/` | `saveastiff` / `loadtiff` by YoonOh Tak (MATLAB File Exchange 35684, v4.0, 2016): fast multi-page TIFF writer/reader | `imager/GrabSave.m`, `Stimulator_master/onlineAnalysis/offlineAnalysis.m`, `offlineAnalysis_script.m`, `analysis/Visual Area Segmentation/average_*_filter_tifs.m` | BSD 2-clause, see `saveastiff_4.0/license.txt` |

`Retinotopy_Master` adds the whole repository to the path with `genpath`, so these folders are found automatically; for offline analysis add them with `addpath(genpath(fullfile(<repo>,'external')))`.
