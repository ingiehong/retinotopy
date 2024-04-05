# Retinotopy 
Ingie Hong and Grace Hwang  

Updated code for retinotopy image acquisition, stimulus presentation, and mouse visual area segmentation.  
The code is now compatible with modern GigE/USB3 cameras, imaging/DAQ libraries, Windows 10/11, and Matlab 2017b-2022a versions.  
Both intrinsic optical imaging and one-photon fluorescence imaging is supported.  
Software can typically be installed in 30 mins. Hardware will take more depending on familiarity.   
Forked, reorganized, and upgraded with permission from original authors.

![Alt text](https://github.com/SNLC/ISI/blob/master/NP-P160101A%20Fig%204.png?raw=true?raw=true "Figure 4 from Juavinett, Nauhaus, Garrett & Callaway 2016")

**EQUIPMENT**  
•	Two computers, connected by Internet, with one computer connected to a large (>27”) screen  
•	National Instruments USB-6001/6002/6003/6008 Multifunction I/O device (NIDAQ)   
•	Matlab 2017b-2022a (Mathworks)  
•	Widefield epifluorescence/reflected light microscope with motorized motion and a low-magnification high-NA objective (e.g. Thorlabs Cerna Mini microscope, Zeiss Axio Zoom.V16, Mightex OASIS Macro, SciMedia THT)  
•	GigE/USB3 camera (e.g. FLIR Grasshopper GS3-PGE-23S6M, GS3-U3-23S6M-C)  
•	Head fixation rig for anesthetized widefield imaging. CAD files available on Github at https://github.com/ingiehong/Gogo-stages. Commercially available rigs include Neurotar’s HeadFix, Narishige’s MAG-2, Amuza’s Self Head-Restraining System, LabeoTech’s Mouse Head Fixation System  
•	Photodiode for visual stimulus synchronization (e.g. OPT101 chip and CJMCU101 breakout board)  
  
**Equipment setup: Imager & Stimulator Programs (Master computer)**

Imager and Stimulator are now consolidated into Retinotopy_Master.  
Imager acquires images from camera, originally written by Dario Ringach and Ian Nauhaus and  
Stimulator configures and triggers visual stimulus on the Slave computer during data acquisition.

1|	Clone (with git) or download and install the updated retinotopy software from Github (https://github.com/ingiehong/retinotopy).  
2|	Connect a GigE or USB3 camera (eg. FLIR Grasshopper3) to the Master computer and install relevant drivers.  
3|	Connect a National Instruments USB-6001/6002/6003/6008 Multifunction I/O device (NIDAQ) and install relevant drivers.  
4|	Using a GPIO cable from the camera vendor, connect the frame TTL signal output to the NIDAQ device analog or digital input. In our setup, we use a Grasshopper3 GS3-PGE-23S6M and the General-Purpose Input/Output (GPIO) Connector pin #3 IO3 (red wire) was connected to the analog input Ai0 (channel 2) of the NIDAQ device USB-6008, while GPIO pin #5 GND (brown wired) was connected to the ground of USB-6008 (channel 1). If you deviate from this scheme, you will need to adjust configSyncInput.m. Below is the GPIO pin layout for FLIR/Pointgrey cameras and the NI USB-6008.  
5|	Connect the photodiode on the corner of the Slave computer monitor to the NIDAQ. Power to the photodiode can be provided by the 5 Volt source on the NIDAQ USB-6008 (Channel 31). Analog output from the photodiode (PD) should be soldered to Ai1 of NIDAQ USB-6008. PD from ground should be connected to ground (Channel #32) of NIDAQ USB-6008. Ground the USB box to a local ground (e.g., via channel 16).  
6|	Install Matlab.  Also install Image Acquisition Toolbox Support Package for Point Grey Hardware (if using a Point Grey/FLIR camera), and Data Acquisition Toolbox Support Package for National Instruments NI-DAQmx Devices.  
7|	Configure downloaded code in Matlab. In configureMstate.m, put in default values for imaging, such as the location that the analyzer files will be saved (make sure you have a folder at this location), and the monitor type. For the monitor type, just enter 'LIN' (as in "LINEAR") for now, since you don't have a monitor calibration file. These default settings will also be displayed on the GUI where you can change them. Mstate.stimulusIDP refers to the IP address of the slave computer.  
8|	Make a hole in your firewall for Matlab.  However, this is not always necessary.  
9|	Run Retinotopy_Master in Matlab.  


For old documentation on installing and using this code, see https://sites.google.com/site/iannauhaus/home/matlab-code

**Equipment setup: Visual stimulation computer (Slave computer)**  

1|	For the Slave computer, mount a large computer monitor (>27”) on a custom, fully adjustable floor stand in front of a mouse head fixation rig for visual stimulation. 
2|	Clone (with git) or download and install the updated retinotopy software from Github (https://github.com/ingiehong/retinotopy).  
3|	In configCom.m, change the 'rip' string variable to the ip address of the Master.  
4|	In configureMstate.m change Mstate.monitor to 'LIN'. This is a default linear look-up table for the gamma function to use until the monitor is calibrated for gamma correction.  
5|	updateMonitor.m calls different calibration files. Define the size of your screen for the different monitors that will be used.  For example, under the 'LIN' case, change Mstate.screenXcm and Mstate.screenYcm to the size of the screen you are using, in units of cm.  
6|	Make a hole in your firewall for Matlab. (Sometimes not necessary, especially on Macs.)  
7|	Install the Psychophysics Toolbox (http://psychtoolbox.org/).  
Attach photodiode to the corner of the visual stimulation monitor, facing the screen. Use black tape to ensure isolation of the corner synchronization signal from Psychophysics Toolbox to the photodiode (Figure 2.). For the OPT101 chip and CJMCU101 breakout board, solder the OPT101 chip to the board, and solder the two-way solder pads (-IN  C_R  1M) located at the bottom of the CJMCU-101 module to increase the sensitivity.  
8|	Run Retinotopy_Slave in Matlab.


**Equipment setup: One-photon calcium imaging (and intrinsic optical imaging) microscope setup**  
  
A widefield epifluorescence/reflected light microscope with motorized motion and a low-magnification high-NA objective is required. Some examples include the Thorlabs Cerna Mini microscope, Zeiss Axio Zoom.V16, Mightex OASIS Macro, SciMedia THT series, etc. A field of view of 5x5mm is preferable to capture the entire visual cortex of a mouse.  
1|	Mount the GigE or USB3 camera to the microscope.  
2|	Position the mouse head-fixation rig below the microscope. Designs and machining instructions are available on Github (https://github.com/ingiehong/Gogo-stages). The goniometers necessary for accurate adjustments in two photon imaging are not required for these experiments. Other head-fixation stages can be used, so long as they are compatible with the light-proofing components below. Light isoflurane anesthesia is required, as provided in the Gogo-stage designs.  
3|	Use a 3D printer to make a light-proofing crown and cylinder with flexible material to attach to the head of mice.  
4|	(Optional) For intrinsic optical imaging, add side illumination through fiber bundles or LEDs (630 and/or 700nm).  
5|	(Optional) Polarization gating to bias towards multiple-scattering events (Song 2022)  
6|	(Optional) To correct for absorption of light by hemoglobin by measuring hemodynamics (Valley 2019), add backscatter imaging at 630 and 570 nm with an additional camera and illuminators.  

**Retinotopy**   

1|	On the master computer, navigate to the Looper window and load 'ori_0_180_3repeats.loop'. The number of repeats should be 3 and ori (orientation) conditions should be set to alternate between 0 and 180.   
2|  In the paramSelect window, load 'Periodic_Grater_10cm_gray_bg\Alt_ret_zoom6_sduty05_sfreq008.param' first.   
3|  Verify that the Imager displays the visual cortex area centered in the FOV of the camera. Use the gain and illumination to avoid saturation, which can be verified with the Histogram button.    
4|  Use the Grab Single button in Imager to collect images to use for anatomical overlays.   
5|  In the Main Window, adjust the Animal tag as appropriate and start vertical retinotopy by clicking the Run button (~25 minutes).   
6|  After completion, load 'Periodic_Grater_10cm_gray_bgAzi_ret_zoom6_phase180_sduty05_sfreq0066.param' in paramSelect window and click the Run button to start horizontal retinotopy.   
7|  Do the same for additional mice.   
8|  Use the 'Close Display' button in the Main Window to terminate the Psychophysics Toolbox session on the slave computer.   
9|  Use the caca command on the Master computer Matlab command prompt to terminate Retinotopy_Master.   
   
**Visual Area Segmentation**

At the command line, execute "getAreaBorders" for a demo of visual cortex segmentation. The current folder will move to retinotopy\Example Data\R44 and analysis will be run on a demo dataset (R44). This will be equivalent to running getAreaBorders('R44', '000_005', '000_006', 'grab_r44_000_007_17_Aug_2012_17_58_02.mat'). The expected output can be found in the paper cited below. The expected run time is 20-60 seconds.

**About**

For more information, see Juavinett, Nauhaus, Garrett, Zhuang, & Callaway (2017) Automated identification of mouse visual areas with intrinsic signal imaging. <i>Nature Protocols.</i> http://www.nature.com/nprot/journal/v12/n1/abs/nprot.2016.158.html
