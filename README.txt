Originated by Grace Hwang, 10/1/2018

Make sure that the slave and master computers are both turned on

Run C:\Users\Huganir Lab\Documents\MATLAB\Callaway_ISI\ISI_Master.m from master computer
run ISI_Slave.m from slave computer
1) Acq ISI_Master and ISI_Slave

Load altitude param file C:\Users\Huganir Lab\Documents\MATLAB\Callaway_ISI\Stimulator_master\ParamFiles\10cm_gray_nonoverlapping_morenoise
Load ori_0_180 file
start

Load Azimuth param file C:\Users\Huganir Lab\Documents\MATLAB\Callaway_ISI\Stimulator_master\ParamFiles\10cm_gray_nonoverlapping_morenoise
start

Although Step 1 creates phase maps for both horizontal (azimuth) and vertical (altitude) retinotopy, best results are obtained when phase maps are reconstructed using the offlineAnalysis_script, which also outputs a raw tif file of the experiments.


2) Phase Map Creation

online versus offline

XXX

offlineAnalysis_script     %recaculate phase maps with 16bit & non-neg
			   %C:\Users\Huganir Lab\Documents\MATLAB\Callaway_ISI\Stimulator_master\onlineAnalysis
%Run the offlineAnalysis_script first select analyzer file, then corresponding two image files sequentially
%That is do above twice, once for altitude and once for azimuth
%The following messages should occur 
%User selected C:\Users\Huganir Lab\Documents\imager_data\180817\01_offlinephasemap\180817_u000_001.analyzer
%User selected C:\Users\Huganir Lab\Documents\imager_data\180817\01_offlinephasemap\180817_u000_001_000.mat
%Detected 10 trials of visual stimulation. Average length: 18.3468
%User selected C:\Users\Huganir Lab\Documents\imager_data\180817\01_offlinephasemap\180817_u000_001_001.mat
%Detected 10 trials of visual stimulation. Average length: 18.3468

Move the newly generated phase files (e.g., 180817_u000_001.mat, 180817_u000_000.mat) to the intended data directory before proceeding to next step
(e.g., C:\Users\Huganir Lab\Documents\imager_data\180817\01_offlinephasemap). You may want to rename the automatically generated phase maps created by step 1 to avoid confusion.
 
3) Retinotopic Analysis Pipeline

go to data diretory (e.g., C:\Users\Huganir Lab\Documents\imager_data\180927) 
Run retinotopic pipeline for a few low pass values

run getAreaBorders_Ingie('180817','000_002', '000_003') %C:\Users\Huganir Lab\Documents\MATLAB\Callaway_ISI\getAreaBorders_Ingie.m

% to run different low pass values, worth trying anything from 0 to 2
Low pass is a spatial kernel - try 1, 1.5 2, empirial determination
Criteria 1 is best left at 1.5
Criteria 2 look for redundant patches
Criteria 3 fuses adjacent patches based on Visual field sign