# 2019 Slow Oscillations Review

This document serves to outline the steps necessary to re-create Kevin L. Turner's data and code contributions to the Review manuscript "TITLE" by "AUTHORS".

Begin by downloading the entire code repository and (if desired) the data from the following locations:
* Code repository location: https://github.com/KL-Turner/Slow-Oscillations-Review
* Data repository location: https://psu.app.box.com/folder/70922070354

The github repository contains a pre-analyzed **ComparisonData.mat** structure that can be used to immediately generate the figures without re-analyzing any data. Add the TurnerFigs-SlowOscReview2019 folder to Matlab's filepath and click the *Run* button of the MainScript function under the *Editor* tab. You may be prompted to initially add the MainScript function to the filepath. Click *Add to path* and the script will run, adding the rest of the sub-functions and data paths itself.

The data is analyzed in numerous stages, each step is described below in short. The data used to generate the figures is pre-processed through several stages up to the point of spectral analysis. To analyze the pre-processed data, download the Kleinfeld_Review2019_Turner_PreProcessedData from box. Due to download limitations, you may need to download each of the 9 animal folders one at a time. If you wish to re-run the analysis that is used to generate each figure, ensure that both the data and the code repository are added to the Matlab path. This can be done by dragging and dropping the code repository's contents into the data repository's folder, so that you have 9 animal folders as well as the contents of TurnerFigs-SlowOscReview2019 in the same folder. Delete the **ComparisonData.mat** structure or move it out of the folder - the analysis will not run if this structure is already analyzed and present in the current directory.

Before beginning, ensure that the most recent version of the Signal Processing Toolbox is installed (version 8.1 or greater). This can be determined by typing **ver** into the Matlab Command Window. If the Signal Processing Toolbox is out of date or not installed, it can be downloaded from the *Add-Ons* button under the *Home* tab on the toolstrip ribbon. More information can be found at https://www.mathworks.com/products/signal.html. 

When ready, click the *Run* button of the MainScript function under the *Editor* tab.

# Data analysis and figure summary

## Figure 1: Whisking-evoked changes in vessel diameter and hippocampal LFP
Whisking events lasting 0.5 to 2 seconds, 2 to 5 seconds, and 5 to 10 seconds in duration were pulled from the data. From the initiation of each whisking event, data was pulled 4 seconds prior and 10 seconds from initiation for 14 seconds total. Each whisking event had at least 1 second of quiescence before whisking initiation. Vessel diameter was normalized by its resting diameter up to the first 30 minutes of data *for that vessel*, for that day, and then smoothed using a 3rd-order 17 sample Savitzky-Golay filter. Each signal was mean-subtracted using the first four seconds prior to whisking, and then averaged across all whisking events for each criteria. The hippocampal LFP spectrograms were analyzed from the raw data (20 kHz Fs, mean subtracted, 60 Hz notch) with [1 1] tapers and a 1 second window taking 0.1 second step-size. The frequency-depend power from each bin was normalized by the resting value for each day. The normalized power corresponding to each whisking criteria time epoch (0.5 to 2, etc) was pulled and averaged across events for each animal. 

The mean change in vessel diameter per whisking condition, per vessel, was then averaged across vessels (n = 28) with the error-bars showing standard deviation across the averaged vessels. Individual vessel averages can be seen in figure S1. The mean frequency-dependent power during these events was averaged across animals (N = 9).

## Figure 2 Cross-correlation between whisker acceleration and vessel diameter
Vessel diameter was mean-subtracted (entire trial, 280 seconds or 900 seconds) and then low-pass (2 Hz) filtered using a 4th-order Butterworth. Raw whisker angle (150 Hz) was differentiated twice to acceleration, taken the absolute value, and then low-pass filtered using the z-p-k -> sos-g from a 2nd-order butterworth 20 Hz filter. After filtering, the absolute value of whisker accelerate was resampled down to either 5 Hz or 20 Hz (depending on animal) to match the sampling rate of the vessel diameter. The cross-correlation (xcorr, 'coeff') with 25 seconds lead/lag time was calculated between the two processed signals. The average of each vessel's cross correlation was then averaged across all vessels, with the error bars showing standard deviation. The individual vessel cross-correlations can be seen in figure S2.

## Figure 3 Spectral coherence between whisker acceleration and vessel diameter
Vessel diameter was detrended (no filtering) and whisker acceleration was processed using the same conditions as Figure 2. The spectral coherence was then calculated between the two signals using the Chronux coherency function with [10 19] tapers and an fpass of [0.05 0.5]. The coherence of for each vessel was then averaged across all vessels, with the error bars showing standard deviation. The confidence intervals are shown (TBD) ... The individual vessel coherence can be seen in figure S3.

## Figure 4 Spectral power for whisker acceleration and vessel diameter
Vessel diameter was detrended (no filtering) and whisker acceleration were processed using the same conditions as Figure 2. The spectral power was then calculated for the two signals using the Chronux mtspectrumc function with [10 19] tapers and an fpass of [0.05 0.5]. The power for each vessel was then averaged across all vessels, with the error bars showing standard deviation. The power of the whisker acceleration for each animal was averaged across animals. The individual vessel power and whisker acceleration power can be seen in figure S4.

## Figure S1-S4
Each supplementary figure corresponds to its respective maintext figure, showing the individual vessel/animal traces for each analysis condition.

# Data pre-processing summary 
This section contains a summary of the analysis that went in to pre-processing of all data. All code and functions are located in the *Pre-processing-scripts* sub-folder of the code repository. Each stage contains a sub-functions folder with its respective dependencies. If a specific function is used in multiple stages, it is located only in the first stage that it is used. If it is used in the MainScript that analyzes the data and generates the figures, the sub-function will be located in *Analysis-scripts* folder.

Data was acquired simultaneously from MScan (Two photon data, neural data, force sensor) and a LabVIEW program (see: https://github.com/KL-Turner/LabVIEW-DAQ) (whisker angle, duplicate of force sensor)

## Animal imaging differences:
* T72 - T76 were 300 second scans per vessel with 20 Hz vessel sampling rate. 10 seconds was trimmed after shifting data (280 seconds left)
* T80 - T83 were 960 second scans per vessel with either 5 or 20 Hz sampling rate, depending on the animal. 30 seconds were trimmed after shifting data (900 seconds left) 

## Stage One Processing

* Extract the whisker angle, force sensor data, and notes from the camera's binary file and the LabVIEW TDMS files. Create a '*_LabVIEW.mat' structure corresponding to the date/time of the imaging.
    
* For more information on whisker tracking, see https://github.com/KL-Turner/Whisker-Tracking

## Stage Two Processing

* Extract the notes from a MS Excel sheet containing the session's information.

* Analyze the diameter changes from the two-photon TIFF stack by drawing the region of interest and axis along the vessel for the radon transform/FWHD.

* Set the binarization threshold for the whisker acceleration and force sensor (movement). This creates a Thresholds.mat structure that has the threshold value for each day. Movement and whisking events that occur within a short period are linked together as one event.

*  Bandpass filter the raw neural data to create specific neural bands (Delta, Theta, Alpha, Beta, Gamma, MUA). These are not used in this specific analysis, but are otherwise included. These bands are filtered using the  z-p-k -> sos-g from a 4th-order butterworth filter. The bandpassed signals are then smoothed using the z-p-k -> sos-g from a 4th-order butterworth 10 Hz lowpass filter. The smoothed signals are then squared and resampled down to 30 Hz.

* Patch any holes in the raw whisker angle using linear interpolation for the approximate dropped-frame time indeces. Typically less than 10 frames are dropped for any given 16-minute (144000 whisker camera frames) trial.

* Smooth the force sensor and whisker angle signals using the z-p-k -> sos-g from a 2nd-order butterworth 20 Hz lowpass filter. Resample both down to 30 Hz. Keep the raw 150 Hz whisker angle in the data structure for later analysis if needed.

* Correct any offset between the MScan data and LabVIEW data by analyzing the cross correlation of the duplicated force sensor signals. Align the data in time, and trim the first 10 (or 30) and last 10 (or 30) seconds down to the expected length based on the respective signal's sampling rate. Typically, the delay between the MScan trigger and the LabVIEW acquisition start was less than 1 second.

* Combine the processed MScan and LabVIEW data into a 'MergedData' structure. 

* Animals T82 and T83 had a few imaging sessions with a lower (5 Hz) two-photon scanning rate. The vessel data with the higher sampling rate (20 Hz) was resampled down to the lower rate (5 Hz) after Stage Two. The duration of imaging was the same, and all other sampling rates were unchanged.

## Stage Three Processing

* Behaviorally characterize the data using the binarized whisker movement and force sensor movement. Periods of 'rest' were categorized by periods of 5 seconds or longer with no movement and no whisking. This creates a RestData.mat and EventData.mat structure.

* Calculate the spectrogram for each session using the raw neural data. The raw data is detrended, trimmed to expected length, and applied a 60 Hz notch filter. One-second spectrograms with [1 1] tapers and a 0.1 second step size are calculated, along with five-second spectrograms with [5 9] tapers and 0.2 second step size. This creates a SpecData.mat file for each corresponding MergedData.mat structure.

* Calculate the resting baseline per animal, per vessel, per day, using the data from resting periods. For neural signals, since the neural activity is the same electrode regardless of which vessel was being imaged, there is only one value for each day. This creates a RestingBaselines.mat structure.

# Acknowledgements
* multiWaitbar.m Author: Ben Tordoff https://www.mathworks.com/matlabcentral/fileexchange/26589-multiwaitbar-label-varargin
* colors.m Author: John Kitchin http://matlab.cheme.cmu.edu/cmu-matlab-package.html
* Chronux subfunctions http://chronux.org/
* Several functions utilize varying bits of code written by Dr. Patrick J. Drew and Dr. Aaron T. Winder https://github.com/DrewLab

#### Feel free to contact Patrick Drew or Kevin Turner (klt8@psu.edu) with any issues running the anaysis. 